# ai-bu-git-productivity

A collection of shell aliases, functions, and git configurations that speed up daily git workflows. Built for engineers who spend serious time in the terminal.

## Quick Start

```bash
git clone https://github.com/MarkellR-RedHat/ai-bu-git-productivity.git
cd ai-bu-git-productivity
bash install.sh
```

The installer will:
1. Add the aliases to your `.zshrc` or `.bashrc`
2. Detect conflicts with any existing aliases you have defined
3. Optionally include the gitconfig extras in your global git config
4. Optionally install the pre-commit hook in the current repo
5. Optionally install the commit-msg hook in the current repo

## Shell Aliases and Functions

Source `aliases.sh` in your shell config to get all of these commands.

### Quick Reference Table

| Command | What it does | Example |
|---------|-------------|---------|
| `glog` | Pretty git log with graph | `glog` |
| `gweek` | Show your commits from the past week | `gweek` |
| `gtoday` | Show what you committed today | `gtoday` |
| `gcontrib` | Your contribution stats (commits, lines, files) | `gcontrib` |
| `gfind <keyword>` | Search commit messages by keyword | `gfind "retry"` |
| `gchanged [N]` | Files changed in the last N commits (default 5) | `gchanged 10` |
| `gdash` | Full repo dashboard in one command | `gdash` |
| `gstale` | Find local branches with no commits in 30+ days | `gstale` |
| `gclean` | Delete merged local branches (with confirmation) | `gclean` |
| `gpr [title]` | Create a PR with the gh CLI | `gpr "Fix auth bug"` |
| `greview` | List PRs assigned to you for review | `greview` |
| `gblame-who <file>` | Who contributed the most to a file | `gblame-who src/main.py` |
| `gdiff-stat [branch] [base]` | File-level diff stats vs a base branch | `gdiff-stat feature-x main` |
| `grebase-main` | Fetch and rebase on main/master (auto-detects) | `grebase-main` |
| `gundo` | Safely undo the last commit (keeps changes staged) | `gundo` |
| `gwip` | Quick work-in-progress commit | `gwip` |
| `gunwip` | Undo the last WIP commit | `gunwip` |
| `gopen` | Open the current repo in your browser | `gopen` |

### Detailed Descriptions

#### `glog`

Pretty git log with graph, one line per commit, across all branches.

```
$ glog
* a1b2c3d (HEAD -> main) Add retry logic
* d4e5f6a Refactor auth module
| * 7g8h9i0 (feature/dashboard) WIP: dashboard layout
|/
* j1k2l3m Initial commit
```

#### `gweek`

Show all your commits from the past week, across every branch.

```
$ gweek
Commits by Jane Engineer this week:

a1b2c3d 2026-06-25 Add retry logic
d4e5f6a 2026-06-24 Refactor auth module
```

#### `gtoday`

Show what you committed today. Useful for standups.

```
$ gtoday
Commits by Jane Engineer today:

a1b2c3d 2026-06-26 Add retry logic
```

#### `gcontrib`

Show your contribution stats for the current repo: total commits, lines added, lines removed, and files touched.

```
$ gcontrib
Contribution stats for Jane Engineer:

  Commits:  42
  Added:    +3800 lines
  Removed:  -1200 lines
  Files:    85 touched
```

#### `gfind`

Search all commit messages for a keyword. Searches across all branches.

```
$ gfind "retry"
Commits matching "retry":

a1b2c3d Add retry logic to API client
f4e5d6c Remove old retry workaround
```

#### `gchanged`

Show the files that changed in the last N commits (defaults to 5).

```
$ gchanged 3
Files changed in the last 3 commit(s):

src/auth.py
src/client.py
tests/test_client.py
```

#### `gdash`

A full dashboard of your repo state in one command. Shows your current branch, ahead/behind status relative to the remote, uncommitted changes, recent commits, and open PRs.

```
$ gdash
========================================
  Git Dashboard
========================================

Branch:  feature/auth-retry
Remote:  origin/feature/auth-retry (ahead 2 / behind 0)

--- Uncommitted Changes ---
  M src/client.py
  ?? notes.txt

--- Recent Commits (last 5) ---
  a1b2c3d Add retry logic
  d4e5f6a Refactor auth module
  7g8h9i0 Fix token refresh
  j1k2l3m Update README
  m4n5o6p Initial commit

--- Open PRs (this repo) ---
  #12  Add retry logic  feature/auth-retry  OPEN
  #10  Fix dashboard     feature/dashboard   OPEN

========================================
```

#### `gstale`

Find local branches that have not had a commit in over 30 days. Useful for periodic cleanup.

```
$ gstale
Local branches with no commits in the last 30 days:

  2026-04-10  old-experiment
  2026-05-01  abandoned-feature
```

#### `gclean`

Delete local branches that have already been merged. Prompts for confirmation before deleting anything.

```
$ gclean
The following merged branches will be deleted:
  bugfix/typo
  feature/done

Proceed? [y/N] y
Done.
```

#### `gpr`

Create a pull request quickly using the `gh` CLI. Pass a title as an argument, or enter it interactively.

```bash
gpr "Add retry logic to API client"
```

#### `greview`

List open PRs that are assigned to you for review.

```
$ greview
PRs waiting for your review:

#15  Update config schema  main  REVIEW REQUIRED
#12  Add retry logic       main  REVIEW REQUIRED
```

#### `gblame-who`

Show who has contributed the most commits to a specific file.

```
$ gblame-who src/main.py
Top contributors to src/main.py:

  15 Jane Engineer
   8 Bob Developer
   3 Alice Reviewer
```

#### `gdiff-stat`

Display file-level diff statistics for a branch compared to main (or any other base branch).

```
$ gdiff-stat feature-branch
Diff stats for feature-branch vs main:

 src/auth.py   | 42 +++++++++++++-------
 src/client.py | 18 ++++++---
 2 files changed, 38 insertions(+), 22 deletions(-)
```

#### `grebase-main`

Fetch the latest changes and rebase your current branch onto main (or master). Automatically detects which is the default branch.

```
$ grebase-main
Fetching origin and rebasing feature/auth-retry onto origin/main...
Rebase complete.
```

#### `gundo`

Safely undo the last commit. Your changes stay staged so nothing is lost.

```
$ gundo
Undoing commit: Add retry logic
Changes are back in staging. Nothing was lost.
```

#### `gwip` / `gunwip`

Create a quick work-in-progress commit with all current changes. The commit message includes `[skip ci]` to avoid triggering CI pipelines. Use `gunwip` to undo it.

```
$ gwip
[feature/auth 4a5b6c7] WIP: work in progress [skip ci]

$ gunwip
WIP commit removed. Changes are staged.
```

#### `gopen`

Open the current repo in your browser. Works with GitHub SSH and HTTPS remotes.

```
$ gopen
Opening https://github.com/your-org/your-repo
```

## Git Config Extras

The `gitconfig-extras` file contains recommended git settings. You can include it globally:

```bash
git config --global include.path /path/to/ai-bu-git-productivity/gitconfig-extras
```

What it configures:

| Setting | What it does |
|---------|-------------|
| `diff.algorithm = histogram` | Produces cleaner, faster diffs |
| `merge.conflictstyle = zdiff3` | Shows the original text alongside both sides of a conflict |
| `rebase.autoStash = true` | Automatically stashes uncommitted changes before rebase |
| `pull.rebase = true` | Rebase instead of merge on pull |
| `push.default = current` | Push to a remote branch with the same name |
| `push.autoSetupRemote = true` | Auto-set upstream tracking on first push |
| `fetch.prune = true` | Clean up stale remote-tracking branches on fetch |
| `rerere.enabled = true` | Remember conflict resolutions and reapply them automatically |

It also includes a set of short git aliases:

- `git st` for short status
- `git amend` to amend without editing the message
- `git last` to show the last commit
- `git recent` to list branches by last commit date
- `git rb N` for interactive rebase on the last N commits
- `git ds` for compact diff summary
- `git stash-all` to stash including untracked files
- `git aliases` to list all configured aliases

## Hooks

### Pre-Commit Hook

The `hooks/pre-commit-check` script catches common mistakes before they land in your history:

| Check | Behavior |
|-------|----------|
| `.env` files | Blocks commit |
| Files over 5 MB | Blocks commit |
| Merge conflict markers | Blocks commit |
| AWS keys or tokens | Blocks commit |
| Credential-like files (.pem, .p12, private keys) | Warns |
| TODO/FIXME/HACK markers | Warns |
| Trailing whitespace | Warns |

Install it manually:

```bash
cp hooks/pre-commit-check .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### Commit-Msg Hook

The `hooks/commit-msg` script validates commit message quality:

| Check | Behavior |
|-------|----------|
| Message under 10 characters | Warns |
| Message does not start with a capital letter | Warns |

Auto-generated messages (merges, reverts, WIP, fixup, squash) are skipped.

Install it manually:

```bash
cp hooks/commit-msg .git/hooks/commit-msg
chmod +x .git/hooks/commit-msg
```

Or let `install.sh` handle both hooks for you.

## Requirements

- Git 2.x or later
- Bash or Zsh
- [gh CLI](https://cli.github.com) (optional, needed for `gpr`, `greview`, and the PR section of `gdash`)

## License

MIT
