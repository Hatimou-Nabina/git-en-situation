---
title: git pull asks me to choose between merge and rebase
description: '"fatal - Need to specify how to reconcile divergent branches". What Git is really asking, what the two options do to the history, and how to settle it once and for all.'
level: debutant
risk: aucun
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
---

## Symptom

You fetch the others' work, like every day, and Git refuses:

```console
$ git pull
From github.com:equipe/projet
   d0a0b32..40cf319  main       -> origin/main
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

## Diagnosis

Someone pushed to `main` while you were making a commit on it: the two histories have **diverged**. There are two ways to bring them together, and they don't leave the same history. Since Git 2.33, `git pull` refuses to choose for you until you have stated your preference. The first part of the output shows, by the way, that the new commits were fetched: only the "bringing together" is pending.

## Solution

**Option 1, the rebase**: your commits are replayed on top of the server's. The history stays a straight line.

```console
$ git pull --rebase
Rebasing (1/1)Successfully rebased and updated refs/heads/main.

$ git log --oneline --graph -4
* db0c9ee Corrige le titre du README
* 40cf319 Ajoute la page contact
* d0a0b32 Premier commit
```

**Option 2, the merge**: a merge commit joins the two lines.

```console
$ git pull --no-rebase
Merge made by the 'ort' strategy.
 contact.html | 1 +
 1 file changed, 1 insertion(+)
 create mode 100644 contact.html

$ git log --oneline --graph -4
*   8e0725f Merge branch 'main' of github.com:equipe/projet
|\
| * 40cf319 Ajoute la page contact
* | 0e03633 Corrige le titre du README
|/
* d0a0b32 Premier commit
```

Both results hold the same code. The difference is in the story told: with the rebase, it looks as if you worked after your colleague; with the merge, you can see that you worked in parallel.

**Choose, then record your choice** so that `git pull` stops asking:

```console
$ git config --global pull.rebase true

$ git config --global --get pull.rebase
true
```

For one or two commits of yours on a shared branch, rebase is what most teams prefer: no "Merge branch 'main' of …" commits that bring nothing. If your team has a convention, it decides.

## Why it works

`git pull` chains two operations: `git fetch`, which gets the server's commits, then the integration of those commits into your branch. When your branch has nothing new, the integration is a simple *fast-forward*: Git moves your bookmark forward, no choice to make. When both sides moved, you have to either replay your commits on the new base, the rebase, or create a commit with two parents, the merge. Old versions of Git merged silently; many people ended up with merge commits without understanding where they came from. Git now asks.

The third option in the message, `pull.ff only`, is the strictest: `git pull` only does *fast-forwards* and fails otherwise, leaving you to run the rebase or the merge by hand. It's a good setting when you always want to see the divergence before acting.

## Pitfalls

- **The rebase rewrites your local commits**: `0e03633` became `db0c9ee`. It has no consequence as long as those commits had not been pushed. And that's precisely the case here: `git pull --rebase` only replays the commits the server doesn't have.
- **A conflict** stops the rebase or the merge the same way: fix the files, `git add`, then `git rebase --continue` or `git commit`. `git rebase --abort` or `git merge --abort` brings back the previous state.
- **`pull.rebase` is a setting of your machine**, to redo on each one. It can also be set per repository, without `--global`.
- **If it's the push that is rejected** rather than the pull, it's the same divergence seen from the other side: [My push is rejected, "rejected", "fetch first"](/en/situations/quotidien/push-refuse-fetch-first/).

## See also

- [My push is rejected, "rejected", "fetch first"](/en/situations/quotidien/push-refuse-fetch-first/)
- [Understand: fast-forward, merge, rebase](/en/comprendre/fast-forward-fusion-rebase/)

:::note[Try it yourself]
This page's script can create the problem on your machine. From a clone of the [site's repository](https://github.com/Hatimou-Nabina/git-en-situation), in Git Bash on Windows:

```bash
EXERCICE=1 bash scripts/situations/git-pull-merge-ou-rebase.sh
```

It stops right after the symptom, tells you which folder to go to and what to do. Fix it, then run it again without `EXERCICE=1` to compare with the solution.
:::

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/situations/git-pull-merge-ou-rebase.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/git-pull-merge-ou-rebase.sh), run with Git 2.50 on 6 October 2026. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
