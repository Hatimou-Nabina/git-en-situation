---
title: Renaming a branch, locally and on the server
description: A typo in the name of a branch already pushed. The three places where the name exists, the commands to bring them into agreement, and the case where renaming from GitHub is better.
level: intermediaire
risk: aucun
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
---

## Symptom

You named your branch `feautre/recherche` instead of `feature/recherche`, and you only notice after pushing it:

```console
$ git branch -vv
* feautre/recherche 5b5dda8 [origin/feautre/recherche] Ajoute la recherche
  main              d0a0b32 [origin/main] Premier commit
```

## Diagnosis

The name of a pushed branch exists in three places: your local branch, the branch on the server, and the **tracking link** between the two. Git has no "rename everywhere" command: you rename locally, push the new name, delete the old one on the server. Three commands, none of them risky, the commits don't move.

## Solution

**1. Rename locally.** If it's the current branch, the new name alone is enough: `git branch -m feature/recherche`.

```console
$ git branch -m feautre/recherche feature/recherche

$ git branch -vv
* feature/recherche 5b5dda8 [origin/feautre/recherche] Ajoute la recherche
  main              d0a0b32 [origin/main] Premier commit
```

The local branch changed name, but it still tracks the old server branch.

**2. Push the new name, then delete the old one on the server.**

```console
$ git push -u origin feature/recherche
To github.com:equipe/projet.git
 * [new branch]      feature/recherche -> feature/recherche
branch 'feature/recherche' set up to track 'origin/feature/recherche'.

$ git push origin --delete feautre/recherche
To github.com:equipe/projet.git
 - [deleted]         feautre/recherche

$ git branch -vv
* feature/recherche 5b5dda8 [origin/feature/recherche] Ajoute la recherche
  main              d0a0b32 [origin/main] Premier commit
```

The push's `-u` replaces the tracking link with the new name.

**3. For colleagues who had fetched the old branch.** Each one cleans up on their side:

```console
$ git fetch --prune
From github.com:equipe/projet
 - [deleted]         (none)            -> origin/feautre/recherche
 * [new branch]      feature/recherche -> origin/feature/recherche

$ git branch -vv
  feautre/recherche 5b5dda8 [origin/feautre/recherche: gone] Ajoute la recherche
* main              d0a0b32 [origin/main] Premier commit

$ git branch -m feautre/recherche feature/recherche

$ git branch -u origin/feature/recherche feature/recherche
branch 'feature/recherche' set up to track 'origin/feature/recherche'.

$ git branch -vv
  feature/recherche 5b5dda8 [origin/feature/recherche] Ajoute la recherche
* main              d0a0b32 [origin/main] Premier commit
```

On GitHub, you can also rename the branch from the site: the repository's branches page, pencil icon next to the name. GitHub renames on the server, updates the open pull requests, and shows everyone the commands of step 3. Only step 1 remains to do on your machine, replaced by those commands.

## Why it works

A branch is a bookmark placed on a commit, stored in `.git/refs/heads/` under its name. Renaming means moving that bookmark: `git branch -m` does it and updates the two configuration lines of the tracking link, without touching any commit. The server knows nothing about it until you talk to it: hence the push of the new name and the deletion of the old one, which for it are only the creation of one bookmark and the deletion of another, on the same commit.

## Pitfalls

- **A pull request open from this branch**: on GitHub, deleting a PR's source branch **closes the PR**. In that case, rename from the GitHub interface, which moves the PR along with the branch, rather than with `push --delete`.
- **A protected branch** cannot be deleted or renamed without touching the rules. `main` is not meant to be renamed lightly.
- **`git branch -M`** forces the rename even if a branch already carries the new name: it is overwritten. Prefer `-m`, which refuses in that case.
- **Colleagues who haven't done step 3** keep seeing `[gone]` on their old branch: see [A remote branch was deleted, but I still see it](/en/situations/quotidien/branche-distante-supprimee-encore-visible/).

## See also

- [First push of a branch, "has no upstream branch"](/en/situations/quotidien/premier-push-no-upstream/)
- [A remote branch was deleted, but I still see it](/en/situations/quotidien/branche-distante-supprimee-encore-visible/)
- [Understand: a branch is a bookmark](/en/comprendre/une-branche-est-un-marque-page/)

:::note[Try it yourself]
This page's script can create the problem on your machine. From a clone of the [site's repository](https://github.com/Hatimou-Nabina/git-en-situation), in Git Bash on Windows:

```bash
EXERCICE=1 bash scripts/situations/renommer-une-branche.sh
```

It stops right after the symptom, tells you which folder to go to and what to do. Fix it, then run it again without `EXERCICE=1` to compare with the solution.
:::

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/situations/renommer-une-branche.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/renommer-une-branche.sh), run with Git 2.50 on 6 October 2026. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
