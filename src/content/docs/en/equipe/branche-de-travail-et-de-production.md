---
title: Working branch and production branch
description: When two long-lived branches are enough, main for the work and prod for what runs. How to move them forward, deliver, fix urgently without taking along what isn't ready, and know at any time what is where.
level: intermediaire
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
sidebar:
  order: 7
---

## What it avoids

Deploying what isn't finished, because `main` is production and a half-ready feature was just merged into it. An urgent fix impossible to deliver without taking along three weeks of unvalidated work. And the question "what is running in production, exactly?", which nobody can answer without opening the deployment tool.

Two long-lived branches are enough: `main`, where work arrives by pull request and which is always in working order, and `prod`, which contains only what is in production. Going to production means moving `prod` forward up to `main`. Nothing more.

It isn't always necessary. If every merge into `main` is deployed automatically and the team is comfortable with that, a single branch and tags are enough. The two branches are useful when deploying is a decision: a client validates on a test environment, a production release has a date, a rollback must be simple.

## How it's done

**1. Create `prod` from `main`, once**, and protect it like `main`.

```console
$ git switch -c prod
Switched to a new branch 'prod'

$ git push -u origin prod
To github.com:equipe/projet.git
 * [new branch]      prod -> prod
branch 'prod' set up to track 'origin/prod'.

$ git switch main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.
```

**2. Work arrives on `main`, by pull request; `prod` doesn't move.** Two PRs have been merged since. What awaits production is what `main` has and `prod` doesn't:

```console
$ git log --oneline prod..main
c6bf1cd Merge pull request #22 from equipe/feature/export
2e51847 Merge pull request #21 from equipe/feature/recherche
57033b7 feat(export): ajoute l export CSV
b9b596d feat(recherche): ajoute la barre de recherche
```

**3. Going to production: `prod` catches up with `main`.** By fast-forward, always: `prod` contains nothing that `main` doesn't have, so there is never a merge commit in that direction.

```console
$ git switch prod
Switched to branch 'prod'
Your branch is up to date with 'origin/prod'.

$ git merge --ff-only main
Updating d0a0b32..c6bf1cd
Fast-forward
 export.js    | 1 +
 recherche.js | 1 +
 2 files changed, 2 insertions(+)
 create mode 100644 export.js
 create mode 100644 recherche.js

$ git push
To github.com:equipe/projet.git
   d0a0b32..c6bf1cd  prod -> prod

$ git log --oneline prod..main
```

Nothing waiting any more. If `--ff-only` refuses, `prod` received something that isn't on `main`: a fix that wasn't carried over (step 5). Don't force, carry over first.

**4. An urgent fix in production, while `main` has already moved on.** A new PR is on `main`, not ready to be delivered. The fix starts from `prod`, not from `main`, so as not to take it along:

```console
$ git switch prod
Switched to branch 'prod'
Your branch is up to date with 'origin/prod'.

$ git switch -c hotfix/export-vide
Switched to a new branch 'hotfix/export-vide'
```

One commit, one pull request to `prod`, and the merge:

```console
$ git switch prod
Switched to branch 'prod'
Your branch is up to date with 'origin/prod'.

$ git merge --ff-only hotfix/export-vide
Updating c6bf1cd..803c3c3
Fast-forward
 export.js | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

$ git push
To github.com:equipe/projet.git
   c6bf1cd..803c3c3  prod -> prod
```

**5. Carry the fix over to `main`, right away.** Otherwise the next production release will refuse to go through, or will overwrite it if someone forces.

```console
$ git switch main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.

$ git log --oneline main..prod
803c3c3 fix(export): corrige l export d une liste vide

$ git merge prod
Merge made by the 'ort' strategy.
 export.js | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

$ git push
To github.com:equipe/projet.git
   c3c4f41..22f3be6  main -> main

$ git log --oneline main..prod
```

That direction produces a merge commit, and that's normal: `main` had moved on. In a project where that bothers, `git cherry-pick 803c3c3` on `main` copies the fix without a merge.

**6. Knowing what is where.** Two questions, two commands: what awaits production, and in which branches is what runs?

```console
$ git log --oneline prod..main
22f3be6 Merge branch 'prod'
c3c4f41 Merge pull request #23 from equipe/feature/filtres
2dcb9b0 feat(recherche): ajoute les filtres

$ git branch -r --contains origin/prod
  origin/main
  origin/prod
```

The filters are waiting; the fix is everywhere. `main..prod` must be empty outside a fix in progress: that's the check to make before every production release.

## On GitHub

- **The default branch stays `main`**: that's where PRs open and where contributors arrive. `prod` is protected like `main`, with the mandatory PR: [Protecting the main branch](/en/equipe/proteger-la-branche-principale/).
- **The production release is a PR** from `main` to `prod` (base `prod`, compare `main`). Its "Files changed" tab is the list of what ships, its description a release note.
- **GitHub doesn't merge by fast-forward**: the merge button creates a merge commit on `prod`, even when a `--ff-only` would go through. That works too, provided you check `main..prod` with `--no-merges`. To keep `prod` strictly fast-forward, the production release is done from the terminal as above, by someone `prod`'s rule allows.
- **A fix is a PR to `prod`**, then a second PR from `prod` to `main`, or a cherry-pick.
- **Deployments follow the branches**: a workflow `on: push: branches: [main]` deploys the test environment, another on `prod` deploys production. "Environments" (Settings → Environments) can require an approval before the production one.
- **The Compare view**, `github.com/<repository>/compare/prod...main`, answers "what's waiting?" without a terminal.

## Pitfalls

- **Committing directly on `prod`**, "just for this fix". Branch protection exists for that.
- **Forgetting to carry the fix over** to `main`. At the next production release, `--ff-only` refuses, or worse, the fix disappears if someone forces. The carry-over is part of the fix, not a separate task.
- **Letting `prod` linger three months behind `main`.** Every production release becomes an event; small ones, often, are better.
- **The whole git-flow**, `develop`, `release/*`, `hotfix/*`, `support/*`, when two branches are enough. Each extra long-lived branch is one more "where is this commit?" question.
- **Without tags**, impossible to say which version runs when `prod` moved three times in the week: [Versions and tags](/en/equipe/versions-et-tags/).
- **Two roles, one name.** `main` for the work here, `main` for production in the repository next door: within one team, one name, one role, everywhere.

## See also

- [One branch per change](/en/equipe/une-branche-par-changement/)
- [Protecting the main branch](/en/equipe/proteger-la-branche-principale/)
- [Fast-forward, merge, rebase](/en/comprendre/fast-forward-fusion-rebase/)
- [Seeing what changed between my branch and main](/en/situations/quotidien/voir-ce-qui-a-change/)

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/equipe/branche-de-travail-et-de-production.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/equipe/branche-de-travail-et-de-production.sh), run with Git 2.50 on 6 October 2026. The pull requests merged on `main` are played locally there, without display. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
