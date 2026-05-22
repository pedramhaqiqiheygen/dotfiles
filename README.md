# Dotfiles

Personal dotfiles managed with a bare git repo.

## Setup

```bash
# Clone to new machine
git clone --bare git@github.com:pedramhaqiqiheygen/dotfiles.git ~/dotfiles
alias dotfiles='/usr/bin/git --git-dir="$HOME/dotfiles/" --work-tree="$HOME"'
dotfiles config --local status.showUntrackedFiles no
dotfiles checkout

# Install dependencies
./bootstrap.sh          # Linux
./bootstrap-macos.sh    # macOS

# Daily usage
dotfiles status
dotfiles add ~/.zshrc
dotfiles commit -m "Update zshrc"
dotfiles push
```

## Terminal Command Center

A tmux-based, dotbar-themed multi-machine workflow: per-machine status rows, clickable tabs, fzf session resume across all your remotes, sleep-resilient SSH, OSC 52 clipboard. One row per machine in the status bar; `C-a R` to bring back any past session; `+` to spawn a fresh one.

**Full docs:** [`docs/dotfiles/terminal-command-center.md`](docs/dotfiles/terminal-command-center.md) — features, requirements, key-bindings cheat sheet, `machines.conf` schema, customization, troubleshooting.

```bash
./bootstrap-macos.sh    # Install tmux, fzf, nerd fonts, TPM
dev setup               # Auto-detect SSH hosts, configure machines
```

Set your terminal font to **JetBrainsMono Nerd Font**, open a new terminal — the command center is live.

## Git Worktree Helpers

Manage worktrees with automatic Cursor IDE integration.

```bash
wt               # Interactive fuzzy branch picker (fzf)
wt <branch>      # Open existing worktree, or create one and open Cursor
wt --no-cursor <branch>  # Create worktree without opening editor (used by `dev --wt`)
wtrm             # Interactive fuzzy worktree picker, select which to remove
wtrm <branch>    # Remove worktree + delete branch
wtrm -f [branch] # Force-remove dirty worktrees
wtls             # List all worktrees
```

## Contents

- Shell: zsh with Oh My Zsh, custom aliases, git worktree helpers
- Editor: neovim with lazy.nvim (gruvbox-material, telescope, treesitter, LSP)
- Terminal: tmux with dotbar-inspired theme, command center status bar
- Prompt: starship
- Fonts: JetBrainsMono Nerd Font
