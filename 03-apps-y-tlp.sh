#!/usr/bin/env bash
set -euo pipefail

echo "=== 03-apps-y-tlp.sh: TLP + codecs + curated apps + final apps ==="

# --- TLP (power management) — remove tuned/tuned-ppd first, they conflict ---
sudo dnf remove -y tuned tuned-ppd 2>/dev/null || true
sudo dnf install -y tlp tlp-rdw
sudo systemctl enable --now tlp.service
sudo systemctl enable --now tlp-pd.service

# --- RPM Fusion + codecs ---
sudo dnf install -y \
  "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
  "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
sudo dnf install -y gstreamer1-plugins-bad-free gstreamer1-plugins-good gstreamer1-plugins-base gstreamer1-plugin-openh264 gstreamer1-libav

# --- Curated apps (GTK4/libadwaita, consistent with the theme) ---
sudo dnf install -y \
  loupe \
  mpv celluloid \
  decibels \
  papers xournalpp \
  gnome-calculator \
  gnome-text-editor \
  file-roller unzip p7zip p7zip-plugins unrar \
  ntfs-3g \
  nautilus

# --- Final user-facing apps ---
sudo dnf install -y firefox libreoffice
sudo dnf install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm

sudo dnf install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.bitwarden.desktop

echo "=== Verification ==="
systemctl is-enabled tlp.service
rpm -q loupe mpv celluloid decibels papers xournalpp gnome-calculator \
       gnome-text-editor nautilus firefox libreoffice-writer google-chrome-stable ffmpeg
flatpak list | grep -i bitwarden

echo "=== 03-apps-y-tlp.sh completed ==="
