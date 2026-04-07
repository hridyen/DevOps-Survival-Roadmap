[![Sector](https://img.shields.io/badge/SECTOR-Git_Version_Control-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Advanced_Branching_Commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Branching & Flow — Commands Reference

---

## ✦ 🔀 Branch Integrations

```bash
# Instantiations
git branch                            # Displays active local branches natively
git checkout feature-login            # Manually switches active branch heads
git checkout -b feature-login         # Creates an active branch AND checks it out simultaneously

# Merging Execution
git merge feature-login               # Safely merges specified branch into active Current branch tracking
git branch -d feature-login           # Deletes branch softly (Errors if not merged!)
git branch -D feature-login           # Aggressively deletes branch memory locally entirely
```

---

## ✦ 🕒 Manipulating History

```bash
# Complex Rewrites
git rebase main                       # Detach active branch and aggressively re-anchor to latest main!
git cherry-pick <hash>                # Steal an exact commit hash dynamically

# Visualization Auditing
git log --oneline --graph             # The most critical debugging tool for mapping exact merge nodes visually!
```

---

## ✦ 📝 My Pipeline Execution Notes

| Command | What it does | Real-World Scenario |
|---------|-------------|----------------|
| `git stash pop` | Resurrects dynamically un-committed raw code that was saved silently using `git stash` to clean the cache. | Extremely useful when checking out a secondary branch to investigate a bug without completely obliterating half-written uncommitted scripts! |
