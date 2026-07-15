#!/usr/bin/env bash
set -euo pipefail

echo "=== 02-dotfiles-sway.sh: Escribiendo configuraciones ==="

mkdir -p ~/.config/sway ~/.config/waybar ~/.config/wofi ~/.config/mako ~/.config/gammastep ~/.local/bin

# ============================================================
# SWAY CONFIG
# ============================================================
cat > ~/.config/sway/config << 'EOF'
### Variables
set $mod Mod4
set $term foot
set $menu wofi --show drun

### Apariencia (paleta Adwaita/GNOME)
client.focused          #3584e4 #3584e4 #ffffff #3584e4 #3584e4
client.focused_inactive #5e5c64 #303030 #ffffff #5e5c64 #303030
client.unfocused        #303030 #242424 #bbbbbb #303030 #242424
client.urgent           #c01c28 #c01c28 #ffffff #c01c28 #c01c28

font pango:Cantarell 10
gaps inner 8
gaps outer 4
smart_gaps off
default_border pixel 2
default_floating_border pixel 2
smart_borders on

bar {
    swaybar_command waybar
}

### Fondo de pantalla (viene con el paquete gnome, no hay que descargar nada)
output * bg /usr/share/backgrounds/gnome/adwaita-d.jxl fill

### Teclados por dispositivo
### IMPORTANTE: verifica los identificadores reales en TU máquina con:
###   swaymsg -t get_inputs | jq -r '.[] | "\(.identifier) — \(.name)"'
### Los de abajo son los que aplicaron en la instalación anterior — pueden
### cambiar si el hardware es distinto.
input "type:keyboard" {
    xkb_layout us
}
input "1:1:AT_Translated_Set_2_keyboard" {
    xkb_layout latam
    repeat_delay 300
    repeat_rate 40
}
input "1133:45967:POP_Icon_Keys" {
    xkb_layout us
    repeat_delay 300
    repeat_rate 40
}

input "type:touchpad" {
    tap enabled
    natural_scroll enabled
    dwt enabled
}

### Asignación de monitores
### Workspaces 1-4: monitor externo (con fallback automático al laptop si
### no está conectado). Workspace 5: dedicado al laptop, para que Sway no
### "robe" un número aleatorio cuando arranca sin monitor externo.
workspace 1 output HDMI-A-1
workspace 2 output HDMI-A-1
workspace 3 output HDMI-A-1
workspace 4 output HDMI-A-1
workspace 5 output eDP-1

### Layout de trabajo habitual
### IMPORTANTE: los app_id de abajo fueron confirmados en la instalación
### anterior. Verifica los tuyos con la app abierta:
###   swaymsg -t get_tree | jq -r '.. | select(.app_id? != null or .window_properties.class? != null) | (.app_id // .window_properties.class)' | sort -u
for_window [app_id="^btop$"] move to workspace 1
for_window [class="^Bitwarden$"] move to workspace 1
for_window [app_id="^google-chrome$"] move to workspace 2
for_window [app_id="^org.mozilla.firefox$"] move to workspace 3
for_window [app_id="^foot$"] move to workspace 4
for_window [app_id="^org.gnome.Nautilus$"] move to workspace 4

### Apps pequeñas: flotantes, tamaño fijo, centradas
for_window [app_id="^org.gnome.Calculator$"] floating enable, resize set 360 500, move position center
for_window [app_id="^org.pulseaudio.pavucontrol$"] floating enable, resize set 700 500, move position center
for_window [app_id="^system-config-printer$"] floating enable, resize set 700 500, move position center

### Autostart
exec_always {
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
    gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'
}
### Agente de autenticación (polkit-gnome está descontinuado en Fedora,
### se usa mate-polkit). VERIFICA la ruta real con:
###   rpm -ql mate-polkit | grep bin
exec /usr/libexec/polkit-mate-authentication-agent-1
exec mako
exec nm-applet --indicator
exec blueman-applet
exec gammastep
exec swayidle -w \
    timeout 300 'swaylock -f -c 000000' \
    timeout 600 'swaymsg "output * power off"' \
        resume 'swaymsg "output * power on"' \
    before-sleep 'swaylock -f -c 000000'

### Atajos básicos
bindsym $mod+Return exec $term
bindsym $mod+d exec $menu
bindsym $mod+q kill
bindsym $mod+Shift+c reload
bindsym $mod+Shift+e exec wlogout
bindsym $mod+Ctrl+l exec swaylock -f -c 000000

### Foco / movimiento
bindsym $mod+Left focus left
bindsym $mod+Right focus right
bindsym $mod+Up focus up
bindsym $mod+Down focus down
bindsym $mod+Shift+Left move left
bindsym $mod+Shift+Right move right
bindsym $mod+Shift+Up move up
bindsym $mod+Shift+Down move down

### Layout
bindsym $mod+f fullscreen
bindsym $mod+Shift+space floating toggle
bindsym $mod+e layout toggle split
bindsym $mod+w layout tabbed

### Workspaces
bindsym $mod+1 workspace number 1
bindsym $mod+2 workspace number 2
bindsym $mod+3 workspace number 3
bindsym $mod+4 workspace number 4
bindsym $mod+5 workspace number 5
bindsym $mod+Shift+1 move container to workspace number 1
bindsym $mod+Shift+2 move container to workspace number 2
bindsym $mod+Shift+3 move container to workspace number 3
bindsym $mod+Shift+4 move container to workspace number 4
bindsym $mod+Shift+5 move container to workspace number 5

mode "resize" {
    bindsym Left resize shrink width 20px
    bindsym Right resize grow width 20px
    bindsym Up resize shrink height 20px
    bindsym Down resize grow height 20px
    bindsym Return mode "default"
    bindsym Escape mode "default"
}
bindsym $mod+r mode "resize"

### Teclas multimedia
bindsym XF86AudioRaiseVolume exec pamixer -i 5
bindsym XF86AudioLowerVolume exec pamixer -d 5
bindsym XF86AudioMute exec pamixer -t
bindsym XF86MonBrightnessUp exec brightnessctl set +5%
bindsym XF86MonBrightnessDown exec brightnessctl set 5%-
bindsym XF86AudioPlay exec playerctl play-pause
bindsym XF86AudioNext exec playerctl next
bindsym XF86AudioPrev exec playerctl previous

### Capturas de pantalla
bindsym Print exec ~/.local/bin/screenshot.sh

include /etc/sway/config.d/*
EOF

# ============================================================
# SCRIPT DE CAPTURAS
# ============================================================
cat > ~/.local/bin/screenshot.sh << 'EOF'
#!/usr/bin/env bash
DIR="$(xdg-user-dir PICTURES)/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/captura-$(date +%Y%m%d-%H%M%S).png"

grim -g "$(slurp)" "$FILE"
wl-copy < "$FILE"
notify-send "Captura guardada" "$FILE"
EOF
chmod +x ~/.local/bin/screenshot.sh

# ============================================================
# WAYBAR
# ============================================================
cat > ~/.config/waybar/config.jsonc << 'EOF'
// -*- mode: jsonc -*-
{
    "height": 30,
    "spacing": 4,
    "modules-left": [
        "sway/workspaces",
        "sway/mode",
        "sway/scratchpad"
    ],
    "modules-center": [
        "clock"
    ],
    "modules-right": [
        "idle_inhibitor",
        "pulseaudio",
        "network",
        "cpu",
        "memory",
        "temperature",
        "backlight",
        "sway/language",
        "battery",
        "tray"
    ],
    "keyboard-state": {
        "numlock": true,
        "capslock": true,
        "format": "{name} {icon}",
        "format-icons": {
            "locked": "",
            "unlocked": ""
        }
    },
    "sway/mode": {
        "format": "<span style=\"italic\">{}</span>"
    },
    "sway/scratchpad": {
        "format": "{icon} {count}",
        "show-empty": false,
        "format-icons": ["", ""],
        "tooltip": true,
        "tooltip-format": "{app}: {title}"
    },
    "idle_inhibitor": {
        "format": "{icon}",
        "format-icons": {
            "activated": "",
            "deactivated": ""
        }
    },
    "tray": {
        "spacing": 10
    },
    "clock": {
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
        "format-alt": "{:%Y-%m-%d}"
    },
    "cpu": {
        "format": "{usage}% ",
        "tooltip": false
    },
    "memory": {
        "format": "{}% "
    },
    "temperature": {
        "critical-threshold": 80,
        "format": "{temperatureC}°C {icon}",
        "format-icons": ["", "", ""]
    },
    "backlight": {
        "format": "{percent}% {icon}",
        "format-icons": ["🌑", "🌘", "🌗", "🌖", "🌕"]
    },
    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{capacity}% {icon}",
        "format-full": "{capacity}% {icon}",
        "format-charging": "{capacity}% ",
        "format-plugged": "{capacity}% ",
        "format-alt": "{time} {icon}",
        "format-icons": ["", "", "", "", ""]
    },
    "network": {
        "format-wifi": "{essid} ({signalStrength}%) ",
        "format-ethernet": "{ipaddr}/{cidr} ",
        "tooltip-format": "{ifname} via {gwaddr} ",
        "format-linked": "{ifname} (No IP) ",
        "format-disconnected": "Disconnected ⚠",
        "format-alt": "{ifname}: {ipaddr}/{cidr}"
    },
    "pulseaudio": {
        "format": "{volume}% {icon} {format_source}",
        "format-bluetooth": "{volume}% {icon} {format_source}",
        "format-bluetooth-muted": " {icon} {format_source}",
        "format-muted": " {format_source}",
        "format-source": "{volume}% ",
        "format-source-muted": "",
        "format-icons": {
            "headphone": "",
            "hands-free": "",
            "headset": "",
            "phone": "",
            "portable": "",
            "car": "",
            "default": ["", "", ""]
        },
        "on-click": "pavucontrol"
    }
}
EOF

cat > ~/.config/waybar/style.css << 'EOF'
* {
    font-family: 'Cantarell', 'Font Awesome 6 Free Solid', 'Font Awesome 6 Brands Regular';
    font-size: 13px;
}

window#waybar {
    background-color: #242424;
    border-bottom: 1px solid #383838;
    color: #ffffff;
}

button {
    box-shadow: inset 0 -3px transparent;
    border: none;
    border-radius: 0;
}

button:hover {
    background: inherit;
    box-shadow: inset 0 -3px #ffffff;
}

#workspaces button {
    padding: 0 10px;
    background-color: transparent;
    color: #bbbbbb;
    border-radius: 6px;
    margin: 4px 2px;
}

#workspaces button:hover {
    background: rgba(255, 255, 255, 0.08);
}

#workspaces button.focused,
#workspaces button.active {
    background-color: #3584e4;
    color: #ffffff;
    box-shadow: none;
}

#workspaces button.urgent {
    background-color: #c01c28;
    color: #ffffff;
}

#mode {
    background-color: #3584e4;
    color: #ffffff;
    padding: 0 10px;
}

#clock,
#battery,
#cpu,
#memory,
#temperature,
#backlight,
#network,
#pulseaudio,
#tray,
#idle_inhibitor,
#scratchpad,
#language,
#keyboard-state {
    padding: 0 10px;
    color: #ffffff;
    background-color: transparent;
}

#window,
#workspaces {
    margin: 0 4px;
}

.modules-left > widget:first-child > #workspaces {
    margin-left: 4px;
}

.modules-right > widget:last-child > #workspaces {
    margin-right: 4px;
}

#battery.warning {
    color: #f5c211;
}

#battery.critical:not(.charging) {
    color: #e01b24;
    font-weight: bold;
}

#network.disconnected {
    color: #e01b24;
}

#temperature.critical {
    color: #e01b24;
}

#pulseaudio.muted {
    color: #9a9996;
}

#idle_inhibitor.activated {
    color: #3584e4;
}

#tray > .needs-attention {
    -gtk-icon-effect: highlight;
}

#scratchpad.empty {
    color: #5e5c64;
}
EOF

# ============================================================
# WOFI
# ============================================================
cat > ~/.config/wofi/config << 'EOF'
width=500
height=400
location=center
show=drun
prompt=Buscar...
filter_rate=100
allow_markup=true
no_actions=true
halign=fill
orientation=vertical
content_halign=fill
insensitive=true
allow_images=true
image_size=32
EOF

cat > ~/.config/wofi/style.css << 'EOF'
window {
    background-color: #242424;
    border: 1px solid #3584e4;
    border-radius: 8px;
    font-family: 'Cantarell';
    font-size: 14px;
}

#input {
    margin: 8px;
    padding: 8px;
    background-color: #303030;
    color: #ffffff;
    border: none;
    border-radius: 6px;
}

#inner-box {
    margin: 4px;
}

#entry {
    padding: 6px;
    border-radius: 6px;
    color: #ffffff;
}

#entry:selected {
    background-color: #3584e4;
}

#text {
    color: inherit;
}
EOF

# ============================================================
# MAKO
# ============================================================
cat > ~/.config/mako/config << 'EOF'
font=Cantarell 10
background-color=#242424
text-color=#ffffff
border-color=#3584e4
border-size=1
border-radius=8
padding=10
margin=8
default-timeout=5000
layer=overlay
anchor=top-right

[urgency=critical]
border-color=#c01c28
default-timeout=0
EOF

# ============================================================
# GAMMASTEP (Night Light — geoclue2 falló la vez pasada, usar manual)
# ============================================================
cat > ~/.config/gammastep/config.ini << 'EOF'
[general]
location-provider=manual
adjustment-method=wayland

[manual]
lat=35.93
lon=-86.87

[gammastep]
temp-day=6500
temp-night=3800
EOF

echo "=== 02-dotfiles-sway.sh completado ==="
echo ">>> ANTES de iniciar sesión en Sway, verifica:"
echo ">>> 1. rpm -ql mate-polkit | grep bin   (confirma la ruta del ejecutable)"
echo ">>> 2. Los identificadores de teclado (swaymsg -t get_inputs) tras el primer login"
echo ">>> 3. Los app_id de Chrome/Firefox/Nautilus tras abrirlos una vez"
