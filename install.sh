#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Deploying dotfiles from $DOTFILES_DIR..."

mkdir -p "$HOME/.config"

# Config folders and files
configs=(
    "sway"
    "waybar"
    "foot"
    "fuzzel"
    "mako"
    "swaylock"
    "starship.toml"
    "btop"
    "nnn"
    "fcitx5"
    "fontconfig"
)

for item in "${configs[@]}"; do
    src="$DOTFILES_DIR/.config/$item"
    dest="$HOME/.config/$item"

    if [ -e "$src" ]; then
        if [ -L "$dest" ]; then
            rm "$dest"
        elif [ -e "$dest" ]; then
            echo "Backing up existing $dest to ${dest}.backup"
            mv "$dest" "${dest}.backup"
        fi
        ln -sf "$src" "$dest"
        echo "  [✓] Linked ~/.config/$item -> $src"
    fi
done

# Home shell configs
home_files=(
    ".zshrc"
    ".zprofile"
    ".bashrc"
    ".bash_profile"
)

for item in "${home_files[@]}"; do
    src="$DOTFILES_DIR/$item"
    dest="$HOME/$item"

    if [ -e "$src" ]; then
        if [ -L "$dest" ]; then
            rm "$dest"
        elif [ -e "$dest" ]; then
            echo "Backing up existing $dest to ${dest}.backup"
            mv "$dest" "${dest}.backup"
        fi
        ln -sf "$src" "$dest"
        echo "  [✓] Linked ~/$item -> $src"
    fi
done

# Wallpapers
if [ -d "$DOTFILES_DIR/wallpapers" ]; then
    mkdir -p "$HOME/Pictures"
    if [ ! -e "$HOME/Pictures/wallpapers" ]; then
        ln -sf "$DOTFILES_DIR/wallpapers" "$HOME/Pictures/wallpapers"
        echo "  [✓] Linked ~/Pictures/wallpapers -> $DOTFILES_DIR/wallpapers"
    fi
fi

# Make scripts executable
find "$DOTFILES_DIR" -name "*.sh" -exec chmod +x {} +
find "$DOTFILES_DIR" -name "*.py" -exec chmod +x {} +

echo "==> All dotfiles linked and permissions set successfully!"
