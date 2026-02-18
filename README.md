# rc pieces 🍬

### install

```sh
./install.sh
```

This links files from this repo into `$HOME` and `$HOME/.config`.
If a target already exists, it is moved to a timestamped backup first.
This also links `.fzf.zsh`.

Install Homebrew dependencies first (optional):

```sh
./install.sh --deps
```

Optional (for pretty syntax colors in zsh):

```sh
git clone --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting "$HOME/.config/zsh/plugins/fast-syntax-highlighting"
```

### ~/.config
the folloing use the `$HOME/.config` directory
* alacritty
* tmux
* neovim
* karabiner

### direnv

I like `direnv` to manage env vars and use a base `.envrc` where I store all
of my source code (usually `$HOME/src`) that loads language runtimes.

```sh
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(nodenv init -)"
```

For project specific env vars I'll have another `.envrc` that overrides my
base. For python projects I use something like this.

```sh
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

eval "$(pyenv init -)"
eval "$(nodenv init -)"
eval "$(pyenv init --path)"

export PYTHONPATH=$PYTHONPATH:$HOME/src/<project>
export VIRTUAL_ENV=venv
layout python
```
