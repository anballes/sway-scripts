# Fedora 44 Minimal + Sway — dotfiles and scripts

Reproducible setup, built and corrected from a real installation. Read
`RETROSPECTIVE.md` first — it documents mistakes already made, so you
don't repeat them.

## Execution order

```bash
chmod +x *.sh
./01-base-sway.sh        # Sway + essentials + WiFi fix
./02-dotfiles-sway.sh     # Writes sway/waybar/wofi/mako/gammastep config
./03-apps-y-tlp.sh        # TLP, codecs, curated apps, Firefox/Chrome/Bitwarden
```

After running all three, log out and select the **Sway** session from the
login screen (GDM/LightDM, depending on which one you installed).

## Mandatory manual steps after the first Sway login

1. **Confirm the mate-polkit path:**
   ```bash
   rpm -ql mate-polkit | grep bin
   ```
   If the path in `~/.config/sway/config` (the `exec /usr/libexec/...`
   line) doesn't match, fix it and run `swaymsg reload`.

2. **Confirm keyboard identifiers:**
   ```bash
   swaymsg -t get_inputs | jq -r '.[] | "\(.identifier) — \(.name)"'
   ```
   If they don't match the ones in `config` (keyboard section), fix them.

3. **Confirm the real `app_id` of each app** (open them once first):
   ```bash
   swaymsg -t get_tree | jq -r '.. | select(.app_id? != null or .window_properties.class? != null) | (.app_id // .window_properties.class)' | sort -u
   ```
   Compare against the `for_window` rules in the config and fix anything
   that changed.

## Before installing: get the right ISO

**Fedora Everything (netinstall)**, not Workstation, not any Spin. On the
"Software Selection" screen, choose **"Fedora Custom Operating System"**
(the equivalent of "Minimal Install" on this particular ISO).

## During installation

- WiFi (Intel Wireless 8265) **does work in the installer** — connect
  there directly if you want, no cable needed.
- Enable disk encryption if you're going to travel with the machine — this
  is the only moment where adding it costs nothing extra (the disk gets
  wiped either way).
- Choose BTRFS (Anaconda's default) to have snapshots available.

## First boot (system installed, no GUI yet)

WiFi on the installed system **does not work until you run
`01-base-sway.sh`** (missing `iwlwifi-mvm-firmware`, `NetworkManager-wifi`,
`wpa_supplicant`). Plug in Ethernet for the first boot, run
`01-base-sway.sh`, and from there WiFi works normally.

## Golden rule to avoid the biggest time sink in this setup

Before writing any `for_window [app_id="..."]` rule in the Sway config,
open that app once and confirm its real `app_id` — never assume it from
the package name (e.g. Chrome is `google-chrome`, not
`com.google.Chrome`):

```bash
swaymsg -t get_tree | jq -r '.. | select(.app_id? != null or .window_properties.class? != null) | (.app_id // .window_properties.class)' | sort -u
```

See `RETROSPECTIVE.md` for the rest of the lessons learned (package names
that don't exist, TLP/tuned conflict, geoclue2 failing, etc.).
