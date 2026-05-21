#!/usr/bin/env bash
set -euo pipefail

PORT="${SSH_SERVER_PORT:-36001}"
CONFIG_FILE="/etc/ssh/sshd_config.d/10-local-ssh-server.conf"
LEGACY_CONFIG_FILE="/etc/ssh/sshd_config.d/99-codex-local.conf"
AUTHORIZED_KEYS="/root/.ssh/authorized_keys"
PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBIevTmb2FAwuHqqspKkYfXO6u9ROMTCc2TMVLOoBfdB 13217@ciel"

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this script as root in a container" >&2
  exit 1
fi

if ! command -v sshd >/dev/null 2>&1; then
  if command -v apt-get >/dev/null 2>&1; then
    DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server
  else
    echo "sshd is missing and this script only knows how to install it with apt-get." >&2
    exit 1
  fi
fi

mkdir -p /etc/ssh/sshd_config.d /run/sshd /root/.ssh
chmod 755 /run/sshd
chmod 700 /root/.ssh

if [ -f "$LEGACY_CONFIG_FILE" ] && [ ! -e "$CONFIG_FILE" ]; then
  mv "$LEGACY_CONFIG_FILE" "$CONFIG_FILE"
fi

cat >"$CONFIG_FILE" <<EOF
# Local OpenSSH server settings for this machine.
Port $PORT
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
AuthorizedKeysFile .ssh/authorized_keys
EOF
chmod 644 "$CONFIG_FILE"

touch "$AUTHORIZED_KEYS"
chmod 600 "$AUTHORIZED_KEYS"
if ! grep -qxF "$PUBLIC_KEY" "$AUTHORIZED_KEYS"; then
  printf '%s\n' "$PUBLIC_KEY" >>"$AUTHORIZED_KEYS"
fi

sshd -t

if [ -s /run/sshd.pid ] && kill -0 "$(cat /run/sshd.pid)" 2>/dev/null; then
  kill -HUP "$(cat /run/sshd.pid)"
else
  /usr/sbin/sshd
fi

echo "OpenSSH server configured on port $PORT."
