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

## Git Worktree Helpers

Manage worktrees with automatic Cursor IDE integration.

```bash
wt <branch>     # Open existing worktree, or create one in ~/workspace/ and open Cursor
wtrm <branch>   # Remove worktree + delete branch (opens main worktree if you were in it)
wtls             # List all worktrees
```

`wt` handles all cases: existing worktree, local branch, remote-only branch, or brand new branch.
`wtrm` finds the worktree by branch name from git (works even if created by Cursor IDE at non-standard paths).

## Contents

- Shell: zsh with Oh My Zsh, custom aliases, git worktree helpers
- Editor: neovim with lazy.nvim
- Tools: tmux, starship prompt
