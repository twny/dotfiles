preview() { qlmanage -p "$@" >& /dev/null; }
gsl(){ git log --pretty=oneline --abbrev-commit | fzf --preview-window down:70% --preview 'echo {} | cut -f 1 -d " " | xargs git show --color=always'; }
gfl() { git log --pretty=oneline --abbrev-commit | fzf --preview-window down:70% --preview 'echo {} | cut -f 1 -d " " | xargs -I % git diff-tree --no-commit-id --name-only -r %'; }
canvas() {
  local tmp="$TMPDIR/canvas-$(date +%s).png"
  # Make a 1px transparent GIF in base64, then resize to 2000×2000 PNG
  printf 'R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw==' | base64 --decode > "$TMPDIR/p.gif"
  sips -s format png -z 2000 2000 "$TMPDIR/p.gif" --out "$tmp" >/dev/null
  open -a Preview "$tmp"
}
show_virtual_env() {
  # direnv: when dynamically loading a python venv add (venv) to path
  if [[ -n "$VIRTUAL_ENV" && -n "$DIRENV_DIR" ]]; then
    echo "($(basename $VIRTUAL_ENV)) "
  fi
}
switch_tmux_theme() {
    if [[ "$1" =~ ^(dark|light)$ ]]; then
        # Set and export the variable outside tmux
        export TMUX_THEME=$1

        # Update the environment variable inside every tmux session
        tmux set-environment -g TMUX_THEME $1

        # Source the tmux configuration to apply changes
        tmux source-file ~/.config/tmux/tmux.conf

        echo "Switched tmux theme to $1 and reloaded configuration."
    else
        echo "Invalid theme specified. Use 'dark' or 'light'."
    fi
}
switch_alacritty_theme() {
  if [[ "$1" =~ ^(dark|light)$ ]]; then
    local theme_file="$HOME/.config/alacritty/${1}_theme.toml"
    sed -i '' "s|^import = \\[.*|import = [ \"$theme_file\", \"$HOME/.config/alacritty/keybindings.toml\" ]|" \
      "$HOME/.config/alacritty/alacritty.toml"
    echo "Switched Alacritty theme to $1."
  else
    echo "Invalid theme specified. Use 'dark' or 'light'."
  fi
}
theme() {
    if [[ "$1" =~ ^(dark|light)$ ]]; then
        # Call existing functions to switch themes
        switch_tmux_theme $1
        switch_alacritty_theme $1
    else
        echo "Invalid theme specified. Use 'dark' or 'light'."
    fi
}
ppcsv() { sed 's/,/ ,/g' "$@"| column -t -s, | less -S; } # pretty prints a csv using column (note: sed adds a space because column merges empty fields)
gtree() { tree -I "$(git ls-files --exclude-standard -oi --directory | tr '\n' '|' | sed 's/|$//')"; }
cf() {
  # collect all args, default to "." if none
  local paths=( "$@" )
  if [ ${#paths[@]} -eq 0 ]; then
    paths=( "." )
  fi

  # feed all paths to git ls-files
  git ls-files -- "${paths[@]}" \
    | grep -Ev '(pnpm-lock\.yaml|bun\.lock|package-lock\.json)$' \
    | while IFS= read -r file; do
        echo "==> $file <=="
        # skip images
        if file "$file" | grep -qE 'image|icon|bitmap'; then
          continue
        fi
        tail -n +1 "$file"
      done
}

fe() {
  local files
  IFS=$'\n' files=($(
    fd --type f --hidden --follow --exclude .git \
      | fzf-tmux --multi --select-1 --exit-0 \
  ))
  [[ -n "$files" ]] && ${EDITOR:-nvim} "${files[@]}"
}

fmtgo() { git status --porcelain | awk '/^ M/ {print $2}' | xargs gofmt -w; }
# git
gs() { git status; }
gss() { git status --short; }
gb() { git branch -vv; }
gco() { git checkout "$@"; }
gc() { git commit -m "$*"; }
gca() { git commit --amend --no-edit; }
gl() { git log --oneline --graph --decorate --all; }
gp() { git pull --rebase origin "$(git rev-parse --abbrev-ref HEAD)"; }
gpush() { git push origin "$(git rev-parse --abbrev-ref HEAD)"; }


athenaq() {
  local WG="logpipe"
  local DB="efchat_logs_db"
  local OUTPUT="s3://efchat-logs-athena-results/"
  local PROFILE="${AWS_PROFILE:-default}"
  local SQL="$*"

  if [[ -z "$SQL" ]]; then
    echo "usage: athenaq <SQL...>" >&2
    return 64
  fi

  local QID
  QID=$(aws athena start-query-execution \
    --work-group "$WG" \
    --query-string "$SQL" \
    --query-execution-context "Database=$DB" \
    --result-configuration "OutputLocation=$OUTPUT" \
    --profile "$PROFILE" \
    --query "QueryExecutionId" \
    --output text) || return 1
  echo "QID=$QID"

  local STATE
  while true; do
    STATE=$(aws athena get-query-execution \
      --query-execution-id "$QID" \
      --profile "$PROFILE" \
      --query 'QueryExecution.Status.State' \
      --output text)
    [[ "$STATE" != "RUNNING" && "$STATE" != "QUEUED" ]] && break
    sleep 2
  done

  aws athena get-query-execution \
    --query-execution-id "$QID" \
    --profile "$PROFILE" \
    --query 'QueryExecution.Status' \
    --output table

  if [[ "$STATE" == "SUCCEEDED" ]]; then
    aws athena get-query-results \
      --query-execution-id "$QID" \
      --profile "$PROFILE" \
      --output table
  else
    aws athena get-query-execution \
      --query-execution-id "$QID" \
      --profile "$PROFILE" \
      --query 'QueryExecution.Status.StateChangeReason' \
      --output text
    return 2
  fi
}



# Note PS1 contains char U+202F or 'Narrow no-break space'
# from vim in normal mode, cursor over this char
# type 'ga' to see more information on it!
# PS1="%~ $ "
# setopt PROMPT_SUBST # PS1 dynamic updates
# PS1='$(show_virtual_env)'$PS1

# Apple /usr/libexec/path_helper | man path_helper
# https://opensource.apple.com/source/shell_cmds/shell_cmds-162/path_helper/path_helper.c
# export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
export HOMEBREW_PREFIX="/opt/homebrew";
export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
export HOMEBREW_REPOSITORY="/opt/homebrew";
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}";
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:";
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";
export PATH=$HOME/bin:$PATH
setopt autocd

# Dedupe PATH items
typeset -U path

# Make zsh <C-p> behave like up arrow ↑
bindkey -e

# Enable Ctrl-x-e to edit command line
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

# Settings
setopt EXTENDED_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS INC_APPEND_HISTORY SHARE_HISTORY
HISTFILE=$HOME/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

export VISUAL=nvim
export EDITOR=nvim

export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --reverse \
  --color=fg:-1,bg:-1,fg+:-1,bg+:-1,hl+:4,hl:4 \
  --color=spinner:-1,info:-1,prompt:-1,pointer:1"
export RIPGREP_CONFIG_PATH=$HOME/.ripgreprc

# Alias
alias vim="nvim"
alias ls="ls -G"
alias path='echo -e ${PATH//:/\\n}'
alias x86='arch -x86_64 zsh'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if command -v nodenv >/dev/null 2>&1; then
  eval "$(nodenv init -)"
fi

# Rainbow color prompt!
# it's very cute and makes you more productive
set_rainbow_prompt() {
    local input="$(print -P "%~ $") "
    local prompt_string=""
    local color_idx=1
    local color

    for ((i=0; i<${#input}; i++)); do
        char="${input:$i:1}"
        color=${rainbow_colors[$color_idx]}
        prompt_string+="%F{$color}$char"
        color_idx=$((color_idx % ${#rainbow_colors[@]} + 1))
    done

    prompt_string+="%F{reset}"
    PROMPT=$prompt_string
}

rainbow_colors=(
  "#8c00ff"  "#a000ff"  "#b400ff"  "#c800ff"  "#dc00ff"  "#f000ff"
  "#ff00f0"  "#ff00dc"  "#ff00c8"  "#ff00b4"  "#ff00a0"  "#ff008c"
  "#ff0078"  "#ff0064"  "#ff0050"  "#ff003c"  "#ff0028"  "#ff0014"
  "#ff0000"  "#ff1400"  "#ff2800"  "#ff3c00"  "#ff5000"  "#ff6400"
  "#ff7800"  "#ff8c00"  "#ffa000"  "#ffb400"  "#ffc800"  "#ffdc00"
  "#fff000"  "#fdff00"  "#e9ff00"  "#d5ff00"  "#c1ff00"  "#adff00"
  "#99ff00"  "#85ff00"  "#71ff00"  "#5dff00"  "#49ff00"  "#35ff00"
  "#21ff00"  "#0dff00"  "#00ff0d"  "#00ff21"  "#00ff35"  "#00ff49"
  "#00ff5d"  "#00ff71"  "#00ff85"  "#00ff99"  "#00ffad"  "#00ffc1"
  "#00ffd5"  "#00ffe9"  "#00fffd"  "#00f0ff"  "#00dcff"  "#00c8ff"
  "#00b4ff"  "#00a0ff"  "#008cff"  "#0078ff"  "#0064ff"  "#0050ff"
  "#003cff"  "#0028ff"  "#0014ff"  "#0000ff"  "#1400ff"  "#2800ff"
  "#3c00ff"  "#5000ff"  "#6400ff"  "#7800ff"
)


rainbow_colors_light=(
  "#8839ef"  "#9546f0"  "#a253f2"  "#af60f3"  "#bc6df5"  "#c97af6"
  "#d687f8"  "#e394f9"  "#f0a1fb"  "#fdaffc"  "#ea76cb"  "#e168bc"
  "#d859ad"  "#cf4b9e"  "#c63c8f"  "#bd2e80"  "#d20f39"  "#ca2346"
  "#c33753"  "#bb4b60"  "#b45f6d"  "#ad737a"  "#fe640b"  "#f0721d"
  "#e3802f"  "#d58e41"  "#c79c53"  "#b9aa65"  "#e49320"  "#d89a3a"
  "#cca154"  "#c0a86e"  "#b4af88"  "#a8b6a2"  "#40a02b"  "#55932e"
  "#6a8631"  "#7f7934"  "#947c37"  "#a9803a"  "#7287fd"  "#667bdd"
  "#5b6fdd"  "#5063dd"  "#4557dd"  "#3a4bdd"  "#2f3fdd"  "#2433dd"
  "#1937dd"  "#0e3bdd"  "#033fdd"  "#2a6ef5"  "#3874f6"  "#467af7"
)
# rainbow_colors_light=(
#   "#660099"  "#7500AB"  "#8400BF"  "#9300D2"  "#A200E6"  "#B100FF"
#   "#C800E6"  "#D200D2"  "#DD00BF"  "#E700AB"  "#F20099"  "#FF0088"
#   "#FF0066"  "#FF0055"  "#FF0044"  "#FF0033"  "#FF0022"  "#FF0011"
#   "#FF0000"  "#E60000"  "#CC0000"  "#B30000"  "#990000"  "#800000"
#   "#660000"  "#4D0000"  "#330000"  "#1A0000"  "#000000"  "#333300"
#   "#666600"  "#999900"  "#CCCC00"  "#FFFF00"  "#CCCC00"  "#999900"
#   "#666600"  "#333300"  "#000000"  "#003300"  "#006600"  "#009900"
#   "#00CC00"  "#00FF00"  "#00CC00"  "#009900"  "#006600"  "#003300"
#   "#000066"  "#003399"  "#0066CC"  "#0099FF"  "#00CCCC"  "#00FFFF"
#   "#00CCCC"  "#0099FF"  "#0066CC"  "#003399"  "#000066"  "#330099"
#   "#4D0099"  "#660099"  "#800099"  "#990099"  "#B30099"
# )

precmd_functions+=(set_rainbow_prompt)

# This gives syntax highlight thanks twitch chat
# git clone https://github.com/zdharma-continuum/fast-syntax-highlighting ~/path/to/location
[ -r "$HOME/.config/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ] && \
  source "$HOME/.config/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export BAT_THEME="Catppuccin-mocha"
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"








################################################################################
# REDIS EFCHAT
################################################################################
# List all moderation keys (works in prod)
redis_scan_moderation() {
  local redis_url="$1"
  if [[ -z "$redis_url" ]]; then
    echo "Usage: redis_scan_moderation <redis://...>"
    return 1
  fi

  echo "Moderation keys in Redis:"
  for pattern in "strike:user:*" "strike:ip:*" "mute:user:*" "mute:ip:*" "ban:user:*" "ban:ip:*"; do
    echo "=== $pattern ==="
    local cursor=0
    while :; do
      # Call redis-cli, suppress stderr for warnings
      result=$(redis-cli -u "$redis_url" --raw SCAN "$cursor" MATCH "$pattern" COUNT 10000 2>/dev/null)
      cursor=$(echo "$result" | head -n1)
      keys=$(echo "$result" | tail -n +2)
      if [[ -n "$keys" ]]; then
        echo "$keys"
      fi
      [[ "$cursor" == "0" ]] && break
    done
  done
}

# strike counts
redis_strike_counts() {
  local REDIS_URL="$1"
  for k in "strike:user:*" "strike:ip:*"; do
    echo "=== $k ==="
    redis-cli -u "$REDIS_URL" --raw KEYS "$k" 2>/dev/null | while read key; do
      [ -n "$key" ] && {
        count=$(redis-cli -u "$REDIS_URL" GET "$key" 2>/dev/null)
        ttl=$(redis-cli -u "$REDIS_URL" TTL "$key" 2>/dev/null)
        if [ "$ttl" -ge 0 ]; then
          days=$((ttl / 86400))
          hours=$(( (ttl % 86400) / 3600 ))
          mins=$(( (ttl % 3600) / 60 ))
          secs=$(( ttl % 60 ))
          echo "$key -> strikes: $count | TTL: $ttl (${days}d ${hours}h ${mins}m ${secs}s)"
        else
          echo "$key -> strikes: $count | TTL: $ttl"
        fi
      }
    done
  done
}

# List moderation keys and their TTLs, with human-readable time, supporting a connection string
redis_check_ttl_moderation() {
  REDIS_CONN="$1"
  for k in "strike:user:*" "strike:ip:*" "mute:user:*" "mute:ip:*" "ban:user:*" "ban:ip:*"; do
    echo "=== $k ==="
    redis-cli -u "$REDIS_CONN" --raw KEYS "$k" 2>/dev/null | while read key; do
      [ -n "$key" ] && {
        ttl=$(redis-cli -u "$REDIS_CONN" TTL "$key" 2>/dev/null)
        if [ "$ttl" -ge 0 ]; then
          days=$((ttl / 86400))
          hours=$(( (ttl % 86400) / 3600 ))
          mins=$(( (ttl % 3600) / 60 ))
          secs=$(( ttl % 60 ))
          echo "$key -> TTL: $ttl (${days}d ${hours}h ${mins}m ${secs}s)"
        else
          echo "$key -> TTL: $ttl"
        fi
      }
    done
  done
}

# Delete all moderation keys (dev/test only)
redis_clear_moderation() {
  for pattern in "strike:user:*" "strike:ip:*" "mute:user:*" "mute:ip:*" "ban:user:*" "ban:ip:*"; do
    keys=$(redis-cli --raw KEYS "$pattern")
    if [[ -n "$keys" ]]; then
      echo "Deleting keys for $pattern..."
      redis-cli DEL $keys
    fi
  done
  echo "All moderation keys deleted."
}

if command -v pyenv >/dev/null 2>&1; then
  export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init - zsh)"
fi
