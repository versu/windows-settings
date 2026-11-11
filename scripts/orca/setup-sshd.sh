#!/usr/bin/env bash
# Windows 側のアプリ（Orca など）から SSH で接続できるよう、WSL 内の sshd を設定する
# root で実行する。引数: <ポート> <接続ユーザー名> <公開鍵>
set -euo pipefail

port="$1"
user="$2"
public_key="$3"

# sshd を systemd のサービスとして常駐させるため、systemd が有効であることを前提にする
if [ "$(ps -p 1 -o comm= 2>/dev/null)" != "systemd" ]; then
  echo "systemd が有効になっていません。/etc/wsl.conf の [boot] に systemd=true を設定し、wsl --shutdown してから再実行してください。" >&2
  exit 1
fi

if ! command -v sshd >/dev/null 2>&1; then
  echo "openssh-server をインストールします"
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server
fi

# 設定はドロップインに書き、ディストリ標準の sshd_config は変更しない
# ※ListenAddress を 127.0.0.1 に絞り、Windows の localhost 以外からは接続できないようにする
cat > /etc/ssh/sshd_config.d/wsl-ssh.conf <<EOF
Port ${port}
ListenAddress 127.0.0.1
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
EOF

# ホスト鍵がなければ作成する
# ※ssh-keygen -A は非推奨の DSA 鍵まで作ってしまうため、ed25519 だけを作る
if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
  ssh-keygen -q -t ed25519 -N "" -f /etc/ssh/ssh_host_ed25519_key
fi

# サービスを再起動する前に設定を検証する
# ※sshd -t は /run/sshd がないと失敗する。/run は起動のたびに消え、/run/sshd は ssh.service の起動時に
#   作られるため、サービスが一度も起動していない状態では先に作っておく必要がある
install -d -m 755 /run/sshd
sshd -t

# 公開鍵を登録する（登録済みなら何もしない）
home_dir="$(getent passwd "$user" | cut -d: -f6)"
group="$(id -gn "$user")"
install -d -m 700 -o "$user" -g "$group" "$home_dir/.ssh"
authorized_keys="$home_dir/.ssh/authorized_keys"
touch "$authorized_keys"
chown "$user:$group" "$authorized_keys"
chmod 600 "$authorized_keys"
if ! grep -qxF "$public_key" "$authorized_keys"; then
  echo "$public_key" >> "$authorized_keys"
  echo "公開鍵を $authorized_keys に登録しました"
fi

# Ubuntu 22.10 以降はソケット起動（ssh.socket）が既定で、ポート変更の反映方法が異なる
# どのバージョンでも同じ手順で扱えるよう、ssh.service での常駐に統一する
systemctl disable --now ssh.socket >/dev/null 2>&1 || true
systemctl enable ssh.service
systemctl restart ssh.service
echo "sshd を 127.0.0.1:${port} で起動しました"
