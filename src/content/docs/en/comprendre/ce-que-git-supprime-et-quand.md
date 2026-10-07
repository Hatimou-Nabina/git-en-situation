---
title: What Git deletes, and when
description: Git almost never deletes anything right away. A removed file stays in the commits, a nameless commit stays in the repository, held by the reflog, and the cleanup only passes after weeks. What disappears, what stays, and what Git never touches on its own.
level: intermediaire
gitVersion: "2.50"
verified: 2026-10-07
published: 2026-10-07
sidebar:
  order: 9
---

## The idea

Git stores everything it records in an object database, and almost never deletes anything directly. Deleting a file means making a commit that no longer contains it: the previous commits still have it. Deleting a branch means removing a name: the commit stays. An object only disappears through the **cleanup**, `git gc`, which only takes away what nothing reaches any more, neither branch, nor tag, nor reflog line, and the reflog keeps its lines for weeks.

There is one exception, and it matters: what was never committed is in no object. There, Git has nothing to keep.

## See for yourself

A file removed from the folder and committed as such is still readable in the previous commit:

```console
$ git rm -q a.js && git commit -q -m "Retire a.js" && git show HEAD~1:a.js
a
```

A `reset --hard` removes that commit from the branch. It's no longer in `log`, but it's in the repository:

```console
$ git reset --hard HEAD~1
HEAD is now at 8952b33 feat: a

$ git log --oneline
8952b33 feat: a
d0a0b32 Premier commit

$ git cat-file -t 0076ed7
commit

$ git log --oneline -1 0076ed7
0076ed7 Retire a.js
```

What holds it is a reflog line. `fsck --unreachable` doesn't list it, because the journal reaches it; ignoring the journal, it shows up:

```console
$ git reflog -2
8952b33 HEAD@{0}: reset: moving to HEAD~1
0076ed7 HEAD@{1}: commit: Retire a.js

$ git fsck --unreachable

$ git fsck --unreachable --no-reflogs
unreachable commit 0076ed7bbc24d22541e5dbe29e229d201b03ab72
```

When the journal's line expires, the cleanup takes the object away. Here the expiry is forced to show it; for real, thirty days pass first:

```console
$ git reflog expire --expire-unreachable=now --all && git gc --prune=now -q

$ git cat-file -t 0076ed7
fatal: Not a valid object name 0076ed7
```

A deleted stash follows the same rule: no name any more, but the object is there, and `drop` gives its id:

```console
$ echo "b" > b.js && git add b.js && git stash push -q -m "brouillon" && git stash list
stash@{0}: On main: brouillon

$ git stash drop
Dropped refs/stash@{0} (87af157283b150c3dd859345e4673466cae69c42)

$ git cat-file -t 87af157
commit

$ git stash apply 87af157
On branch main
Your branch is ahead of 'origin/main' by 1 commit.
  (use "git push" to publish your local commits)

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	new file:   b.js

```

Conversely, what Git never deletes on its own: your copies of the server's branches, even when the branch no longer exists there. You have to ask it.

```console
$ git branch -r
  origin/HEAD -> origin/main
  origin/feature/ancienne
  origin/main

$ git fetch --prune
From github.com:equipe/projet
 - [deleted]         (none)     -> origin/feature/ancienne

$ git branch -r
  origin/HEAD -> origin/main
  origin/main
```

## What it changes in practice

- **Deleting a file doesn't remove it from the history.** A committed secret can be read in every past commit: [I pushed a secret by mistake](/en/situations/fichiers/secret-pousse-par-erreur/) explains the only real answer, rewriting the history, and why it isn't enough.
- **Deleting a branch deletes no commit.** `-d` refuses when commits would exist nowhere else; `-D` overrides, and the reflog keeps the id for thirty days.
- **The cleanup is slow and cautious**: `git gc` runs on its own from time to time, and only takes away what nothing has reached for weeks. Forcing `--prune=now` is the only way to lose something fast.
- **Uncommitted work is protected by nothing**: no object, no reflog. A `reset --hard` or a `restore` throws it away for good.
- **The server copies and your local branches are yours**: Git only removes them on order, `fetch --prune` for the former, `branch -d` for the latter.
- **The server has no reflog**: what a force push erases over there can only be found on the machine of someone who had fetched it.

## Where it's used

- [Finding a lost commit](/en/situations/reparer/retrouver-un-commit-perdu/)
- [I pushed a secret by mistake](/en/situations/fichiers/secret-pousse-par-erreur/)
- [Deleting an old branch without losing anything](/en/situations/quotidien/supprimer-une-vieille-branche-sans-rien-perdre/)
- [A remote branch was deleted, but I still see it](/en/situations/quotidien/branche-distante-supprimee-encore-visible/)
- [The reflog, your safety net](/en/comprendre/le-reflog-ton-filet-de-securite/)
- [A commit is a snapshot](/en/comprendre/un-commit-est-un-instantane/)

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/comprendre/ce-que-git-supprime-et-quand.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/comprendre/ce-que-git-supprime-et-quand.sh), run with Git 2.50 on 7 October 2026. The journal's expiry is forced there, in the sandbox only; the server branch is created then deleted by a second machine. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
