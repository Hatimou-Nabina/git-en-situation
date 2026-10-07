---
title: One branch per change
description: Naming, creating, keeping it short, deleting after merge. Why one change per branch makes pull requests readable and conflicts rare, and a local guard rail against committing on main out of habit.
level: debutant
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
sidebar:
  order: 3
---

## What it avoids

An urgent fix stuck behind a half-finished feature, because both are on the same branch. A pull request that mixes three topics, and that nobody really reviews. Branches named `test`, `fix2` or `awa` that nobody remembers the contents of. And the commit made on `main` out of habit, which then has to be moved.

The rule fits in one sentence: a branch carries one change, and only one. It is born from an up-to-date `main`, lives a few days, goes out as a pull request, and disappears at merge.

## How it's done

**1. Start from an up-to-date `main`, and name the branch by what it changes.** The name follows the type of the change, like [conventional commits](/en/equipe/commits-conventionnels/): `fix/`, `feature/`, `docs/`, then the subject.

```console
$ git switch main
Already on 'main'
Your branch is up to date with 'origin/main'.

$ git pull --ff-only
Already up to date.

$ git switch -c fix/connexion-timeout
Switched to a new branch 'fix/connexion-timeout'
```

**2. Commits that only talk about that.** If a commit has nothing to do with the branch's name, it's on the wrong branch.

```console
$ git log --oneline main..HEAD
ea67720 test(connexion): couvre le timeout
0ce76f1 fix(connexion): porte le timeout a 30 s

$ git diff --stat main...HEAD
 connexion.js      | 1 +
 connexion.test.js | 1 +
 2 files changed, 2 insertions(+)
```

**3. A second change in progress is a second branch**, which also starts from `main`, not from the first one.

```console
$ git switch main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.

$ git switch -c feature/export-csv
Switched to a new branch 'feature/export-csv'

$ git branch
* feature/export-csv
  fix/connexion-timeout
  main
```

To find your way when they pile up, the date and the last commit of each:

```console
$ git for-each-ref --sort=committerdate --format='%(refname:short)  %(committerdate:short)  %(subject)' refs/heads/
feature/export-csv  2026-10-05  feat(export): ajoute l export CSV
fix/connexion-timeout  2026-10-05  test(connexion): couvre le timeout
main  2026-10-05  Premier commit
```

**4. Keep the branch short.** The longer it lives, the more `main` moves on without it, and the more painful the merge will be. Two commands say where you stand: what `main` received in the meantime, and what the branch brings.

```console
$ git fetch
From github.com:equipe/projet
   d0a0b32..8c3c408  main       -> origin/main

$ git log --oneline HEAD..origin/main
8c3c408 docs: complete le README

$ git log --oneline origin/main..HEAD
9e8bc55 feat(export): ajoute l export CSV
```

One commit behind is caught up painlessly: [Updating my branch with main](/en/situations/avec-les-autres/mettre-ma-branche-a-jour-avec-main/). Fifty is the sign the branch should have been split.

**5. A local guard rail against committing on `main` out of habit.** Five lines in `.git/hooks/pre-commit`:

```console
$ cat .git/hooks/pre-commit
#!/usr/bin/env bash
# Refuse un commit fait directement sur main.
if [ "$(git symbolic-ref --short HEAD 2>/dev/null)" = "main" ]; then
  echo "Pas de commit direct sur main : cree une branche, git switch -c type/sujet" >&2
  exit 1
fi

$ git switch main
Switched to branch 'main'
Your branch is behind 'origin/main' by 1 commit, and can be fast-forwarded.
  (use "git pull" to update your local branch)

$ git commit -m "fix: corrige un detail"
Pas de commit direct sur main : cree une branche, git switch -c type/sujet

$ git switch -c fix/detail
Switched to a new branch 'fix/detail'

$ git commit -m "fix: corrige un detail"
[fix/detail dddeb30] fix: corrige un detail
 1 file changed, 1 insertion(+)
 create mode 100644 oups.js
```

The hook's message, in French, reads "No direct commit on main: create a branch, git switch -c type/subject". The files staged for the commit follow into the new branch: nothing is lost, the commit happens in the right place. A hook is not versioned, everyone installs it; the real protection is [on the server](/en/equipe/proteger-la-branche-principale/).

**6. After the merge, the branch disappears.** On the server, GitHub deletes it; on your machine, `git branch -d` only deletes a merged branch, and refuses the others.

```console
$ git switch main
Switched to branch 'main'
Your branch is behind 'origin/main' by 1 commit, and can be fast-forwarded.
  (use "git pull" to update your local branch)

$ git pull --ff-only
From github.com:equipe/projet
   8c3c408..4dcd567  main       -> origin/main
Updating d0a0b32..4dcd567
Fast-forward
 README.md         | 1 +
 connexion.js      | 1 +
 connexion.test.js | 1 +
 3 files changed, 3 insertions(+)
 create mode 100644 connexion.js
 create mode 100644 connexion.test.js

$ git fetch --prune
From github.com:equipe/projet
 - [deleted]         (none)     -> origin/fix/connexion-timeout

$ git branch -d fix/connexion-timeout
Deleted branch fix/connexion-timeout (was ea67720).

$ git branch -d feature/export-csv
error: the branch 'feature/export-csv' is not fully merged
hint: If you are sure you want to delete it, run 'git branch -D feature/export-csv'
hint: Disable this message with "git config set advice.forceDeleteBranch false"
```

## On GitHub

- **A branch from an issue**: in an issue's right-hand column, "Create a branch" creates the branch named after the issue and links it; the PR will close the issue at merge. From the terminal: `gh issue develop 12 --checkout`.
- **The "Compare & pull request" banner** appears on the repository's page right after a branch is pushed: it's the shortest path to the PR.
- **"Automatically delete head branches"** (Settings → General) deletes the branch at merge. Only the `fetch --prune` on your side remains.
- **The Branches tab** shows for each one how far ahead and behind `main` it is, and the associated PR: that's where you spot the ones that linger.
- **Protecting `main`** makes the rule mandatory rather than voluntary: [Protecting the main branch](/en/equipe/proteger-la-branche-principale/).

## Pitfalls

- **The catch-all branch**, where you commit everything you do in the week. It becomes an unreadable PR, then a giant conflict. One intention, one branch.
- **The branch that starts from another branch** without saying so: its PR also shows the first one's commits. If it's intended, the PR says so and targets the other branch as base.
- **The branch that lives three weeks.** If the change is big, split it: a first PR that prepares, a second that delivers, each merged quickly.
- **Naming by first name or by date**: `awa-2`, `lundi`. In a month, nobody will know what it was, not even you.
- **The commit already made on `main`**: [I committed on the wrong branch](/en/situations/reparer/commit-sur-la-mauvaise-branche/) moves it in three commands.
- **Deleting with `-D` to silence the error**: `-d` refuses for a reason. Check first what the branch contains: [Deleting an old branch without losing anything](/en/situations/quotidien/supprimer-une-vieille-branche-sans-rien-perdre/).

## See also

- [The pull request, from opening to merge](/en/equipe/la-pull-request/)
- [Conventional commits](/en/equipe/commits-conventionnels/)
- [Setting my work in progress aside to change branch](/en/situations/quotidien/mettre-son-travail-de-cote/)
- [A branch is a bookmark](/en/comprendre/une-branche-est-un-marque-page/)

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/equipe/une-branche-par-changement.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/equipe/une-branche-par-changement.sh), run with Git 2.50 on 6 October 2026, hook included. The merge "by GitHub" is played there by a second machine. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
