---
title: My local branch is behind after a merge on GitHub
description: 'The pull request is merged on GitHub, but on your machine main has not moved and git status ends up saying "behind". What it means, git pull --ff-only, and cleaning up the merged branch.'
level: debutant
risk: aucun
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptom

Your pull request was just merged on GitHub. On your machine, `main` shows nothing new, and `git status` is even reassuring:

```console
$ git status
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

After a `git fetch`, the tone changes:

```console
$ git fetch
From github.com:equipe/projet
   d0a0b32..e86885d  main       -> origin/main

$ git status
On branch main
Your branch is behind 'origin/main' by 2 commits, and can be fast-forwarded.
  (use "git pull" to update your local branch)

nothing to commit, working tree clean

$ git branch -vv
  feature/recherche 5b5dda8 [origin/feature/recherche] Ajoute la recherche
* main              d0a0b32 [origin/main: behind 2] Premier commit
```

## Diagnosis

The merge happened **on the server**: GitHub created a merge commit on `main`, over there. Your local `main` knows nothing about it until you ask for news. The first `git status` compares your branch to the local copy of the server's state, `origin/main`, which dated from your last `fetch`: hence "up to date". The `fetch` refreshed that copy.

"Behind 2, can be fast-forwarded" is the best possible situation: your branch is a plain ancestor of the server's. There is nothing to merge, only a bookmark to move forward.

## Solution

**1. Move `main` forward, without creating anything.**

```console
$ git pull --ff-only
Updating d0a0b32..e86885d
Fast-forward
 recherche.js | 1 +
 1 file changed, 1 insertion(+)
 create mode 100644 recherche.js

$ git log --oneline --graph -4
*   e86885d Merge pull request #12 from equipe/feature/recherche
|\
| * 5b5dda8 Ajoute la recherche
|/
* d0a0b32 Premier commit
```

The merge commit created by GitHub is now on your machine.

**2. Clean up the merged branch.** GitHub deleted it on the server, or you did it from the PR; your machine still has it:

```console
$ git fetch --prune
From github.com:equipe/projet
 - [deleted]         (none)     -> origin/feature/recherche

$ git branch -vv
  feature/recherche 5b5dda8 [origin/feature/recherche: gone] Ajoute la recherche
* main              e86885d [origin/main] Merge pull request #12 from equipe/feature/recherche

$ git branch -d feature/recherche
Deleted branch feature/recherche (was 5b5dda8).
```

**If `--ff-only` refuses**, your `main` has a commit the server doesn't have:

```console
$ git pull --ff-only
hint: Diverging branches can't be fast-forwarded, you need to either:
hint:
hint: 	git merge --no-ff
hint:
hint: or:
hint:
hint: 	git rebase
hint:
hint: Disable this message with "git config set advice.diverging false"
fatal: Not possible to fast-forward, aborting.

$ git status
On branch main
Your branch and 'origin/main' have diverged,
and have 1 and 1 different commits each, respectively.
  (use "git pull" if you want to integrate the remote branch with yours)

nothing to commit, working tree clean
```

Did that commit belong on `main`? Rarely: see [I committed on the wrong branch](/en/situations/reparer/commit-sur-la-mauvaise-branche/). If it does belong there, it's an ordinary divergence: [git pull asks me to choose between merge and rebase](/en/situations/quotidien/git-pull-merge-ou-rebase/).

## Why it works

A *fast-forward* creates no commit: Git moves the `main` bookmark up to the server's commit, and updates the files. `--ff-only` is a guarantee: if a fast-forward isn't possible, the command fails instead of manufacturing a merge commit or starting a rebase without asking you. On a branch where you never commit directly, like `main`, it's the setting that never surprises: `git config --global pull.ff only` makes it permanent.

## Pitfalls

- **"Up to date" doesn't mean the server hasn't moved.** It means "up to date with what I know of the server". `git fetch` first, always.
- **A `git pull` without options** would have done the same thing here, a fast-forward. But on a `main` that has diverged, it would merge or rebase depending on your configuration, without you having asked.
- **PR merged by "squash" or "rebase"**: GitHub creates brand-new commits, and your local branch is no longer an ancestor of `main`. `git branch -d` then refuses to delete it, although everything is merged. Check the PR's state, then `-D`: see [Deleting an old branch without losing anything](/en/situations/quotidien/supprimer-une-vieille-branche-sans-rien-perdre/).
- **On GitHub**, Settings → General → "Automatically delete head branches" deletes the branch at every merge; only the `fetch --prune` on your side remains.

## See also

- [A remote branch was deleted, but I still see it](/en/situations/quotidien/branche-distante-supprimee-encore-visible/)
- [git pull asks me to choose between merge and rebase](/en/situations/quotidien/git-pull-merge-ou-rebase/)
- [Working as a team: the pull request, from opening to merge](/en/equipe/la-pull-request/)

:::note[Try it yourself]
This page's script can create the problem on your machine. From a clone of the [site's repository](https://github.com/Hatimou-Nabina/git-en-situation), in Git Bash on Windows:

```bash
EXERCICE=1 bash scripts/situations/branche-locale-en-retard-apres-fusion.sh
```

It stops right after the symptom, tells you which folder to go to and what to do. Fix it, then run it again without `EXERCICE=1` to compare with the solution.
:::

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/situations/branche-locale-en-retard-apres-fusion.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/branche-locale-en-retard-apres-fusion.sh), run with Git 2.50 on 5 October 2026. Only the server address and the commit ids are those of the example repository, whose commit messages are in French; the merge "by GitHub" is played there by a second machine.
:::
