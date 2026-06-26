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
