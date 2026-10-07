---
title: I committed on the wrong branch
description: The commit went to main instead of a working branch, or to the branch next door. How to move it without losing anything, as long as it isn't pushed, and what to do if it already is.
level: intermediaire
risk: reversible
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptom

You meant to open a branch for the search feature. You forgot, and the commit went to `main`:

```console
$ git status
On branch main
Your branch is ahead of 'origin/main' by 1 commit.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean

$ git log --oneline -2
5b5dda8 Ajoute la recherche
d0a0b32 Premier commit
```

"Ahead of 'origin/main' by 1 commit": the commit isn't pushed. Good news, everything gets sorted out locally.

## Diagnosis

A commit doesn't belong to a branch. A branch is a bookmark placed on a commit, that's all. "Moving a commit" therefore means moving bookmarks: placing a new one on the commit, the right branch, then moving back the one that shouldn't have advanced. The commit doesn't move, nothing is copied or lost.

## Solution

**Case 1: the commit is on `main`, it should have opened a branch.**

1. Place the branch on the commit, without switching to it:

```console
$ git branch feature/recherche
```

2. Put `main` back where the server has it:

```console
$ git reset --keep origin/main

$ git log --oneline -2
d0a0b32 Premier commit
```

3. Carry on on the branch, the commit is waiting for you there:

```console
$ git switch feature/recherche
Switched to branch 'feature/recherche'

$ git log --oneline -2
5b5dda8 Ajoute la recherche
d0a0b32 Premier commit
```

**Case 2: the commit went to another working branch.** You were on `feature/export`, and a commit for the search feature slipped in:

```console
$ git log --oneline -3
4c2654e Trie les resultats de recherche
3481de9 Ajoute un export
d0a0b32 Premier commit
```

1. Copy it onto the right branch. A branch's name refers to its last commit, so that's the one `cherry-pick` takes:

```console
$ git switch feature/recherche
Switched to branch 'feature/recherche'

$ git cherry-pick feature/export
[feature/recherche f4c3525] Trie les resultats de recherche
 Date: Mon Oct 5 10:00:00 2026 +0000
 1 file changed, 1 insertion(+)
 create mode 100644 tri.js

$ git log --oneline -3
f4c3525 Trie les resultats de recherche
5b5dda8 Ajoute la recherche
d0a0b32 Premier commit
```

2. Remove it from the wrong one:

```console
$ git switch feature/export
Switched to branch 'feature/export'

$ git reset --keep HEAD~1

$ git log --oneline -3
3481de9 Ajoute un export
d0a0b32 Premier commit
```

The copied commit has a new id, `4c2654e` became `f4c3525`: same content, different parent, so a different commit.

**Case 3: the commit is already pushed.** Don't rewrite a branch others have fetched. On `main`, leave it and undo it cleanly if needed: [Undoing a commit already pushed](/en/situations/reparer/annuler-un-commit-deja-pousse/). On your own working branch, not yet reviewed by anyone, cases 1 and 2 apply, followed by a `git push --force-with-lease`.

## Why it works

`git branch feature/recherche` creates a bookmark on the current commit. `git reset origin/main` moves the current branch's bookmark to the targeted commit; with `--keep`, Git also brings the working folder in line with that commit, but **refuses** if uncommitted changes would be lost in the process. That's what makes it preferable to `--hard`, which would throw them away without a word.

Nothing is deleted: after the reset, commit `5b5dda8` stays reachable from `feature/recherche`. `cherry-pick`, for its part, replays a commit's changes as a new commit on the current branch.

## Pitfalls

- **Check that the commit isn't pushed** before moving a branch back: `git status` must say "ahead". If it says "up to date with 'origin/main'" while the commit is there, it's pushed: case 3.
- **Forgetting the `git branch` step** before the reset makes the commit invisible. It isn't lost: [Finding a lost commit](/en/situations/reparer/retrouver-un-commit-perdu/).
- **Several commits**: `git reset --keep origin/main` moves back all unpushed commits at once, and the branch placed beforehand keeps them all. For case 2, `cherry-pick` accepts a range: `git cherry-pick 3481de9..feature/export`.
- **`git reset --hard`** does the same thing as `--keep` here, but also erases any uncommitted work. Keep it for the cases where that's intended.

## See also

- [Undoing my last commit, not yet pushed](/en/situations/reparer/annuler-mon-dernier-commit/)
- [Undoing a commit already pushed](/en/situations/reparer/annuler-un-commit-deja-pousse/)
- [Finding a lost commit](/en/situations/reparer/retrouver-un-commit-perdu/)
- [Understand: a branch is a bookmark](/en/comprendre/une-branche-est-un-marque-page/)

:::note[Try it yourself]
This page's script can create the problem on your machine. From a clone of the [site's repository](https://github.com/Hatimou-Nabina/git-en-situation), in Git Bash on Windows:

```bash
EXERCICE=1 bash scripts/situations/commit-sur-la-mauvaise-branche.sh
```

It stops right after the symptom, tells you which folder to go to and what to do. Fix it, then run it again without `EXERCICE=1` to compare with the solution.
:::

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/situations/commit-sur-la-mauvaise-branche.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/commit-sur-la-mauvaise-branche.sh), run with Git 2.50 on 5 October 2026. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
