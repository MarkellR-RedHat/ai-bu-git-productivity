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
2. Optionally include the gitconfig extras in your global git config
3. Optionally install the pre-commit hook in the current repo

## Shell Aliases and Functions

Source `aliases.sh` in your shell config to get these commands:

### `glog`

Pretty git log with graph, one line per commit, across all branches.

```bash
glog
```

### `gweek`

Show all your commits from the past week, across every branch.

```bash
gweek
```

### `gstale`

Find local branches that have not had a commit in over 30 days. Useful for periodic cleanup.

```bash
gstale
```

### `gclean`

Delete local branches that have already been merged. Prompts for confirmation before deleting anything.

```bash
gclean
```

### `gpr`

Create a pull request quickly using the `gh` CLI. Pass a title as an argument, or enter it interactively.

```bash
gpr "Add retry logic to API client"
```

### `greview`

List open PRs that are assigned to you for review.

```bash
greview
```

### `gblame-who`

Show who has contributed the most commits to a specific file.

```bash
gblame-who src/main.py
```

### `gdiff-stat`

Display file-level diff statistics for a branch compared to main (or any other base branch).

```bash
gdiff-stat feature-branch
gdiff-stat feature-branch develop
```

### `gundo`

Safely undo the last commit. Your changes stay staged so nothing is lost.

```bash
gundo
```

### `gwip`

Create a quick work-in-progress commit with all current changes. The commit message includes `[skip ci]` to avoid triggering CI pipelines.

```bash
gwip
```

### `gunwip`

Undo the last commit, but only if it was a WIP commit. Changes go back to staging.

```bash
gunwip
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

## Pre-Commit Hook

The `hooks/pre-commit-check` script catches common mistakes before they land in your history:

- **Blocks `.env` files** from being committed (they often contain secrets)
- **Blocks large files** over 5 MB (use Git LFS instead)
- **Blocks merge conflict markers** left in source files
- **Warns about credential-like files** (private keys, `.pem`, etc.)

Install it manually:

```bash
cp hooks/pre-commit-check .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

Or let `install.sh` handle it for you.

## Requirements

- Git 2.x or later
- Bash or Zsh
- [gh CLI](https://cli.github.com) (optional, needed for `gpr` and `greview`)

## License

MIT
