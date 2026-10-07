---
title: Working on the same project from two machines
description: In the evening, at home, the afternoon's work is not there. What Git synchronises and what it never synchronises, and the two-command routine that avoids the bad surprise.
level: debutant
risk: aucun
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
---

## Symptom

At the office, you made progress: a commit on a new branch, a draft set aside, a `.env` file configured.

```console
$ git log --oneline -3
77e300c Ignore le fichier .env
5b5dda8 Ajoute la recherche
d0a0b32 Premier commit

$ git stash list
stash@{0}: On feature/recherche: Brouillon

$ ls -a
.
..
.env
.git
.gitignore
README.md
recherche.js
```

In the evening, at home, none of that:

```console
$ git fetch

$ git branch -a
* main
  remotes/origin/HEAD -> origin/main
  remotes/origin/main
```

## Diagnosis

Git only synchronises what you **push**: the commits of pushed branches. Everything else belongs to the machine where it was made. Unpushed commits, stashes, ignored files like `.env`, the global configuration, the reflog: none of them travels. It's not an oversight of Git, it's its model: each machine has its complete repository, and the server only receives what you send it.

## Solution

**The routine when leaving: check what exists only on this machine, then push.** Three commands, in this order.

```console
$ git status --short --branch
## feature/recherche

$ git log --branches --not --remotes --oneline
77e300c Ignore le fichier .env
5b5dda8 Ajoute la recherche
```

The first says which branch you are on and whether uncommitted changes remain. The second lists the commits that are **on no server**: those would be invisible elsewhere.

```console
$ git push -u origin feature/recherche
To github.com:equipe/projet.git
 * [new branch]      feature/recherche -> feature/recherche
branch 'feature/recherche' set up to track 'origin/feature/recherche'.

$ git log --branches --not --remotes --oneline
```

Nothing left: everything is on the server. The stash remains, and it won't leave: see "Pitfalls".

**The routine when arriving: fetch, then get in position.**

```console
$ git fetch --prune
From github.com:equipe/projet
 * [new branch]      feature/recherche -> origin/feature/recherche

$ git switch feature/recherche
Switched to a new branch 'feature/recherche'
branch 'feature/recherche' set up to track 'origin/feature/recherche'.

$ git log --oneline -3
77e300c Ignore le fichier .env
5b5dda8 Ajoute la recherche
d0a0b32 Premier commit

$ ls -a
.
..
.git
.gitignore
README.md
recherche.js

$ git stash list
```

The commits are there. The `.env` and the stash are not.

**What doesn't travel either: Git's configuration.** A setting made on one machine doesn't exist on the other:

```console
$ git config --global pull.rebase true
```

```console
$ git config --global --get pull.rebase
```

The first command was run at the office, the second at home, which answers nothing.

## Why it works

A Git repository is commits and **names** that point to them, the branches. `git push` sends the server the commits reachable from the pushed branch, and nothing else. A stash is a commit filed under a local name, `refs/stash`, which `push` never looks at. An ignored file is, by definition, outside Git. The configuration lives in `.git/config` for the repository and in `~/.gitconfig` for the machine: two files that are never pushed. `git log --branches --not --remotes` asks precisely "the commits of my branches that are in no remote branch": the list of what would be lost if this disk died.

## Pitfalls

- **The stash doesn't travel.** To take work in progress with you, commit it on your branch with a frank message, `wip: filtre en cours`, push, and rework the commit later. On a branch of your own, it has no consequence.
- **Environment files** are recreated on each machine, from a versioned `.env.example`. Never push them to "synchronise": they are secrets. The project's README must say what to install and create on a new machine.
- **Two machines on the same branch without `pull`** before committing: the two diverge, and the second push is rejected. See [My push is rejected, "rejected", "fetch first"](/en/situations/quotidien/push-refuse-fetch-first/).
- **The configuration to redo**: identity, `fetch.prune`, `pull.rebase`, `push.autoSetupRemote`, aliases. Keep the list somewhere, or version your `.gitconfig` in a "dotfiles" repository.
- **The reflog is local too**: a lost commit is found only on the machine where it was made. [Finding a lost commit](/en/situations/reparer/retrouver-un-commit-perdu/).

## See also

- [Two GitHub accounts on the same machine](/en/situations/avec-les-autres/deux-comptes-github-sur-un-poste/)
- [Setting my work in progress aside to change branch](/en/situations/quotidien/mettre-son-travail-de-cote/)
- [First push of a branch, "has no upstream branch"](/en/situations/quotidien/premier-push-no-upstream/)

:::note[Try it yourself]
This page's script can create the problem on your machine. From a clone of the [site's repository](https://github.com/Hatimou-Nabina/git-en-situation), in Git Bash on Windows:

```bash
EXERCICE=1 bash scripts/situations/travailler-depuis-deux-machines.sh
```

It stops right after the symptom, tells you which folder to go to and what to do. Fix it, then run it again without `EXERCICE=1` to compare with the solution.
:::

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/situations/travailler-depuis-deux-machines.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/travailler-depuis-deux-machines.sh), run with Git 2.50 on 6 October 2026, with two clones and two separate global configurations to play the two machines. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
