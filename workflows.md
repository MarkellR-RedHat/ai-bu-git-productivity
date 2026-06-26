# Git Workflows Reference

A practical guide to common git workflows. Each section includes the exact commands
to run, using aliases from this toolkit where they save time.

## Feature Branch Workflow

The standard flow for shipping a new feature from start to finish.

```bash
# 1. Start from a fresh default branch
git checkout main
gpull                           # pull with rebase

# 2. Create your feature branch
gcb feature/add-retry-logic     # shortcut for git checkout -b

# 3. Do your work, committing as you go
ga src/retry.py                 # stage specific files
gc "feat: add retry logic to API client"

# 4. Keep your branch up to date with main
grebase-main                    # fetch + rebase onto main automatically

# 5. Push and create a PR
gpush                           # push + set upstream in one shot
pr-create                       # auto-fills title from branch name

# 6. After review, merge via GitHub UI or:
gh pr merge --squash

# 7. Clean up
pr-cleanup                      # delete merged local + remote branches
```

## Hotfix Workflow

When production is broken and you need a fix shipped fast.

```bash
# 1. Start from main, make sure it is current
git checkout main
gpull

# 2. Create a hotfix branch
gcb hotfix/fix-auth-timeout

# 3. Make the minimal fix
ga src/auth.py
gc "fix: increase auth timeout to prevent 502s"

# 4. Push and create a PR with urgency
gpush
pr-create "fix: increase auth timeout to prevent 502s"

# 5. Get a quick review, then merge
gh pr merge --squash

# 6. If you need to deploy from the branch before merging:
# (depends on your CI/CD setup)
git push origin hotfix/fix-auth-timeout:deploy/hotfix-auth
```

## Release Workflow

When you cut a release from main.

```bash
# 1. Make sure main is current
git checkout main
gpull

# 2. Tag the release
git tag -a v1.2.0 -m "Release v1.2.0: retry logic and auth fixes"
git push origin v1.2.0

# 3. If you need a release branch for patch releases:
gcb release/v1.2
gpush

# 4. Cherry-pick a fix into the release branch later:
git checkout release/v1.2
gcp abc1234                     # cherry-pick with conflict hints

# 5. Tag the patch release
git tag -a v1.2.1 -m "Release v1.2.1: hotfix for auth timeout"
git push origin v1.2.1
```

## Recovery: "I Pushed to Main by Accident"

You committed directly to main and pushed. Here is how to fix it without causing
problems for the rest of the team.

**If you just pushed and nobody has pulled yet:**

```bash
# 1. Create a branch from your current position (saves your work)
gcb fix/move-off-main

# 2. Switch back to main
git checkout main

# 3. Reset main to match the remote
git fetch origin
git reset --hard origin/main

# 4. Your work is safe on the fix/move-off-main branch
# Create a PR from there instead
git checkout fix/move-off-main
pr-create
```

**If other people have already pulled:**

Do NOT force-push main. Instead, revert your commits:

```bash
# 1. Find the commits you accidentally pushed
glog1                           # see recent commits

# 2. Revert them (creates new commits that undo the changes)
git revert abc1234              # revert a single commit
# or for multiple commits:
git revert abc1234..def5678

# 3. Push the revert
git push origin main

# 4. Now create a proper branch with your changes
gcb feature/my-actual-work
git revert HEAD                 # revert the revert to get your changes back
pr-create
```

## Recovery: "I Force-Pushed and Lost Commits"

Someone (maybe you) force-pushed and now commits are gone. Git keeps everything
for at least 30 days in the reflog.

```bash
# 1. Check the reflog to find the lost commits
git reflog

# The output looks like:
#   abc1234 HEAD@{0}: reset: moving to origin/main
#   def5678 HEAD@{1}: commit: feat: the commit you lost
#   ghi9012 HEAD@{2}: commit: fix: another lost commit

# 2. Find the commit hash from BEFORE the force-push

# 3. Create a recovery branch from that point
git checkout -b recovery/lost-work def5678

# 4. Verify everything is there
glog1
git diff main

# 5. If you need to restore a branch to where it was:
git branch -f feature/my-branch def5678
```

## Rebase vs Merge: When to Use Which

**Use rebase when:**
- Updating your feature branch with the latest from main
- You want a clean, linear commit history
- Working on a branch that only you are using
- Cleaning up commits before a PR review

```bash
# Rebase your branch onto the latest main
grebase-main

# Interactive rebase to clean up your last 5 commits
git rb 5                        # uses the git alias from gitconfig-extras
```

**Use merge when:**
- Merging a finished PR into main (usually done via GitHub)
- Combining two branches where you want to preserve the branch history
- Working on a shared branch where others are also pushing commits
- You want a merge commit as a clear record that a feature landed

```bash
# Merge a branch into main (creates a merge commit)
git checkout main
git merge --no-ff feature/dashboard
```

**The short version:**
- Rebase to update your branch FROM main
- Merge to land your branch INTO main
- Never rebase a branch that other people are also working on

## Daily Standup Prep

Run these commands in the morning to prepare for standup:

```bash
# What did I do yesterday?
gweek                           # shows your commits from the past week

# What is on my plate today?
greview                         # PRs waiting for my review
pr-stack                        # my open PRs and their status

# Quick snapshot of repo state
gdash                           # full dashboard
```

## End of Sprint Cleanup

```bash
# Clean up merged branches
pr-cleanup                      # delete merged branches local + remote

# Find stale branches
gstale                          # branches with no commits in 2+ weeks

# Check your contribution stats
gcontrib                        # commits, lines added/removed, files touched
```
