# ✦ Git & GitHub Scenario-Based Interview Questions

This section compiles **100 scenario-based interview questions and answers** covering Git basics, commits, branches, conflict resolution, hooks, and GitHub Actions.

---

## ✦ Section 1: Branching Strategies & Workflows (Questions 1-20)

<details>
<summary><b>Q1: Scenario: You accidentally committed secrets (API Key) to a public GitHub repo. What is the immediate recovery process?</b></summary>
1. Revoke the API Key immediately.
2. Use tools like `git-filter-repo` or `BFG Repo-Cleaner` to purge the file history globally.
3. Push force: `git push origin main --force`.
4. Check GitHub secret scanning alerts and rotate all leaked passwords.
</details>

<details>
<summary><b>Q2: Scenario: A developer wants to switch to a new branch, but has uncommitted changes they aren't ready to save in a commit. How can they switch safely?</b></summary>
Use `git stash` to save local changes, switch branch with `git checkout <branch>`, complete tasks, switch back, and run `git stash pop` to restore changes.
</details>

<details>
<summary><b>Q3: Scenario: How does GitFlow branching strategy differ from Trunk-Based Development?</b></summary>
- **GitFlow:** Features multiple long-lived branches (`main`, `develop`, `release`, `feature/*`, `hotfix/*`). Features are isolated. High merge overhead.
- **Trunk-Based:** Developers push short-lived feature branches directly to a single branch (`main`/`trunk`) multiple times a day. Emphasizes fast integration, feature flags, and robust CI.
</details>

<details>
<summary><b>Q4: Scenario: You want to restrict any developer from pushing directly to the `main` branch. How do you enforce this?</b></summary>
Go to Repository Settings on GitHub -> Branches -> Add branch protection rule for `main`. Enable "Require a pull request before merging" and restrict who can push directly.
</details>

<details>
<summary><b>Q5: Scenario: You need to pull changes from a remote branch, but want to make sure your local commits are placed on top of the remote commits. What command?</b></summary>
Run:
```bash
git pull --rebase origin <branch_name>
```
</details>

<details>
<summary><b>Q6: Scenario: How do you verify who made a specific line change in a file 6 months ago?</b></summary>
Run `git blame <file_name>` to see commit hashes, authors, and dates line by line, or use `git log -S "modified string" -p` to find the exact change.
</details>

<details>
<summary><b>Q7: Scenario: A developer wants to copy a single commit `a1b2c3d` from a legacy branch onto their current active branch. How?</b></summary>
Run:
```bash
git cherry-pick a1b2c3d
```
</details>

<details>
<summary><b>Q8: Scenario: You want to delete a local branch `feature-old` that has unmerged code. Git blocks `git branch -d`. How do you force delete?</b></summary>
Run:
```bash
git branch -D feature-old
```
</details>

<details>
<summary><b>Q9: Scenario: How do you configure a global Git username and email across all local repositories?</b></summary>
Run:
```bash
git config --global user.name "John Doe"
git config --global user.email "john@example.com"
```
</details>

<details>
<summary><b>Q10: Scenario: You want to track a remote branch `origin/dev` locally as a new branch `dev`. What is the command?</b></summary>
Run:
```bash
git checkout -b dev origin/dev
```
</details>

<details>
<summary><b>Q11: Scenario: You need to delete a remote branch named `feature-logout` from the command line. How?</b></summary>
Run:
```bash
git push origin --delete feature-logout
```
</details>

<details>
<summary><b>Q12: Scenario: How do you prune local tracking branches that no longer exist on the remote host?</b></summary>
Run:
```bash
git fetch --prune
```
</details>

<details>
<summary><b>Q13: Scenario: A feature branch needs to be updated with changes from `main`, but you want to keep the commit history linear. How?</b></summary>
Rebase the feature branch onto `main`:
```bash
git checkout feature
git rebase main
```
</details>

<details>
<summary><b>Q14: Scenario: You want to list all branches that have already been fully merged into `main`. What is the command?</b></summary>
Run:
```bash
git checkout main
git branch --merged
```
</details>

<details>
<summary><b>Q15: Scenario: You want to check the status of local repository changes in short format. How?</b></summary>
Run:
```bash
git status -s
```
</details>

<details>
<summary><b>Q16: Scenario: How do you rename the current active branch to `feature-login`?</b></summary>
Run:
```bash
git branch -m feature-login
```
</details>

<details>
<summary><b>Q17: Scenario: A developer wants to share their local stashes with another team member. Is this possible via git commands directly?</b></summary>
No, stashes are purely local to the workspace. To share, they must create a branch, apply/commit the changes, and push.
</details>

<details>
<summary><b>Q18: Scenario: You need to temporarily ignore changes in a tracked file `config.properties` without deleting it. How?</b></summary>
Run:
```bash
git update-index --assume-unchanged config.properties
```
</details>

<details>
<summary><b>Q19: Scenario: You want to display a tree-like, single-line log of all branch histories. What command do you use?</b></summary>
Run:
```bash
git log --oneline --graph --all
```
</details>

<details>
<summary><b>Q20: Scenario: How do you compare the differences in a file `app.js` between two branches `main` and `dev`?</b></summary>
Run:
```bash
git diff main dev -- app.js
```
</details>

---

## ✦ Section 2: Commits & History Management (Questions 21-40)

<details>
<summary><b>Q21: Scenario: You committed changes locally but realized your commit message has a typo. You haven't pushed yet. How do you fix it?</b></summary>
Run:
```bash
git commit --amend -m "Correct commit message"
```
</details>

<details>
<summary><b>Q22: Scenario: You need to combine (squash) 5 small commits into 1 single clean commit before merging. How?</b></summary>
Perform an interactive rebase:
```bash
git rebase -i HEAD~5
```
In the editor, keep the first as `pick` and change the subsequent 4 to `squash` or `s`. Save and write the final commit message.
</details>

<details>
<summary><b>Q23: Scenario: You have committed a change but want to undo it, completely wiping the commits and local workspace changes back to the state of `origin/main`. How?</b></summary>
Run:
```bash
git reset --hard origin/main
```
*Caution: This permanently deletes all uncommitted and local committed work.*
</details>

<details>
<summary><b>Q24: Scenario: You want to undo the last commit but keep all modified code in your local working directory unstaged. What is the command?</b></summary>
Run:
```bash
git reset HEAD~1
```
(Defaults to `--mixed`).
</details>

<details>
<summary><b>Q25: Scenario: You want to undo the last commit, but keep the modified code staged in the Git index. How?</b></summary>
Run:
```bash
git reset --soft HEAD~1
```
</details>

<details>
<summary><b>Q26: Scenario: How do you revert a commit `c1d2e3f` that has already been pushed to production, without rewriting git history?</b></summary>
Run:
```bash
git revert c1d2e3f
```
This creates a new "revert commit" that undoes the changes of `c1d2e3f` safely.
</details>

<details>
<summary><b>Q27: Scenario: You want to view a log of changes showing the exact lines added/deleted in each commit. How?</b></summary>
Run:
```bash
git log -p
```
</details>

<details>
<summary><b>Q28: Scenario: How do you search the entire commit history for a commit containing the word "database"?</b></summary>
Run:
```bash
git log --grep="database"
```
</details>

<details>
<summary><b>Q29: Scenario: A developer committed a file but forgot to add another. How can they add this file to the previous commit without creating a new one?</b></summary>
Stage the forgotten file first: `git add file.txt`. Then run:
```bash
git commit --amend --no-edit
```
</details>

<details>
<summary><b>Q30: Scenario: How do you list commits made by a specific author only?</b></summary>
Run:
```bash
git log --author="Author Name"
```
</details>

<details>
<summary><b>Q31: Scenario: You want to view the commit history of a single file `index.html`. What command?</b></summary>
Run:
```bash
git log -- index.html
```
</details>

<details>
<summary><b>Q32: Scenario: How do you create an empty commit (with no file changes) to trigger a CI/CD build?</b></summary>
Run:
```bash
git commit --allow-empty -m "trigger pipeline"
```
</details>

<details>
<summary><b>Q33: Scenario: How do you view logs for only the last 5 commits?</b></summary>
Run:
```bash
git log -n 5
```
</details>

<details>
<summary><b>Q34: Scenario: What is the difference between `git checkout <commit_hash>` and `git reset <commit_hash>`?</b></summary>
- `checkout` moves `HEAD` to the commit (detached HEAD state) but leaves branches unchanged. Safe for inspecting history.
- `reset` moves the branch pointer itself to the target commit, effectively discarding or staging commits in between.
</details>

<details>
<summary><b>Q35: Scenario: You want to check what modifications are currently staged in the index compared to HEAD. What diff command?</b></summary>
Run:
```bash
git diff --cached
```
</details>

<details>
<summary><b>Q36: Scenario: How do you find all files that are tracked by Git?</b></summary>
Run:
```bash
git ls-files
```
</details>

<details>
<summary><b>Q37: Scenario: You want to untrack a file `logs.txt` without deleting it from the local disk. How?</b></summary>
Run:
```bash
git rm --cached logs.txt
```
</details>

<details>
<summary><b>Q38: Scenario: You committed a huge binary file by mistake. You used `--amend` to remove it, but the repo size is still bloated. Why?</b></summary>
The blob object is still in Git's local database objects store. Force garbage collection:
```bash
git gc --prune=now --aggressive
```
</details>

<details>
<summary><b>Q39: Scenario: How do you tag the current commit as version `v1.0.0`?</b></summary>
Create an annotated tag:
```bash
git tag -a v1.0.0 -m "release version 1.0.0"
```
Push tags to remote: `git push origin v1.0.0`.
</details>

<details>
<summary><b>Q40: Scenario: How do you list all tags in a repository?</b></summary>
Run:
```bash
git tag
```
</details>

---

## ✦ Section 3: Merging, Rebasing & Conflict Resolution (Questions 41-60)

<details>
<summary><b>Q41: Scenario: You run `git merge feature` and hit a massive merge conflict. You want to abort the merge entirely and revert to the pre-merge state. How?</b></summary>
Run:
```bash
git merge --abort
```
</details>

<details>
<summary><b>Q42: Scenario: How do you resolve a merge conflict in a file `index.html`?</b></summary>
1. Open `index.html` in an editor.
2. Find conflict markers: `<<<<<<<`, `=======`, `>>>>>>>`.
3. Manually edit the file to select the correct code and delete the markers.
4. Stage the file: `git add index.html`.
5. Complete merge: `git commit`.
</details>

<details>
<summary><b>Q43: Scenario: What is a fast-forward merge?</b></summary>
A fast-forward merge occurs when the target branch has no new commits since the source branch split. Git simply moves the branch pointer forward to point to the source branch commit, without creating a merge commit.
</details>

<details>
<summary><b>Q44: Scenario: You want to force a merge commit to be created even if a fast-forward merge is possible. What flag?</b></summary>
Run:
```bash
git merge --no-ff feature
```
</details>

<details>
<summary><b>Q45: Scenario: You are rebasing your branch onto `main` and hit a conflict. How do you resume the rebase after resolving conflicts and staging files?</b></summary>
Do not run `git commit`. Instead, run:
```bash
git rebase --continue
```
</details>

<details>
<summary><b>Q46: Scenario: How do you cancel an active rebase session and return to the state before rebasing began?</b></summary>
Run:
```bash
git rebase --abort
```
</details>

<details>
<summary><b>Q47: Scenario: What is the main danger of rebasing commits that have already been pushed to a shared remote repository?</b></summary>
Rebasing changes/rewrites commit hashes. If other developers are working on those commits, it will break their branches and desynchronize histories, forcing complex reconciliations.
</details>

<details>
<summary><b>Q48: Scenario: You want to merge branch `feature` into `main`, but prefer to keep all conflicts resolved in favor of the current branch (`main`). How?</b></summary>
Use the `ours` strategy:
```bash
git merge feature -X ours
```
</details>

<details>
<summary><b>Q50: Scenario: You want to merge branch `feature` but favor their changes in all conflicts. How?</b></summary>
Use the `theirs` strategy:
```bash
git merge feature -X theirs
```
</details>

<details>
<summary><b>Q51: Scenario: What is the difference between `git merge` and `git rebase`?</b></summary>
- `merge` joins branch histories together, creating a new merge commit. Preserves history exactly as it occurred.
- `rebase` rewrites the project history by placing the current branch commits on top of the target branch, keeping history linear.
</details>

<details>
<summary><b>Q52: Scenario: How do you pull remote changes while forcing a rebase instead of a merge?</b></summary>
Run:
```bash
git pull --rebase
```
</details>

<details>
<summary><b>Q53: Scenario: How do you check if a branch has conflicts with another branch before actually running a merge?</b></summary>
Perform a dry-run merge:
```bash
git merge-tree $(git merge-base main feature) main feature
```
Or run `git merge --no-commit --no-ff feature` and then `git merge --abort`.
</details>

<details>
<summary><b>Q54: Scenario: A developer pushed a rebased branch to remote, but GitHub rejects standard pushes because history is rewritten. How to push safely?</b></summary>
Use force-with-lease (safer than force as it won't overwrite other people's commits):
```bash
git push origin branch-name --force-with-lease
```
</details>

<details>
<summary><b>Q55: Scenario: How do you display conflict differences in a three-way diff?</b></summary>
Run:
```bash
git diff --cc
```
</details>

<details>
<summary><b>Q56: Scenario: How do you checkout a conflicted file during merge to keep our version?</b></summary>
Run:
```bash
git checkout --ours file.txt
```
</details>

<details>
<summary><b>Q57: Scenario: How do you checkout a conflicted file during merge to keep their version?</b></summary>
Run:
```bash
git checkout --theirs file.txt
```
</details>

<summary><b>Q58: Scenario: How do you show the common ancestor commit of two branches?</b></summary>
Run:
```bash
git merge-base main feature
```
</details>

<details>
<summary><b>Q59: Scenario: You want to track conflicts resolved by Git automatically in the future. What configuration enables this?</b></summary>
Enable reuse recorded resolution (`rerere`):
```bash
git config --global rerere.enabled true
```
</details>

<details>
<summary><b>Q60: Scenario: How do you dry-run a merge commit on a remote pull request locally?</b></summary>
Fetch the pull request head: `git fetch origin pull/ID/head:pr-branch`, switch to it, and dry-run merge `main`.
</details>

---

## ✦ Section 4: Git Internals, Reflog & Recovery (Questions 61-80)

<details>
<summary><b>Q61: Scenario: You ran `git reset --hard HEAD~5` and realized you deleted critical work. How do you recover?</b></summary>
1. Run `git reflog` to view the local history of HEAD references.
2. Find the commit hash before the reset (e.g., `HEAD@{1}`).
3. Checkout or reset to it: `git reset --hard HEAD@{1}`.
</details>

<details>
<summary><b>Q62: Scenario: What are the three states in Git?</b></summary>
1. **Working Directory:** Modified files that are not staged.
2. **Staging Area (Index):** Files that are marked for the next commit.
3. **Git Directory (.git Repository):** Comitted files stored in the database.
4. </details>

<details>
<summary><b>Q63: Scenario: How does Git store data internally?</b></summary>
Git is a content-addressable storage filesystem. It stores objects in `.git/objects/` under four types:
- **Blobs:** File contents.
- **Trees:** Directory directories and filenames.
- **Commits:** Commit metadata, author, parent pointer, and reference to tree.
- **Annotated Tags:** References to commits with messages.
</details>

<details>
<summary><b>Q64: Scenario: You suspect your local Git repository is corrupted. How do you scan the object database for errors?</b></summary>
Run:
```bash
git fsck --full
```
</details>

<details>
<summary><b>Q65: Scenario: What is a detached HEAD state?</b></summary>
It occurs when you checkout a specific commit hash or tag instead of a branch. `HEAD` points directly to a commit instead of a branch reference. Any commit made here will not belong to any branch and will be lost unless saved to a new branch.
</details>

<details>
<summary><b>Q66: Scenario: How do you save commits made in a detached HEAD state onto a new branch named `recovery-work`?</b></summary>
Run:
```bash
git checkout -b recovery-work
```
This attaches HEAD to the new branch pointing to the current commit.
</details>

<details>
<summary><b>Q67: Scenario: How do you find the SHA-1 hash of a string "hello" using low-level git commands?</b></summary>
Run:
```bash
echo "hello" | git hash-object --stdin
```
</details>

<details>
<summary><b>Q68: Scenario: You want to inspect the content and type of a git object `a1b2c3d`. What plumbing commands do you use?</b></summary>
- Show type: `git cat-file -t a1b2c3d`
- Show content: `git cat-file -p a1b2c3d`
</details>

<details>
<summary><b>Q69: Scenario: How do you verify what the `HEAD` reference is currently pointing to?</b></summary>
Run:
```bash
cat .git/HEAD
```
(Typically points to `ref: refs/heads/main`).
</details>

<details>
<summary><b>Q70: Scenario: How does `git pull` work under the hood?</b></summary>
`git pull` is a combination of two commands: first it runs `git fetch` (downloads remote commits to target branches), and then runs `git merge` (joins remote tracking branches to local branches).
</details>

<details>
<summary><b>Q71: Scenario: You want to see the difference between your working directory and the staging area (index). What command?</b></summary>
Run:
```bash
git diff
```
</details>

<details>
<summary><b>Q72: Scenario: You want to see the difference between staging area and repository. What command?</b></summary>
Run:
```bash
git diff --cached
```
</details>

<details>
<summary><b>Q73: Scenario: How do you find dangling blobs or commits that are unreferenced?</b></summary>
Run:
```bash
git fsck --lost-found
```
</details>

<details>
<summary><b>Q74: Scenario: Where does Git store the history logs used by the `git reflog` command?</b></summary>
Under `.git/logs/HEAD` and `.git/logs/refs/heads/*`.
</details>

<details>
<summary><b>Q75: Scenario: You want to completely delete reflog history to free space. How?</b></summary>
Run:
```bash
git reflog expire --expire=now --all
git gc --prune=now
```
</details>

<details>
<summary><b>Q76: Scenario: How do you list the commit hashes of all parent commits of a merge commit `m1n2b3v`?</b></summary>
Run:
```bash
git show --pretty=%P -s m1n2b3v
```
</details>

<details>
<summary><b>Q77: Scenario: What is a bare repository?</b></summary>
A bare repository is a Git repository created without a working directory (contains only the `.git` files, created with `git init --bare`). Used as central repositories for push/pull destinations.
</details>

<details>
<summary><b>Q78: Scenario: How do you initialize a new bare repository?</b></summary>
Run:
```bash
git init --bare repo.git
```
</details>

<details>
<summary><b>Q79: Scenario: How do you verify the config variables currently active, showing which files configured them?</b></summary>
Run:
```bash
git config --list --show-origin
```
</details>

<details>
<summary><b>Q80: Scenario: How do you check the size of all packed objects in Git database?</b></summary>
Run:
```bash
git count-objects -v
```
</details>

---

## ✦ Section 5: GitHub Actions & Hooks (Questions 81-100)

<details>
<summary><b>Q81: Scenario: You want to block any commits that contain the word "TODO" in files. How?</b></summary>
Create a client-side `pre-commit` hook in `.git/hooks/pre-commit` containing:
```bash
#!/bin/sh
if git diff --cached | grep -q "TODO"; then
    echo "Aborting commit: Found TODO in code."
    exit 1
fi
```
Make the hook executable: `chmod +x .git/hooks/pre-commit`.
</details>

<details>
<summary><b>Q82: Scenario: How do you disable Git hooks temporarily for a specific commit?</b></summary>
Run:
```bash
git commit -m "bypass hooks" --no-verify
```
</details>

<details>
<summary><b>Q83: Scenario: You want to automate checking of commit message formats (e.g., must contain a ticket ID like PROJ-123). What hook?</b></summary>
Use the `commit-msg` hook located in `.git/hooks/commit-msg`.
</details>

<details>
<summary><b>Q84: Scenario: In GitHub Actions, how do you specify that a workflow should only run on pushes to `main` and pull requests to `dev`?</b></summary>
In the YAML file:
```yaml
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ dev ]
```
</details>

<details>
<summary><b>Q85: Scenario: You want to securely inject an AWS access key into a GitHub Actions step. How?</b></summary>
1. Save the key in GitHub repository -> Settings -> Secrets and variables -> Actions.
2. In the workflow YAML:
```yaml
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
```
</details>

<details>
<summary><b>Q86: Scenario: How do you run steps inside a GitHub Actions job only if a previous step failed?</b></summary>
Use the `if: failure()` expression check:
```yaml
- name: Notify Failure
  if: failure()
  run: echo "The previous step failed."
```
</details>

<details>
<summary><b>Q87: Scenario: You want to reuse a custom action defined in another repository `actions/checkout@v4` in your workflow. How?</b></summary>
Reference it in a step:
```yaml
steps:
  - name: Checkout Code
    uses: actions/checkout@v4
```
</details>

<details>
<summary><b>Q88: Scenario: How do you define dependency relations between different jobs in a GitHub Actions workflow?</b></summary>
Use the `needs` parameter. For example, to make job `deploy` run only after job `build` succeeds:
```yaml
jobs:
  build:
    runs-on: ubuntu-latest
  deploy:
    needs: build
    runs-on: ubuntu-latest
```
</details>

<details>
<summary><b>Q89: Scenario: In GitHub Actions, how do you share build artifacts between a build job and a test job?</b></summary>
Use `actions/upload-artifact@v4` in the first job to save the file, and `actions/download-artifact@v4` in the second job to pull it.
</details>

<details>
<summary><b>Q90: Scenario: How do you configure a matrix build to run tests across Node.js versions 18, 20, and 22 simultaneously?</b></summary>
Define a matrix strategy:
```yaml
strategy:
  matrix:
    node-version: [18, 20, 22]
```
</details>

<details>
<summary><b>Q91: Scenario: What event triggers a workflow manually from the GitHub UI?</b></summary>
Add the `workflow_dispatch` trigger:
```yaml
on:
  workflow_dispatch:
```
</details>

<details>
<summary><b>Q92: Scenario: You want to run a GitHub Actions workflow on a scheduled time (e.g., every midnight). How?</b></summary>
Use a cron schedule:
```yaml
on:
  schedule:
    - cron: '0 0 * * *'
```
</details>

<details>
<summary><b>Q93: Scenario: How do you set environment variables scoped only to a single step in a job?</b></summary>
Define the `env` block inside the step:
```yaml
- name: Build
  env:
    BUILD_ENV: production
  run: npm run build
```
</details>

<details>
<summary><b>Q94: Scenario: You want to run a job on a custom self-hosted runner. What runner environment do you specify?</b></summary>
Set `runs-on` to `self-hosted`:
```yaml
runs-on: self-hosted
```
</details>

<details>
<summary><b>Q95: Scenario: How do you skip triggering a GitHub Actions workflow for a specific commit?</b></summary>
Include `[skip ci]` or `[ci skip]` in the commit message.
</details>

<details>
<summary><b>Q96: Scenario: How do you limit a GitHub repository token permission to only read contents in a workflow?</b></summary>
Specify permissions at job or workflow level:
```yaml
permissions:
  contents: read
```
</details>

<details>
<summary><b>Q97: Scenario: What is a Git hook template directory and how do you customize it?</b></summary>
The default template directory is `/usr/share/git-core/templates`. Customize it using `git config --global init.templateDir "/path/to/templates"`.
</details>

<details>
<summary><b>Q98: Scenario: You want to fetch git submodules recursively inside a GitHub Actions checkout step. How?</b></summary>
Configure checkout parameter:
```yaml
- uses: actions/checkout@v4
  with:
    submodules: recursive
```
</details>

<details>
<summary><b>Q99: Scenario: How do you run tests on multiple OS platforms (ubuntu, macos, windows) using a matrix?</b></summary>
Define:
```yaml
strategy:
  matrix:
    os: [ubuntu-latest, macos-latest, windows-latest]
runs-on: ${{ matrix.os }}
```
</details>

<details>
<summary><b>Q100: Scenario: How do you view debug logging for a GitHub Actions run?</b></summary>
Set the repository secret `ACTIONS_STEP_DEBUG` to `true` to enable verbose logging.
</details>
