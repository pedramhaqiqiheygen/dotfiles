# Core aliases
alias v=nvim
alias vim=nvim
alias today='date +%Y%m%d'
alias now='date +%s'
alias mm='micromamba'

# Dotfiles management (bare repo)
alias dotfiles='/usr/bin/git --git-dir="$HOME/dotfiles/" --work-tree="$HOME"'

# Helper functions
touchp() {
    mkdir -p "$(dirname "$1")" && touch "$1"
}

# ─── Git Worktree Helpers ─────────────────────────────────────────────────────

# Find the worktree path for a given branch name.
# Prints the path to stdout. Returns 0 if found, 1 if not.
_wt_find_by_branch() {
    local target_branch="$1"
    local current_path=""
    local line
    while IFS= read -r line; do
        if [[ "$line" == worktree\ * ]]; then
            current_path="${line#worktree }"
        elif [[ "$line" == "branch refs/heads/$target_branch" ]]; then
            echo "$current_path"
            return 0
        fi
    done < <(git worktree list --porcelain)
    return 1
}

# Create or open a worktree for a branch and open Cursor
# Usage: wt [--no-cursor] <branch-name>
wt() {
  local open_cursor=true
  local branch=""

  # Parse args
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --no-cursor) open_cursor=false; shift ;;
      *) branch="$1"; shift ;;
    esac
  done

  # If no branch given, use fzf
  if [[ -z "$branch" ]]; then
    branch="$(git branch -a | grep -v '\*' | sed 's/remotes\///' | fzf --preview 'git show --color=always {}' --preview-window=right:70%)"
  fi

  if [[ -z "$branch" ]]; then
    return 1
  fi

  # Remove 'remotes/' prefix if present
  branch="${branch#remotes/}"

  # Fetch latest
  git fetch origin

  local worktree_dir="$PWD/../${branch}"

  # Create branch if needed
  if ! git branch -a | grep -q "^  ${branch}$"; then
    if git branch -a | grep -q "remotes/origin/${branch}"; then
      git branch --track "${branch}" "origin/${branch}"
    else
      git branch "${branch}"
    fi
  fi

  # Create worktree if needed
  if [ ! -d "$worktree_dir" ]; then
    git worktree add "$worktree_dir" "${branch}"
  fi

  # Copy .infisical.json if it exists
  if [ -f "$PWD/.infisical.json" ]; then
    cp "$PWD/.infisical.json" "$worktree_dir/"
  fi

  cd "$worktree_dir"

  # Open editor unless --no-cursor
  if [[ "$open_cursor" == true ]]; then
    cursor .
  fi
}

# Remove a worktree, delete its branch, and open Cursor at the main worktree
# Usage: wtrm [-f] <branch-name>
wtrm() {
    local force=false
    if [[ "$1" == "-f" ]]; then
        force=true
        shift
    fi

    local branch="$1"
    if [[ -z "$branch" ]]; then
        local main_wt_early=$(git worktree list --porcelain | grep '^worktree ' | head -1 | sed 's/^worktree //')
        local main_branch_early=$(git -C "$main_wt_early" symbolic-ref --short HEAD 2>/dev/null)
        branch=$(git worktree list --porcelain \
            | awk '/^branch refs\/heads\//{sub("branch refs/heads/",""); print}' \
            | grep -v "^${main_branch_early}$" \
            | fzf --prompt="Remove worktree> ")
        if [[ -z "$branch" ]]; then
            return 1
        fi
    fi

    local repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -z "$repo_root" ]]; then
        echo "Error: Not in a git repository"
        return 1
    fi

    # Look up the actual worktree path from git
    local wt_path
    wt_path=$(_wt_find_by_branch "$branch")
    if [[ $? -ne 0 || -z "$wt_path" ]]; then
        echo "Error: No worktree found for branch '$branch'"
        return 1
    fi

    # Get main worktree path (for opening after removal)
    local main_wt=$(git worktree list --porcelain | grep '^worktree ' | head -1 | sed 's/^worktree //')

    # Never remove the main worktree
    if [[ "$wt_path" == "$main_wt" ]]; then
        echo "Error: Refusing to remove the main worktree"
        return 1
    fi

    local in_removed_wt=false
    [[ "$repo_root" == "$wt_path" ]] && in_removed_wt=true

    # cd out before removing if we're standing in it
    if $in_removed_wt; then
        cd "$main_wt" || return 1
    fi

    echo "Removing worktree at $wt_path..."
    if $force; then
        git worktree remove --force "$wt_path"
    else
        git worktree remove "$wt_path"
    fi
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to remove worktree (try: wtrm -f $branch)"
        return 1
    fi

    echo "Branch '$branch' kept locally"

    # Clean up leftover directory
    if [[ -d "$wt_path" ]]; then
        read -q "reply?Directory still exists at $wt_path. Remove it? [y/N] "
        echo
        if [[ "$reply" == "y" ]]; then
            rm -rf "$wt_path"
        fi
    fi

    # Open main worktree if we just removed the one we were standing in
    if $in_removed_wt; then
        echo "Opening main worktree..."
        cursor "$main_wt"
    fi
    echo "Done"
}

# List worktrees for current repo
# Usage: wtls
wtls() {
    git worktree list
}
