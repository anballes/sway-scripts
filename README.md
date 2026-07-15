# Fedora 44 Minimal + Sway — dotfiles y scripts

Receta reproducible, construida y corregida a partir de una instalación real.
Lee `RETROSPECTIVA-SWAY.md` primero — documenta los errores ya cometidos
para no repetirlos.

**Nota:** este repo también incluye una rama de intento con XFCE
(`*-xfce.sh` si los conservas) que se descartó a favor de Sway tras un
análisis comparativo — ver el documento `xfce-vs-sway-analisis-completo.md`
si quieres el razonamiento completo.

## Orden de ejecución

```bash
chmod +x *.sh
./01-base-sway.sh        # Sway + esenciales + fix de WiFi
./02-dotfiles-sway.sh     # Escribe sway/waybar/wofi/mako/gammastep config
./03-apps-y-tlp.sh         # TLP, códecs, apps curadas, Firefox/Chrome/Bitwarden
```

Después de correr los tres, cierra sesión y entra a la sesión **Sway**
desde la pantalla de login (GDM/LightDM, según cuál instalaste).

## Pasos manuales OBLIGATORIOS tras el primer login en Sway

1. **Confirma la ruta de mate-polkit:**
   ```bash
   rpm -ql mate-polkit | grep bin
   ```
   Si la ruta en `~/.config/sway/config` (línea `exec /usr/libexec/...`)
   no coincide, corrígela y `swaymsg reload`.

2. **Confirma los identificadores de teclado:**
   ```bash
   swaymsg -t get_inputs | jq -r '.[] | "\(.identifier) — \(.name)"'
   ```
   Si no coinciden con los del `config` (sección de teclados), corrígelos.

3. **Confirma los `app_id` de las apps** (ábrelas una vez primero):
   ```bash
   swaymsg -t get_tree | jq -r '.. | select(.app_id? != null or .window_properties.class? != null) | (.app_id // .window_properties.class)' | sort -u
   ```
   Compara contra las reglas `for_window` del config y corrige si algo cambió.

## Antes de instalar: descarga la ISO correcta

**Fedora Everything (netinstall)**, no Workstation ni ningún Spin.
En "Software Selection" elige **"Fedora Custom Operating System"**
(el equivalente a "Minimal Install" en esta ISO).

## Durante la instalación

- El WiFi (Intel Wireless 8265) **sí funciona en el instalador** — conéctate
  ahí mismo si quieres, sin necesitar cable.
- Activa cifrado de disco si vas a viajar con el equipo — es el único momento
  donde agregarlo no cuesta nada extra (de todas formas se borra el disco).
- Elige BTRFS (default de Anaconda) para tener snapshots disponibles.

## Primer arranque (sistema ya instalado, sin GUI todavía)

El WiFi del sistema instalado **no funciona hasta correr `01-base.sh`**
(faltan `iwlwifi-mvm-firmware`, `NetworkManager-wifi`, `wpa_supplicant`).
Conecta el cable Ethernet para el primer arranque, corre `01-base.sh`,
y desde ahí ya puedes usar WiFi normal.

## La regla más importante de todo el repo

**Después de cualquier script que toque `xfconf-query` sobre paneles o
atajos de teclado: cierra sesión y vuelve a entrar.** Nunca intentes
`pkill xfce4-panel` ni `xfsettingsd --replace` en vivo — en la práctica,
eso generó paneles duplicados y atajos que dejan de responder, en vez de
arreglar nada. Ver `RETROSPECTIVA.md` para el detalle completo.
