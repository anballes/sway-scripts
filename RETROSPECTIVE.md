# Retrospective — Fedora Minimal + Sway

## What worked well

- **Config in a single text file** (`~/.config/sway/config`) — when
  something broke, Sway showed a red banner "there are errors in your
  config" with the exact line. Fast, deterministic diagnosis, no hidden
  state bugs.
- **Identifying devices by their stable name, not a temporary ID:**
  - Keyboards: `swaymsg -t get_inputs` gives a stable identifier
    (e.g. `1:1:AT_Translated_Set_2_keyboard`)
  - Apps for window routing: `swaymsg -t get_tree | jq` gives the real
    `app_id` (e.g. Chrome is `google-chrome`, NOT `com.google.Chrome` as
    you'd assume from the package name)
- **`for_window` rules** to route apps to specific workspaces and make
  small apps (calculator, pavucontrol) floating with a fixed size.

## What cost time (avoid repeating)

1. **Package names assumed from memory, wrong:**
   - `gnome-themes-extra` → doesn't exist on Fedora 44, use
     `adw-gtk3-theme` instead
   - `tlp` conflicted with `tuned`/`tuned-ppd` (Fedora's newer power
     management package) — remove `tuned`/`tuned-ppd` first
   - `polkit-gnome` → discontinued, use `mate-polkit`

2. **Copy-pasting long blocks with special Unicode characters (Font
   Awesome icons) corrupted the file once.** The icons ended up as empty
   quotes. Fixed by restoring from backup + editing with `sed` (which
   doesn't go through the clipboard).
   **Lesson: for files with special icons, use `sed`/line substitution
   instead of rewriting the whole file via copy-paste.**

3. **"Minimal Install" doesn't ship working WiFi** (applies to Sway just
   like any other desktop environment — it's an ISO issue, not a Sway
   issue): missing `iwlwifi-mvm-firmware`, `NetworkManager-wifi`,
   `wpa_supplicant`.

4. **`geoclue2` (automatic location for gammastep/Night Light) didn't
   work** — timed out. Fixed with a manual fixed location in
   `~/.config/gammastep/config.ini` (`location-provider=manual`).

5. **The real `app_id` of an app almost never matches the package name or
   binary name.** Always verify with:
   `swaymsg -t get_tree | jq -r '.. | select(.app_id? != null or .window_properties.class? != null) | (.app_id // .window_properties.class)' | sort -u`
   with the app already open, before writing a `for_window` rule.

## Golden rule

Before writing any `for_window [app_id="..."]`, open the app and run the
command above to confirm the real `app_id` — don't assume it from the
package name.
