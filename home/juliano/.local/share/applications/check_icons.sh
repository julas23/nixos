#!/bin/bash

echo "🔍 Verificando arquivos .desktop"
echo

for file in ~/Git/nixos/HOME/.local/share/applications/*.desktop; do
    app_name=$(basename "$file")
    icon_name=$(grep -m1 '^Icon=' "$file" | cut -d'=' -f2)

    if [[ -z "$icon_name" ]]; then
        echo "❌ $app_name → Icon não definido"
        continue
    fi

    # Verifica se é caminho absoluto
    if [[ "$icon_name" == /* ]]; then
        [[ -f "$icon_name" ]] && status="✅ Ícone encontrado (absoluto)" || status="❌ Caminho inválido"
    else
        # Procura no tema de ícones (pastas padrão)
        if find /usr/share/icons ~/.local/share/icons /usr/share/pixmaps -iname "$icon_name.*" | grep -q .; then
            status="✅ Ícone encontrado ($icon_name)"
        else
            status="❌ Ícone NÃO encontrado ($icon_name)"
        fi
    fi

    echo "$status → $app_name"
done
