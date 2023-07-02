# rc pieces 🍬


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

export PYTHONPATH=$PYTHONPATH:/Users/<user>/src/<project>
export VIRTUAL_ENV=venv
layout python
```
