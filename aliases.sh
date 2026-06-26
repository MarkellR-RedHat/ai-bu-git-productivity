#!/usr/bin/env bash
# ai-bu-git-productivity/aliases.sh
# A comprehensive git productivity toolkit for engineers who live in the terminal.
# Source this file from your .zshrc or .bashrc:
#   source /path/to/ai-bu-git-productivity/aliases.sh
#
# Every alias and function here is built to save real keystrokes on tasks
# you do multiple times a day. Organized by workflow so you can find what
# you need fast.

# =============================================================================
# INTERNAL HELPERS (not meant to be called directly)
# =============================================================================

# Auto-detect the default branch name (main vs master vs something else)
_git_default_branch() {
  local branch
  branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||')
  if [ -n "$branch" ]; then
    echo "$branch"
    return
  fi
  # Fallback: check common names on origin
  if git rev-parse --verify origin/main &>/dev/null; then
    echo "main"
  elif git rev-parse --verify origin/master &>/dev/null; then
    echo "master"
  else
    # Last resort: check local branches
    if git rev-parse --verify main &>/dev/null; then
      echo "main"
    elif git rev-parse --verify master &>/dev/null; then
      echo "master"
    else
      echo "main"
    fi
  fi
}

# Check if gh CLI is available (shared guard for PR functions)
_require_gh() {
  if ! command -v gh &>/dev/null; then
    echo "Error: gh cli is not installed. Get it at https://cli.github.com"
    return 1
  fi
}

# Check if inside a git repo
_require_git_repo() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
    echo "Error: not inside a git repository."
    return 1
  fi
}

# =============================================================================
# DAILY WORKFLOW - The commands you'll use every single day
# =============================================================================

# Show git status with branch info and ahead/behind count
gs() {
  _require_git_repo || return 1
  git status -sb "$@"
}

# Beautiful one-line log with colors, graph, and relative dates
alias glog='git log --oneline --graph --decorate --all --color --format="%C(yellow)%h%C(auto)%d %C(reset)%s %C(cyan)(%cr) %C(blue)<%an>"'

# Condensed log: just hashes, messages, and dates (no graph)
alias glog1='git log --oneline --format="%C(yellow)%h %C(reset)%s %C(cyan)(%cr)" -20'

# What did I commit today? Great for standups.
gtoday() {
  _require_git_repo || return 1
  local author
  author=$(git config user.name)
  if [ -z "$author" ]; then
    echo "Error: git user.name is not set."
    return 1
  fi
  echo "Commits by $author today:"
  echo ""
  git log --all --author="$author" --since="midnight" \
    --format="%C(yellow)%h %C(cyan)%ad %C(reset)%s" \
    --date=short
}

# What did I commit this week? Useful for weekly updates.
gweek() {
  _require_git_repo || return 1
  local author
  author=$(git config user.name)
  if [ -z "$author" ]; then
    echo "Error: git user.name is not set."
    return 1
  fi
  echo "Commits by $author this week:"
  echo ""
  git log --all --author="$author" --since="1 week ago" \
    --format="%C(yellow)%h %C(cyan)%ad %C(reset)%s %C(green)(%D)" \
    --date=short
}

# Stage all changes and commit with a message in one shot
gc() {
  if [ -z "$1" ]; then
    echo "Usage: gc \"your commit message\""
    return 1
  fi
  git add -A && git commit -m "$*"
}

# Quick WIP commit: stage everything and commit as WIP (skips CI)
gwip() {
  _require_git_repo || return 1
  git add -A && git commit -m "WIP: work in progress [skip ci]"
}

# Undo the last WIP commit, keeping changes staged
gunwip() {
  _require_git_repo || return 1
  local last_msg
  last_msg=$(git log -1 --format='%s' 2>/dev/null)
  if [[ "$last_msg" == WIP:* ]]; then
    git reset --soft HEAD~1
    echo "WIP commit removed. Changes are staged and ready."
  else
    echo "Last commit is not a WIP commit: $last_msg"
    return 1
  fi
}

# Safely undo the last commit, keeping all changes staged
gundo() {
  _require_git_repo || return 1
  local last_msg
  last_msg=$(git log -1 --format='%s' 2>/dev/null)
  if [ -z "$last_msg" ]; then
    echo "Error: no commits to undo."
    return 1
  fi
  echo "Undoing commit: $last_msg"
  git reset --soft HEAD~1
  echo "Changes are back in staging. Nothing was lost."
}

# Amend the last commit with any new staged changes (keeps original message)
alias gamend='git commit --amend --no-edit'

# Amend the last commit and edit the message too
alias gamend-msg='git commit --amend'

# Stage specific files interactively with patch mode
alias gap='git add -p'

# Stash everything including untracked files, with a description
gstash() {
  local msg="${1:-}"
  if [ -n "$msg" ]; then
    git stash push --include-untracked -m "$msg"
  else
    git stash push --include-untracked
  fi
}

# Pop the most recent stash
alias gstash-pop='git stash pop'

# List all stashes with a clean format
alias gstash-ls='git stash list --format="%C(yellow)%gd %C(reset)%s %C(cyan)(%cr)"'

# Fetch and rebase on main/master (auto-detects default branch)
grebase-main() {
  _require_git_repo || return 1
  local default_branch
  default_branch=$(_git_default_branch)
  local current_branch
  current_branch=$(git branch --show-current)
  if [ "$current_branch" = "$default_branch" ]; then
    echo "You are already on $default_branch. Pulling latest changes."
    git pull --rebase
    return
  fi
  echo "Fetching origin and rebasing $current_branch onto origin/$default_branch..."
  git fetch origin "$default_branch"
  git rebase "origin/$default_branch"
  echo "Rebase complete."
}

# Quickly switch to a branch with fuzzy matching (uses fzf if available)
gco() {
  _require_git_repo || return 1
  if [ -n "$1" ]; then
    git checkout "$@"
    return
  fi
  # If fzf is available, use it for interactive branch selection
  if command -v fzf &>/dev/null; then
    local branch
    branch=$(git branch --all --format='%(refname:short)' | fzf --height 40% --reverse --prompt="Switch to branch: ")
    if [ -n "$branch" ]; then
      # Strip the "origin/" prefix for remote branches
      branch="${branch#origin/}"
      git checkout "$branch"
    fi
  else
    echo "Usage: gco <branch-name>"
    echo "Tip: install fzf for interactive branch selection"
    return 1
  fi
}

# Create a new branch and switch to it
gcb() {
  if [ -z "$1" ]; then
    echo "Usage: gcb <branch-name>"
    return 1
  fi
  git checkout -b "$@"
}

# Push current branch and set upstream in one command
gpush() {
  _require_git_repo || return 1
  local branch
  branch=$(git branch --show-current)
  git push -u origin "$branch" "$@"
}

# Pull with rebase (cleaner than merge commits)
alias gpull='git pull --rebase'

# Fetch all remotes and prune stale tracking branches
alias gfetch='git fetch --all --prune'

# Show files changed in the last N commits
gchanged() {
  _require_git_repo || return 1
  local count="${1:-5}"
  echo "Files changed in the last $count commit(s):"
  echo ""
  git diff --name-only HEAD~"$count" HEAD 2>/dev/null || \
    git diff --name-only "$(git rev-list --max-parents=0 HEAD)" HEAD
}

# Open the current repo in your browser
gopen() {
  _require_git_repo || return 1
  local url
  url=$(git remote get-url origin 2>/dev/null)
  if [ -z "$url" ]; then
    echo "Error: no origin remote found."
    return 1
  fi
  # Convert SSH URLs to HTTPS
  url=$(echo "$url" | sed -E 's|^git@([^:]+):|https://\1/|' | sed 's|\.git$||')
  echo "Opening $url"
  if command -v xdg-open &>/dev/null; then
    xdg-open "$url"
  elif command -v open &>/dev/null; then
    open "$url"
  elif command -v wslview &>/dev/null; then
    wslview "$url"
  else
    echo "Could not detect a browser opener. Visit the URL above manually."
  fi
}

# =============================================================================
# PR WORKFLOW - From branch creation to merge
# =============================================================================

# Create a PR with a title auto-filled from the branch name
pr-create() {
  _require_gh || return 1
  _require_git_repo || return 1
  local branch title
  branch=$(git branch --show-current)

  # Auto-generate title from branch name: feature/add-auth-retry -> Add auth retry
  if [ -n "$1" ]; then
    title="$*"
  else
    title=$(echo "$branch" | sed -E 's|^(feature|fix|bugfix|hotfix|chore|docs)/||' | tr '-' ' ' | tr '_' ' ')
    # Capitalize first letter
    title="$(echo "${title:0:1}" | tr '[:lower:]' '[:upper:]')${title:1}"
    echo "Auto-generated title: $title"
    printf "Use this title? [Y/n] "
    read -r answer
    if [[ "${answer:-Y}" =~ ^[Nn]$ ]]; then
      printf "Enter PR title: "
      read -r title
    fi
  fi

  # Push branch if not yet pushed
  if ! git rev-parse --verify "origin/$branch" &>/dev/null; then
    echo "Pushing $branch to origin..."
    git push -u origin "$branch"
  fi

  gh pr create --title "$title" --fill
}

# Create a draft PR (for early feedback before it is ready)
pr-draft() {
  _require_gh || return 1
  _require_git_repo || return 1
  local branch title
  branch=$(git branch --show-current)

  if [ -n "$1" ]; then
    title="$*"
  else
    title=$(echo "$branch" | sed -E 's|^(feature|fix|bugfix|hotfix|chore|docs)/||' | tr '-' ' ' | tr '_' ' ')
    title="$(echo "${title:0:1}" | tr '[:lower:]' '[:upper:]')${title:1}"
  fi

  if ! git rev-parse --verify "origin/$branch" &>/dev/null; then
    echo "Pushing $branch to origin..."
    git push -u origin "$branch"
  fi

  gh pr create --title "$title" --fill --draft
}

# Mark a draft PR as ready for review and optionally request reviewers
pr-ready() {
  _require_gh || return 1
  _require_git_repo || return 1
  echo "Marking PR as ready for review..."
  gh pr ready

  if [ -n "$1" ]; then
    echo "Requesting review from: $*"
    gh pr edit --add-reviewer "$@"
  else
    echo "PR is ready. Add reviewers with: gh pr edit --add-reviewer <user>"
  fi
}

# Delete local and remote branches that have been merged
pr-cleanup() {
  _require_git_repo || return 1
  local default_branch
  default_branch=$(_git_default_branch)

  echo "Switching to $default_branch and pulling latest..."
  git checkout "$default_branch"
  git pull --rebase

  # Find merged branches (excluding default and develop)
  local merged
  merged=$(git branch --merged | grep -v '^\*' | grep -vE "^\s*(${default_branch}|develop|staging)$" || true)

  if [ -z "$merged" ]; then
    echo "No merged branches to clean up. You are tidy."
    return 0
  fi

  echo ""
  echo "Merged branches that can be deleted:"
  echo "$merged"
  echo ""
  printf "Delete these local branches? [y/N] "
  read -r confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "$merged" | xargs git branch -d
    echo "Local branches cleaned up."
  else
    echo "Cancelled."
    return 0
  fi

  # Optionally clean up remote branches too
  echo ""
  printf "Also delete these branches from origin? [y/N] "
  read -r confirm_remote
  if [[ "$confirm_remote" =~ ^[Yy]$ ]]; then
    echo "$merged" | while IFS= read -r branch; do
      branch=$(echo "$branch" | xargs)  # trim whitespace
      if git ls-remote --exit-code --heads origin "$branch" &>/dev/null; then
        git push origin --delete "$branch"
        echo "  Deleted origin/$branch"
      fi
    done
    echo "Remote branches cleaned up."
  fi
}

# Show your stack of PRs with their status
pr-stack() {
  _require_gh || return 1
  _require_git_repo || return 1
  local author
  author=$(gh api user --jq '.login' 2>/dev/null)
  if [ -z "$author" ]; then
    echo "Error: could not determine your GitHub username."
    return 1
  fi
  echo "Your open PRs:"
  echo ""
  gh pr list --author "$author" --state open --json number,title,headRefName,state,isDraft,reviewDecision \
    --template '{{range .}}#{{.number}} {{if .isDraft}}[DRAFT] {{end}}{{.title}}
  Branch: {{.headRefName}}
  Review: {{if .reviewDecision}}{{.reviewDecision}}{{else}}pending{{end}}
{{end}}'
}

# List PRs that need your review
greview() {
  _require_gh || return 1
  echo "PRs waiting for your review:"
  echo ""
  gh pr list --search "review-requested:@me" --limit 25
}

# Quickly check out a PR branch by PR number
pr-checkout() {
  _require_gh || return 1
  if [ -z "$1" ]; then
    echo "Usage: pr-checkout <pr-number>"
    return 1
  fi
  gh pr checkout "$1"
}

# View PR diff in the terminal
pr-diff() {
  _require_gh || return 1
  local pr="${1:-}"
  if [ -n "$pr" ]; then
    gh pr diff "$pr"
  else
    gh pr diff
  fi
}

# =============================================================================
# INVESTIGATION - Figure out what happened and who did it
# =============================================================================

# Who changed this file the most? Shows top contributors by commit count.
gwho() {
  _require_git_repo || return 1
  local file="${1:-}"
  if [ -z "$file" ]; then
    echo "Usage: gwho <file>"
    return 1
  fi
  if [ ! -f "$file" ]; then
    echo "Error: file '$file' not found."
    return 1
  fi
  echo "Top contributors to $file:"
  echo ""
  git log --format='%aN' -- "$file" | sort | uniq -c | sort -rn | head -10
}

# When was this line last changed? Formatted blame with age coloring.
gwhen() {
  _require_git_repo || return 1
  local file="${1:-}"
  if [ -z "$file" ]; then
    echo "Usage: gwhen <file> [line-number]"
    return 1
  fi
  if [ ! -f "$file" ]; then
    echo "Error: file '$file' not found."
    return 1
  fi
  if [ -n "${2:-}" ]; then
    # Blame a specific line range
    git blame -L "$2","$2" --date=relative "$file"
  else
    git blame --date=relative "$file"
  fi
}

# Search commit messages for a string across all branches
gfind() {
  _require_git_repo || return 1
  local keyword="${1:-}"
  if [ -z "$keyword" ]; then
    echo "Usage: gfind <keyword>"
    return 1
  fi
  echo "Commits matching \"$keyword\":"
  echo ""
  git log --all --oneline --grep="$keyword" --format="%C(yellow)%h %C(reset)%s %C(cyan)(%cr) %C(blue)<%an>"
}

# Search the actual code diff history for a string (finds when code was added/removed)
gfind-code() {
  _require_git_repo || return 1
  local keyword="${1:-}"
  if [ -z "$keyword" ]; then
    echo "Usage: gfind-code <string>"
    echo "Searches commit diffs for when a string was added or removed."
    return 1
  fi
  echo "Commits where \"$keyword\" was added or removed:"
  echo ""
  git log --all -p -S "$keyword" --format="%C(yellow)%h %C(reset)%s %C(cyan)(%cr) %C(blue)<%an>" -- | \
    grep -v '^[+-]' | head -30
}

# Word-level diff instead of line-level (great for prose and config files)
alias gdiff-words='git diff --word-diff=color'

# Word-level diff for staged changes
alias gdiff-words-staged='git diff --staged --word-diff=color'

# File-level diff stats for a branch vs the default branch
gdiff-stat() {
  _require_git_repo || return 1
  local branch="${1:-HEAD}"
  local base="${2:-$(_git_default_branch)}"
  echo "Diff stats for $branch vs $base:"
  echo ""
  git diff --stat "$base"..."$branch"
}

# Show what changed between two commits or refs
alias gdiff-staged='git diff --staged'

# Show the full diff of the last commit
alias gdiff-last='git diff HEAD~1 HEAD'

# Contribution stats for the current repo
gcontrib() {
  _require_git_repo || return 1
  local author
  author=$(git config user.name)
  if [ -z "$author" ]; then
    echo "Error: git user.name is not set."
    return 1
  fi
  echo "Contribution stats for $author:"
  echo ""
  local commits
  commits=$(git rev-list --author="$author" --count HEAD 2>/dev/null || echo 0)
  echo "  Commits:  $commits"
  local stats
  stats=$(git log --author="$author" --pretty=tformat: --numstat 2>/dev/null |
    awk '{ added += $1; removed += $2; files++ } END { printf "%d %d %d", added, removed, files }')
  local added removed files
  added=$(echo "$stats" | cut -d' ' -f1)
  removed=$(echo "$stats" | cut -d' ' -f2)
  files=$(echo "$stats" | cut -d' ' -f3)
  echo "  Added:    +${added:-0} lines"
  echo "  Removed:  -${removed:-0} lines"
  echo "  Files:    ${files:-0} touched"
}

# Cherry-pick with conflict resolution hints
gcp() {
  _require_git_repo || return 1
  if [ -z "$1" ]; then
    echo "Usage: gcp <commit-hash> [commit-hash...]"
    return 1
  fi
  for commit in "$@"; do
    echo "Cherry-picking $commit..."
    if ! git cherry-pick "$commit"; then
      echo ""
      echo "Conflict detected. Here is what to do:"
      echo "  1. Fix the conflicts in the files listed above"
      echo "  2. Stage the resolved files:  git add <file>"
      echo "  3. Continue the cherry-pick:  git cherry-pick --continue"
      echo "  4. Or abort entirely:         git cherry-pick --abort"
      echo ""
      echo "Files with conflicts:"
      git diff --name-only --diff-filter=U
      return 1
    fi
  done
  echo "Cherry-pick complete."
}

# =============================================================================
# TEAM COLLABORATION - See what everyone is working on
# =============================================================================

# What is everyone working on? Shows open branches and their last commit.
gteam() {
  _require_git_repo || return 1
  echo "Active branches (by most recent commit):"
  echo ""
  git fetch --all --prune --quiet 2>/dev/null
  git for-each-ref --sort=-committerdate refs/remotes/origin/ \
    --format='%(color:cyan)%(committerdate:relative)%(color:reset) %(color:yellow)%(refname:short)%(color:reset) %(color:blue)%(authorname)%(color:reset) %(subject)' \
    --count=20 | grep -v 'origin/HEAD'
}

# Find stale branches with no commits in 2+ weeks
gstale() {
  _require_git_repo || return 1
  local days="${1:-14}"
  local cutoff
  cutoff=$(date -v-"${days}"d +%s 2>/dev/null || date -d "${days} days ago" +%s 2>/dev/null)
  if [ -z "$cutoff" ]; then
    echo "Error: could not compute date cutoff."
    return 1
  fi
  echo "Branches with no commits in the last $days days:"
  echo ""
  local found=0
  git for-each-ref --sort=committerdate refs/heads/ \
    --format='%(committerdate:unix) %(committerdate:relative) %(refname:short)' |
  while read -r ts date_info branch; do
    if [ "$ts" -lt "$cutoff" ]; then
      printf "  %-30s %s\n" "$branch" "($date_info)"
      found=1
    fi
  done
  if [ "$found" -eq 0 ]; then
    echo "  No stale branches found. Nice."
  fi
}

# Show a leaderboard of who committed the most in the last 30 days
gleaderboard() {
  _require_git_repo || return 1
  local days="${1:-30}"
  echo "Commit leaderboard (last $days days):"
  echo ""
  git shortlog -sn --since="${days} days ago" --all | head -15
}

# =============================================================================
# DASHBOARD - Full repo overview in one command
# =============================================================================

# Git dashboard: a snapshot of your entire repo state
gdash() {
  _require_git_repo || return 1
  echo "========================================"
  echo "  Git Dashboard"
  echo "========================================"
  echo ""

  # Current branch
  local branch
  branch=$(git branch --show-current 2>/dev/null)
  if [ -z "$branch" ]; then
    branch="(detached HEAD)"
  fi
  echo "Branch:  $branch"

  # Ahead/behind status
  local upstream
  upstream=$(git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
  if [ -n "$upstream" ]; then
    local ahead behind
    ahead=$(git rev-list --count '@{upstream}'..HEAD 2>/dev/null || echo 0)
    behind=$(git rev-list --count 'HEAD..@{upstream}' 2>/dev/null || echo 0)
    echo "Remote:  $upstream (ahead $ahead / behind $behind)"
  else
    echo "Remote:  no upstream configured"
  fi
  echo ""

  # Uncommitted changes
  echo "--- Uncommitted Changes ---"
  local status_output
  status_output=$(git status --short 2>/dev/null)
  if [ -z "$status_output" ]; then
    echo "  Working tree clean."
  else
    echo "$status_output" | while IFS= read -r line; do
      echo "  $line"
    done
  fi
  echo ""

  # Stash count
  local stash_count
  stash_count=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
  if [ "$stash_count" -gt 0 ]; then
    echo "--- Stashes: $stash_count ---"
    git stash list --format="  %gd: %s" | head -3
    echo ""
  fi

  # Recent commits
  echo "--- Recent Commits (last 5) ---"
  git log --oneline -5 --format="  %C(yellow)%h %C(reset)%s %C(cyan)(%cr)" 2>/dev/null
  echo ""

  # Open PRs (only if gh is available)
  if command -v gh &>/dev/null; then
    echo "--- Open PRs (this repo) ---"
    local prs
    prs=$(gh pr list --limit 5 --state open 2>/dev/null)
    if [ -z "$prs" ]; then
      echo "  No open PRs."
    else
      echo "$prs" | while IFS= read -r line; do
        echo "  $line"
      done
    fi
  else
    echo "--- Open PRs ---"
    echo "  Install gh cli to see open PRs here."
  fi
  echo ""
  echo "========================================"
}

# =============================================================================
# CLEANUP - Keep your repo tidy
# =============================================================================

# Delete local branches that have been merged (with confirmation)
gclean() {
  _require_git_repo || return 1
  local default_branch
  default_branch=$(_git_default_branch)

  local branches
  branches=$(git branch --merged | grep -v '^\*' | grep -vE "^\s*(${default_branch}|develop|staging)$")
  if [ -z "$branches" ]; then
    echo "No merged branches to clean up."
    return 0
  fi
  echo "The following merged branches will be deleted:"
  echo "$branches"
  echo ""
  printf "Proceed? [y/N] "
  read -r confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "$branches" | xargs git branch -d
    echo "Done."
  else
    echo "Cancelled."
  fi
}

# Nuke all untracked files and directories (with confirmation)
gclean-files() {
  _require_git_repo || return 1
  echo "Untracked files that would be removed:"
  git clean -fdn
  echo ""
  printf "Remove all of these? [y/N] "
  read -r confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    git clean -fd
    echo "Cleaned."
  else
    echo "Cancelled."
  fi
}

# Reset current branch to match the remote exactly (with confirmation)
greset-hard() {
  _require_git_repo || return 1
  local branch
  branch=$(git branch --show-current)
  local upstream
  upstream=$(git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
  if [ -z "$upstream" ]; then
    echo "Error: no upstream branch configured for $branch."
    return 1
  fi
  echo "WARNING: This will discard ALL local changes on $branch"
  echo "and reset to match $upstream exactly."
  echo ""
  printf "Are you sure? [y/N] "
  read -r confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    git fetch origin
    git reset --hard "$upstream"
    echo "Reset complete. $branch now matches $upstream."
  else
    echo "Cancelled."
  fi
}

# =============================================================================
# QUICK SHORTCUTS - Common operations in fewer keystrokes
# =============================================================================

# Short aliases for the stuff you type a hundred times a day
alias ga='git add'
alias gaa='git add -A'
alias gd='git diff'
alias gds='git diff --staged'
alias gb='git branch'
alias gba='git branch -a'
alias gm='git merge'
alias gcp-continue='git cherry-pick --continue'
alias gcp-abort='git cherry-pick --abort'
alias grb='git rebase'
alias grb-continue='git rebase --continue'
alias grb-abort='git rebase --abort'
alias grs='git restore'
alias grs-staged='git restore --staged'
