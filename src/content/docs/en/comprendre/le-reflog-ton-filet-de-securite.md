---
title: The reflog, your safety net
description: Git keeps a journal of everything HEAD and each branch did on your machine, for weeks. A commit "lost" to a reset, a branch -D or a rebase is almost always in it. What the journal contains, what it doesn't, and when it expires.
level: intermediaire
gitVersion: "2.50"
verified: 2026-10-07
published: 2026-10-07
sidebar:
  order: 6
---

## The idea

Every time `HEAD` or a branch changes position, through a commit, a branch change, a reset, a rebase, Git adds a line to a local journal: where we came from, where we're going, and why. That's the **reflog**. A commit no branch reaches any more has disappeared from `git log`, but not from the repository: as long as a line of the journal cites it, it exists, and its id is enough to find it. The journal is kept for ninety days, thirty for the lines leading to commits nothing else reaches.

Two limits, and they matter: the reflog only contains commits, never uncommitted work; and it belongs to your machine, neither pushed nor cloned.

## See for yourself

Three commits, three lines:

```console
$ git log --oneline
4b99ea3 feat: b
8952b33 feat: a
d0a0b32 Premier commit

$ git reflog
4b99ea3 HEAD@{0}: commit: feat: b
8952b33 HEAD@{1}: commit: feat: a
d0a0b32 HEAD@{2}: commit (initial): Premier commit
```

A `reset --hard` moves the branch back. "feat: b" disappears from `log`; the journal, for its part, records the reset and keeps the commit's line:

```console
$ git reset --hard HEAD~1
HEAD is now at 8952b33 feat: a

$ git log --oneline
8952b33 feat: a
d0a0b32 Premier commit

$ git reflog -3
8952b33 HEAD@{0}: reset: moving to HEAD~1
4b99ea3 HEAD@{1}: commit: feat: b
8952b33 HEAD@{2}: commit: feat: a
```

`HEAD@{1}`, "where `HEAD` was just before", is not `HEAD~1`, "the current commit's parent". Here one is the lost commit, the other the first commit:

```console
$ git log --oneline -1 HEAD@{1}
4b99ea3 feat: b

$ git log --oneline -1 HEAD~1
d0a0b32 Premier commit

$ git reset --hard HEAD@{1}
HEAD is now at 4b99ea3 feat: b

$ git log --oneline
4b99ea3 feat: b
8952b33 feat: a
d0a0b32 Premier commit
```

A force-deleted branch: its last commit is in the journal, with its id, and a branch can be recreated on it.

```console
$ git branch -D experimentation
Deleted branch experimentation (was ae0fb9e).

$ git reflog -4
4b99ea3 HEAD@{0}: checkout: moving from experimentation to main
ae0fb9e HEAD@{1}: commit: feat: x
4b99ea3 HEAD@{2}: checkout: moving from main to experimentation
4b99ea3 HEAD@{3}: reset: moving to HEAD@{1}

$ git branch experimentation ae0fb9e

$ git log --oneline experimentation -1
ae0fb9e feat: x
```

Each branch has its own journal, and `main@{1}` is not `HEAD@{1}`: the first is `main`'s previous position, the second `HEAD`'s, which also moves at every branch change.

```console
$ git reflog show main -3
4b99ea3 main@{0}: reset: moving to HEAD@{1}
8952b33 main@{1}: reset: moving to HEAD~1
4b99ea3 main@{2}: commit: feat: b

$ git log --oneline -1 main@{1}
8952b33 feat: a

$ git log --oneline -1 HEAD@{1}
ae0fb9e feat: x
```

The journal is local. On a colleague's machine that just cloned, it only contains the clone:

```console
$ git reflog
d0a0b32 HEAD@{0}: clone: from github.com:equipe/projet.git
```

And it only contains commits. A change never committed, thrown away by a `reset --hard`, leaves no trace:

```console
$ echo "modif" >> a.js && git status --short
 M a.js

$ git reset --hard
HEAD is now at 4b99ea3 feat: b

$ git reflog -1
4b99ea3 HEAD@{0}: reset: moving to HEAD

$ cat a.js
a
```

Finally, the journal expires. When its lines are gone, the cleanup takes away the commits nothing reaches any more. Here the expiry is forced to show it; for real, it takes weeks:

```console
$ git branch -D experimentation
Deleted branch experimentation (was ae0fb9e).

$ git cat-file -t ae0fb9e
commit

$ git reflog expire --expire=now --all && git gc --prune=now -q

$ git cat-file -t ae0fb9e
fatal: Not a valid object name ae0fb9e
```

## What it changes in practice

- **A commit is rarely lost.** `reset --hard` too far, `branch -D` too fast, a failed rebase: `git reflog`, the id, and a branch or a `reset --hard HEAD@{n}` onto it.
- **Quickly, not in six months.** Thirty days for what nothing reaches any more, then the cleanup passes. A lost commit is recovered the same week.
- **Uncommitted work has no net.** `reset --hard`, `restore`, `checkout -- file` on uncommitted changes: no line anywhere. Committing often, even as a draft, is giving yourself that net.
- **The reflog doesn't leave your machine.** A dying disk takes the never-pushed commits with it, reflog included. Pushing early, even to a draft branch, is the real insurance.
- **`HEAD@{1}` and `HEAD~1` only point to the same commit by chance.** The braces speak of the journal, the tilde of the history.
- **Never "free up space" with `gc --prune=now`** while looking for something: that's precisely the net you're cutting.

## Where it's used

- [Finding a lost commit](/en/situations/reparer/retrouver-un-commit-perdu/)
- [Undoing my last commit, not yet pushed](/en/situations/reparer/annuler-mon-dernier-commit/)
- [Deleting an old branch without losing anything](/en/situations/quotidien/supprimer-une-vieille-branche-sans-rien-perdre/)
- [I am in "detached HEAD"](/en/situations/reparer/detached-head/)
- [What Git deletes, and when](/en/comprendre/ce-que-git-supprime-et-quand/)
- Commands: [`git reflog`](/en/commandes/reflog/), [`git reset`](/en/commandes/reset/)

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/comprendre/le-reflog-ton-filet-de-securite.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/comprendre/le-reflog-ton-filet-de-securite.sh), run with Git 2.50 on 7 October 2026. The journal's expiry is forced there with `--expire=now`, in the sandbox only. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
