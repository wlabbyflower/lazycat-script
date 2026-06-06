#!/usr/bin/env bash
set -euo pipefail

USER_NAME="${USER_NAME:-${SUDO_USER:-${USER}}}"
USER_HOME="$(eval echo "~${USER_NAME}")"
DISPLAY_NUM="${DISPLAY_NUM:-1}"
VNC_GEOMETRY="${VNC_GEOMETRY:-1440x900}"
NOVNC_PORT="${NOVNC_PORT:-6080}"
NOVNC_LISTEN="${NOVNC_LISTEN:-${NOVNC_PORT}}"
VNC_NO_PASSWORD="${VNC_NO_PASSWORD:-0}"

log() {
  printf '\n\033[1;32m==> %s\033[0m\n' "$*"
}

warn() {
  printf '\n\033[1;33m[WARN] %s\033[0m\n' "$*"
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

if ! need_cmd pacman; then
  echo "This script is intended for Arch Linux with pacman." >&2
  exit 1
fi

if [[ "${EUID}" -eq 0 ]]; then
  echo "Please run this script as a normal user with sudo privileges, not as root." >&2
  exit 1
fi

log "Validate sudo access"
if ! sudo -v; then
  echo "sudo authentication failed. Please run this script in an interactive terminal." >&2
  exit 1
fi

while true; do
  sudo -n true
  sleep 60
done 2>/dev/null &
SUDO_KEEPALIVE_PID=$!
trap 'kill "${SUDO_KEEPALIVE_PID}" 2>/dev/null || true' EXIT

log "Sync system package database"
sudo pacman -Syu --noconfirm

log "Refresh pacman keyrings"
sudo pacman -S --needed --noconfirm archlinux-keyring

if pacman-conf --repo-list | grep -qx 'archlinuxcn'; then
  sudo pacman -S --needed --noconfirm archlinuxcn-keyring
  sudo pacman-key --populate archlinuxcn >/dev/null 2>&1 || true
fi

log "Clean known-bad cached signature packages"
sudo find /var/cache/pacman/pkg -maxdepth 1 -type f \
  \( -name 'gconf-*.pkg.tar.*' -o -name 'archlinuxcn-keyring-*.pkg.tar.*' \) \
  -delete

log "Install base dependencies"
sudo pacman -S --needed --noconfirm \
  base-devel \
  git \
  noto-fonts-cjk \
  libxkbfile \
  libxcomposite \
  libxdamage \
  libxrandr \
  libxss \
  libxtst \
  alsa-lib \
  gtk3 \
  nss \
  at-spi2-core \
  xorg-xauth \
  xorg-xinit

log "Prepare WeChat DevTools config directory"
install -d -m 700 "${USER_HOME}/.config/wechat-devtools"

if ! need_cmd yay; then
  log "Install yay AUR helper"
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "${tmp_dir}"' EXIT
  git clone https://aur.archlinux.org/yay.git "${tmp_dir}/yay"
  (cd "${tmp_dir}/yay" && makepkg -si --noconfirm)
else
  log "yay already installed"
fi

log "Install WeChat DevTools, KDE, TigerVNC and noVNC"
yay -S --needed --noconfirm --answerclean None --answerdiff None \
  wechat-devtools-bin \
  plasma-desktop \
  plasma-workspace \
  plasma-x11-session \
  kwin-x11 \
  sddm \
  konsole \
  dolphin \
  tigervnc \
  novnc \
  websockify

log "Configure TigerVNC user mapping"
sudo install -m 0644 /dev/stdin /etc/tigervnc/vncserver.users <<EOF
# TigerVNC user assignment
:${DISPLAY_NUM}=${USER_NAME}
EOF

log "Configure TigerVNC KDE session"
install -d -m 700 "${USER_HOME}/.vnc" "${USER_HOME}/.config/tigervnc"
cat > "${USER_HOME}/.vnc/config" <<EOF
session=plasmax11
geometry=${VNC_GEOMETRY}
localhost
alwaysshared
EOF

if [[ "${VNC_NO_PASSWORD}" == "1" ]]; then
  cat >> "${USER_HOME}/.vnc/config" <<EOF
securitytypes=none
EOF
else
  cat >> "${USER_HOME}/.vnc/config" <<EOF
securitytypes=vncauth
EOF
fi
install -m 600 "${USER_HOME}/.vnc/config" "${USER_HOME}/.config/tigervnc/config"
chmod 600 "${USER_HOME}/.vnc/config" "${USER_HOME}/.config/tigervnc/config"

if [[ "${VNC_NO_PASSWORD}" == "1" ]]; then
  warn "VNC password is disabled. Anyone who can access noVNC can use the desktop."
elif [[ -n "${VNC_PASSWORD:-}" ]]; then
  log "Set VNC password from VNC_PASSWORD environment variable"
  printf '%s\n' "${VNC_PASSWORD}" | vncpasswd -f > "${USER_HOME}/.vnc/passwd"
  install -m 600 "${USER_HOME}/.vnc/passwd" "${USER_HOME}/.config/tigervnc/passwd"
else
  warn "VNC_PASSWORD is not set. Existing VNC password will be reused if present."
  if [[ -f "${USER_HOME}/.vnc/passwd" ]]; then
    install -m 600 "${USER_HOME}/.vnc/passwd" "${USER_HOME}/.config/tigervnc/passwd"
  elif [[ -f "${USER_HOME}/.config/tigervnc/passwd" ]]; then
    install -m 600 "${USER_HOME}/.config/tigervnc/passwd" "${USER_HOME}/.vnc/passwd"
  else
    warn "No VNC password file found. Run one of these before starting VNC:"
    warn "  VNC_PASSWORD='your-password' ./arch-wechat.sh"
    warn "  vncpasswd && cp ~/.vnc/passwd ~/.config/tigervnc/passwd"
  fi
fi

log "Configure noVNC systemd service"
sudo install -m 0644 /dev/stdin /etc/systemd/system/novnc.service <<EOF
[Unit]
Description=noVNC web client for TigerVNC display :${DISPLAY_NUM}
After=network.target vncserver@:${DISPLAY_NUM}.service
Requires=vncserver@:${DISPLAY_NUM}.service

[Service]
Type=simple
User=${USER_NAME}
ExecStart=/usr/bin/novnc --listen ${NOVNC_LISTEN} --vnc localhost:$((5900 + DISPLAY_NUM)) --web /usr/share/webapps/novnc
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

log "Reload systemd and enable services at boot"
sudo systemctl daemon-reload
sudo systemctl enable "vncserver@:${DISPLAY_NUM}.service"
sudo systemctl enable novnc.service
sudo systemctl enable sddm.service

if [[ "${VNC_NO_PASSWORD}" == "1" || -f "${USER_HOME}/.config/tigervnc/passwd" ]]; then
  log "Start VNC and noVNC services now"
  sudo systemctl enable --now "vncserver@:${DISPLAY_NUM}.service" novnc.service
else
  warn "Skipped starting VNC/noVNC because VNC password is missing."
fi

log "Deployment summary"
cat <<EOF
User:              ${USER_NAME}
VNC display:       :${DISPLAY_NUM}
VNC local port:    127.0.0.1:$((5900 + DISPLAY_NUM))
noVNC listen:      ${NOVNC_LISTEN}
VNC auth:          $([[ "${VNC_NO_PASSWORD}" == "1" ]] && echo "disabled" || echo "password")
Project path:      ${USER_HOME}/wechat-miniprogram-demo

Open noVNC from LAN:
  http://<this-machine-ip>:${NOVNC_PORT}/vnc.html?host=<this-machine-ip>&port=${NOVNC_PORT}

Open noVNC over IPv6 when using NOVNC_LISTEN='[::]:${NOVNC_PORT}':
  http://[<this-machine-ipv6>]:${NOVNC_PORT}/vnc.html?host=<this-machine-ipv6>&port=${NOVNC_PORT}

Open WeChat DevTools in VNC desktop:
  wechat-devtools

CLI preview example:
  DISPLAY=:${DISPLAY_NUM} XAUTHORITY=${USER_HOME}/.Xauthority \\
  wechat-devtools-cli preview --project ${USER_HOME}/wechat-miniprogram-demo --qr-format image --qr-output ${USER_HOME}/wechat-miniprogram-demo/preview-qr.png --lang zh --disable-gpu
EOF
