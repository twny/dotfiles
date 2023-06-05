# Note PS1 contains char U+202F or 'Narrow no-break space'
# from vim in normal mode, cursor over this char
# type 'ga' to see more information on it!
export PS1="%~ $ "

# Apple /usr/libexec/path_helper | man path_helper
# https://opensource.apple.com/source/shell_cmds/shell_cmds-162/path_helper/path_helper.c
# export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

export PATH=$HOME/bin:$PATH
PATH=/opt/homebrew/bin:$PATH
PATH=/opt/homebrew/opt/postgresql@15/bin:$PATH

# Make zsh <C-p> behave like up arrow ↑
bindkey -e

# Settings
export HISTCONTROL="ignorespace"
export HISTFILESIZE=1000000
export HISTSIZE=1000000
export VISUAL=vim
export EDITOR=nvim
export FZF_DEFAULT_OPTS=--reverse
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
    --color=fg:-1,bg:-1,fg+:-1,bg+:-1,hl+:4,hl:4
    --color=spinner:-1,info:-1,prompt:-1,pointer:1'
export RIPGREP_CONFIG_PATH=$HOME/.ripgreprc

# Alias
alias vim="nvim"
alias ls="ls -G"

preview() {  qlmanage -p "$@" >& /dev/null; }

# Function exports
#export -f preview

gsl(){ git log --pretty=oneline --abbrev-commit | fzf --preview-window down:70% --preview 'echo {} | cut -f 1 -d " " | xargs git show --color=always'; }

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval "$(nodenv init -)"
eval "$(pyenv init -)"
eval "$(rbenv init -)"

# .env files and for python virtual env setups the PS1 (venv)
eval "$(direnv hook zsh)"
setopt PROMPT_SUBST

show_virtual_env() {
  if [[ -n "$VIRTUAL_ENV" && -n "$DIRENV_DIR" ]]; then
    echo "($(basename $VIRTUAL_ENV))"
  fi
}
PS1='$(show_virtual_env)'$PS1
