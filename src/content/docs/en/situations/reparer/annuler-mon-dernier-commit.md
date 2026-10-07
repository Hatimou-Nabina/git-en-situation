---
title: Undoing my last commit, not yet pushed
description: Wrong message, forgotten file, or a commit to undo completely. The three cases, with commit --amend and git reset, what each one keeps or throws away, and how to go back even after a --hard.
level: intermediaire
risk: destructif
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptom

You just committed, and you see the problem right after: a typo in the message, a forgotten file, or a commit that should never have existed. Nothing is pushed.

```console
$ git log --oneline -1
808235f Ajoute la recherhce
```

## Diagnosis

As long as a commit isn't pushed, it exists only on your machine: you can replace it or undo it without bothering anyone. Git offers two tools depending on the need. `commit --amend` **replaces** the last commit with a corrected version. `reset` **moves the branch back** by one or more commits, keeping or not the work they contained.

:::caution[Only one command on this page throws work away]
`git reset --hard` erases changes. The end of the page shows how to recover a commit erased by mistake, but not changes that were never committed.
:::

## Solution

**Case 1: the message is wrong.**

```console
$ git commit --amend -m "Ajoute la recherche"
[feature/recherche 5b5dda8] Ajoute la recherche
 Date: Mon Oct 5 10:00:00 2026 +0000
 1 file changed, 1 insertion(+)
 create mode 100644 recherche.js

$ git log --oneline -1
5b5dda8 Ajoute la recherche
```

**Case 1 bis: a file is missing.** Add it, then amend while keeping the message:

```console
$ git add recherche.test.js

$ git commit --amend --no-edit
[feature/recherche 847c9cb] Ajoute la recherche
 Date: Mon Oct 5 10:00:00 2026 +0000
 2 files changed, 2 insertions(+)
 create mode 100644 recherche.js
 create mode 100644 recherche.test.js

$ git show --stat --oneline HEAD
847c9cb Ajoute la recherche
 recherche.js      | 1 +
 recherche.test.js | 1 +
 2 files changed, 2 insertions(+)
```

**Case 2: undo the commit, keep the work.** The files come back into the index, ready for a new commit:

```console
$ git reset --soft HEAD~1

$ git status --short
A  recherche.js
A  recherche.test.js

$ git log --oneline -1
d0a0b32 Premier commit
```

**Case 3: undo the commit and throw the work away.**

```console
$ git reset --hard HEAD~1
HEAD is now at d0a0b32 Premier commit

$ git status --short

$ git log --oneline -1
d0a0b32 Premier commit
```

**Even after `--hard`, the commit isn't lost right away.** The reflog keeps a trace of every position of the branch:

```console
$ git reflog -3
d0a0b32 HEAD@{0}: reset: moving to HEAD~1
4bdd879 HEAD@{1}: commit: Ajoute la recherche et son test
d0a0b32 HEAD@{2}: reset: moving to HEAD~1

$ git reset --hard HEAD@{1}
HEAD is now at 4bdd879 Ajoute la recherche et son test

$ git log --oneline -1
4bdd879 Ajoute la recherche et son test

$ git ls-files
README.md
recherche.js
recherche.test.js
```

## Why it works

A commit cannot be modified: `--amend` creates a new one, with the same parent, and moves the branch onto it. Hence the id changing every time, `808235f`, then `5b5dda8`, then `847c9cb`. The old commit stays in the repository, nameless, until the automatic cleanup.

`git reset HEAD~1` moves the branch onto the previous commit. What changes is the fate of the content: `--soft` touches nothing else, the changes of the undone commit stay in the index; `--mixed`, the default, leaves them in the folder but out of the index; `--hard` also resets the folder to the targeted commit, so it erases those changes. The reflog, for its part, records every move of the branch: `HEAD@{1}` means "where I was just before", whatever the command that moved me away.

## Pitfalls

- **Never on a pushed commit.** Amending or moving back a commit the server already has makes the next push fail, and the temptation to force destroys other people's work. For a pushed commit: [Undoing a commit already pushed](/en/situations/reparer/annuler-un-commit-deja-pousse/).
- **`--hard` also erases what wasn't committed.** Before a `--hard`, `git status`; if there are changes in progress you want to keep, [set them aside](/en/situations/quotidien/mettre-son-travail-de-cote/) first.
- **`HEAD@{1}` is not `HEAD~1`.** The first is a position in the reflog, "just before"; the second is the parent of the current commit. Mixing them up in a `reset --hard` leads to the wrong place.
- **For a single file**, no need to undo the commit: `git restore --source HEAD~1 path` brings back its previous version, to commit afterwards.
- **`--amend` without `-m` or `--no-edit`** opens the configured editor to rework the message. If it's Vim and you don't know it: `:q!` leaves without changing anything.

## See also

- [I committed on the wrong branch](/en/situations/reparer/commit-sur-la-mauvaise-branche/)
- [Undoing a commit already pushed](/en/situations/reparer/annuler-un-commit-deja-pousse/)
- [Finding a lost commit](/en/situations/reparer/retrouver-un-commit-perdu/)
- [Understand: the reflog, your safety net](/en/comprendre/le-reflog-ton-filet-de-securite/)

:::note[Try it yourself]
This page's script can create the problem on your machine. From a clone of the [site's repository](https://github.com/Hatimou-Nabina/git-en-situation), in Git Bash on Windows:

```bash
EXERCICE=1 bash scripts/situations/annuler-mon-dernier-commit.sh
```

It stops right after the symptom, tells you which folder to go to and what to do. Fix it, then run it again without `EXERCICE=1` to compare with the solution.
:::

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/situations/annuler-mon-dernier-commit.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/annuler-mon-dernier-commit.sh), run with Git 2.50 on 5 October 2026. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
