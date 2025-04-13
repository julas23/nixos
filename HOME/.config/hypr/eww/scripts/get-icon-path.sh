#!/run/current-system/sw/bin/bash

app="$1"
desktop_file="$HOME/.local/share/applications/$app.desktop"
icon=$(grep -i "^Icon=" "$desktop_file" 2>/dev/null | cut -d'=' -f2)

for dir in ~/.local/share/icons /usr/share/icons /usr/share/pixmaps; do
  [[ -f "$dir/$icon.png" ]] && echo "$dir/$icon.png" && exit
  [[ -f "$dir/$icon.svg" ]] && echo "$dir/$icon.svg" && exit
done

# fallback
echo "/usr/share/icons/hicolor/48x48/apps/unknown.png"
