# Retrospectiva — Fedora Minimal + Sway

## Qué funcionó bien

- **Config en un solo archivo de texto** (`~/.config/sway/config`) — cuando
  algo fallaba, Sway mostraba un banner rojo "hay errores en tu config" con
  la línea exacta. Diagnóstico rápido y determinista, sin bugs de estado.
- **Identificar dispositivos por su nombre único**, no por ID temporal:
  - Teclados: `swaymsg -t get_inputs` da un identificador estable
    (ej. `1:1:AT_Translated_Set_2_keyboard`)
  - Apps para routing de ventanas: `swaymsg -t get_tree | jq` da el `app_id`
    real (ej. Chrome es `google-chrome`, NO `com.google.Chrome` como se
    asume por el nombre del paquete)
- **`for_window` rules** para enrutar apps a workspaces específicos y hacer
  apps pequeñas (calculadora, pavucontrol) flotantes con tamaño fijo.

## Qué costó tiempo (evitar repetir)

1. **Nombres de paquete asumidos de memoria, incorrectos:**
   - `gnome-themes-extra` → no existe en Fedora 44, usar `adw-gtk3-theme`
   - `tlp` chocaba con `tuned`/`tuned-ppd` (paquete nuevo de gestión de
     energía de Fedora) — hay que quitar `tuned`/`tuned-ppd` primero
   - `polkit-gnome` → descontinuado, usar `mate-polkit`

2. **Copiar bloques largos con caracteres Unicode especiales (íconos Font
   Awesome) por copy-paste corrompió el archivo una vez.** Los íconos
   quedaron como comillas vacías. Se resolvió restaurando desde backup +
   editando con `sed` (que no pasa por el portapapeles).
   **Lección: para archivos con íconos especiales, usar `sed`/sustitución
   de línea en vez de reescribir el archivo completo por copy-paste.**

3. **"Minimal Install" no trae WiFi funcional** (aplica a Sway igual que a
   cualquier otro entorno — no es un problema de Sway, es de la ISO):
   faltan `iwlwifi-mvm-firmware`, `NetworkManager-wifi`, `wpa_supplicant`.

4. **`geoclue2` (ubicación automática para gammastep/Night Light) no
   funcionó** — dio timeout. Se resolvió con ubicación manual fija en
   `~/.config/gammastep/config.ini` (`location-provider=manual`).

5. **El `app_id` real de una app casi nunca coincide con el nombre del
   paquete o el binario.** Siempre verificar con
   `swaymsg -t get_tree | jq -r '.. | select(.app_id? != null or .window_properties.class? != null) | (.app_id // .window_properties.class)' | sort -u`
   con la app ya abierta, antes de escribir una regla `for_window`.

## Regla de oro

Antes de escribir cualquier `for_window [app_id="..."]`, abre la app y
corre el comando de arriba para confirmar el `app_id` real — no lo asumas
del nombre del paquete.
