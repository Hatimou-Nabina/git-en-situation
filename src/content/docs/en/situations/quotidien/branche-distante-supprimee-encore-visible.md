---
title: A remote branch was deleted, but I still see it
description: The branch is gone from GitHub, yet git branch -a still shows it and git fetch changes nothing. What remote-tracking references are, and how git fetch --prune cleans up.
level: debutant
risk: aucun
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptom

A colleague merged her branch `feature/export-pdf` into `main`, then deleted it on GitHub. On your machine, it's still there:

```console
$ git branch -a
  feature/export-pdf
* main
  remotes/origin/HEAD -> origin/main
  remotes/origin/feature/export-pdf
  remotes/origin/main
```

You run `git fetch`: nothing changes. On GitHub, the branch no longer exists. What did Git not understand?

## Diagnosis

On your machine, two distinct things carry that name:

- `remotes/origin/feature/export-pdf` is a **remote-tracking reference**: the local copy of what Git saw on the server last time. A bookmark that says "the last time I looked, this server branch was here".
- `feature/export-pdf` is **your local branch**, created when you ran `git switch feature/export-pdf` to have a look.

`git fetch` updates the bookmarks of the branches that still exist on the server. It does not remove those whose branch has disappeared. Nothing is broken: Git is cautious, it never deletes anything on its own.

## Solution

**1. Ask `fetch` to clean up the remote-tracking references.**

```console
$ git fetch --prune
From github.com:equipe/projet
 - [deleted]         (none)     -> origin/feature/export-pdf
```

`git branch -a` no longer shows `remotes/origin/feature/export-pdf`. Your local branch remains, which Git now flags as orphaned:

```console
$ git branch -vv
  feature/export-pdf 7abda0a [origin/feature/export-pdf: gone] Ajoute la fonction export PDF
* main               61d6827 [origin/main] Fusionne feature/export-pdf
```

`gone`: this local branch was tracking a remote branch that no longer exists.

**2. Delete the local branch.**

```console
$ git branch -d feature/export-pdf
Deleted branch feature/export-pdf (was 7abda0a).
```

The lowercase `-d` is cautious: it refuses if the branch holds commits that exist nowhere else. If it refuses, read [Deleting an old branch without losing anything](/en/situations/quotidien/supprimer-une-vieille-branche-sans-rien-perdre/) before insisting.

**3. To stop thinking about it.**

```console
$ git config --global fetch.prune true
```

From now on, every `git fetch` and every `git pull` does this cleanup by itself. To redo on each of your machines: this setting belongs to the machine, not to the repository.

## Why it works

Everything Git knows about the server lives in `origin/<branch>` references, stored in your `.git` folder. An ordinary `fetch` does only two things: create the references of new branches, and move forward those of branches that moved. It has no reason to touch the others, and out of caution it doesn't.

With `--prune`, `fetch` also compares the list of branches the server announces with your `origin/*` references, and deletes those that no longer match anything. It is **risk-free**: a remote-tracking reference is only a bookmark, it holds none of your work. `--prune` touches neither your local branches nor the server.

Your local branch, on the other hand, belongs to you. Git will never delete it unless asked, hence step 2.

## Pitfalls

- **`--prune` does not delete local branches.** To find those that became orphaned: `git branch -vv | grep ': gone]'`.
- **The branch may have been deleted by mistake.** If `git branch -vv` shows `gone` and your local branch has commits that `main` doesn't, you may hold the only copy: `git push -u origin feature/export-pdf` puts it back on the server.
- **`git remote prune origin`** does the same thing as `git fetch --prune`, without fetching what's new. `git fetch -p` is the shortcut.
- **Your editor or graphical client** often has its own "prune" option: under the hood, it's this command.

## See also

- [Deleting an old branch without losing anything](/en/situations/quotidien/supprimer-une-vieille-branche-sans-rien-perdre/)
- [Understand: remotes and remote-tracking references](/en/comprendre/remotes-et-references-distantes/)

:::note[Try it yourself]
This page's script can create the problem on your machine. From a clone of the [site's repository](https://github.com/Hatimou-Nabina/git-en-situation), in Git Bash on Windows:

```bash
EXERCICE=1 bash scripts/situations/branche-distante-supprimee-encore-visible.sh
```

It stops right after the symptom, tells you which folder to go to and what to do. Fix it, then run it again without `EXERCICE=1` to compare with the solution.
:::

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/situations/branche-distante-supprimee-encore-visible.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/branche-distante-supprimee-encore-visible.sh), run with Git 2.50 on 5 October 2026. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
