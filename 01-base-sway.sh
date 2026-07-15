#!/usr/bin/env bash
set -euo pipefail

echo "=== 01-base.sh: Sway + esenciales + fix de WiFi ==="

sudo dnf install -y \
  sway swaybg swaylock swayidle \
  waybar wofi mako \
  foot \
  grim slurp wl-clipboard \
  brightnessctl \
  pamixer pavucontrol \
  playerctl \
  mate-polkit \
  network-manager-applet \
  blueman \
  system-config-printer \
  wlogout \
  adwaita-icon-theme adw-gtk3-theme \
  fontawesome-fonts jetbrains-mono-fonts \
  xdg-desktop-portal-wlr \
  xdg-user-dirs \
  jq \
  btop

# --- FIX DE WIFI (crítico en "Minimal Install", no se instala solo) ---
echo "=== Instalando piezas de WiFi que Minimal Install omite ==="
sudo dnf install -y iwlwifi-mvm-firmware NetworkManager-wifi wpa_supplicant
sudo systemctl restart NetworkManager

xdg-user-dirs-update

echo "=== Verificación ==="
rpm -q sway waybar wofi mako mate-polkit network-manager-applet blueman \
       iwlwifi-mvm-firmware NetworkManager-wifi wpa_supplicant && echo "OK"

nmcli device status

echo ""
echo "=== 01-base.sh completado ==="
echo ">>> Si el WiFi no aparece como 'wifi' arriba, reinicia:"
echo ">>>   sudo modprobe -r iwlwifi && sudo modprobe iwlwifi"
