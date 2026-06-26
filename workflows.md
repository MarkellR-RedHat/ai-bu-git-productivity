# Git Workflows: Copy-Paste Commands for Every Scenario

Jump to the scenario you need. Each section gives you the exact commands to run.
All aliases reference this toolkit. Install it first or swap in the full git commands.

---

## I need to start a new feature

```bash
git checkout main
gpull
gcb feature/my-feature-name
# ... do your work ...
ga src/my-file.py
gc "feat: add the thing"
gpush
pr-create
```

## I need to fix a bug in production

```bash
git checkout main
gpull
gcb hotfix/describe-the-fix
# ... make the minimal fix ...
ga src/broken-thing.py
gc "fix: describe what you fixed"
gpush
pr-create "fix: describe what you fixed"
# Get a fast review, then merge via GitHub UI or:
gh pr merge --squash
```

## I need to save my work and switch branches

```bash
gwip                    # stages everything, commits as WIP [skip ci]
gco other-branch        # switch to the other branch
# ... do your work on the other branch ...
gco -                   # switch back (dash means "previous branch")
gunwip                  # undo the WIP commit, changes are staged and ready
```

Alternative using stash:

```bash
gstash "half-done auth work"
gco other-branch
# ... do your work ...
gco -
gstash-pop
```

## I need to update my branch with the latest from main

```bash
grebase-main            # fetches origin, rebases onto main/master automatically
```

If there are conflicts:

```bash
# Fix the conflicting files, then:
git add <fixed-file>
git rebase --continue
# Or abort and go back to where you were:
git rebase --abort
```

## I need to undo my last commit (keep changes)

```bash
gundo                   # resets the commit, changes stay staged
```

## I need to change my last commit message

```bash
gamend-msg              # opens your editor to rewrite the message
```

## I need to add more changes to my last commit

```bash
ga src/forgot-this.py
gamend                  # adds staged changes to the last commit, same message
```

## I pushed to main by accident

**If nobody has pulled yet:**

```bash
gcb fix/move-off-main       # save your work on a new branch
git checkout main
git fetch origin
git reset --hard origin/main
git checkout fix/move-off-main
pr-create                   # create a PR from the branch instead
```

**If other people already pulled:**

Do NOT force-push main. Revert your commits instead:

```bash
glog1                       # find the commit hashes you pushed
git revert abc1234           # creates a new commit that undoes the change
git push origin main
# Now put your work on a proper branch:
gcb feature/my-actual-work
git revert HEAD             # revert the revert to get your changes back
pr-create
```

## My rebase has conflicts

```bash
# Git will pause and tell you which files have conflicts.
# Open each conflicting file, look for the markers:
#   <<<<<<< HEAD
#   (your changes)
#   =======
#   (incoming changes)
#   >>>>>>> commit-hash

# Fix the file, then:
git add <fixed-file>
grb-continue                # git rebase --continue

# If you want to skip this one commit:
git rebase --skip

# If you want to give up and go back to where you started:
grb-abort                   # git rebase --abort
```

## I need to cherry-pick a commit from another branch

```bash
glog                        # find the commit hash on the other branch
gcp abc1234                 # cherry-pick with conflict hints if needed
```

For multiple commits:

```bash
gcp abc1234 def5678 ghi9012
```

## I need to find who last changed a file

```bash
gwho src/auth.py            # top contributors by commit count
gwhen src/auth.py           # full blame with relative dates
gwhen src/auth.py 42        # blame just line 42
```

## I need to find when a piece of code was added or removed

```bash
gfind-code "some_function"  # shows commits where that string was added/removed
gfind "retry"               # search commit messages instead
```

## I need to cut a release

```bash
git checkout main
gpull
git tag -a v1.2.0 -m "Release v1.2.0: description of what shipped"
git push origin v1.2.0
```

If you need a release branch for patches:

```bash
gcb release/v1.2
gpush
# Later, cherry-pick fixes into it:
git checkout release/v1.2
gcp abc1234
git tag -a v1.2.1 -m "Release v1.2.1: describe the patch"
git push origin v1.2.1
```

## I force-pushed and lost commits

Git keeps everything for at least 30 days in the reflog.

```bash
git reflog
# Find the commit hash from BEFORE the force-push, then:
git checkout -b recovery/lost-work <hash-from-reflog>
glog1                       # verify everything is there
```

## I need to clean up old branches

```bash
pr-cleanup                  # deletes merged branches locally and on the remote
gstale                      # shows branches with no commits in 14+ days
gclean                      # deletes merged local branches (with confirmation)
```

## I need to prepare for standup

```bash
gtoday                      # what did I commit today?
gweek                       # what did I commit this week?
greview                     # PRs waiting for my review
pr-stack                    # my open PRs and their status
gdash                       # full repo snapshot
```

## Rebase vs merge: when to use which

**Rebase** when updating your feature branch from main:

```bash
grebase-main
```

**Merge** when landing a finished feature into main (usually done via GitHub PR).

The short version:
- Rebase to update your branch FROM main
- Merge to put your branch INTO main
- Never rebase a branch that other people are also pushing to
