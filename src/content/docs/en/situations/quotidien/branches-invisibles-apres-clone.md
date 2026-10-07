---
title: After cloning, I don't see the other people's branches
description: git branch only shows main while the team works on several branches. Where they are, how to switch to them, and why a clone creates only one local branch.
level: debutant
risk: aucun
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
---

## Symptom

You just cloned the project. A colleague tells you "have a look at my branch `feature/export-pdf`". On your machine:

```console
$ git branch
* main
```

## Diagnosis

The clone did bring everything back. But Git distinguishes **local branches**, yours, from **remote-tracking references**, its copy of what exists on the server. A clone creates a single local branch, the default one, and files all the others under `origin/`:

```console
$ git branch -a
* main
  remotes/origin/HEAD -> origin/main
  remotes/origin/feature/export-pdf
  remotes/origin/main
```

Your colleague's branch is there, read-only. What you lack is a local branch to work on it.

## Solution

**Switch to it using its short name.** Git understands that you want a local branch modelled on the server's, and creates it:

```console
$ git switch feature/export-pdf
Switched to a new branch 'feature/export-pdf'
branch 'feature/export-pdf' set up to track 'origin/feature/export-pdf'.

$ git branch -vv
* feature/export-pdf 7abda0a [origin/feature/export-pdf] Ajoute la fonction export PDF
  main               d0a0b32 [origin/main] Premier commit
```

Your branch tracks the server's: `git pull` and `git push` will know what to do.

**If the branch was pushed after your clone**, Git doesn't know it yet:

```console
$ git switch feature/recherche
fatal: invalid reference: feature/recherche
```

Fetch the server's state first, then try again:

```console
$ git fetch
From github.com:equipe/projet
 * [new branch]      feature/recherche -> origin/feature/recherche

$ git switch feature/recherche
Switched to a new branch 'feature/recherche'
branch 'feature/recherche' set up to track 'origin/feature/recherche'.
```

## Why it works

`git clone` does two things: it fetches the server's whole history, branches included, as `origin/<name>` references, then it creates **one** local branch, modelled on the default branch, so that you have a starting point. The other branches have no local version until you ask for one.

`git switch <name>` has a convenience rule: if no local branch has that name but an `origin/<name>` reference exists, it creates the local branch from it and sets up tracking. It's exactly `git switch -c <name> origin/<name>` in one command.

## Pitfalls

- **`git switch -c feature/export-pdf`** or `git checkout -b feature/export-pdf` creates a branch **empty of their work**, starting from where you are. You end up with a branch of the same name, without your colleague's commits. To start from hers, no `-c`, or else `git switch -c feature/export-pdf origin/feature/export-pdf`.
- **`git switch origin/feature/export-pdf`**, with the prefix, puts you in "detached HEAD": you are looking at the remote-tracking reference instead of having a branch. Use the short name.
- **Two servers configured** (for instance `origin` and `upstream` on a fork): if the branch exists on both, the shortcut is ambiguous and Git refuses. Be explicit: `git switch -c feature/x origin/feature/x`.
- **`git branch -r`** lists only the remote-tracking references, handy to look for a name without the noise of local branches.

## See also

- [First push of a branch, "has no upstream branch"](/en/situations/quotidien/premier-push-no-upstream/)
- [A remote branch was deleted, but I still see it](/en/situations/quotidien/branche-distante-supprimee-encore-visible/)
- [Understand: remotes and remote-tracking references](/en/comprendre/remotes-et-references-distantes/)

:::note[Try it yourself]
This page's script can create the problem on your machine. From a clone of the [site's repository](https://github.com/Hatimou-Nabina/git-en-situation), in Git Bash on Windows:

```bash
EXERCICE=1 bash scripts/situations/branches-invisibles-apres-clone.sh
```

It stops right after the symptom, tells you which folder to go to and what to do. Fix it, then run it again without `EXERCICE=1` to compare with the solution.
:::

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/situations/branches-invisibles-apres-clone.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/branches-invisibles-apres-clone.sh), run with Git 2.50 on 6 October 2026. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
