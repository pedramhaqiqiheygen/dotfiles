# dev — terminal command center

A tmux-based, dotbar-themed command center for engineers who work across multiple remote machines and want a fast, mouse-and-keyboard, multi-machine workflow without leaving their terminal.

```
●  GPU    1 prodai-planning  2 bazel-setup  3 eval-framework  4 input-error-contract  +
●  AWS    1 experiment-framework-research
●  HOME   1 zsh  2 zsh                                                          C-a   15:32
```

Each row groups all tmux windows for one machine. Click any tab to jump, click `+` to spawn a fresh session, hit `C-a R` to resurrect any past session from any machine. Splits route to the right pane operation depending on whether the focused window is local or remote. SSH sessions survive sleep via mosh; dead connections auto-respawn.

---

## Features

- **3-row status bar**, one row per registered machine (configurable). Each row only renders its own machine's tabs — no cross-machine overflow.
- **Clickable tabs and pills.** Single-click switches; double-click previews; `+` at end of focused row spawns a new tab.
- **Silent jump leader (`C-a j`).** Press `j` then a machine letter then a digit to land on any tab on any machine. No yellow command-prompt.
- **Spawn (`C-a N`).** Fresh tab on the current machine, lands in the configured workspace root.
- **Session resume (`C-a R`).** Fzf popup over every detached tmux session across all your remotes plus every local HOME window. Left/Right arrows tab between machines.
- **Sleep-resilient SSH.** Uses mosh when available (`mosh-server` on remote + `mosh` locally), falls back to `autossh -M 0`, finally plain `ssh -t`. Plus tighter `ServerAliveInterval` + `ControlMaster` connection multiplexing.
- **Dead-pane auto-reaper.** When a remote pane dies, tmux hook respawns it (rate-limited to 3 attempts per 60s; bails to a "press R to retry" prompt after that).
- **HOME splits, remote new-windows.** `C-a v` / `C-a h` splits the pane on HOME, opens a new tmux window on remote rows. Routed via per-window `@dev_machine` user-option, not name parsing.
- **Unread-tab indicator.** Tabs with new output (since last viewed) brighten without changing width. Active tab is accent green; read inactive is dim grey.
- **OSC 52 clipboard.** Mouse drag-select inside any pane (local or nested remote tmux) → release → text is in your macOS clipboard. No `y` press, no yellow highlight.
- **Themed kill confirm.** `C-a x` opens a floating dotbar-styled menu instead of tmux's yellow `confirm-before` that eats the whole status bar.

---

## Requirements

- **tmux 3.4+** (uses `display-menu -b rounded`, `menu-style`, `allow-passthrough`, `set-clipboard`). Older tmux works for the remote side (graceful degradation).
- **bash 4+** (`declare -A` in `dev-lib.sh`). macOS ships bash 3.2 — install via Homebrew (`brew install bash`).
- **fzf** for the resume picker and machine picker. `brew install fzf`.
- **Optional:** **mosh** (`brew install mosh` locally; `apt install mosh` or equivalent on remotes), **autossh** (`brew install autossh`) as a fallback.
- **A Nerd Font** for the icons (`󰢮 󰅟 󰆍`). [Nerd Fonts](https://www.nerdfonts.com).
- **iTerm2** or **Ghostty** as the terminal. iTerm2 requires *Settings → General → Selection → "Applications in terminal may access clipboard"* enabled for OSC 52.

---

## Quick start

```sh
# 1. Clone / install the files
mkdir -p ~/.config/dev ~/.config/tmux ~/.local/bin
cp dev/* ~/.local/bin/
cp tmux/* ~/.config/tmux/
chmod +x ~/.local/bin/dev*

# 2. Configure machines (interactive wizard)
dev setup

# 3. Source tmux config (or kill-server and restart)
tmux source-file ~/.config/tmux/tmux.local.conf

# 4. (Optional) load shell aliases
echo 'source ~/.config/dev/aliases.sh' >> ~/.zshrc
```

`dev setup` writes `~/.config/dev/machines.conf` and regenerates `~/.config/dev/tmux-status.conf` from it.

---

## Configuring machines

`~/.config/dev/machines.conf` — pipe-delimited, whitespace-tolerant:

```
# name | ssh_host | workspace      | icon | color    | show_on_status | key
gpu    | nebius   | ~/workspace    | 󰢮    | #a6e3a1  | true           | g
aws    | devbox   | ~/workspaces   | 󰅟    | #7aa2f7  | true           | a
```

| Field            | Purpose                                              |
|------------------|------------------------------------------------------|
| `name`           | Short identifier used everywhere (`dev gpu`, etc.)   |
| `ssh_host`       | What `ssh` should connect to (resolved via `~/.ssh/config`) |
| `workspace`      | Default `cd` target for `+` spawn and `dev <m> --ws` |
| `icon`           | Nerd-font glyph rendered in the status bar           |
| `color`          | Hex; tinted bullet and label                         |
| `show_on_status` | `true` adds a row in the status bar                  |
| `key`            | Single letter for the jump leader (`C-a j <key>`)    |

Re-run `dev setup` after edits — it regenerates `tmux-status.conf` and `aliases.sh`.

---

## Key bindings cheat sheet

All prefixed by `C-a` unless noted (or `C-b` inside a nested remote tmux).

### Navigation

| Keys          | Action                                                  |
|---------------|---------------------------------------------------------|
| `1`..`9`      | Jump to Nth tab of the **focused** machine row          |
| `j g 4`       | Jump to GPU tab 4 (silent leader; works for any letter) |
| `j l 1`       | Jump to HOME (local) tab 1                              |
| `R`           | Resume picker (fzf popup, all machines + HOME)          |
| `G` / `A`     | Launch default session on `gpu` / `aws`                 |
| `B`           | Fzf window-picker with previews (cross-row)             |
| `Tab` (in resume) | Cycle to next machine                                |

### Spawning

| Keys      | Action                                                |
|-----------|-------------------------------------------------------|
| `N`       | Fresh tab on current machine (at workspace root)      |
| `j g N`   | Fresh GPU tab (any machine letter works)              |
| `v` / `h` | Split horizontal / vertical (HOME), or new-window (remote) |

### Editing

| Keys      | Action                                                |
|-----------|-------------------------------------------------------|
| `q`       | Kill pane (immediate, no confirm)                     |
| `x`       | Kill pane (with themed floating menu confirm)         |
| `[`       | Enter copy mode; `v` start selection; `y` copy + exit |
| Mouse drag | Auto-copy on release (works locally and from remote) |
| Double-click word / triple-click line | Copy that token        |

### Misc

| Keys      | Action                            |
|-----------|-----------------------------------|
| `C-a a`   | Forward prefix to nested tmux     |
| `S-←/→/↑/↓` | Resize pane (no prefix needed)  |
| `M-1`..`M-9` | Direct window jump by index (no prefix) |

---

## File layout

```
~/.config/
  dev/
    machines.conf          # source of truth: which machines exist
    tmux-status.conf       # auto-generated from machines.conf; status-format + jump tables
    aliases.sh             # auto-generated: dg / dgc / dgl / dgr / da / ...
    README.md              # this file
  tmux/
    tmux.local.conf        # macOS-only: prefix C-a, mouse copy, kill-menu, etc.
    tmux.conf              # remote-only: prefix C-b, minimal status
    tmux.shared.conf       # sourced by both: mouse, clipboard, mode-style, copy-mode-vi
    theme.conf             # palette tokens (BG, FG, ACCENT, machine colors)

~/.local/bin/
  dev                      # main entry: pick / spawn / connect / setup / migrate / sessions
  dev-lib.sh               # sourced helpers: machines.conf parser, width-aware truncate
  dev-status               # status-bar renderer (row / pill / bar / status-bullet / tabs-only)
  dev-jump                 # tmux select-window <machine> <Nth-in-row>
  dev-jump-current         # dev-jump for the focused machine
  dev-preview              # popup preview of a tab's pane scrollback
  dev-click                # tmux mouse-range dispatcher
  dev-spawn                # spawn new tab on current/named machine
  dev-reap-pane            # pane-died hook handler
  dev-track-last-window    # after-select-window hook: caches @dev_last_window_<m>
  dev-sessions-cycle       # fzf Left/Right helper for the resume picker
  dev-lib-test.sh          # bash assertion tests for dev-lib.sh
```

`@dev_machine` and `@dev_session` are per-tmux-window user-options set at spawn time by `connect()` and read by every routing script — replacing the older `gpu:foo` name-prefix convention.

---

## Customization

### Palette

Edit hex values at the top of `tmux.local.conf`, `tmux.shared.conf`, and the `_BG` / `_FG_*` / `_ACCENT_*` / `_LOCAL_COLOR` block in `~/.local/bin/dev`. Tokens are intentionally duplicated in three places so each layer can be lifted out independently.

### Adding a machine

1. `dev setup` and add it interactively, OR edit `machines.conf` directly and run `dev setup` to regenerate.
2. Pick a unique single-letter `key` (used by the jump leader).
3. Pick an unused color and Nerd Font icon.
4. Source the new config: `tmux source-file ~/.config/tmux/tmux.local.conf`.

### Changing layout

`tmux-status.conf` is auto-generated. To hand-tune:
- One-time: edit `tmux-status.conf` directly (will be overwritten next `dev setup`).
- Permanent: edit `_generate_tmux_status()` in `~/.local/bin/dev` and re-run `dev setup`.

---

## Troubleshooting

| Symptom                                            | Likely cause / fix                                                    |
|----------------------------------------------------|-----------------------------------------------------------------------|
| Bar shows windows in wrong machine row             | Run `dev migrate` (tags existing windows with `@dev_machine`)         |
| Cmd-V doesn't paste tmux selection                 | Enable iTerm2 "Applications in terminal may access clipboard"         |
| Kill-pane menu (`C-a x`) is yellow                 | Older tmux on remote — falls back to `confirm-before`; styled but no menu |
| `dev sessions` errors: `systime`                   | Update; uses bash `date +%s` now (BSD awk has no `systime()`)         |
| `+` click opens broken `cmdand>` prompt            | Ensure `dev` is recent; older versions appended trailing ` && ` to startup |
| HOME window can't split                            | Run `dev migrate`; older windows lack `@dev_machine=local`            |
| Bar takes 3s to update on tab activity             | `set -g status-interval 1` (default is 3; tradeoff: more shell-outs)  |
| Tabs overflow on the status bar                    | `dev_lib::truncate` clips to 22 cells; lower it in `dev-status` if needed |

---

## Architecture notes

- The bar shell-outs to `dev-status bar` (or per-row `dev-status <machine>` in 3-row mode) every `status-interval` seconds. One shell-out per render, regardless of tab count.
- Window machine identity is stored as the tmux user-option `@dev_machine` (set at spawn by `connect()`). All routing (`dev-jump`, splits, status filtering) reads this — name-prefix matching is gone.
- The fzf resume picker queries every machine's remote tmux server in parallel (`ssh -o ConnectTimeout=5 -o BatchMode=yes`). Hosts that don't respond in 5s just don't appear.
- `dev-lib.sh` is the single config parser. Sourced by every other `dev*` script.

---

## Inspiration / credits

- **dotbar**-inspired palette: dark, low-contrast, accent-driven.
- **tmuxinator** and **smug** showed that session orchestration is its own valid layer.
- **mosh** (Keith Winstein, Anders Kaseorg) for the SSH-survival story.
- The Nerd Fonts project for the machine icons.

---

## License

MIT — do whatever, attribution appreciated.
