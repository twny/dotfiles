#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SUFFIX="backup.$(date +%Y%m%d%H%M%S)"
INSTALL_DEPS="${1:-}"

if [ "$INSTALL_DEPS" = "--help" ] || [ "$INSTALL_DEPS" = "-h" ]; then
  cat <<'EOF'
Usage:
  ./install.sh         # link dotfiles
  ./install.sh --deps  # install Homebrew dependencies, then link dotfiles
EOF
  exit 0
fi

if [ -n "$INSTALL_DEPS" ] && [ "$INSTALL_DEPS" != "--deps" ]; then
  echo "Unknown option: $INSTALL_DEPS"
  echo "Use --help for usage."
  exit 1
fi

if [ "$INSTALL_DEPS" = "--deps" ]; then
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Install Homebrew first: https://brew.sh"
    exit 1
  fi
  brew bundle --file "$REPO_DIR/Brewfile"
fi

link_item() {
  local src="$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "ok: $dest"
    return
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    local backup="${dest}.${BACKUP_SUFFIX}"
    mv "$dest" "$backup"
    echo "backup: $dest -> $backup"
  fi

  ln -s "$src" "$dest"
  echo "linked: $dest -> $src"
}

# Home dotfiles
link_item "$REPO_DIR/.zshrc" "$HOME/.zshrc"
link_item "$REPO_DIR/.fzf.zsh" "$HOME/.fzf.zsh"
link_item "$REPO_DIR/.psqlrc" "$HOME/.psqlrc"
link_item "$REPO_DIR/.tmux.conf" "$HOME/.tmux.conf"
link_item "$REPO_DIR/.ripgreprc" "$HOME/.ripgreprc"
link_item "$REPO_DIR/.curlrc" "$HOME/.curlrc"
link_item "$REPO_DIR/.skhdrc" "$HOME/.skhdrc"
link_item "$REPO_DIR/.yabairc" "$HOME/.yabairc"

# XDG config directories
link_item "$REPO_DIR/alacritty" "$HOME/.config/alacritty"
link_item "$REPO_DIR/tmux" "$HOME/.config/tmux"
link_item "$REPO_DIR/nvim" "$HOME/.config/nvim"
link_item "$REPO_DIR/karabiner" "$HOME/.config/karabiner"

PLUGIN_DIR="$HOME/.config/zsh/plugins/fast-syntax-highlighting"
if [ ! -r "$PLUGIN_DIR/fast-syntax-highlighting.plugin.zsh" ]; then
  mkdir -p "$HOME/.config/zsh/plugins"
  echo
  echo "Optional pretty zsh syntax highlighting:"
  echo "  git clone --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting \"$PLUGIN_DIR\""
fi

if ls "$REPO_DIR"/fonts/*.otf >/dev/null 2>&1; then
  echo
  echo "Optional Nerd Font install (macOS):"
  echo "  cp \"$REPO_DIR\"/fonts/*.otf \"$HOME/Library/Fonts/\""
fi

echo
echo "Done."
