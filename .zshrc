# Functions
preview() { qlmanage -p "$@" >& /dev/null; }
gsl(){ git log --pretty=oneline --abbrev-commit | fzf --preview-window down:70% --preview 'echo {} | cut -f 1 -d " " | xargs git show --color=always'; }
gfl() { git log --pretty=oneline --abbrev-commit | fzf --preview-window down:70% --preview 'echo {} | cut -f 1 -d " " | xargs -I % git diff-tree --no-commit-id --name-only -r %'; }
show_virtual_env() {
  # direnv: when dynamically loading a python venv add (venv) to path
  if [[ -n "$VIRTUAL_ENV" && -n "$DIRENV_DIR" ]]; then
    echo "($(basename $VIRTUAL_ENV)) "
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
export PATH=$HOME/bin:$PATH
PATH=/opt/homebrew/bin:$PATH
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
export HISTCONTROL="ignorespace"
export HISTFILESIZE=1000000
export HISTSIZE=1000000

export VISUAL=nvim
export EDITOR=nvim

export FZF_DEFAULT_OPTS=--reverse
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
    --color=fg:-1,bg:-1,fg+:-1,bg+:-1,hl+:4,hl:4
    --color=spinner:-1,info:-1,prompt:-1,pointer:1'
export RIPGREP_CONFIG_PATH=$HOME/.ripgreprc

# Alias
alias vim="nvim"
alias ls="ls -G"
alias path='echo -e ${PATH//:/\\n}'
alias x86='arch -x86_64 zsh'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval "$(nodenv init -)"
eval "$(pyenv init -)"
# eval "$(rbenv init -)"

# .env files and for python virtual env setups the PS1 (venv)
eval "$(direnv hook zsh)"

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

rainbow_colors=("#8c00ff"  "#a000ff"  "#b400ff"  "#c800ff"  "#dc00ff"  "#f000ff"  "#ff00f0"  "#ff00dc"  "#ff00c8"  "#ff00b4"  "#ff00a0"  "#ff008c"  "#ff0078"  "#ff0064"  "#ff0050"  "#ff003c"  "#ff0028"  "#ff0014"  "#ff0000"  "#ff1400"  "#ff2800"  "#ff3c00"  "#ff5000"  "#ff6400"  "#ff7800"  "#ff8c00"  "#ffa000"  "#ffb400"  "#ffc800"  "#ffdc00"  "#fff000"  "#fdff00"  "#e9ff00"  "#d5ff00"  "#c1ff00"  "#adff00"  "#99ff00"  "#85ff00"  "#71ff00"  "#5dff00"  "#49ff00"  "#35ff00"  "#21ff00"  "#0dff00"  "#00ff0d"  "#00ff21"  "#00ff35"  "#00ff49"  "#00ff5d"  "#00ff71"  "#00ff85"  "#00ff99"  "#00ffad"  "#00ffc1"  "#00ffd5"  "#00ffe9"  "#00fffd"  "#00f0ff"  "#00dcff"  "#00c8ff"  "#00b4ff"  "#00a0ff"  "#008cff"  "#0078ff"  "#0064ff"  "#0050ff"  "#003cff"  "#0028ff"  "#0014ff"  "#0000ff"  "#1400ff"  "#2800ff"  "#3c00ff"  "#5000ff"  "#6400ff"  "#7800ff"  )

precmd_functions+=(set_rainbow_prompt)
