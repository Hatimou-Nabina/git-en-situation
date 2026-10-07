---
title: Forking and contributing to an open source project
description: Fork, clone, upstream, one branch per contribution, the pull request between two repositories, keeping up to date during review, and keeping your fork level with the project. What to read beforehand, and what gets a contribution accepted.
level: intermediaire
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
sidebar:
  order: 12
---

## What it avoids

Wanting to fix a typo in a project you use, and not knowing how, since you're not allowed to write to it. A pull request impossible to merge because the fork is three months behind. A second contribution that takes the first one along, because everything was done on `main`. And a fork that drifts until it no longer looks like the project.

The fork is a copy of the repository on your account, where you have every right. You push your branches there, and you propose to the original project to take them: that's the pull request between two repositories. The project keeps control, you need no permission.

## How it's done

**0. Before anything, read.** The project's `CONTRIBUTING.md` says how it wants to receive contributions; often, an issue first, to check that the change is welcome. A project that has "good first issue" issues, or « bonne première contribution » like this site, shows where to start.

**1. Fork, clone your fork, and add the original project under the name `upstream`.** The "Fork" button on GitHub creates the copy. The clone comes from your copy, `origin`; the original project becomes `upstream`, to read what happens there.

```console
$ git remote -v
origin	github.com:awa/projet.git (fetch)
origin	github.com:awa/projet.git (push)

$ git remote add upstream github.com:equipe/projet.git

$ git remote -v
origin	github.com:awa/projet.git (fetch)
origin	github.com:awa/projet.git (push)
upstream	github.com:equipe/projet.git (fetch)
upstream	github.com:equipe/projet.git (push)

$ git fetch upstream
From github.com:equipe/projet
 * [new branch]      main       -> upstream/main
```

Two servers: `origin`, where you write, `upstream`, where you read.

**2. One branch per contribution, starting from `upstream/main`**, the project's real `main`, not your fork's, which may be behind. The branch is pushed to your fork.

```console
$ git switch -c fix/typo-readme upstream/main
Switched to a new branch 'fix/typo-readme'
branch 'fix/typo-readme' set up to track 'upstream/main'.

$ git push -u origin fix/typo-readme
To github.com:awa/projet.git
 * [new branch]      fix/typo-readme -> fix/typo-readme
branch 'fix/typo-readme' set up to track 'origin/fix/typo-readme'.
```

**3. The pull request to the original project.** On GitHub, the push shows the link; the PR is created from your fork, base `equipe/projet:main`, compare `awa/projet:fix/typo-readme`. Everything that holds for [a pull request](/en/equipe/la-pull-request/) holds here: one intention, a description, readable commits. Leave the "Allow edits from maintainers" box ticked: the maintainer can rework your branch without a round trip.

**4. During the review, the project moves on: keeping up to date.** You rebase onto `upstream/main`, and push to your fork with `--force-with-lease`, since it's your own branch:

```console
$ git fetch upstream
From github.com:equipe/projet
   8d5eeb7..49b270f  main       -> upstream/main

$ git log --oneline HEAD..upstream/main
49b270f chore: ajoute la licence

$ git rebase upstream/main
Rebasing (1/1)Successfully rebased and updated refs/heads/fix/typo-readme.

$ git push --force-with-lease
To github.com:awa/projet.git
 + 5180fab...d957b79 fix/typo-readme -> fix/typo-readme (forced update)
```

**5. After the merge: bring your fork level with the project.** Your fork's `main` hasn't moved; it catches up with `upstream`, then you push it to `origin`, and the contribution's branch disappears.

```console
$ git switch main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.

$ git pull --ff-only upstream main
From github.com:equipe/projet
 * branch            main       -> FETCH_HEAD
   49b270f..2cc7037  main       -> upstream/main
Updating 8d5eeb7..2cc7037
Fast-forward
 LICENSE   | 1 +
 README.md | 3 +--
 2 files changed, 2 insertions(+), 2 deletions(-)
 create mode 100644 LICENSE

$ git push origin main
To github.com:awa/projet.git
   8d5eeb7..2cc7037  main -> main

$ git branch -d fix/typo-readme
Deleted branch fix/typo-readme (was d957b79).

$ git push origin --delete fix/typo-readme
To github.com:awa/projet.git
 - [deleted]         fix/typo-readme

$ git log --oneline origin/main..upstream/main
```

Nothing between `origin/main` and `upstream/main`: the fork is level. It has only one role, carrying your branches; its `main` never receives a commit of yours.

## On GitHub

- **`gh repo fork --clone`** does the fork, the clone, and adds `upstream` in one command.
- **"Sync fork"**, on your fork's page, does step 5 without a terminal: "Update branch" brings the fork's `main` level. It remains to `git pull` on your machine.
- **"Compare across forks"**, on a PR's creation page, when GitHub doesn't offer the right base repository.
- **"Allow edits from maintainers"**: ticked by default, to leave as is.
- **Forks have neither the project's secrets nor all its CI**: the workflows of a PR coming from a fork run with reduced rights, without access to secrets. That's intended. A CI that depends on a secret won't pass on your PR, and it's not your fault.
- **Deleting the fork after the merge** is possible: the merged PR keeps its commits on the project. To contribute again, you fork again, or you keep the fork up to date.

## Pitfalls

- **Working on the fork's `main`.** The second PR contains the first; updating the fork becomes a merge. `main` stays the copy of `upstream`, full stop.
- **Starting from the fork's `main` instead of `upstream/main`**: the branch is born already behind.
- **Updating with `git pull`**, hence by merge, during the review: merge commits in the PR, which maintainers will ask you to clean up. Rebase, then `--force-with-lease`.
- **A huge PR.** The first contribution is small; it serves first to learn how the project works.
- **Not reading the `CONTRIBUTING.md`**: commit conventions, tests to run, DCO or CLA to sign, language. A PR that doesn't follow them waits.
- **Forcing without `--with-lease`**, and overwriting the commit a maintainer pushed to your branch thanks to "Allow edits from maintainers".

## See also

- [The pull request, from opening to merge](/en/equipe/la-pull-request/)
- [One branch per change](/en/equipe/une-branche-par-changement/)
- [Updating my branch with main](/en/situations/avec-les-autres/mettre-ma-branche-a-jour-avec-main/)
- [Remotes and remote-tracking references](/en/comprendre/remotes-et-references-distantes/)
- Contributing to this site: [CONTRIBUTING.md](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/CONTRIBUTING.md)

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/equipe/forker-et-contribuer.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/equipe/forker-et-contribuer.sh), run with Git 2.50 on 6 October 2026. The fork there is a second bare repository, `github.com:awa/projet.git`, and the merge "by GitHub" is played by Bakary, maintainer of the original project. Only the servers' addresses and the commit ids are those of the example repository, whose commit messages are in French.
:::
