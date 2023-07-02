# Functions
preview() {  qlmanage -p "$@" >& /dev/null; }
gsl(){ git log --pretty=oneline --abbrev-commit | fzf --preview-window down:70% --preview 'echo {} | cut -f 1 -d " " | xargs git show --color=always'; }
gfl() { git log --pretty=oneline --abbrev-commit | fzf --preview-window down:70% --preview 'echo {} | cut -f 1 -d " " | xargs -I % git diff-tree --no-commit-id --name-only -r %'; }
show_virtual_env() {
# direnv: when dynamically loading a python venv add (venv) to path
  if [[ -n "$VIRTUAL_ENV" && -n "$DIRENV_DIR" ]]; then
    echo "($(basename $VIRTUAL_ENV)) "
  fi
}
show_arch_env() {
  # Add (x86) to prompt when in x86 mode
  if [ "$(arch)" = "i386" ]; then
    echo "(x86) "
  fi
}

# This function removes a specified path from the PATH environment variable.
function path_remove {
  # If the entire PATH is the specified path, set PATH to an empty string.
  if [ "$PATH" = "$1" ]; then
    PATH=""
  else
    PATH="${PATH//":$1:"/":"}" # Replace ":$1:" (path in middle)
    PATH="${PATH/#"$1:"/}" # Replace "$1:" (path at beginning)
    PATH="${PATH/%":$1"/}" # Replace ":$1" (path at end)
  fi
}

# Note PS1 contains char U+202F or 'Narrow no-break space'
# from vim in normal mode, cursor over this char
# type 'ga' to see more information on it!
export PS1="%~ $ "
setopt PROMPT_SUBST # PS1 dynamic updates
PS1='$(show_virtual_env)''$(show_arch_env)'$PS1

# Apple /usr/libexec/path_helper | man path_helper
# https://opensource.apple.com/source/shell_cmds/shell_cmds-162/path_helper/path_helper.c
# export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
export PATH=$HOME/bin:$PATH
PATH=/opt/homebrew/bin:$PATH
# Multiple Homebrews on Apple Silicon
if [ "$(arch)" = "arm64" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  # Remove the ARM Homebrew path
  path_remove "/opt/homebrew/bin"
  eval "$(/usr/local/bin/brew shellenv)"
fi

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
