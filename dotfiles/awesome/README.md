# Awesome WM Dotfiles

Modern Hyprland-like configuration for Awesome WM using:
- **Catppuccin Mocha** color palette
- **bling** — tabbed layouts, tag preview, playerctl widget
- **lain** — extra layouts and async widgets
- **vicious** — CPU, memory, network widgets
- **picom** — blur, rounded corners, shadows, fading
- **dunst** — rounded notification popups
- **rofi** — application launcher

## Installation

The NixOS module (`modules/desktop/awesome.nix`) automatically:
1. Clones `bling` and `lain` to `~/.config/awesome/libs/` on first boot
2. Installs all required packages via Nix

You only need to copy the dotfiles manually:

```bash
# Awesome WM config
mkdir -p ~/.config/awesome
cp rc.lua ~/.config/awesome/rc.lua

# Picom compositor
mkdir -p ~/.config/picom
cp picom.conf ~/.config/picom/picom.conf

# Dunst notifications
mkdir -p ~/.config/dunst
cp dunstrc ~/.config/dunst/dunstrc

# Set a wallpaper (feh reads from this path in rc.lua)
cp your-wallpaper.jpg ~/.config/awesome/wallpaper.jpg
```

## Key bindings

| Key | Action |
|---|---|
| `Super + Enter` | Open terminal (kitty) |
| `Super + r` | Rofi app launcher |
| `Super + e` | File manager (pcmanfm) |
| `Super + b` | Browser (Brave) |
| `Super + q` | Close window |
| `Super + f` | Fullscreen |
| `Super + t` | Toggle floating |
| `Super + m` | Maximize |
| `Super + l` | Lock screen (blur) |
| `Super + Space` | Next layout |
| `Super + 1-9` | Switch workspace |
| `Super + Shift + 1-9` | Move window to workspace |
| `Super + j/k` | Focus next/previous window |
| `Super + h/l` | Resize master area |
| `Print` | Screenshot (flameshot) |

## Layouts

1. **Tile** — classic master + stack
2. **Mstab** (bling) — tabbed master, like Hyprland tabbed
3. **Centered** (bling) — centered master with gaps
4. Tile left, bottom, fair, spiral, max, floating

## Visual tweaks

Edit `picom.conf` to adjust:
- `blur-strength` — background blur intensity (1-20)
- `corner-radius` — window corner rounding (px)
- `inactive-opacity` — transparency of unfocused windows
- `shadow-radius` — shadow size

Edit `rc.lua` → `colors` table to change the color palette.
