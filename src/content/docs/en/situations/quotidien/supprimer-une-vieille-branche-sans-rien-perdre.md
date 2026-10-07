---
title: Deleting an old branch without losing anything
description: The repository is cluttered with branches nobody remembers. How to know whether one still holds unique work, delete it with confidence, and keep a trace when in doubt.
level: intermediaire
risk: reversible
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptom

No error message here, just a cluttered repository:

```console
$ git fetch --prune
$ git branch -a
  brouillon
  experimentation
* main
  refonte-header
  remotes/origin/HEAD -> origin/main
  remotes/origin/experimentation
  remotes/origin/main
  remotes/origin/refonte-header
```

`refonte-header` is several months old. You'd like to clean up, but without losing work someone forgot to merge.

## Diagnosis

The right question is not "is this branch old?" but "**does it hold commits that exist nowhere else?**". If all its commits are already in `main`, deleting it only deletes a name. Git can answer that question with certainty.

Always start with `git fetch --prune`, so that your view of the server is up to date (see [A remote branch was deleted, but I still see it](/en/situations/quotidien/branche-distante-supprimee-encore-visible/)).

## Solution

**1. Check that `main` holds everything.** Three ways to ask the same question:

```console
$ git log --oneline main..refonte-header

$ git rev-list --count main..refonte-header
0

$ git merge-base --is-ancestor refonte-header main && echo "tout est dans main" || echo "des commits manquent dans main"
tout est dans main
```

`main..refonte-header` means the commits reachable from `refonte-header` but not from `main`. The first `log` shows nothing and the count is zero: no commit is missing. The two `echo` strings, in French, say "everything is in main" and "commits are missing from main".

To examine all branches at once, ask for those fully contained in `main`:

```console
$ git branch --merged main
* main
  refonte-header

$ git branch -r --merged origin/main
  origin/HEAD -> origin/main
  origin/main
  origin/refonte-header
```

**2. Delete, on the server then locally.**

```console
$ git push origin --delete refonte-header
To github.com:equipe/projet.git
 - [deleted]         refonte-header

$ git branch -d refonte-header
Deleted branch refonte-header (was c4bc016).
```

The server first: colleagues will see the branch disappear at their next `git fetch --prune`. On GitHub, the "Delete branch" button of a merged pull request does the same thing as this `push --delete`.

### When the branch still has unique commits

`experimentation` is pushed to the server and holds a commit that `main` doesn't have:

```console
$ git rev-list --count main..experimentation
1

$ git log --oneline main..experimentation
ba5b93a Essai non termine
```

Three choices: finish it and integrate it through a pull request, delete it knowing what you give up, or archive it (below). A detail that surprises: here, `git branch -d` accepts anyway, with a warning.

```console
$ git branch -d experimentation
warning: deleting branch 'experimentation' that has been merged to
         'refs/remotes/origin/experimentation', but not yet merged to HEAD
Deleted branch experimentation (was ba5b93a).
```

Nothing is lost: the branch still exists on the server. `-d` only protects what exists **nowhere else**.

`brouillon`, on the other hand, was never pushed. There, Git refuses:

```console
$ git log --oneline main..brouillon
baf14ca Brouillon local

$ git branch -d brouillon
error: the branch 'brouillon' is not fully merged
hint: If you are sure you want to delete it, run 'git branch -D brouillon'
hint: Disable this message with "git config set advice.forceDeleteBranch false"
```

That refusal is what protects you: this commit exists only on your machine.

**Keep a trace, then delete for good.** A tag costs zero extra bytes and keeps the commit reachable:

```console
$ git tag archive/brouillon brouillon

$ git branch -D brouillon
Deleted branch brouillon (was baf14ca).

$ git log --oneline -1 archive/brouillon
baf14ca Brouillon local
```

To find that work again one day: `git switch -c brouillon archive/brouillon`. To put the tag on the server: `git push origin archive/brouillon`.

## Why it works

A branch is only a bookmark placed on a commit. Deleting the branch deletes the bookmark, never the commits. A commit only disappears when nothing leads to it any more, neither branch, nor tag, nor descendant commit, and even then Git keeps it for a while in the *reflog*, thirty days by default, before cleaning it up.

`git branch -d` checks that the branch is contained in the current branch **or in the remote branch it tracks**. `-D` skips that check. The `archive/…` tag creates a new path to the commit: it will never be cleaned up as long as the tag exists.

## Pitfalls

- **Branches merged by "squash" on GitHub.** The "Squash and merge" button creates in `main` a brand-new commit with the same content: the branch's commits themselves are not in `main`. `--merged` doesn't list it and `-d` refuses, although nothing would be lost. Check the pull request's state on GitHub ("Merged"), then delete with `-D`. Or let GitHub do it: Settings → General → "Automatically delete head branches".
- **Deleting on the server deletes nothing on colleagues' machines.** Their local copies stay until their next `git fetch --prune`.
- **`-D` without checking.** The commit stays recoverable for a while through `git reflog`, but that's a safety net, not a method. Tag first.
- **Protected branches.** GitHub refuses to delete a protected branch, and that's intended.

## See also

- [A remote branch was deleted, but I still see it](/en/situations/quotidien/branche-distante-supprimee-encore-visible/)
- [Understand: a branch is a bookmark](/en/comprendre/une-branche-est-un-marque-page/), and [the reflog, your safety net](/en/comprendre/le-reflog-ton-filet-de-securite/)
- [Working as a team: the pull request, from opening to merge](/en/equipe/la-pull-request/)

:::note[Try it yourself]
This page's script can create the problem on your machine. From a clone of the [site's repository](https://github.com/Hatimou-Nabina/git-en-situation), in Git Bash on Windows:

```bash
EXERCICE=1 bash scripts/situations/supprimer-une-vieille-branche-sans-rien-perdre.sh
```

It stops right after the symptom, tells you which folder to go to and what to do. Fix it, then run it again without `EXERCICE=1` to compare with the solution.
:::

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/situations/supprimer-une-vieille-branche-sans-rien-perdre.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/supprimer-une-vieille-branche-sans-rien-perdre.sh), run with Git 2.50 on 5 October 2026. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
