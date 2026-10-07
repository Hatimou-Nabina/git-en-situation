---
title: Upstream, the branch yours follows
description: A local branch can track a server branch. That link fits in two configuration lines, which push -u writes and which push, pull and status read. It's what says "ahead", "behind" or "gone", and its absence that makes the first push fail.
level: debutant
gitVersion: "2.50"
verified: 2026-10-07
published: 2026-10-07
sidebar:
  order: 5
---

## The idea

Your `main` branch and the server's `main` branch are two distinct things, and nothing ties them together by nature. What ties them is a **tracking link**, the *upstream*: two lines in `.git/config` that say "this local branch corresponds to that branch on that server". `git push -u` writes those two lines. Afterwards, `git push` and `git pull` without arguments read them to know where to go, and `git status` uses them to compare your branch to its copy of the server's: "ahead" if you have extra commits, "behind" if the server does, "gone" if the server's branch has disappeared.

A branch created locally doesn't have that link. It's not an error, it's the normal state before the first push.

## See for yourself

A new branch, and `main` next to it. The brackets of `git branch -vv` show the link; the configuration only holds `main`'s:

```console
$ git branch -vv
* feature/recherche 5b5dda8 Ajoute la recherche
  main              d0a0b32 [origin/main] Premier commit

$ git config --get-regexp '^branch\.'
branch.main.remote origin
branch.main.merge refs/heads/main

$ git push
fatal: The current branch feature/recherche has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin feature/recherche

To have this happen automatically for branches without a tracking
upstream, see 'push.autoSetupRemote' in 'git help config'.
```

`push -u` pushes the branch and writes the two lines:

```console
$ git push -u origin feature/recherche
To github.com:equipe/projet.git
 * [new branch]      feature/recherche -> feature/recherche
branch 'feature/recherche' set up to track 'origin/feature/recherche'.

$ git config --get-regexp '^branch\.feature'
branch.feature/recherche.remote origin
branch.feature/recherche.merge refs/heads/feature/recherche

$ git branch -vv
* feature/recherche 5b5dda8 [origin/feature/recherche] Ajoute la recherche
  main              d0a0b32 [origin/main] Premier commit
```

**"ahead"**: a local commit the server doesn't have yet.

```console
$ git status -sb
## feature/recherche...origin/feature/recherche [ahead 1]

$ git branch -vv
* feature/recherche df6e2e1 [origin/feature/recherche: ahead 1] Filtre les resultats
  main              d0a0b32 [origin/main] Premier commit
```

**"behind"**: after the push, a colleague pushed to the same branch, and `fetch` refreshed the copy.

```console
$ git fetch
From github.com:equipe/projet
   df6e2e1..6ffaf63  feature/recherche -> origin/feature/recherche

$ git status -sb
## feature/recherche...origin/feature/recherche [behind 1]

$ git branch -vv
* feature/recherche df6e2e1 [origin/feature/recherche: behind 1] Filtre les resultats
  main              d0a0b32 [origin/main] Premier commit
```

**"gone"**: the branch was deleted on the server, `fetch --prune` removed the copy, but the tracking link is still there, pointing at nothing.

```console
$ git fetch --prune
From github.com:equipe/projet
 - [deleted]         (none)     -> origin/feature/recherche

$ git branch -vv
* feature/recherche 6ffaf63 [origin/feature/recherche: gone] Trie les resultats
  main              d0a0b32 [origin/main] Premier commit

$ git status -sb
## feature/recherche...origin/feature/recherche [gone]
```

The link can be removed, and set afterwards on a branch that already exists on both sides:

```console
$ git branch --unset-upstream

$ git branch -vv
* feature/recherche 6ffaf63 Trie les resultats
  main              d0a0b32 [origin/main] Premier commit

$ git push origin feature/recherche
To github.com:equipe/projet.git
 * [new branch]      feature/recherche -> feature/recherche

$ git branch -vv
* feature/recherche 6ffaf63 Trie les resultats
  main              d0a0b32 [origin/main] Premier commit

$ git branch -u origin/feature/recherche
branch 'feature/recherche' set up to track 'origin/feature/recherche'.

$ git branch -vv
* feature/recherche 6ffaf63 [origin/feature/recherche] Trie les resultats
  main              d0a0b32 [origin/main] Premier commit
```

A `push origin branch` without `-u` does push, but doesn't create the link: the branch stays without brackets.

## What it changes in practice

- **A branch's first push needs `-u`**, once. Or the `push.autoSetupRemote` setting, which does it for you forever.
- **"Up to date" talks about your copy of the server**, not about the server: "ahead", "behind" and "up to date" compare your branch to `origin/<branch>`, which only moves on `fetch`.
- **`git push` and `git pull` without arguments** go where the link points, and refuse to guess when there is none: that's the first push's message.
- **"gone" is not a breakdown**: the branch was merged and deleted on the server, or renamed. Your local branch and its work are intact.
- **The link is local configuration**, in `.git/config`: it doesn't travel with the repository, and a clone only has it for the default branch. On another machine, `git switch name` recreates it from the server's branch.

## Where it's used

- [First push of a branch, "has no upstream branch"](/en/situations/quotidien/premier-push-no-upstream/)
- [A remote branch was deleted, but I still see it](/en/situations/quotidien/branche-distante-supprimee-encore-visible/)
- [After cloning, I don't see the other people's branches](/en/situations/quotidien/branches-invisibles-apres-clone/)
- [My local branch is behind after a merge on GitHub](/en/situations/avec-les-autres/branche-locale-en-retard-apres-fusion/)
- [Working on the same project from two machines](/en/situations/avec-les-autres/travailler-depuis-deux-machines/)
- [Remotes and remote-tracking references](/en/comprendre/remotes-et-references-distantes/)

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/comprendre/upstream-la-branche-que-la-tienne-suit.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/comprendre/upstream-la-branche-que-la-tienne-suit.sh), run with Git 2.50 on 7 October 2026. The colleague's commit and the deletion of the branch on the server are played by a second machine. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
