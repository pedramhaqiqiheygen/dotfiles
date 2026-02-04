# Dotfiles

Personal dotfiles managed with a bare git repo.

## Usage

```bash
# Clone to new machine
git clone --bare git@github.com:pedramhaqiqiheygen/dotfiles.git ~/dotfiles
alias dotfiles='/usr/bin/git --git-dir="$HOME/dotfiles/" --work-tree="$HOME"'
dotfiles config --local status.showUntrackedFiles no
dotfiles checkout

# Daily usage
dotfiles status
dotfiles add ~/.zshrc
dotfiles commit -m "Update zshrc"
dotfiles push
```

## Contents

- Shell: zsh with Oh My Zsh, custom aliases, git worktree helpers
- Editor: neovim with lazy.nvim
- Tools: tmux, starship prompt
