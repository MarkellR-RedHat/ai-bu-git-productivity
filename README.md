# Git Productivity Toolkit

40+ aliases and functions I actually use every day. `gs` instead of `git status`. `gc "msg"` instead of `git add -A && git commit -m "msg"`. `glog` instead of the 42-character log command nobody remembers.

Three optional git hooks that catch secrets, suggest conventional commits, and block WIP pushes to main.

## Install

```bash
git clone https://github.com/MarkellR-RedHat/ai-bu-git-productivity.git
cd ai-bu-git-productivity
bash install.sh            # detects your shell, backs up configs, asks before changing anything
bash install.sh --preview  # dry run
```

## What You Get

### 1. `gs` instead of `git status`

```bash
# BEFORE:
git status

# AFTER:
gs
main  +2 -0
 M src/auth.py
?? notes.txt
```

Branch, ahead/behind, and changed files at a glance.

### 2. `gc "msg"` instead of `git add -A && git commit -m "msg"`

```bash
# BEFORE:
git add -A
git commit -m "feat: add retry logic"

# AFTER:
gc "feat: add retry logic"
```

### 3. `glog` instead of `git log --oneline --graph --decorate --all`

```bash
# BEFORE:
git log --oneline --graph --decorate --all

# AFTER:
glog
* a1b2c3d (HEAD -> main) feat: add retry logic  (2 hours ago) <Jane>
| * d4e5f6a (feature/dashboard) WIP: layout       (5 hours ago) <Bob>
|/
* 7g8h9i0 fix: auth timeout                       (yesterday) <Jane>
```

### 4. `gpush` instead of the first-push dance

```bash
# BEFORE:
git push
# fatal: The current branch feature/foo has no upstream branch.
git push --set-upstream origin feature/foo

# AFTER:
gpush
```

Sets upstream automatically. No more copying the suggested command.

### 5. `gwip` / `gunwip`

```bash
gwip                   # stages everything, commits as WIP [skip ci]
# switch branches, do other work, come back
gunwip                 # undoes the WIP commit, leaves changes staged
```

### 6. `grebase-main`

```bash
# BEFORE:
git fetch origin main   # or was it master? let me check...
git rebase origin/main

# AFTER:
grebase-main           # auto-detects main vs master, fetches, rebases
```

### 7. `pr-create`

```bash
# BEFORE:
git push -u origin feature/add-auth-retry
gh pr create --title "Add auth retry" --fill

# AFTER:
pr-create              # auto-pushes, generates title from branch name
```

Generates PR title from branch name. `feature/add-auth-retry` becomes "Add auth retry".

### 8. `gdash`

```bash
gdash
========================================
  Git Dashboard
========================================

Branch:  feature/auth-retry
Remote:  origin/feature/auth-retry (ahead 2 / behind 0)

--- Uncommitted Changes ---
  M src/client.py

--- Recent Commits (last 5) ---
  a1b2c3d feat: add retry logic        (2 hours ago)
  d4e5f6a refactor: extract auth module (yesterday)

--- Open PRs (this repo) ---
  #12  Add retry logic  feature/auth-retry  OPEN
========================================
```

### 9. `gundo`

```bash
gundo
Undoing commit: feat: add retry logic
Changes are back in staging. Nothing was lost.
```

### 10. `gfind` / `gwho`

```bash
gfind "retry"          # search commit messages across all branches
gwho src/auth.py       # who changed this file the most?
gwhen src/auth.py 42   # who last touched line 42?
```

## Full Command Reference

### Every 5 Minutes

| Command | What it does | Keystrokes saved |
|---------|-------------|-----------------|
| `gs` | Status with branch info and ahead/behind | 8 per use |
| `ga` / `gaa` | `git add` / `git add -A` | 5-8 per use |
| `gd` / `gds` | `git diff` / `git diff --staged` | 6-12 per use |
| `gc "msg"` | Stage all + commit in one shot | 25 per use |
| `gpush` | Push + set upstream automatically | 30+ per use |
| `gpull` | Pull with rebase | 12 per use |
| `gco [branch]` | Checkout (fzf picker if no arg given) | 8 per use |
| `gcb <name>` | Create and switch to new branch | 10 per use |

### Every Hour

| Command | What it does |
|---------|-------------|
| `glog` | One-line log with graph, colors, relative dates |
| `glog1` | Condensed log, last 20 commits, no graph |
| `gamend` | Amend last commit, keep message |
| `gamend-msg` | Amend last commit, edit message |
| `gap` | Stage hunks interactively (patch mode) |
| `gstash [msg]` | Stash everything including untracked files |
| `gstash-pop` | Pop the most recent stash |
| `gstash-ls` | List stashes with clean formatting |
| `grebase-main` | Fetch + rebase onto main/master (auto-detects) |
| `gfetch` | Fetch all remotes, prune stale branches |

### Several Times a Day

| Command | What it does |
|---------|-------------|
| `gwip` | Quick WIP commit (warns on main, skips CI) |
| `gunwip` | Undo the last WIP commit |
| `gundo` | Undo last commit, keep changes staged |
| `gtoday` | Your commits from today (great for standups) |
| `gweek` | Your commits from the past week |
| `gdiff-words` | Word-level diff (great for prose and config) |
| `gdiff-staged` | Show staged changes |
| `gdiff-last` | Diff of the last commit |
| `gchanged [N]` | Files changed in the last N commits |

### PR Workflow

| Command | What it does |
|---------|-------------|
| `pr-create` | Create PR, auto-fill title from branch name |
| `pr-draft` | Create a draft PR |
| `pr-ready [reviewers]` | Mark draft as ready, request reviewers |
| `pr-cleanup` | Delete merged branches locally and remotely |
| `pr-stack` | Your open PRs with review status |
| `pr-checkout <num>` | Check out a PR branch by number |
| `pr-diff [num]` | View PR diff in terminal |
| `greview` | PRs waiting for your review |

### Investigation

| Command | What it does |
|---------|-------------|
| `gwho <file>` | Who changed this file most (by commit count) |
| `gwhen <file> [line]` | When was this file/line last changed |
| `gfind <string>` | Search commit messages across all branches |
| `gfind-code <string>` | Search diffs for when code was added/removed |
| `gdiff-stat [branch]` | File-level diff stats vs default branch |
| `gcontrib` | Your stats: commits, lines added/removed, files |

### Team

| Command | What it does |
|---------|-------------|
| `gteam` | Active branches with last commit and author |
| `gstale [days]` | Branches with no commits in N+ days (default 14) |
| `gleaderboard [days]` | Commit leaderboard for the last N days |
| `gdash` | Full repo dashboard in one command |

### Cleanup

| Command | What it does |
|---------|-------------|
| `gclean` | Delete merged local branches (with confirmation) |
| `gclean-files` | Remove untracked files (with confirmation) |
| `greset-hard` | Reset branch to match remote (with confirmation) |

### Single-Letter Shortcuts

| Shortcut | Expands to |
|----------|-----------|
| `ga` | `git add` |
| `gaa` | `git add -A` |
| `gd` | `git diff` |
| `gds` | `git diff --staged` |
| `gb` | `git branch` |
| `gba` | `git branch -a` |
| `gm` | `git merge` |
| `grb` | `git rebase` |
| `grs` | `git restore` |

## Git Config Extras

Sane defaults that most engineers should have. The installer adds these to your
global config, or do it manually:

```bash
git config --global include.path /path/to/ai-bu-git-productivity/gitconfig-extras
```

What it sets:
- `diff.algorithm = histogram` -- cleaner diffs
- `merge.conflictstyle = zdiff3` -- better conflict markers
- `rebase.autoStash = true` -- no more "stash before rebase"
- `push.autoSetupRemote = true` -- no more "no upstream" error
- `rerere.enabled = true` -- remembers conflict resolutions
- `core.fsmonitor = true` -- faster status on large repos

## Hooks

Optional, per-repo. Bypass any hook with `--no-verify`.

- **pre-commit** -- Blocks `.env` files, large files, conflict markers, secrets, debug statements. Warns on TODOs and trailing whitespace.
- **commit-msg** -- Suggests conventional commit format based on staged files. Never blocks.
- **pre-push** -- Warns on uncommitted changes. Blocks WIP commits to main/master.

## Workflows

See [workflows.md](workflows.md) for copy-paste commands: fix a prod bug, undo a push to main, resolve rebase conflicts, prep for standup, etc.

## Requirements

- Git 2.x+
- Bash or Zsh (fish works via [bass](https://github.com/edc/bass))
- [gh CLI](https://cli.github.com) (optional, for PR commands)
- [fzf](https://github.com/junegunn/fzf) (optional, for `gco` branch picker)

## License

MIT
