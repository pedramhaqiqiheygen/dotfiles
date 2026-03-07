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

A tmux-based workflow for managing remote dev machines from your local terminal. Provides a 3-line status bar showing SSH sessions grouped by machine with health indicators, Nerd Font icons, and a dotbar-inspired theme.

### Quick Start

```bash
./bootstrap-macos.sh    # Install tmux, fzf, nerd fonts, TPM
dev setup               # Auto-detect SSH hosts, configure machines
```

Set your terminal font to **JetBrainsMono Nerd Font**, then open a new terminal. The tmux command center starts automatically.

### The `dev` Command

```bash
dev                          # fzf pick a machine
dev <machine>                # SSH + attach remote tmux session
dev <machine> <repo>         # SSH + cd to ~/workspace/<repo>
dev <machine> <repo> --claude    # SSH + repo + start claude code
dev <machine> <repo> --wt <branch>  # SSH + repo + worktree + claude
dev <machine> --list         # List remote tmux sessions
dev <machine> --repos        # List repos on machine
dev <machine> --kill <name>  # Kill a remote tmux session
dev setup                    # Configure machines from SSH hosts
```

### Machine Configuration

Machines are configured in `~/.config/dev/machines.conf`:

```
# name|ssh_host|workspace|icon|color|show_on_status
gpu|nebius|~/workspace|icon|#a6e3a1|true
aws|devbox|~/workspaces|icon|#7aa2f7|true
```

Run `dev setup` to auto-detect SSH hosts from `~/.ssh/config` and interactively configure them. The tmux status bar regenerates automatically.

### Nested tmux

Local tmux uses `C-a` as prefix, remote uses `C-b`. They don't collide:

- `C-a <key>` always controls your local tmux
- `C-b <key>` passes through to the remote tmux
- `C-a g` / `C-a d` — quick-open GPU / AWS windows

### Status Bar

Three lines (one per machine + local), powered by a dotbar-inspired theme:

- Health dot (green/red) per machine — async SSH probe, never blocks
- Nerd Font icons for each machine type
- Dot-separated window names, active window highlighted
- Prefix indicator flashes when `C-a` is pressed
- Pane count shown when splits are active

### File Layout

```
.config/tmux/
  theme.conf          # Dotbar color palette + icon definitions
  tmux.shared.conf    # Common settings (mouse, vim-nav, splits, vi keys)
  tmux.conf           # Remote config (C-b prefix, hostname status bar)
  tmux.local.conf     # Local config (C-a prefix, 3-line command center)

.config/dev/
  machines.conf       # Machine registry (edit or use `dev setup`)
  tmux-status.conf    # Auto-generated status lines

.local/bin/
  dev                 # Dev command
  dev-status          # Status line helper
```

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
