---
title: Setting my work in progress aside to change branch
description: 'Git refuses to switch branches, "Your local changes would be overwritten by checkout". How to set your work aside with git stash, get it back intact, and what happens underneath.'
level: debutant
risk: aucun
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
---

## Symptom

You are in the middle of a development, nothing is finished, and you're asked to fix an urgent bug on `main`:

```console
$ git status --short
 M recherche.js
?? brouillon.txt

$ git switch main
error: Your local changes to the following files would be overwritten by checkout:
	recherche.js
Please commit your changes or stash them before you switch branches.
Aborting
```

## Diagnosis

Changing branch means replacing the files in the folder with those of the other branch. `recherche.js` doesn't exist on `main`: switching there would erase your changes. Git refuses to lose work that exists nowhere else. It offers you two ways out: commit, or set aside.

Committing half-done work is possible, but you end up with a "WIP" commit to clean up later. Setting aside is made for this.

## Solution

**1. Set your work aside.** `-u` also takes the new, not yet tracked files along; the message will help you find your way later.

```console
$ git stash push -u -m "Filtre de recherche en cours"
Saved working directory and index state On feature/recherche: Filtre de recherche en cours

$ git status --short
```

The folder is clean, as at the last commit.

**2. Change branch, make the fix, commit it.**

```console
$ git switch main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.
```

**3. Come back and get your work back.**

```console
$ git switch feature/recherche
Switched to branch 'feature/recherche'

$ git stash list
stash@{0}: On feature/recherche: Filtre de recherche en cours

$ git stash pop
On branch feature/recherche
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   recherche.js

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	brouillon.txt

no changes added to commit (use "git add" and/or "git commit -a")
Dropped refs/stash@{0} (1908be8eec168ebcfe850c21f2d2f57f09b3e52e)

$ git status --short
 M recherche.js
?? brouillon.txt
```

Everything is back: the modification, and the new file.

## Why it works

A stash is a commit like any other, but hidden: it is on no branch, Git files it under a special reference, `refs/stash`, as a stack. `git stash push` creates that commit with the state of your folder, then resets the folder to the branch's last commit. `git stash pop` reapplies that commit and removes it from the stack; `git stash apply` does the same without removing it.

Since it's a commit, a stash keeps indefinitely, can be listed, shown with `git stash show -p`, and can even be reapplied on a different branch than the original one.

## Pitfalls

- **Without `-u`, new files stay in the folder.** They don't prevent the branch change, but they follow you everywhere, and you may commit them by mistake on `main`.
- **Sometimes `git switch` goes through without a word**: if your changes don't touch a file that differs between the two branches, Git takes them along with you. It's intended, but it surprises: you find yourself with your work in progress on `main`. When in doubt, stash.
- **A conflict on `pop`** leaves the stash in the stack: fix the files, then `git stash drop` once it's good.
- **Stashes pile up.** `git stash list` from time to time; without a message, `stash@{3}: WIP on main: a1b2c3d …` says nothing a month later.
- **The alternative for long work**: a second working folder on the same copy of the repository, with `git worktree add`. No more switching, each branch has its folder. Command page coming.

## See also

- [Seeing what changed between my branch and main](/en/situations/quotidien/voir-ce-qui-a-change/)
- [Understand: the index, the step between your folder and the commit](/en/comprendre/l-index-l-etape-entre-ton-dossier-et-le-commit/)

:::note[Try it yourself]
This page's script can create the problem on your machine. From a clone of the [site's repository](https://github.com/Hatimou-Nabina/git-en-situation), in Git Bash on Windows:

```bash
EXERCICE=1 bash scripts/situations/mettre-son-travail-de-cote.sh
```

It stops right after the symptom, tells you which folder to go to and what to do. Fix it, then run it again without `EXERCICE=1` to compare with the solution.
:::

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/situations/mettre-son-travail-de-cote.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/mettre-son-travail-de-cote.sh), run with Git 2.50 on 6 October 2026. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
