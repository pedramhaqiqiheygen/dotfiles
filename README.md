# Dotfiles

Personal dotfiles managed with a bare git repo.

## Usage

```bash
# Clone to new machine
git clone --bare git@github.com:pedramhaqiqiheygen/dotfiles.git ~/dotfiles
alias dotfiles='/usr/bin/git --git-dir="$HOME/dotfiles/" --work-tree="$HOME"'
dotfiles config --local status.showUntrackedFiles no
dotfiles checkout

# Install dependencies
./bootstrap.sh

# Daily usage
dotfiles status
dotfiles add ~/.zshrc
dotfiles commit -m "Update zshrc"
dotfiles push
```

## Git Worktree Helpers

Manage worktrees with automatic Cursor IDE integration.

```bash
wt               # Interactive fuzzy branch picker (fzf), type to filter or enter a new branch name
wt <branch>      # Open existing worktree, or create one in ~/workspace/ and open Cursor
wtrm             # Interactive fuzzy worktree picker (fzf), select which to remove
wtrm <branch>    # Remove worktree + delete branch (opens main worktree if you were in it)
wtrm -f [branch] # Force-remove dirty worktrees
wtls             # List all worktrees
```

- `wt` handles all cases: existing worktree, local branch, remote-only branch, or brand new branch
- `wtrm` looks up the real worktree path from git (works even for worktrees created by Cursor IDE at non-standard paths)
- `wtrm` refuses to remove the main worktree, prompts to clean up leftover directories
- New worktrees automatically get `.infisical.json` copied from the main worktree

## Contents

- Shell: zsh with Oh My Zsh, custom aliases, git worktree helpers
- Editor: neovim with lazy.nvim
- Tools: tmux, starship prompt
