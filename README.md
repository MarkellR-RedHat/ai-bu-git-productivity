# ai-bu-git-productivity

Shell aliases, git config, and hooks that make git actually fast to use. Built for
engineers who live in the terminal and are tired of typing the same long commands
over and over.

## Quick Start

```bash
git clone https://github.com/MarkellR-RedHat/ai-bu-git-productivity.git
cd ai-bu-git-productivity
bash install.sh
```

The installer is interactive. It detects your shell (bash/zsh/fish), previews
each component, lets you pick what you want, and backs up your existing configs
before changing anything.

## The 10 Aliases That Will Change Your Workflow

These are the commands people use most. Once you get used to them, going back
feels painful.

### 1. `gs` instead of `git status`

**Before:**
```bash
git status
```

**After:**
```bash
gs
## main...origin/main [ahead 2]
 M src/auth.py
?? notes.txt
```

Short output with branch info and ahead/behind count. You will type this 50 times a day.

### 2. `glog` instead of `git log`

**Before:**
```bash
git log --oneline --graph --decorate --all
```

**After:**
```bash
glog
* a1b2c3d (HEAD -> main) feat: add retry logic  (2 hours ago) <Jane>
| * d4e5f6a (feature/dashboard) WIP: layout       (5 hours ago) <Bob>
|/
* 7g8h9i0 fix: auth timeout                       (yesterday) <Jane>
```

Color-coded graph with relative dates and author names. No more guessing
what the `--format` flags are.

### 3. `gwip` / `gunwip` for work-in-progress

**Before:**
```bash
git add -A
git commit -m "WIP"
# later...
git reset --soft HEAD~1
```

**After:**
```bash
gwip                   # stages everything, commits as WIP [skip ci]
gunwip                 # undoes the WIP commit, leaves changes staged
```

Save your work before switching branches. Pick up exactly where you left off.

### 4. `gpush` instead of the first-push dance

**Before:**
```bash
git push
# fatal: The current branch feature/foo has no upstream branch.
git push --set-upstream origin feature/foo
```

**After:**
```bash
gpush                  # pushes and sets upstream automatically
```

No more copying the suggested command from the error message.

### 5. `grebase-main` to stay current

**Before:**
```bash
git fetch origin main
git rebase origin/main
# or was it master? Let me check...
```

**After:**
```bash
grebase-main           # auto-detects main vs master, fetches, rebases
```

Works on repos that use `main` and repos that use `master`. No thinking required.

### 6. `pr-create` for pull requests

**Before:**
```bash
git push -u origin feature/add-auth-retry
gh pr create --title "Add auth retry" --fill
```

**After:**
```bash
pr-create              # auto-pushes, generates title from branch name
```

Your branch name `feature/add-auth-retry` becomes PR title "Add auth retry"
automatically. Override it if you want, or just press Enter.

### 7. `gdash` for the full picture

```bash
gdash
========================================
  Git Dashboard
========================================

Branch:  feature/auth-retry
Remote:  origin/feature/auth-retry (ahead 2 / behind 0)

--- Uncommitted Changes ---
  M src/client.py

--- Stashes: 1 ---
  stash@{0}: On main: quick experiment

--- Recent Commits (last 5) ---
  a1b2c3d feat: add retry logic        (2 hours ago)
  d4e5f6a refactor: extract auth module (yesterday)

--- Open PRs (this repo) ---
  #12  Add retry logic  feature/auth-retry  OPEN

========================================
```

Everything you need to know about your repo in one command.

### 8. `gwho` to investigate ownership

**Before:**
```bash
git log --format='%aN' -- src/auth.py | sort | uniq -c | sort -rn | head -10
```

**After:**
```bash
gwho src/auth.py
Top contributors to src/auth.py:

  15 Jane Engineer
   8 Bob Developer
   3 Alice Reviewer
```

Know who to ask about a file before you start changing it.

### 9. `pr-cleanup` to stay tidy

**Before:**
```bash
git checkout main
git pull
git branch --merged | grep -v main | xargs git branch -d
# then manually delete each one from the remote too
```

**After:**
```bash
pr-cleanup             # switches to main, deletes merged branches, offers to clean remote too
```

Run this at the end of every sprint. Takes 5 seconds.

### 10. `gfind` to search history

**Before:**
```bash
git log --all --oneline --grep="retry"
```

**After:**
```bash
gfind "retry"
Commits matching "retry":

a1b2c3d feat: add retry logic to API client  (2 hours ago) <Jane>
f4e5d6c fix: remove old retry workaround      (3 weeks ago) <Bob>
```

Search commit messages across all branches with color-coded output.

## Full Command Reference

### Daily Workflow

| Command | What it does |
|---------|-------------|
| `gs` | Git status with branch info and ahead/behind count |
| `glog` | One-line log with colors, graph, and relative dates |
| `glog1` | Condensed log, last 20 commits, no graph |
| `gtoday` | Your commits from today (great for standups) |
| `gweek` | Your commits from the past week |
| `gc "msg"` | Stage all + commit in one shot |
| `gwip` | Quick WIP commit that skips CI |
| `gunwip` | Undo the last WIP commit |
| `gundo` | Safely undo the last commit (keeps changes staged) |
| `gpush` | Push and set upstream in one command |
| `gpull` | Pull with rebase |
| `gfetch` | Fetch all remotes and prune stale branches |
| `grebase-main` | Fetch + rebase onto main/master (auto-detects) |
| `gco` | Checkout branch (uses fzf for interactive selection if available) |
| `gcb <name>` | Create and switch to a new branch |
| `gstash [msg]` | Stash everything including untracked files |
| `gstash-pop` | Pop the most recent stash |
| `gopen` | Open the repo in your browser |

### PR Workflow

| Command | What it does |
|---------|-------------|
| `pr-create` | Create PR, auto-fill title from branch name |
| `pr-draft` | Create a draft PR |
| `pr-ready [reviewers]` | Mark draft as ready, optionally request reviewers |
| `pr-cleanup` | Delete merged branches locally and remotely |
| `pr-stack` | Show your open PRs with review status |
| `pr-checkout <num>` | Check out a PR branch by number |
| `pr-diff [num]` | View PR diff in terminal |
| `greview` | PRs waiting for your review |

### Investigation

| Command | What it does |
|---------|-------------|
| `gwho <file>` | Who changed this file most (by commit count) |
| `gwhen <file> [line]` | When was this file/line last changed (formatted blame) |
| `gfind <string>` | Search commit messages for a string |
| `gfind-code <string>` | Search code diffs for when a string was added/removed |
| `gdiff-words` | Word-level diff (great for prose and config) |
| `gdiff-stat [branch]` | File-level diff stats vs default branch |
| `gcontrib` | Your contribution stats (commits, lines, files) |
| `gchanged [N]` | Files changed in the last N commits |

### Team

| Command | What it does |
|---------|-------------|
| `gteam` | Active branches with last commit and author |
| `gstale [days]` | Branches with no commits in N+ days (default 14) |
| `gleaderboard [days]` | Commit leaderboard for the last N days |

### Cleanup

| Command | What it does |
|---------|-------------|
| `gclean` | Delete merged local branches (with confirmation) |
| `gclean-files` | Remove untracked files (with confirmation) |
| `greset-hard` | Reset branch to match remote (with confirmation) |

### Quick Shortcuts

| Shortcut | Expands to |
|----------|-----------|
| `ga` | `git add` |
| `gaa` | `git add -A` |
| `gd` | `git diff` |
| `gds` | `git diff --staged` |
| `gb` | `git branch` |
| `gba` | `git branch -a` |
| `gm` | `git merge` |
| `gap` | `git add -p` (interactive patch mode) |
| `gamend` | Amend last commit, keep message |
| `gamend-msg` | Amend last commit, edit message |

## Git Config Extras

The `gitconfig-extras` file includes settings that most engineers should have
but few know about. Include it globally:

```bash
git config --global include.path /path/to/ai-bu-git-productivity/gitconfig-extras
```

**Performance:**
- `core.fsmonitor = true` - filesystem event monitor for faster `git status`
- `core.untrackedCache = true` - cached untracked file list
- `fetch.writeCommitGraph = true` - faster log traversal after fetch
- `feature.manyFiles = true` - optimizations for repos with lots of files

**Better defaults:**
- `diff.algorithm = histogram` - cleaner diffs
- `merge.conflictstyle = zdiff3` - easier conflict resolution
- `rebase.autoStash = true` - auto-stash during rebase
- `push.autoSetupRemote = true` - no more `--set-upstream`
- `rerere.enabled = true` - remembers conflict resolutions
- `pull.rebase = true` - rebase on pull instead of merge

**Git aliases** (these work as `git <alias>`):
- `git st` - short status
- `git amend` - amend without editing message
- `git recent` - branches by last commit date
- `git rb 5` - interactive rebase on last 5 commits
- `git who <file>` - who contributed most to a file
- `git backup` - create a backup tag before risky operations
- `git root` - show repo root directory

## Hooks

All hooks are optional and installed per-repo. Each one can be skipped with
`--no-verify` when you have a legitimate reason.

### Pre-commit Hook

Catches common mistakes before they land in history.

| Check | Behavior |
|-------|----------|
| `.env` files | Blocks commit |
| Files over 5 MB | Blocks commit |
| Merge conflict markers | Blocks commit |
| AWS keys, API tokens, private keys | Blocks commit |
| `console.log`, `debugger`, `binding.pry` | Blocks commit |
| Credential-like files (.pem, .p12) | Warns |
| TODO/FIXME/HACK in new code | Warns |
| Trailing whitespace | Warns |

### Commit-msg Hook

Enforces conventional commit format for consistent, parseable history.

| Check | Behavior |
|-------|----------|
| Not conventional format (`type: description`) | Blocks commit |
| Subject line over 72 characters | Warns |
| Description under 10 characters | Warns |
| Trailing period on subject | Warns |

Valid types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

### Pre-push Hook

Last line of defense before code goes to the remote.

| Check | Behavior |
|-------|----------|
| WIP commits being pushed to main/master | Blocks push |
| Uncommitted local changes | Warns |
| Untracked files | Notes |

## Workflows Reference

See [workflows.md](workflows.md) for complete step-by-step guides:
- Feature branch workflow
- Hotfix workflow
- Release workflow
- "I pushed to main by accident" recovery
- "I force-pushed and lost commits" recovery
- Rebase vs merge: when to use which

## Requirements

- Git 2.x or later
- Bash or Zsh (fish works with the [bass](https://github.com/edc/bass) plugin)
- [gh CLI](https://cli.github.com) (optional, needed for PR commands and dashboard PR section)
- [fzf](https://github.com/junegunn/fzf) (optional, enables interactive branch selection with `gco`)

## License

MIT
