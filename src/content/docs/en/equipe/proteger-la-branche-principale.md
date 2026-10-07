---
title: Protecting the main branch
description: Mandatory pull request, green CI, force push and deletion forbidden. What a force push does to main without protection, the two settings every Git server knows, and the GitHub rule that makes the pull request unavoidable.
level: intermediaire
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
sidebar:
  order: 4
---

## What it avoids

A `git push --force` on `main` that erases a colleague's commit pushed an hour earlier. A commit pushed directly to `main` that breaks the build for everyone, on a Friday evening. A published branch that disappears by mistake. And, less visible: the fear of `main`, which makes people hesitate to touch the project.

Protecting `main` means moving those guard rails from everyone's goodwill to the server, which never tires and is never in a hurry. Everything goes through a pull request; force pushes and deletions are refused; the CI must be green to merge. This site has applied the rule to itself since its first day.

## How it's done

**Without protection, here is what happens.** Bakary pushes a commit to `main`. Awa, who hasn't fetched it, sees her push rejected, and "fixes" the problem with `--force`:

```console
$ git log --oneline origin/main
879e74d feat(export): ajoute l export CSV
d0a0b32 Premier commit
```

```console
$ git push
To github.com:equipe/projet.git
 ! [rejected]        main -> main (fetch first)
error: failed to push some refs to 'github.com:equipe/projet.git'
hint: Updates were rejected because the remote contains work that you do not
hint: have locally. This is usually caused by another repository pushing to
hint: the same ref. If you want to integrate the remote changes, use
hint: 'git pull' before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.

$ git push --force
To github.com:equipe/projet.git
 + 879e74d...b9b596d main -> main (forced update)
```

The server obeyed. On Bakary's machine, his commit is no longer on `main`:

```console
$ git fetch
From github.com:equipe/projet
 + 879e74d...b9b596d main       -> origin/main  (forced update)

$ git log --oneline origin/main
b9b596d feat(recherche): ajoute la barre de recherche
d0a0b32 Premier commit

$ git status
On branch main
Your branch and 'origin/main' have diverged,
and have 1 and 1 different commits each, respectively.
  (use "git pull" if you want to integrate the remote branch with yours)

nothing to commit, working tree clean
```

:::danger[What was lost]
Bakary's commit now exists only on his machine. If he had cleaned up his local branch in the meantime, or if the push had come from a CI machine, it would have vanished: a server repository keeps no reflog by default. Here, Bakary is lucky: a `git rebase origin/main` then a `git push` put it back in place.
:::

**Two settings every Git server knows.** On a server you administer yourself, two configuration lines of the bare repository refuse force pushes and the deletion of any branch:

```console
$ git config receive.denyNonFastForwards true

$ git config receive.denyDeletes true
```

Awa tries again:

```console
$ git push --force
remote: error: denying non-fast-forward refs/heads/main (you should pull first)
To github.com:equipe/projet.git
 ! [remote rejected] main -> main (non-fast-forward)
error: failed to push some refs to 'github.com:equipe/projet.git'

$ git push origin --delete main
remote: error: denying ref deletion for refs/heads/main
To github.com:equipe/projet.git
 ! [remote rejected] main (deletion prohibited)
error: failed to push some refs to 'github.com:equipe/projet.git'
```

`remote rejected`, not `rejected`: it's no longer Git on your machine that refuses, it's the server. No local option gets around it.

**Imposing the pull request.** The server can go further and refuse any direct push to `main`, even a fast-forward. On GitHub, it's a checkbox; on a server of your own, it's an `update` hook, run before each branch update:

```console
$ cat hooks/update
#!/usr/bin/env bash
# Refuse tout push direct sur main : les changements passent par une pull request.
if [ "$1" = "refs/heads/main" ]; then
  echo "main est protegee : passe par une branche et une pull request." >&2
  exit 1
fi
```

Awa committed on `main` out of habit. Her push is refused, with the hook's message, which reads in French "main is protected: go through a branch and a pull request":

```console
$ git push
remote: main est protegee : passe par une branche et une pull request.
remote: error: hook declined to update refs/heads/main
To github.com:equipe/projet.git
 ! [remote rejected] main -> main (hook declined)
error: failed to push some refs to 'github.com:equipe/projet.git'
```

**The reflex: the commit goes to a branch.** Nothing is lost, the commit exists; it only changes branch, then goes out as a pull request.

```console
$ git branch feature/filtre

$ git reset --keep origin/main

$ git switch feature/filtre
Switched to branch 'feature/filtre'

$ git push -u origin feature/filtre
To github.com:equipe/projet.git
 * [new branch]      feature/filtre -> feature/filtre
branch 'feature/filtre' set up to track 'origin/feature/filtre'.
```

The details of those three commands are in [I committed on the wrong branch](/en/situations/reparer/commit-sur-la-mauvaise-branche/).

## On GitHub

- **Settings → Rules → Rulesets**, "New branch ruleset", target `main`. The useful rules, in order: "Require a pull request before merging", "Require status checks to pass" (pick the name of the CI job, for this site "Vérifier et construire le site"), "Block force pushes", "Restrict deletions". The classic "Branch protection rules" setting does the same thing with an older interface.
- **Zero approvals required** when you're alone: GitHub forbids approving your own PR, a mandatory approval would block everything. As soon as there are two people, one.
- **What the person pushing to `main` sees**: a `remote rejected` with a `GH006` code (classic protection) or `GH013` (ruleset), and the broken rule spelled out. The reflex is the same as above: a branch, a PR.
- **"Bypass list"**: by default, nobody, not even the administrator. That's the right setting; a bypass you allow yourself "just this once" ends up being used every week.
- **Tags** are not covered by a branch rule: a tag ruleset protects `v*` the same way.
- **"Require linear history"** forbids merge commits on `main`: only enable it if the team always merges with "Squash" or "Rebase and merge". See [Fast-forward, merge, rebase](/en/comprendre/fast-forward-fusion-rebase/).

## Pitfalls

- **The required check that no longer exists.** The rule targets a job by its name. If the job is renamed, the PR waits for a check that will never arrive, and nobody can merge. Update the rule at the same time as the workflow.
- **Protecting `main` and forgetting `prod`**, or any other deployed branch. The rule holds for every branch someone depends on: [Working branch and production branch](/en/equipe/branche-de-travail-et-de-production/).
- **Protection is not backup.** A reviewed, green PR can still break something. The way back is a `revert`, as a PR too: [Undoing a commit already pushed](/en/situations/reparer/annuler-un-commit-deja-pousse/).
- **The legitimate force push** exists: erasing a secret from the history requires suspending the rule for the duration of the operation, then putting it back. [I pushed a secret by mistake](/en/situations/fichiers/secret-pousse-par-erreur/).
- **The local hook only protects your machine**, and a server hook only exists on a server you administer. On GitHub, only the repository's rules count.

## See also

- [One branch per change](/en/equipe/une-branche-par-changement/)
- [The pull request, from opening to merge](/en/equipe/la-pull-request/)
- [My push is rejected, "rejected", "fetch first"](/en/situations/quotidien/push-refuse-fetch-first/)
- [Finding a lost commit](/en/situations/reparer/retrouver-un-commit-perdu/)

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/equipe/proteger-la-branche-principale.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/equipe/proteger-la-branche-principale.sh), run with Git 2.50 on 6 October 2026. The server there is a bare repository of the sandbox, configured then fitted with the hook shown; GitHub's rules themselves cannot be replayed, and the `GH006` and `GH013` codes are quoted, not run. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
