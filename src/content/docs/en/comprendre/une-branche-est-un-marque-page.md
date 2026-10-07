---
title: A branch is a bookmark
description: A branch is a file that holds a commit's id, nothing more. Committing moves that bookmark, creating one is free, deleting one deletes no commit. Once that model is in your head, reset, detached HEAD and lost branches become obvious.
level: debutant
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
sidebar:
  order: 2
---

## The idea

A branch is not a "copy of the code" or a "line of development" stored somewhere. It's a forty-one-character file: a commit's id, and a line break. A bookmark placed on a commit. `HEAD` is the bookmark that says which branch you are on. When you commit, Git creates the commit, then moves the current branch forward onto it. Nothing else moves.

## See for yourself

```console
$ cat .git/HEAD
ref: refs/heads/main

$ cat .git/refs/heads/main
d0a0b32921f0e3e6484b075d9ff287b1f409cc5c

$ git log --oneline -1
d0a0b32 Premier commit
```

Creating a branch means writing the same id in a new file:

```console
$ git branch feature/recherche

$ cat .git/refs/heads/feature/recherche
d0a0b32921f0e3e6484b075d9ff287b1f409cc5c

$ ls -R .git/refs/heads
.git/refs/heads:
feature
main

.git/refs/heads/feature:
recherche
```

Switching to it changes `HEAD`. Committing moves that branch forward, and only that one:

```console
$ git switch feature/recherche
Switched to branch 'feature/recherche'

$ cat .git/HEAD
ref: refs/heads/feature/recherche

$ cat .git/refs/heads/feature/recherche
5b5dda8e7458ad1406b35f8e2ec6a00141f5f0f3

$ cat .git/refs/heads/main
d0a0b32921f0e3e6484b075d9ff287b1f409cc5c

$ git log --oneline --graph --all
* 5b5dda8 Ajoute la recherche
* d0a0b32 Premier commit
```

"Which branch is this commit on?" has no single answer: a commit is contained by every branch it is an ancestor of.

```console
$ git branch --contains HEAD
* feature/recherche

$ git branch --contains main
* feature/recherche
  main
```

Deleting the branch erases the bookmark. The commit, for its part, is still there:

```console
$ git switch main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.

$ git branch -D feature/recherche
Deleted branch feature/recherche (was 5b5dda8).

$ ls -R .git/refs/heads
.git/refs/heads:
main

$ git cat-file -t 5b5dda8
commit

$ git log --oneline -1 5b5dda8
5b5dda8 Ajoute la recherche
```

## What it changes in practice

- **A branch for each thing, without counting.** Creating, renaming, deleting: these are operations on a forty-one-character file.
- **Deleting a branch loses nothing, as long as another name leads to the commit.** If there is none left, the commit stays in the repository for a while, and the reflog keeps its id.
- **"Moving a commit" means moving bookmarks**: `git branch` places one, `git reset` moves the current branch's back.
- **The "detached HEAD"** is `HEAD` holding a commit id directly instead of `ref: refs/heads/…`. A commit made in that state moves no bookmark forward.
- **The server's branches are the same files**, stored under `refs/remotes/origin/`, and Git only moves them during a `fetch` or a `push`.

## Where it's used

- [Deleting an old branch without losing anything](/en/situations/quotidien/supprimer-une-vieille-branche-sans-rien-perdre/)
- [I committed on the wrong branch](/en/situations/reparer/commit-sur-la-mauvaise-branche/)
- [Renaming a branch, locally and on the server](/en/situations/quotidien/renommer-une-branche/)
- [I am in "detached HEAD"](/en/situations/reparer/detached-head/)
- [Finding a lost commit](/en/situations/reparer/retrouver-un-commit-perdu/)
- [Remotes and remote-tracking references](/en/comprendre/remotes-et-references-distantes/)

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/comprendre/une-branche-est-un-marque-page.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/comprendre/une-branche-est-un-marque-page.sh), run with Git 2.50 on 6 October 2026. In an older repository, Git packs the bookmarks into `.git/packed-refs` and the individual files may be missing; `git show-ref` lists them in every case. The example repository's commit messages are in French.
:::
