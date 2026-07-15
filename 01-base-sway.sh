#!/usr/bin/env bash
set -euo pipefail

echo "=== 01-base-sway.sh: Sway + essentials + WiFi fix ==="

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

# --- WIFI FIX (critical on "Minimal Install", not installed by default) ---
echo "=== Installing WiFi pieces that Minimal Install omits ==="
sudo dnf install -y iwlwifi-mvm-firmware NetworkManager-wifi wpa_supplicant
sudo systemctl restart NetworkManager

xdg-user-dirs-update

echo "=== Verification ==="
rpm -q sway waybar wofi mako mate-polkit network-manager-applet blueman \
       iwlwifi-mvm-firmware NetworkManager-wifi wpa_supplicant && echo "OK"

nmcli device status

echo ""
echo "=== 01-base-sway.sh completed ==="
echo ">>> If WiFi doesn't show up as 'wifi' above, reload the driver:"
echo ">>>   sudo modprobe -r iwlwifi && sudo modprobe iwlwifi"
