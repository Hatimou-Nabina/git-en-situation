---
title: Updating my branch with main
description: main moved on while you were working on your branch. Rebase or merge, compared on the same state, the force push that follows a rebase, and what --force-with-lease prevents when a colleague pushed in the meantime.
level: intermediaire
risk: reversible
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptom

You've been working for a few days on `feature/recherche`, pushed regularly. Meanwhile, `main` received other things, and your pull request shows "This branch is out-of-date with the base branch". You want to start again from an up-to-date `main` before asking for review.

```console
$ git fetch
From github.com:equipe/projet
   d0a0b32..6ccbbac  main       -> origin/main

$ git log --oneline --left-right origin/main...feature/recherche
< 6ccbbac Ajoute la page contact
> df6e2e1 Filtre les resultats
> 5b5dda8 Ajoute la recherche
```

One commit on the left, on `main`; two on the right, yours.

## Diagnosis

Two ways to bring `main` into your branch. The **rebase** replays your commits on top of the up-to-date `main`: a straight-line history, but your commits are rewritten, and you will have to replace the ones the server has. The **merge** brings `main` into your branch through a merge commit: nothing is rewritten, the push is ordinary, but the branch's history keeps a trace of the crossing. Both are correct. The choice is a team convention; what follows shows both on exactly the same state.

## Solution

**Option 1: rebase, my branch starts again from the up-to-date `main`.**

```console
$ git rebase origin/main
Rebasing (1/2)Rebasing (2/2)Successfully rebased and updated refs/heads/feature/recherche.

$ git log --oneline --graph -4
* b44c2d1 Filtre les resultats
* 1ea02d2 Ajoute la recherche
* 6ccbbac Ajoute la page contact
* d0a0b32 Premier commit
```

Your two commits changed id. The ordinary push is rejected, as expected:

```console
$ git push
To github.com:equipe/projet.git
 ! [rejected]        feature/recherche -> feature/recherche (non-fast-forward)
error: failed to push some refs to 'github.com:equipe/projet.git'
hint: Updates were rejected because the tip of your current branch is behind
hint: its remote counterpart. If you want to integrate the remote changes,
hint: use 'git pull' before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
```

Above all, no `git pull` here, despite the advice: it would mix the old version of your commits back in with the new one. On **your** branch, after **your** rebase, the right move is to replace the server's version, with the proper protection:

```console
$ git push --force-with-lease
To github.com:equipe/projet.git
 + df6e2e1...b44c2d1 feature/recherche -> feature/recherche (forced update)

$ git status
On branch feature/recherche
Your branch is up to date with 'origin/feature/recherche'.

nothing to commit, working tree clean
```

**Option 2: merge, `main` comes into my branch.**

```console
$ git merge origin/main
Merge made by the 'ort' strategy.
 contact.html | 1 +
 1 file changed, 1 insertion(+)
 create mode 100644 contact.html

$ git log --oneline --graph -5
*   d8fe638 Merge remote-tracking branch 'origin/main' into feature/recherche
|\
| * 6ccbbac Ajoute la page contact
* | df6e2e1 Filtre les resultats
* | 5b5dda8 Ajoute la recherche
|/
* d0a0b32 Premier commit

$ git push
To github.com:equipe/projet.git
   df6e2e1..d8fe638  feature/recherche -> feature/recherche
```

Nothing forced: the branch only moved forward by one commit.

**What `--force-with-lease` prevents.** Let's pick up after the rebase of option 1. Without you knowing, Bakary pushed a small fix to your branch. You, meanwhile, fix the message of your last commit and force again:

```console
$ git push --force-with-lease
To github.com:equipe/projet.git
 ! [rejected]        feature/recherche -> feature/recherche (stale info)
error: failed to push some refs to 'github.com:equipe/projet.git'
```

"Stale info": the branch on the server is no longer where you had seen it. Someone pushed. A bare `--force` would have overwritten their work without a word. Look at what arrived:

```console
$ git fetch
From github.com:equipe/projet
   b44c2d1..b79ce61  feature/recherche -> origin/feature/recherche

$ git log --oneline feature/recherche..origin/feature/recherche
b79ce61 Retouche de Bakary
b44c2d1 Filtre les resultats
```

The server has two commits your branch no longer has: Bakary's fix, and your own commit from before the message correction. Take the fix back onto your branch, then force again, knowingly this time:

```console
$ git cherry-pick origin/feature/recherche
[feature/recherche 61dce8e] Retouche de Bakary
 Author: Bakary <bakary@example.com>
 Date: Mon Oct 5 10:00:00 2026 +0000
 1 file changed, 1 insertion(+)

$ git push --force-with-lease
To github.com:equipe/projet.git
 + b79ce61...61dce8e feature/recherche -> feature/recherche (forced update)

$ git log --oneline --graph -5
* 61dce8e Retouche de Bakary
* 0acb0d2 Filtre les resultats de recherche
* 1ea02d2 Ajoute la recherche
* 6ccbbac Ajoute la page contact
* d0a0b32 Premier commit
```

Bakary's commit keeps its author. Nothing is lost.

## Why it works

A rebase creates new commits: same content, different parent, so a different id (`df6e2e1` became `b44c2d1`). The commit the server knows is no longer an ancestor of yours: the *fast-forward* is impossible, and the ordinary push is rejected, as for any divergence.

`--force` says "replace, whatever is there". `--force-with-lease` says "replace, **provided** the server's branch is still where my last `fetch` saw it". That condition is checked on the server side, against your `origin/feature/recherche` reference. If someone pushed in the meantime, it no longer holds, and the push is rejected: that's the "stale info".

The merge, for its part, rewrites nothing: one more commit, with two parents, and the server does an ordinary fast-forward.

## Pitfalls

- **`git fetch` cancels the protection.** After a `fetch`, your `origin/feature/recherche` reference is up to date, and the next `--force-with-lease` goes through, even if you didn't take back the work that arrived in the meantime. Between the `fetch` and the force push, always look at what arrived, as above.
- **Never a force push on a shared branch.** `main`, `develop`, the branch of a PR with several people: if your rebase is necessary there, it's the sign you need to talk first.
- **A rebase can stop on a conflict**, commit by commit: [A conflict during a merge or a rebase](/en/situations/reparer/resoudre-un-conflit/). `git rebase --abort` brings back the previous state.
- **GitHub's "Update branch" button** does a merge by default, and can do a rebase if the repository is configured that way. Same choice, same consequence.
- **`git pull --rebase origin main`** chains the `fetch` and the `rebase origin/main` in one command; the rest of the page is identical.

## See also

- [My push is rejected, "rejected", "fetch first"](/en/situations/quotidien/push-refuse-fetch-first/)
- [git pull asks me to choose between merge and rebase](/en/situations/quotidien/git-pull-merge-ou-rebase/)
- [A conflict during a merge or a rebase](/en/situations/reparer/resoudre-un-conflit/)
- [My local branch is behind after a merge on GitHub](/en/situations/avec-les-autres/branche-locale-en-retard-apres-fusion/)

:::note[Try it yourself]
This page's script can create the problem on your machine. From a clone of the [site's repository](https://github.com/Hatimou-Nabina/git-en-situation), in Git Bash on Windows:

```bash
EXERCICE=1 bash scripts/situations/mettre-ma-branche-a-jour-avec-main.sh
```

It stops right after the symptom, tells you which folder to go to and what to do. Fix it, then run it again without `EXERCICE=1` to compare with the solution.
:::

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/situations/mettre-ma-branche-a-jour-avec-main.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/mettre-ma-branche-a-jour-avec-main.sh), run with Git 2.50 on 5 October 2026. Both options are played on two copies of the same state, the server being reset identically between the two. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
