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

# Create worktree from default branch and open Cursor
# Usage: wt <branch-name>
wt() {
    local branch="$1"
    if [[ -z "$branch" ]]; then
        echo "Usage: wt <branch-name>"
        return 1
    fi

    local repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -z "$repo_root" ]]; then
        echo "Error: Not in a git repository"
        return 1
    fi

    # Get the main worktree (original repo) path to handle being called from within a worktree
    local main_wt=$(git worktree list --porcelain | grep '^worktree ' | head -1 | sed 's/^worktree //')
    local repo_name=$(basename "$main_wt")
    local default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
    default_branch="${default_branch:-master}"

    local dir_name="${branch//\//-}"
    local wt_path="$HOME/workspace/${repo_name}-${dir_name}"

    echo "Fetching latest changes..."
    git fetch origin

    # Check if branch exists locally
    if git show-ref --verify --quiet "refs/heads/$branch"; then
        echo "Branch '$branch' already exists, checking it out..."
        git worktree add "$wt_path" "$branch"
    else
        echo "Creating new branch '$branch' from origin/${default_branch}..."
        git worktree add -b "$branch" "$wt_path" "origin/$default_branch"
    fi

    echo "Opening Cursor..."
    cursor "$wt_path"

    echo "Done: $wt_path"
}

# Remove worktree and delete branch
# Usage: wtrm <branch-name>
wtrm() {
    local branch="$1"
    if [[ -z "$branch" ]]; then
        echo "Usage: wtrm <branch-name>"
        return 1
    fi

    local repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -z "$repo_root" ]]; then
        echo "Error: Not in a git repository"
        return 1
    fi

    # Get the main worktree (original repo) path to handle being called from within a worktree
    local main_wt=$(git worktree list --porcelain | grep '^worktree ' | head -1 | sed 's/^worktree //')
    local repo_name=$(basename "$main_wt")
    local dir_name="${branch//\//-}"
    local wt_path="$HOME/workspace/${repo_name}-${dir_name}"

    if [[ ! -d "$wt_path" ]]; then
        echo "Error: Worktree not found at $wt_path"
        return 1
    fi

    echo "Removing worktree..."
    git worktree remove "$wt_path"

    echo "Deleting branch..."
    git branch -D "$branch" 2>/dev/null || true

    echo "Done"
}

# List worktrees for current repo
# Usage: wtls
wtls() {
    git worktree list
}
