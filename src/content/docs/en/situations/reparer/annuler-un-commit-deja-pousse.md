---
title: Undoing a commit already pushed
description: A pushed commit breaks something. Why going back and forcing is the wrong idea, and how git revert undoes cleanly, keeping the history intact.
level: intermediaire
risk: aucun
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptom

The last commit pushed to `main` breaks production. It has to be undone, fast, without making things worse.

```console
$ git log --oneline -3
a1f9ab1 Active le nouveau cache
40cf319 Ajoute la page contact
d0a0b32 Premier commit
```

## Diagnosis

This commit is on the server, and maybe already on colleagues' machines. A shared history is not rewritten: you don't remove a commit, you add one that **undoes** it. That's the job of `git revert`. The faulty commit stays visible, and that's intended: you will always know what happened, and when.

## Solution

**What not to do**: move the branch back and push. Git refuses, because the server has a commit your branch no longer has:

```console
$ git reset --hard HEAD~1
HEAD is now at 40cf319 Ajoute la page contact

$ git push
To github.com:equipe/projet.git
 ! [rejected]        main -> main (non-fast-forward)
error: failed to push some refs to 'github.com:equipe/projet.git'
hint: Updates were rejected because the tip of your current branch is behind
hint: its remote counterpart. If you want to integrate the remote changes,
hint: use 'git pull' before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
```

Forcing it with `--force` would go through, and would make the commit disappear for everyone, with the damage that goes with it for those who already built on top of it.

**Solution: a commit that undoes.**

```console
$ git revert --no-edit HEAD
[main c69579e] Revert "Active le nouveau cache"
 Date: Mon Oct 5 10:00:00 2026 +0000
 1 file changed, 1 deletion(-)
 delete mode 100644 cache.js

$ git log --oneline -3
c69579e Revert "Active le nouveau cache"
a1f9ab1 Active le nouveau cache
40cf319 Ajoute la page contact

$ git ls-files
README.md
contact.html

$ git push
To github.com:equipe/projet.git
   a1f9ab1..c69579e  main -> main
```

The file `cache.js` is gone, the history grew by one commit, the push goes through without forcing.

**Undoing an older commit** works the same way: you name the commit, not necessarily the last one.

```console
$ git revert --no-edit HEAD~2
[main 0a929dd] Revert "Ajoute la page contact"
 Date: Mon Oct 5 10:00:00 2026 +0000
 1 file changed, 1 deletion(-)
 delete mode 100644 contact.html

$ git log --oneline -5
0a929dd Revert "Ajoute la page contact"
c69579e Revert "Active le nouveau cache"
a1f9ab1 Active le nouveau cache
40cf319 Ajoute la page contact
d0a0b32 Premier commit

$ git ls-files
README.md
```

## Why it works

A commit is a snapshot of the project, and the difference with its parent is its "patch". `git revert` computes the inverse patch and applies it as a new commit. For the server, it's an ordinary push: the branch moves forward, not back, so no refused *fast-forward*. On colleagues' machines, the next `git pull` brings the revert like any other commit.

What is pushed is, by convention, final. That rule makes everything else possible: everyone can build on `main` knowing that what they saw won't vanish under their feet.

## Pitfalls

- **A merge commit** has two parents: `git revert` asks which one to keep, `-m 1` for the branch you merged into. On GitHub, the "Revert" button of a merged pull request does exactly that, by opening a PR.
- **A conflict** can happen if later commits touched the same lines. It is resolved like any other, then `git revert --continue`. See [A conflict during a merge or a rebase](/en/situations/reparer/resoudre-un-conflit/).
- **Several commits at once**: `git revert --no-edit HEAD~2..HEAD` undoes them from the most recent to the oldest, one undo commit each.
- **Undoing a revert**: `git revert` of the revert commit puts the change back. Handy when you undo in an emergency and reapply a fixed version later.
- **On your own branch, not yet reviewed**, rewriting stays acceptable: see [Undoing my last commit, not yet pushed](/en/situations/reparer/annuler-mon-dernier-commit/) and `--force-with-lease`. On `main`, never.

## See also

- [Undoing my last commit, not yet pushed](/en/situations/reparer/annuler-mon-dernier-commit/)
- [I committed on the wrong branch](/en/situations/reparer/commit-sur-la-mauvaise-branche/)
- [My push is rejected, "rejected", "fetch first"](/en/situations/quotidien/push-refuse-fetch-first/)
- [Working as a team: protecting the main branch](/en/equipe/proteger-la-branche-principale/)

:::note[Try it yourself]
This page's script can create the problem on your machine. From a clone of the [site's repository](https://github.com/Hatimou-Nabina/git-en-situation), in Git Bash on Windows:

```bash
EXERCICE=1 bash scripts/situations/annuler-un-commit-deja-pousse.sh
```

It stops right after the symptom, tells you which folder to go to and what to do. Fix it, then run it again without `EXERCICE=1` to compare with the solution.
:::

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/situations/annuler-un-commit-deja-pousse.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/annuler-un-commit-deja-pousse.sh), run with Git 2.50 on 5 October 2026. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
