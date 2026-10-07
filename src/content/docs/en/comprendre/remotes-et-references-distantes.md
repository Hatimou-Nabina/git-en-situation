---
title: Remotes and remote-tracking references
description: origin is a nickname for an address, origin/main is your local copy of the server's branch, and your main is tied to it. Three things are called main, and almost every surprise with fetch, pull and push comes from confusing them.
level: debutant
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
sidebar:
  order: 3
---

## The idea

A **remote** is a nickname for a server address: `origin` is the one `git clone` gives to the original repository. A **remote-tracking reference**, `origin/main`, is your local copy of the server's `main` branch, **as you last saw it**: it only moves when you talk to the server, through `fetch` or `push`. And your `main` branch is **tied** to it, which lets Git tell you "ahead" or "behind".

Three things are therefore called `main`: yours, your copy of the server's, and the server's. Only the first two are on your disk.

## See for yourself

```console
$ git remote -v
origin	github.com:equipe/projet.git (fetch)
origin	github.com:equipe/projet.git (push)

$ git branch -a
* main
  remotes/origin/main

$ git show-ref main
d0a0b32921f0e3e6484b075d9ff287b1f409cc5c refs/heads/main
d0a0b32921f0e3e6484b075d9ff287b1f409cc5c refs/remotes/origin/main

$ git config --get branch.main.remote && git config --get branch.main.merge
origin
refs/heads/main
```

Two files, `refs/heads/main` and `refs/remotes/origin/main`, and two configuration lines that tie them. A colleague pushes to the server. On your machine, nothing changes until you ask:

```console
$ git status
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean

$ git fetch
From github.com:equipe/projet
   d0a0b32..6ccbbac  main       -> origin/main

$ git status
On branch main
Your branch is behind 'origin/main' by 1 commit, and can be fast-forwarded.
  (use "git pull" to update your local branch)

nothing to commit, working tree clean

$ git log --oneline main..origin/main
6ccbbac Ajoute la page contact

$ git branch -vv
* main d0a0b32 [origin/main: behind 1] Premier commit
```

The first `git status` wasn't lying: it compared `main` to `origin/main`, which hadn't moved. `fetch` updated the copy, and only the copy: `main` is still on `d0a0b32`.

The copy is read-only. You don't work on it:

```console
$ git switch origin/main
fatal: a branch is expected, got remote branch 'origin/main'
hint: If you want to detach HEAD at the commit, try again with the --detach option.
```

`pull` is `fetch` followed by the integration into your branch. Afterwards, the two local `main`s are in the same place:

```console
$ git pull --ff-only
Updating d0a0b32..6ccbbac
Fast-forward
 contact.html | 1 +
 1 file changed, 1 insertion(+)
 create mode 100644 contact.html

$ git branch -vv
* main 6ccbbac [origin/main] Ajoute la page contact
```

The other way round, a local commit puts your branch ahead; `push` sends it to the server and moves the copy forward at the same time:

```console
$ git branch -vv
* main 8f1e53a [origin/main: ahead 1] Ajoute a.txt

$ git push
To github.com:equipe/projet.git
   6ccbbac..8f1e53a  main -> main

$ git branch -vv
* main 8f1e53a [origin/main] Ajoute a.txt
```

## What it changes in practice

- **`git fetch` is always risk-free**: it only touches the `origin/*` copies. Running it often means seeing the server as it is.
- **"Up to date" means "up to date with my copy"**, not with the server. Before concluding, `fetch`.
- **A server branch that was deleted stays in your copies** until a `fetch --prune`; a local branch whose copy disappeared is marked `gone`.
- **The tracking link is configuration**: two lines per branch. `git push -u` writes them, `git branch -u` changes them.
- **Several remotes** are possible: on a fork, `origin` is your copy on GitHub and `upstream` the original project, each with its `origin/*` and `upstream/*` references.

## Where it's used

- [A remote branch was deleted, but I still see it](/en/situations/quotidien/branche-distante-supprimee-encore-visible/)
- [After cloning, I don't see the other people's branches](/en/situations/quotidien/branches-invisibles-apres-clone/)
- [First push of a branch, "has no upstream branch"](/en/situations/quotidien/premier-push-no-upstream/)
- [My local branch is behind after a merge on GitHub](/en/situations/avec-les-autres/branche-locale-en-retard-apres-fusion/)
- [Working on the same project from two machines](/en/situations/avec-les-autres/travailler-depuis-deux-machines/)
- [A branch is a bookmark](/en/comprendre/une-branche-est-un-marque-page/)

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/comprendre/remotes-et-references-distantes.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/comprendre/remotes-et-references-distantes.sh), run with Git 2.50 on 5 October 2026. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
