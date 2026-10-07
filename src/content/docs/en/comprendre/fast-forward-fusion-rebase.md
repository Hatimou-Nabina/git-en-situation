---
title: Fast-forward, merge, rebase
description: Three ways to bring two lines of work together. The fast-forward moves a bookmark, the merge creates a commit with two parents, the rebase copies commits. What each one leaves in the history, and when to choose which.
level: intermediaire
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
sidebar:
  order: 4
---

## The idea

Two branches, and you want one to contain the other's work. Git has three answers, and the right choice depends on a single question: **have both moved forward since they parted?**

- If only one moved forward, there is nothing to bring together: Git moves the other's bookmark all the way. That's the **fast-forward**.
- If both moved forward, either you create a commit that has both as parents, the **merge**, or you copy one's commits on top of the other, the **rebase**.

## See for yourself

**Case 1: `main` hasn't moved since the branch was created.**

```console
$ git log --oneline --graph --all
* 56c300b Ajoute a
* d0a0b32 Premier commit

$ git merge feature/a
Updating d0a0b32..56c300b
Fast-forward
 a.txt | 1 +
 1 file changed, 1 insertion(+)
 create mode 100644 a.txt

$ git log --oneline --graph --all
* 56c300b Ajoute a
* d0a0b32 Premier commit
```

No commit created. `main` was on `d0a0b32`, it is now on `56c300b`, and the history is exactly the same as before.

**Case 2: both moved forward.** Git first finds their last common point:

```console
$ git log --oneline --graph --all
* ec93f91 Ajoute b
| * fe06073 Ajoute c
|/
* 56c300b Ajoute a
* d0a0b32 Premier commit

$ git merge-base main feature/b
56c300b2b7d2a2b596607ce7c6454b0b731de9ce
```

**The merge** creates a commit with two parents. Both lines stay visible:

```console
$ git merge feature/b
Merge made by the 'ort' strategy.
 b.txt | 1 +
 1 file changed, 1 insertion(+)
 create mode 100644 b.txt

$ git log --oneline --graph --all
*   753cba5 Merge branch 'feature/b'
|\
| * ec93f91 Ajoute b
* | fe06073 Ajoute c
|/
* 56c300b Ajoute a
* d0a0b32 Premier commit

$ git log --format='%h  parents: %p  %s' -1
753cba5  parents: fe06073 ec93f91  Merge branch 'feature/b'
```

**The rebase**, on the same starting state, copies the branch's commits on top of `main`. `ec93f91` becomes `71f6422`: same content, different parent, different commit. Afterwards, `main` can move forward by fast-forward:

```console
$ git switch feature/b
Switched to branch 'feature/b'

$ git rebase main
Rebasing (1/1)Successfully rebased and updated refs/heads/feature/b.

$ git log --oneline --graph --all
* 71f6422 Ajoute b
* fe06073 Ajoute c
* 56c300b Ajoute a
* d0a0b32 Premier commit

$ git switch main
Switched to branch 'main'
Your branch is ahead of 'origin/main' by 2 commits.
  (use "git push" to publish your local commits)

$ git merge feature/b
Updating fe06073..71f6422
Fast-forward
 b.txt | 1 +
 1 file changed, 1 insertion(+)
 create mode 100644 b.txt
```

A straight line, as if `b` had been written after `c`. It's chronologically false, and it's intended: the history tells a readable order, not the reality of the timings.

**Forcing a merge commit** even when a fast-forward is possible, to keep the trace that a branch existed:

```console
$ git merge --no-ff feature/d
Merge made by the 'ort' strategy.
 d.txt | 1 +
 1 file changed, 1 insertion(+)
 create mode 100644 d.txt

$ git log --oneline --graph -4
*   818ae05 Merge branch 'feature/d'
|\
| * 03f353c Ajoute d
|/
* 71f6422 Ajoute b
* fe06073 Ajoute c
```

## What it changes in practice

- **On a shared branch you only follow**, like `main`, you want fast-forwards only: `git pull --ff-only`. If it fails, you committed on it by mistake, and that's good to know.
- **On your own branch, before asking for review**, the rebase onto `main` gives a clean pull request, without stray merge commits. Since it copies your commits, the next push is forced, with `--force-with-lease`.
- **When a branch is shared**, or when the story of the crossing matters, the merge: nothing is rewritten, nobody needs to force.
- **GitHub's three buttons** do exactly that: "Create a merge commit" is a `merge --no-ff`, "Rebase and merge" a rebase followed by a fast-forward, "Squash and merge" makes a single new commit with the whole content of the branch.
- **Conflicts are the same** in all three cases, only the way to resume differs: `git commit` after a merge, `git rebase --continue` after a rebase.

## Where it's used

- [git pull asks me to choose between merge and rebase](/en/situations/quotidien/git-pull-merge-ou-rebase/)
- [Updating my branch with main](/en/situations/avec-les-autres/mettre-ma-branche-a-jour-avec-main/)
- [My push is rejected, "rejected", "fetch first"](/en/situations/quotidien/push-refuse-fetch-first/)
- [A conflict during a merge or a rebase](/en/situations/reparer/resoudre-un-conflit/)
- [My local branch is behind after a merge on GitHub](/en/situations/avec-les-autres/branche-locale-en-retard-apres-fusion/)
- [A commit is a snapshot](/en/comprendre/un-commit-est-un-instantane/)

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/comprendre/fast-forward-fusion-rebase.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/comprendre/fast-forward-fusion-rebase.sh), run with Git 2.50 on 6 October 2026. The merge and the rebase are played on two copies of the same state. Only the commit ids are those of the example repository, whose commit messages are in French.
:::
