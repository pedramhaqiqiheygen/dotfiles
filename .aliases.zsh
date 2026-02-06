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

    # Check if a worktree already exists for this branch
    local existing_path
    existing_path=$(_wt_find_by_branch "$branch")
    if [[ $? -eq 0 && -n "$existing_path" ]]; then
        echo "Worktree already exists at $existing_path"
        cursor "$existing_path"
        return 0
    fi

    # Compute path for new worktree
    local main_wt=$(git worktree list --porcelain | grep '^worktree ' | head -1 | sed 's/^worktree //')
    local repo_name=$(basename "$main_wt")
    local default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
    default_branch="${default_branch:-master}"

    local dir_name="${branch//\//-}"
    local wt_path="$HOME/workspace/${repo_name}-${dir_name}"

    echo "Fetching latest changes..."
    git fetch origin

    # Create worktree
    if git show-ref --verify --quiet "refs/heads/$branch"; then
        echo "Branch '$branch' exists, creating worktree..."
        git worktree add "$wt_path" "$branch"
    elif git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
        echo "Remote branch 'origin/$branch' found, creating tracking worktree..."
        git worktree add "$wt_path" "$branch"
    else
        echo "Creating new branch '$branch' from origin/${default_branch}..."
        git worktree add -b "$branch" "$wt_path" "origin/$default_branch"
    fi

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to create worktree"
        return 1
    fi

    echo "Opening Cursor..."
    cursor "$wt_path"
    echo "Done: $wt_path"
}

# Remove a worktree, delete its branch, and open Cursor at the main worktree
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

    # Look up the actual worktree path from git
    local wt_path
    wt_path=$(_wt_find_by_branch "$branch")
    if [[ $? -ne 0 || -z "$wt_path" ]]; then
        echo "Error: No worktree found for branch '$branch'"
        return 1
    fi

    # Get main worktree path (for opening after removal)
    local main_wt=$(git worktree list --porcelain | grep '^worktree ' | head -1 | sed 's/^worktree //')

    echo "Removing worktree at $wt_path..."
    git worktree remove "$wt_path"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to remove worktree (try: git worktree remove --force \"$wt_path\")"
        return 1
    fi

    echo "Deleting branch '$branch'..."
    git branch -D "$branch" 2>/dev/null || true

    # Only open main worktree if we just removed the one we were standing in
    if [[ "$repo_root" == "$wt_path" ]]; then
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
