# Git Productivity Toolkit

Part of the [AI BU](https://github.com/MarkellR-RedHat/ai-bu-hub) tool suite.

**You type `git status` 30 times a day.** That is 330 keystrokes spent on a command you could run in two. Multiply by every `git add -A && git commit -m`, every `git log --oneline --graph --decorate --all`, every time you copy-paste the upstream push command Git helpfully suggests after rejecting yours.

This toolkit gives you 40+ shell aliases and functions that replace the commands you already use with shorter, smarter versions. No new workflows to learn. No plugins to configure. Just the same Git, faster.

## Before / After

```
BEFORE                                              AFTER
─────────────────────────────────────────────────    ─────────────
git status                                           gs
git add -A && git commit -m "feat: add retry"        gc "feat: add retry"
git log --oneline --graph --decorate --all           glog
git push --set-upstream origin feature/foo           gpush
git fetch origin main && git rebase origin/main      grebase-main
git push -u origin feature/foo && gh pr create       pr-create
```

## Quick Start

```bash
git clone https://github.com/MarkellR-RedHat/ai-bu-git-productivity.git
cd ai-bu-git-productivity
bash install.sh            # detects your shell, backs up configs, asks before changing anything
```

That is it. The installer detects bash or zsh, backs up your shell config, and adds one `source` line. Run `bash install.sh --preview` first if you want a dry run.

## What Gets Installed

**Three things, all optional:**

1. **Shell aliases** -- a `source` line added to your `.bashrc` or `.zshrc`
2. **Git config extras** -- sane defaults (histogram diffs, auto-stash, rerere) via `include.path`
3. **Three hooks** -- pre-commit (blocks secrets), commit-msg (suggests conventional format), pre-push (blocks WIP to main)

Every step asks for confirmation. Every file gets backed up first. Uninstall by removing the `source` line and the `include.path` entry.

## The Top 10

### `gs` -- status at a glance

```bash
gs
main  +2 -0
 M src/auth.py
?? notes.txt
```

Branch, ahead/behind, and changed files. Two keystrokes instead of ten.

### `gc "msg"` -- stage and commit in one shot

```bash
gc "feat: add retry logic"
# equivalent to: git add -A && git commit -m "feat: add retry logic"
```

### `glog` -- the log command you actually want

```bash
glog
* a1b2c3d (HEAD -> main) feat: add retry logic  (2 hours ago) <Jane>
| * d4e5f6a (feature/dashboard) WIP: layout       (5 hours ago) <Bob>
|/
* 7g8h9i0 fix: auth timeout                       (yesterday) <Jane>
```

### `gpush` -- push without the upstream dance

```bash
gpush
# sets upstream automatically on first push, plain push after that
```

### `gwip` / `gunwip` -- park your work

```bash
gwip                   # stages everything, commits as WIP [skip ci]
# switch branches, do other work, come back
gunwip                 # undoes the WIP commit, leaves changes staged
```

### `grebase-main` -- rebase without guessing

```bash
grebase-main           # auto-detects main vs master, fetches, rebases
```

### `pr-create` -- branch to PR in one command

```bash
pr-create              # pushes, generates PR title from branch name
# feature/add-auth-retry -> "Add auth retry"
```

### `gdash` -- full repo dashboard

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

### `gundo` -- uncommit without losing anything

```bash
gundo
Undoing commit: feat: add retry logic
Changes are back in staging. Nothing was lost.
```

### `gfind` / `gwho` -- investigate history

```bash
gfind "retry"          # search commit messages across all branches
gwho src/auth.py       # who changed this file the most?
gwhen src/auth.py 42   # who last touched line 42?
```

## Full Alias Reference

### Every 5 Minutes

| Alias | What it does | Replaces |
|-------|-------------|----------|
| `gs` | Status with branch + ahead/behind | `git status` |
| `ga` / `gaa` | Stage file / stage all | `git add` / `git add -A` |
| `gd` / `gds` | Diff / diff staged | `git diff` / `git diff --staged` |
| `gc "msg"` | Stage all + commit | `git add -A && git commit -m` |
| `gpush` | Push + auto set upstream | `git push --set-upstream origin ...` |
| `gpull` | Pull with rebase | `git pull --rebase` |
| `gco [branch]` | Checkout (fzf picker if no arg) | `git checkout` |
| `gcb <name>` | Create + switch branch | `git checkout -b` |

### Every Hour

| Alias | What it does |
|-------|-------------|
| `glog` | Graph log with colors and relative dates |
| `glog1` | Condensed log, last 20, no graph |
| `gamend` | Amend last commit, keep message |
| `gamend-msg` | Amend last commit, edit message |
| `gap` | Stage hunks interactively (patch mode) |
| `gstash [msg]` | Stash everything including untracked |
| `gstash-pop` | Pop most recent stash |
| `gstash-ls` | List stashes, clean format |
| `grebase-main` | Fetch + rebase onto main/master |
| `gfetch` | Fetch all remotes, prune stale branches |

### Several Times a Day

| Alias | What it does |
|-------|-------------|
| `gwip` | Quick WIP commit (warns on main, skips CI) |
| `gunwip` | Undo last WIP commit |
| `gundo` | Undo last commit, keep changes staged |
| `gtoday` | Your commits from today (standup-ready) |
| `gweek` | Your commits from the past week |
| `gdiff-words` | Word-level diff (good for prose and config) |
| `gdiff-staged` | Show staged changes |
| `gdiff-last` | Diff of the last commit |
| `gchanged [N]` | Files changed in last N commits |

### PR Workflow

| Alias | What it does |
|-------|-------------|
| `pr-create` | Create PR, auto-fill title from branch |
| `pr-draft` | Create a draft PR |
| `pr-ready [reviewers]` | Mark draft ready, request reviewers |
| `pr-cleanup` | Delete merged branches locally and remotely |
| `pr-stack` | Your open PRs with review status |
| `pr-checkout <num>` | Check out a PR branch by number |
| `pr-diff [num]` | View PR diff in terminal |
| `greview` | PRs waiting for your review |

### Investigation

| Alias | What it does |
|-------|-------------|
| `gwho <file>` | Who changed this file most |
| `gwhen <file> [line]` | When was this file/line last changed |
| `gfind <string>` | Search commit messages across all branches |
| `gfind-code <string>` | Search diffs for added/removed code |
| `gdiff-stat [branch]` | File-level diff stats vs default branch |
| `gcontrib` | Your stats: commits, lines, files |

### Team

| Alias | What it does |
|-------|-------------|
| `gteam` | Active branches with last commit and author |
| `gstale [days]` | Branches with no commits in N+ days (default 14) |
| `gleaderboard [days]` | Commit leaderboard for last N days |
| `gdash` | Full repo dashboard in one command |

### Cleanup

| Alias | What it does |
|-------|-------------|
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

The installer adds sane defaults to your global config via `include.path`. You can also add them manually:

```bash
git config --global include.path /path/to/ai-bu-git-productivity/gitconfig-extras
```

| Setting | Why |
|---------|-----|
| `diff.algorithm = histogram` | Cleaner diffs |
| `merge.conflictstyle = zdiff3` | Better conflict markers |
| `rebase.autoStash = true` | No more "stash before rebase" |
| `push.autoSetupRemote = true` | No more "no upstream" errors |
| `rerere.enabled = true` | Remembers conflict resolutions |
| `core.fsmonitor = true` | Faster status on large repos |

## Hooks

Optional, per-repo. Bypass any hook with `--no-verify`.

| Hook | Behavior |
|------|----------|
| **pre-commit** | Blocks `.env` files, large files, conflict markers, secrets, debug statements. Warns on TODOs and trailing whitespace. |
| **commit-msg** | Suggests conventional commit format based on staged files. Never blocks. |
| **pre-push** | Warns on uncommitted changes. Blocks WIP commits to main/master. |

## Workflows

See [workflows.md](workflows.md) for copy-paste recipes: fix a prod bug, undo a push to main, resolve rebase conflicts, prep for standup, and more.

## Pair with Other AI BU Tools

This toolkit handles the git plumbing. The tools below handle what happens before, during, and after the code work.

| When | Tool | What it does |
|------|------|--------------|
| Before a meeting | [meeting-notes](https://github.com/MarkellR-RedHat/ai-bu-meeting-notes) | Structured agendas, action tracking, decision logs |
| After a PR merge | [shipped-digest](https://github.com/MarkellR-RedHat/ai-bu-shipped-digest) | Turns merged PRs into a narrative digest for stakeholders |
| Friday afternoon | [status-report](https://github.com/MarkellR-RedHat/ai-bu-status-report) | Weekly status from git history and GitHub data |
| Writing a commit message | [style-checker](https://github.com/MarkellR-RedHat/ai-bu-style-checker) | Catches product name typos (OpenShift, not Openshift) |
| Reviewing a PR | [review-as-persona](https://github.com/MarkellR-RedHat/ai-bu-review-as-persona) | Reviews code from specific perspectives (security, perf, API design) |

## Pro Tip

Run `gtoday` before standup to see exactly what you shipped. Then pipe that context into `/status-report` from [ai-bu-status-report](https://github.com/MarkellR-RedHat/ai-bu-status-report) for a polished update. On a team of six, this saves roughly 20 minutes per standup because nobody is searching their terminal history trying to remember what they did yesterday.

## Requirements

- Git 2.x+
- Bash or Zsh (fish works via [bass](https://github.com/edc/bass))
- [gh CLI](https://cli.github.com) (optional, for PR commands)
- [fzf](https://github.com/junegunn/fzf) (optional, for `gco` branch picker)

## License

MIT
