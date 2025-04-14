#!/bin/bash

echo "🔍 Buscando ícones usados nos arquivos .desktop..."

ICON_DIR="$HOME/Git/nixos/HOME/.local/applications/icons"
mkdir -p "$ICON_DIR"

# Caminhos padrões de ícones
ICON_PATHS=(
  "/usr/share/icons"
  "/usr/share/pixmaps"
  "$HOME/.local/share/icons"
)

# Função para encontrar o caminho do ícone
find_icon_path() {
  local icon_name="$1"
  for path in "${ICON_PATHS[@]}"; do
    # PNG padrão
    if [[ -f "$path/hicolor/64x64/apps/$icon_name.png" ]]; then
      echo "$path/hicolor/64x64/apps/$icon_name.png"
      return
    fi
    # Arquivo com nome direto (sem subpastas)
    result=$(find "$path" -type f \( -name "$icon_name.png" -o -name "$icon_name.svg" \) 2>/dev/null | head -n1)
    if [[ -n "$result" ]]; then
      echo "$result"
      return
    fi
  done
}

# Loop pelos .desktop files
for desktop in ~/Git/nixos/HOME/.local/share/applications/*.desktop; do
  icon=$(grep -E '^Icon=' "$desktop" | cut -d= -f2)
  name=$(basename "$desktop" .desktop)

  [[ -z "$icon" ]] && continue

  # Pega o caminho do ícone real
  icon_path=$(find_icon_path "$icon")
  if [[ -f "$icon_path" ]]; then
    cp "$icon_path" "$ICON_DIR/$name.png"
    echo "✅ Ícone copiado: $name → $icon_path"
  else
    echo "❌ Ícone NÃO encontrado: $icon → $name.desktop"
  fi
done

echo "🎉 Todos os ícones disponíveis foram copiados para $ICON_DIR"
