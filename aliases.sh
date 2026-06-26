#!/usr/bin/env bash
# ai-bu-git-productivity/aliases.sh
# Shell aliases and functions to speed up daily git workflows.
# Source this file from your .zshrc or .bashrc:
#   source /path/to/ai-bu-git-productivity/aliases.sh

# ─── Pretty git log with graph ───────────────────────────────────────────────
alias glog='git log --oneline --graph --decorate --all'

# ─── What did I commit this week (across all branches) ───────────────────────
gweek() {
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

# ─── Find branches older than 30 days ────────────────────────────────────────
gstale() {
  local cutoff
  cutoff=$(date -v-30d +%s 2>/dev/null || date -d "30 days ago" +%s 2>/dev/null)
  if [ -z "$cutoff" ]; then
    echo "Error: could not compute date cutoff."
    return 1
  fi
  echo "Local branches with no commits in the last 30 days:"
  echo ""
  git for-each-ref --sort=committerdate refs/heads/ \
    --format='%(committerdate:unix) %(committerdate:short) %(refname:short)' |
  while read -r ts date branch; do
    if [ "$ts" -lt "$cutoff" ]; then
      echo "  $date  $branch"
    fi
  done
}

# ─── Delete merged local branches (with confirmation) ────────────────────────
gclean() {
  local branches
  branches=$(git branch --merged | grep -v '^\*' | grep -vE '^\s*(main|master|develop)$')
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

# ─── Quick PR creation with gh cli ───────────────────────────────────────────
gpr() {
  if ! command -v gh &>/dev/null; then
    echo "Error: gh cli is not installed. Install it from https://cli.github.com"
    return 1
  fi
  local title="${1:-}"
  if [ -z "$title" ]; then
    printf "PR title: "
    read -r title
  fi
  gh pr create --title "$title" --fill
}

# ─── List PRs assigned to you for review ─────────────────────────────────────
greview() {
  if ! command -v gh &>/dev/null; then
    echo "Error: gh cli is not installed. Install it from https://cli.github.com"
    return 1
  fi
  echo "PRs waiting for your review:"
  echo ""
  gh pr list --search "review-requested:@me" --limit 25
}

# ─── Who touched this file the most ──────────────────────────────────────────
gblame-who() {
  local file="${1:-}"
  if [ -z "$file" ]; then
    echo "Usage: gblame-who <file>"
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

# ─── File-level diff stats for a branch vs main ──────────────────────────────
gdiff-stat() {
  local branch="${1:-HEAD}"
  local base="${2:-main}"
  echo "Diff stats for $branch vs $base:"
  echo ""
  git diff --stat "$base"..."$branch"
}

# ─── Safely undo the last commit (keeps changes staged) ──────────────────────
gundo() {
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

# ─── Quick work-in-progress commit ───────────────────────────────────────────
gwip() {
  git add -A && git commit -m "WIP: work in progress [skip ci]"
}

# ─── Undo the last WIP commit ────────────────────────────────────────────────
gunwip() {
  local last_msg
  last_msg=$(git log -1 --format='%s' 2>/dev/null)
  if [[ "$last_msg" == WIP:* ]]; then
    git reset --soft HEAD~1
    echo "WIP commit removed. Changes are staged."
  else
    echo "Last commit is not a WIP commit: $last_msg"
    return 1
  fi
}

# ─── Contribution stats for the current repo ─────────────────────────────────
gcontrib() {
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

# ─── Search commit messages by keyword ────────────────────────────────────────
gfind() {
  local keyword="${1:-}"
  if [ -z "$keyword" ]; then
    echo "Usage: gfind <keyword>"
    return 1
  fi
  echo "Commits matching \"$keyword\":"
  echo ""
  git log --all --oneline --grep="$keyword"
}

# ─── Show files changed in the last N commits ────────────────────────────────
gchanged() {
  local count="${1:-5}"
  echo "Files changed in the last $count commit(s):"
  echo ""
  git diff --name-only HEAD~"$count" HEAD 2>/dev/null || \
    git diff --name-only "$(git rev-list --max-parents=0 HEAD)" HEAD
}

# ─── What you committed today ────────────────────────────────────────────────
gtoday() {
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

# ─── Fetch and rebase on main/master (auto-detects default branch) ────────────
grebase-main() {
  local default_branch
  default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||')
  if [ -z "$default_branch" ]; then
    # Fallback: check if main or master exists on origin
    if git rev-parse --verify origin/main &>/dev/null; then
      default_branch="main"
    elif git rev-parse --verify origin/master &>/dev/null; then
      default_branch="master"
    else
      echo "Error: could not detect default branch. Neither main nor master found on origin."
      return 1
    fi
  fi
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

# ─── Open current repo in the browser ────────────────────────────────────────
gopen() {
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

# ─── Git dashboard: a snapshot of your repo state ────────────────────────────
gdash() {
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

  # Recent commits
  echo "--- Recent Commits (last 5) ---"
  git log --oneline -5 2>/dev/null | while IFS= read -r line; do
    echo "  $line"
  done
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
