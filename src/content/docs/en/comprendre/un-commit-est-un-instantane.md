---
title: A commit is a snapshot
description: A commit is not a difference, it is a complete picture of the project, with its author, its message and its parent. Its id is the fingerprint of all that. That is why you never modify a commit, you make another one.
level: debutant
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
sidebar:
  order: 1
---

## The idea

A commit is a picture of the whole project at a given instant, along with four pieces of information: who, when, why (the message), and where we come from (the parent commit or commits). Its name, that forty-character string of which we quote the first seven, is the fingerprint of all that. Change one byte of the content, one letter of the message, the parent, and the fingerprint changes: it's another commit.

It is **not** a difference. The difference `git show` displays is computed by Git by comparing two pictures.

## See for yourself

The last commit, as Git stores it:

```console
$ git log --oneline -2
86601e7 Ajoute l application
d0a0b32 Premier commit

$ git cat-file -p HEAD
tree cdc69cad0d86b74201c78b3873e94acc2019e27d
parent d0a0b32921f0e3e6484b075d9ff287b1f409cc5c
author Awa <awa@example.com> 1791194400 +0000
committer Awa <awa@example.com> 1791194400 +0000

Ajoute l application
```

Four lines and a message. The `tree` is the picture: the list of every file in the project, with the fingerprint of its content. The previous commit's has only one file:

```console
$ git cat-file -p HEAD^{tree}
100644 blob b60e1ad35025d69cbe886686e6a0b040551b9fde	README.md
100644 blob e14c4f2a9561ade31986f9319d5c639094509905	app.js

$ git cat-file -p HEAD~1^{tree}
100644 blob b60e1ad35025d69cbe886686e6a0b040551b9fde	README.md
```

`README.md` didn't change between the two: same fingerprint, and Git stores it only once.

```console
$ git rev-parse HEAD:README.md HEAD~1:README.md
b60e1ad35025d69cbe886686e6a0b040551b9fde
b60e1ad35025d69cbe886686e6a0b040551b9fde
```

What `git show` displays as "one file added" is computed by comparing the two trees:

```console
$ git show --stat --oneline HEAD
86601e7 Ajoute l application
 app.js | 1 +
 1 file changed, 1 insertion(+)
```

Rework only the message, without touching a file:

```console
$ git commit --amend -q -m "Ajoute l application (message retouche)"

$ git log --oneline -2
bfa6f25 Ajoute l application (message retouche)
d0a0b32 Premier commit

$ git cat-file -p HEAD
tree cdc69cad0d86b74201c78b3873e94acc2019e27d
parent d0a0b32921f0e3e6484b075d9ff287b1f409cc5c
author Awa <awa@example.com> 1791194400 +0000
committer Awa <awa@example.com> 1791194400 +0000

Ajoute l application (message retouche)
```

Same tree, same parent, same author. Another commit: `86601e7` became `bfa6f25`. The old one still exists, nothing points to it any more.

## What it changes in practice

- **"Modifying a commit" doesn't exist.** `--amend`, `rebase`, `cherry-pick`, `filter-repo` make new commits. That's why a pushed commit is not reworked: the others have the old one, and the two don't recognise each other.
- **The same change on another parent is another commit.** A `cherry-pick` copies, it doesn't move.
- **A fingerprint names an exact content, forever.** That's what makes it possible to find a "lost" commit: as long as the object exists in the repository, its name is enough.
- **Git stores pictures, not differences**, but it stores each file only once per version: a repository of a thousand commits where a file never changed contains it only once. A large binary file modified often, on the other hand, costs its size at every version.

## Where it's used

- [Undoing my last commit, not yet pushed](/en/situations/reparer/annuler-mon-dernier-commit/)
- [I committed on the wrong branch](/en/situations/reparer/commit-sur-la-mauvaise-branche/)
- [Undoing a commit already pushed](/en/situations/reparer/annuler-un-commit-deja-pousse/)
- [Finding a lost commit](/en/situations/reparer/retrouver-un-commit-perdu/)
- [I pushed a secret by mistake](/en/situations/fichiers/secret-pousse-par-erreur/)

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/comprendre/un-commit-est-un-instantane.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/comprendre/un-commit-est-un-instantane.sh), run with Git 2.50 on 5 October 2026. The dates are frozen by the script, hence the same ids at every run. The example repository's commit messages are in French.
:::
