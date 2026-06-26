# Git Productivity Toolkit

You type `git status` 30 times a day. That is 300 keystrokes. `gs` does the same thing in 2.

You type `git add -A && git commit -m "message"` 15 times a day. That is 525 keystrokes. `gc "message"` does it in 14.

You type `git log --oneline --graph --decorate --all` to see the branch graph. That is 42 keystrokes. `glog` does it in 4.

**Estimated keystrokes saved per day: 1,500+**

That is 30 minutes per week you get back just from shorter commands, better output, and fewer mistakes.

## Quick Start

```bash
git clone https://github.com/MarkellR-RedHat/ai-bu-git-productivity.git
cd ai-bu-git-productivity
bash install.sh            # interactive: picks your shell, backs up configs
bash install.sh --preview  # see what would be installed without changing anything
```

## Top 10 Aliases: Before and After

### 1. `gs` instead of `git status` (saves 8 keystrokes, 30x/day)

```bash
# BEFORE:
git status

# AFTER:
gs
main  +2 -0
 M src/auth.py
?? notes.txt
```

Shows your branch name, how far ahead/behind you are, and changed files in a clean format.

### 2. `gc "msg"` instead of `git add -A && git commit -m "msg"` (saves 25 keystrokes, 15x/day)

```bash
# BEFORE:
git add -A
git commit -m "feat: add retry logic"

# AFTER:
gc "feat: add retry logic"
```

Stages everything and commits in one shot.

### 3. `glog` instead of `git log --oneline --graph --decorate --all` (saves 38 keystrokes)

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

Color-coded graph with relative dates and author names.

### 4. `gpush` instead of the first-push dance (saves 30+ keystrokes)

```bash
# BEFORE:
git push
# fatal: The current branch feature/foo has no upstream branch.
git push --set-upstream origin feature/foo

# AFTER:
gpush
```

Pushes and sets upstream automatically. No more copying the suggested command.

### 5. `gwip` / `gunwip` for saving work fast

```bash
gwip                   # stages everything, commits as WIP [skip ci]
# switch branches, do other work, come back
gunwip                 # undoes the WIP commit, leaves changes staged
```

Warns you if you try to WIP on main. Pairs with `gunwip` to pick up where you left off.

### 6. `grebase-main` instead of the fetch-and-rebase dance

```bash
# BEFORE:
git fetch origin main   # or was it master? let me check...
git rebase origin/main

# AFTER:
grebase-main           # auto-detects main vs master, fetches, rebases
```

### 7. `pr-create` for pull requests

```bash
# BEFORE:
git push -u origin feature/add-auth-retry
gh pr create --title "Add auth retry" --fill

# AFTER:
pr-create              # auto-pushes, generates title from branch name
```

Branch name `feature/add-auth-retry` becomes PR title "Add auth retry" automatically.

### 8. `gdash` for a full repo snapshot

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

### 9. `gundo` to safely undo a commit

```bash
gundo
Undoing commit: feat: add retry logic
Changes are back in staging. Nothing was lost.
```

Soft-resets the last commit. All your changes stay staged.

### 10. `gfind` / `gwho` to investigate history

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

The `gitconfig-extras` file includes settings most engineers should have but few
know about. The installer adds it to your global config, or you can do it manually:

```bash
git config --global include.path /path/to/ai-bu-git-productivity/gitconfig-extras
```

Highlights:
- `diff.algorithm = histogram` for cleaner diffs
- `merge.conflictstyle = zdiff3` for easier conflict resolution
- `rebase.autoStash = true` so you never have to stash before rebasing
- `push.autoSetupRemote = true` so you never see the "no upstream" error
- `rerere.enabled = true` so git remembers how you resolved conflicts
- `core.fsmonitor = true` for faster `git status` on large repos

## Hooks

All hooks are optional and installed per-repo. Each one can be bypassed with
`--no-verify` when you have a legitimate reason.

### Pre-commit

Catches real mistakes before they land in history: `.env` files, files over 5MB,
merge conflict markers, AWS keys, API tokens, private keys, and debug statements
like `console.log` and `debugger`. Warns (but does not block) on TODO markers
and trailing whitespace.

### Commit-msg

Checks for conventional commit format (`type: description`). If your message is
not in the right format, it **suggests a prefix** based on the files you changed
and lets the commit proceed. It does not reject your commit.

### Pre-push

Warns about uncommitted changes that will not be included in the push. Blocks
WIP commits from being pushed to main/master.

## Workflows

See [workflows.md](workflows.md) for copy-paste commands organized by scenario:
- "I need to fix a bug in production"
- "I pushed to main by accident"
- "My rebase has conflicts"
- "I need to find who changed this file"
- "I need to prepare for standup"

## Requirements

- Git 2.x or later
- Bash or Zsh (fish works with the [bass](https://github.com/edc/bass) plugin)
- [gh CLI](https://cli.github.com) (optional, for PR commands and dashboard)
- [fzf](https://github.com/junegunn/fzf) (optional, for interactive branch picking with `gco`)

## License

MIT
