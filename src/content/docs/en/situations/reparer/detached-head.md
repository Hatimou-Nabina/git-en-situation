---
title: I am in "detached HEAD"
description: 'git status says "HEAD detached at …". What it means, why it is not an error, and how not to lose a commit made in that state.'
level: debutant
risk: reversible
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
---

## Symptom

You wanted to look at version 1.0 of the project, marked by a tag:

```console
$ git switch v1.0
fatal: a branch is expected, got tag 'v1.0'
hint: If you want to detach HEAD at the commit, try again with the --detach option.

$ git switch --detach v1.0
HEAD is now at ea6d02e Version 1

$ git status
HEAD detached at v1.0
nothing to commit, working tree clean

$ git branch
* (HEAD detached at v1.0)
  main
```

The word "detached" worries. Nothing is broken.

## Diagnosis

`HEAD` is "where I am". Usually, HEAD points to a branch, and the branch points to a commit. Here, you asked to be placed on a specific commit, the tag's: HEAD points to it **directly**, with no branch in between. It's the normal state for looking at an old version, and Git even suggested it to you with `--detach`.

The only risk: a commit made in that state is on no branch. Nobody will remember it, except the reflog.

## Solution

**You're only looking.** When you're done, go back to a branch: `git switch main`. Nothing else to do.

**You committed without thinking about it.** `git status` flags it discreetly, "detached from" instead of "detached at":

```console
$ git log --oneline -1
36e3dd0 Corrige la version 1

$ git status
HEAD detached from v1.0
nothing to commit, working tree clean
```

Give that commit a branch, and everything is back in order:

```console
$ git switch -c hotfix/v1
Switched to a new branch 'hotfix/v1'

$ git status
On branch hotfix/v1
nothing to commit, working tree clean
```

**You already left for a branch.** Git warns you as you leave, and gives you the id of the commit left behind:

```console
$ git switch main
Warning: you are leaving 1 commit behind, not connected to
any of your branches:

  45dba92 Autre correction de la version 1

If you want to keep it by creating a new branch, this may be a good time
to do so with:

 git branch <new-branch-name> 45dba92

Switched to branch 'main'
Your branch is up to date with 'origin/main'.
```

Do what it says. `HEAD@{1}`, "where I was just before", refers to the same commit as `45dba92`:

```console
$ git branch hotfix/v1-bis HEAD@{1}

$ git log --oneline -1 hotfix/v1-bis
45dba92 Autre correction de la version 1
```

## Why it works

In `.git/HEAD`, there is either a branch name or a commit id. With a branch name, each new commit moves the branch forward: it's the branch that remembers where you are. With an id, HEAD moves forward alone; as soon as you move it elsewhere, no name leads to that commit any more. It stays in the repository, recoverable through the reflog for a while, but invisible in `git log` and in the branches.

`git switch -c` creates a branch on the current commit and attaches HEAD to it: the commit has a name again.

## Pitfalls

- **You get there without meaning to** with `git checkout <id>`, `git checkout origin/main`, or `git switch origin/feature/x` with the `origin/` prefix. To work on a colleague's branch, use its short name: [After cloning, I don't see the other people's branches](/en/situations/quotidien/branches-invisibles-apres-clone/).
- **CI is always in detached HEAD.** GitHub Actions and the others check out a specific commit, not a branch. It's normal, and harmless as long as nobody commits from the CI.
- **The long message "You are in 'detached HEAD' state"** from `git checkout` says the same thing as this page, in ten lines. `git switch --detach` is more sober.
- **A commit left behind and forgotten** stays recoverable for a while: [Finding a lost commit](/en/situations/reparer/retrouver-un-commit-perdu/).

## See also

- [Finding a lost commit](/en/situations/reparer/retrouver-un-commit-perdu/)
- [After cloning, I don't see the other people's branches](/en/situations/quotidien/branches-invisibles-apres-clone/)
- [Understand: HEAD, or "where am I"](/en/comprendre/head-ou-ou-je-suis/)

:::note[Try it yourself]
This page's script can create the problem on your machine. From a clone of the [site's repository](https://github.com/Hatimou-Nabina/git-en-situation), in Git Bash on Windows:

```bash
EXERCICE=1 bash scripts/situations/detached-head.sh
```

It stops right after the symptom, tells you which folder to go to and what to do. Fix it, then run it again without `EXERCICE=1` to compare with the solution.
:::

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/situations/detached-head.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/detached-head.sh), run with Git 2.50 on 6 October 2026. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
