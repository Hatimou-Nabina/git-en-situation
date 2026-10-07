---
title: Finding a lost commit
description: A branch deleted too fast, a reset --hard too far, and the commit vanished from git log. The reflog kept it. How to find it, and how long Git keeps it.
level: intermediaire
risk: aucun
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptom

You deleted an experimentation branch, and you realise it held a commit you wanted to keep:

```console
$ git branch -D experimentation
Deleted branch experimentation (was e08efa9).

$ git log --oneline --all
d0a0b32 Premier commit
```

Even with `--all`, the commit no longer shows up anywhere.

## Diagnosis

Git doesn't delete commits: it deletes the **names** that lead to them. A commit without a branch or a tag becomes invisible to `git log`, but it is still in the repository. And Git keeps a journal of everything HEAD has visited, the **reflog**. Finding a commit means finding its id there and giving it a name again.

## Solution

**Case 1: a deleted branch.** Git even gave you the id in the message, "was e08efa9". If the terminal has scrolled far away, the reflog has it:

```console
$ git reflog -4
d0a0b32 HEAD@{0}: checkout: moving from experimentation to main
e08efa9 HEAD@{1}: commit: Essai prometteur
d0a0b32 HEAD@{2}: checkout: moving from main to experimentation
d0a0b32 HEAD@{3}: commit (initial): Premier commit
```

Recreate the branch on that commit:

```console
$ git branch experimentation e08efa9

$ git log --oneline experimentation -1
e08efa9 Essai prometteur
```

**Case 2: a `reset --hard` too far.** Two commits from the day, erased at once:

```console
$ git reset --hard HEAD~2
HEAD is now at d0a0b32 Premier commit

$ git log --oneline -1
d0a0b32 Premier commit
```

The reflog shows where the branch was just before, and a second reset goes back there:

```console
$ git reflog -3
d0a0b32 HEAD@{0}: reset: moving to HEAD~2
b15abe4 HEAD@{1}: commit: Travail de l apres-midi
81ceaf2 HEAD@{2}: commit: Travail du matin

$ git reset --hard HEAD@{1}
HEAD is now at b15abe4 Travail de l apres-midi

$ git log --oneline -3
b15abe4 Travail de l apres-midi
81ceaf2 Travail du matin
d0a0b32 Premier commit
```

## Why it works

Every time HEAD changes position, through a commit, a branch change, a reset, a rebase, Git adds a line to the reflog, with the commit's id and the reason. Entries are kept **90 days**, and **30 days** for those leading to commits nothing else reaches any more. During that time, the commit is protected from the automatic cleanup.

`HEAD@{1}` reads "HEAD's position just before the last one", `HEAD@{2}` the one before, and so on. These are positions in the journal, not parents in the history.

Each branch also has its own reflog: `git reflog show feature/recherche` shows only the positions it occupied.

## Pitfalls

- **The reflog is local.** It is neither pushed nor cloned. A commit never pushed, lost on a dead disk or in a deleted folder, is lost for good. Pushing early, even to a draft branch, is the real insurance.
- **`HEAD@{1}` is not `HEAD~1`**: position in the journal versus parent of the commit. A `reset --hard` on the wrong one of the two sends you elsewhere. The reflog is there to start over, but better to read before typing.
- **A deleted stash** is not in HEAD's reflog. `git fsck --unreachable | grep commit` lists the commits nothing reaches any more, and `git show` on each one lets you recognise the right one.
- **`git gc --prune=now` or `git reflog expire --expire=now`** remove the safety net immediately. Don't run them to "free up space" while you're looking for something.

## See also

- [Undoing my last commit, not yet pushed](/en/situations/reparer/annuler-mon-dernier-commit/)
- [I am in "detached HEAD"](/en/situations/reparer/detached-head/)
- [Deleting an old branch without losing anything](/en/situations/quotidien/supprimer-une-vieille-branche-sans-rien-perdre/)
- Understand: *The reflog, your safety net* and *What Git deletes, and when* (coming)

:::note[Try it yourself]
This page's script can create the problem on your machine. From a clone of the [site's repository](https://github.com/Hatimou-Nabina/git-en-situation), in Git Bash on Windows:

```bash
EXERCICE=1 bash scripts/situations/retrouver-un-commit-perdu.sh
```

It stops right after the symptom, tells you which folder to go to and what to do. Fix it, then run it again without `EXERCICE=1` to compare with the solution.
:::

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/situations/retrouver-un-commit-perdu.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/retrouver-un-commit-perdu.sh), run with Git 2.50 on 5 October 2026. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
