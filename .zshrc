# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting zsh-autocomplete)
source $ZSH/oh-my-zsh.sh

# Emacs keybindings (not vi mode)
bindkey -e

# Editor
export EDITOR="nvim"
export VISUAL="nvim"

# PATH
export PATH="$PATH:$HOME/.local/bin"

# Homebrew (Linuxbrew)
[[ -f /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Tools
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
command -v micromamba &>/dev/null && eval "$(micromamba shell hook --shell zsh)"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Share model zoo cache across worktrees

# Custom
source "$HOME/.aliases.zsh"
[[ -f "$HOME/.localconf.zsh" ]] && source "$HOME/.localconf.zsh"
