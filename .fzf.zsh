# Setup fzf
# ---------
if ! command -v fzf >/dev/null 2>&1 && [ -d "/opt/homebrew/opt/fzf/bin" ]; then
  PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
fi

if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi
