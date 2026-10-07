---
title: 'My push is rejected, "rejected", "fetch first"'
description: 'git push answers "! [rejected] main -> main (fetch first)". Someone pushed before you. What it means, and how to publish your commit without overwriting theirs.'
level: debutant
risk: aucun
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptom

A commit, a push, as usual. And this time:

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
```

## Diagnosis

Between your last `pull` and now, someone pushed to `main`. The server therefore has a commit you don't have, and you have a commit it doesn't have: the two histories have **diverged**. Git refuses to overwrite the other person's work. That is exactly what we expect from it.

To see it with your own eyes:

```console
$ git fetch
From github.com:equipe/projet
   d0a0b32..40cf319  main       -> origin/main

$ git status
On branch main
Your branch and 'origin/main' have diverged,
and have 1 and 1 different commits each, respectively.
  (use "git pull" if you want to integrate the remote branch with yours)

nothing to commit, working tree clean
```

What the server has and you don't, then the reverse:

```console
$ git log --oneline main..origin/main
40cf319 Ajoute la page contact

$ git log --oneline origin/main..main
0e03633 Corrige le titre du README
```

## Solution

Your commit has to be placed **after** the server's, then pushed.

**1. Fetch the server's state**, if not already done: `git fetch`, as above.

**2. Replay your commit on top.**

```console
$ git rebase origin/main
Rebasing (1/1)Successfully rebased and updated refs/heads/main.

$ git log --oneline -3
db0c9ee Corrige le titre du README
40cf319 Ajoute la page contact
d0a0b32 Premier commit
```

Your commit changed id, `0e03633` became `db0c9ee`. That's normal: a rebase creates a new commit, with the same content, placed on a new base.

**3. Push.**

```console
$ git status
On branch main
Your branch is ahead of 'origin/main' by 1 commit.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean

$ git push
To github.com:equipe/projet.git
   40cf319..db0c9ee  main -> main
```

In a single command, `git pull --rebase` chains steps 1 and 2.

### What if both commits touch the same line?

The rebase stops and tells you which files are in conflict. You fix them, `git add` each one, then `git rebase --continue`. At any time, `git rebase --abort` brings you back exactly to the state before. [A conflict during a merge or a rebase](/en/situations/reparer/resoudre-un-conflit/) walks through it.

### Why not simply `git pull`?

With a recent Git and no configuration, `git pull` refuses to choose for you:

```console
$ git pull
hint: You have divergent branches and need to specify how to reconcile them.
hint: You can do so by running one of the following commands sometime before
hint: your next pull:
hint:
hint:   git config pull.rebase false  # merge
hint:   git config pull.rebase true   # rebase
hint:   git config pull.ff only       # fast-forward only
hint:
hint: You can replace "git config" with "git config --global" to set a default
hint: preference for all repositories. You can also pass --rebase, --no-rebase,
hint: or --ff-only on the command line to override the configured default per
hint: invocation.
fatal: Need to specify how to reconcile divergent branches.
```

Two ways to bring diverged histories together: the **merge**, which adds a commit "Merge branch 'main' of github.com:equipe/projet", and the **rebase**, which keeps a straight-line history. Both are correct; it's a team choice. For a small commit of yours on a shared branch, rebase is what most teams prefer. To make it your default: `git config --global pull.rebase true`.

## Why it works

The server only agrees to move a branch forward if the commit it currently points to is an **ancestor** of the one you send. It then only has to move its bookmark forward: that's a *fast-forward*. If the histories have diverged, moving the bookmark would make your colleague's commit unreachable, in other words make it disappear. The server refuses.

The rebase makes your commit a descendant of the server's. The *fast-forward* becomes possible again, the push goes through.

## Pitfalls

- **Never force on a shared branch.** `git push --force` would do precisely what Git just prevented: erase the other person's commit. On a branch of your own, after a deliberate rebase, use `git push --force-with-lease`, which refuses if someone pushed in the meantime.
- **"fetch first" and "non-fast-forward"** are two wordings of the same situation. The first when you haven't fetched the server's commits yet, the second when you have fetched them without integrating them.
- **A different message on GitHub**, like `protected branch hook declined` or `GH006`, is not this situation: the branch is protected and expects a pull request. See [Protecting the main branch](/en/equipe/proteger-la-branche-principale/).

## See also

- [Understand: fast-forward, merge, rebase](/en/comprendre/fast-forward-fusion-rebase/)
- [Working as a team: protecting the main branch](/en/equipe/proteger-la-branche-principale/)

:::note[Try it yourself]
This page's script can create the problem on your machine. From a clone of the [site's repository](https://github.com/Hatimou-Nabina/git-en-situation), in Git Bash on Windows:

```bash
EXERCICE=1 bash scripts/situations/push-refuse-fetch-first.sh
```

It stops right after the symptom, tells you which folder to go to and what to do. Fix it, then run it again without `EXERCICE=1` to compare with the solution.
:::

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/situations/push-refuse-fetch-first.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/push-refuse-fetch-first.sh), run with Git 2.50 on 5 October 2026. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
