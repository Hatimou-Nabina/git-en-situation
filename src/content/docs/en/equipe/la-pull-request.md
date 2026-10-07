---
title: The pull request, from opening to merge
description: The branch, the commits, the push, the review, the merge, the cleanup. What each step avoids, the commands that go with it, and what GitHub's three merge buttons really do.
level: debutant
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
sidebar:
  order: 1
---

## What it avoids

Code landing on `main` without a second pair of eyes having seen it. Weeks of work integrated at once, with the conflicts and surprises that go with it. A history where nobody knows any more why a change was made. And the fear of breaking `main`, which ends up slowing everyone down.

The pull request is the unit of change: a branch, a description, a review, a green CI, a merge. The name is GitHub's; GitLab says "merge request", it's the same thing.

## How it's done

**1. Start from an up-to-date `main`, on a branch with a telling name.** [One branch per change](/en/equipe/une-branche-par-changement/), not one more.

```console
$ git switch main
Already on 'main'
Your branch is up to date with 'origin/main'.

$ git pull --ff-only
Already up to date.

$ git switch -c feature/recherche
Switched to a new branch 'feature/recherche'
```

**2. Small, readable commits**, in the [conventional](/en/equipe/commits-conventionnels/) format:

```console
$ git log --oneline main..HEAD
d3b93ce test(recherche): couvre la recherche vide
b9b596d feat(recherche): ajoute la barre de recherche
```

**3. Push, then open the pull request.** GitHub shows the link in the push's response; `gh pr create` does the same from the terminal.

```console
$ git push -u origin feature/recherche
To github.com:equipe/projet.git
 * [new branch]      feature/recherche -> feature/recherche
branch 'feature/recherche' set up to track 'origin/feature/recherche'.
```

The title follows the commit format. The description answers three questions, and that's what the repository's template asks: what, why, what was checked. What the pull request will contain, you can see before opening it:

```console
$ git log --oneline main..feature/recherche
d3b93ce test(recherche): couvre la recherche vide
b9b596d feat(recherche): ajoute la barre de recherche

$ git diff --stat main...feature/recherche
 recherche.js      | 1 +
 recherche.test.js | 1 +
 2 files changed, 2 insertions(+)
```

**4. A review remark: one more commit, no rewriting.** The reviewer keeps their bearings, and sees exactly what changed since their reading.

```console
$ git push
To github.com:equipe/projet.git
   d3b93ce..2b52f41  feature/recherche -> feature/recherche

$ git log --oneline main..feature/recherche
2b52f41 fix(recherche): ignore les espaces en debut de saisie
d3b93ce test(recherche): couvre la recherche vide
b9b596d feat(recherche): ajoute la barre de recherche
```

**5. Green CI, approval, merge, then the cleanup.** The merge happens on GitHub, the branch is deleted there. On your machine:

```console
$ git switch main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.

$ git pull --ff-only
From github.com:equipe/projet
   d0a0b32..70803f8  main       -> origin/main
Updating d0a0b32..70803f8
Fast-forward
 recherche.js      | 1 +
 recherche.test.js | 1 +
 2 files changed, 2 insertions(+)
 create mode 100644 recherche.js
 create mode 100644 recherche.test.js

$ git fetch --prune
From github.com:equipe/projet
 - [deleted]         (none)     -> origin/feature/recherche

$ git branch -d feature/recherche
Deleted branch feature/recherche (was 2b52f41).
```

This site applies the rule to itself: every change since its first day went through a pull request, including when there was only one person to review it. [The list is public](https://github.com/Hatimou-Nabina/git-en-situation/pulls?q=is%3Apr+is%3Amerged).

## On GitHub

- **The template** `.github/PULL_REQUEST_TEMPLATE.md` prefills the description: the questions are asked before they're forgotten.
- **A "Draft" PR** opens early, to show a direction before it's finished; it can't be merged by mistake.
- **"Files changed"** is `git diff main...feature/recherche`: what the branch changed since it left `main`, without what `main` received in the meantime.
- **The review** has three outcomes: comment, approve, request changes. Each conversation is resolved when the remark is addressed. On the reviewer's side: [Reviewing a pull request](/en/equipe/relire-une-pull-request/).
- **The branch rules** (Settings → Rules) impose the PR, the required checks and the ban on force pushes. With a single person in the project, zero approvals required: GitHub forbids approving yourself. The details: [Protecting the main branch](/en/equipe/proteger-la-branche-principale/).
- **The three merge buttons**: "Create a merge commit" keeps the commits and adds a merge commit, "Squash and merge" melts them into a single one whose message is the PR's title, "Rebase and merge" copies them one by one onto `main`. The details are in [Fast-forward, merge, rebase](/en/comprendre/fast-forward-fusion-rebase/).
- **"Automatically delete head branches"**, in Settings → General, deletes the branch at merge; only the `fetch --prune` on each machine remains.
- **`gh`** does everything from the terminal: `gh pr create`, `gh pr checks`, `gh pr view --web`, `gh pr merge`.

## Pitfalls

- **Big PRs.** Beyond what you can review in twenty minutes, the review becomes a skim. One PR, one intention; if it has two, that's two PRs.
- **Rewriting the branch during review.** A rebase or an `--amend` while you're being reviewed makes the reviewer lose the bearings of their previous reading. You add commits; you clean up, if the team wishes, with "Squash and merge".
- **Starting from a branch that isn't `main`**, or from a PR still open, without saying so: the PR then shows the other branch's changes on top of yours.
- **`main` moved during the review**: the "Update branch" button merges `main` into the branch. If the team prefers a straight-line history, it's a rebase: [Updating my branch with main](/en/situations/avec-les-autres/mettre-ma-branche-a-jour-avec-main/).
- **Forgetting the `pull` after the merge**, then committing on a `main` that is behind: [My local branch is behind after a merge on GitHub](/en/situations/avec-les-autres/branche-locale-en-retard-apres-fusion/).

## See also

- [Conventional commits](/en/equipe/commits-conventionnels/)
- [Seeing what changed between my branch and main](/en/situations/quotidien/voir-ce-qui-a-change/)
- [Updating my branch with main](/en/situations/avec-les-autres/mettre-ma-branche-a-jour-avec-main/)
- [Fast-forward, merge, rebase](/en/comprendre/fast-forward-fusion-rebase/)

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/equipe/la-pull-request.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/equipe/la-pull-request.sh), run with Git 2.50 on 6 October 2026. The merge "by GitHub" is played there by a second machine. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
