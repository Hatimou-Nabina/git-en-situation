---
title: HEAD, or "where am I"
description: HEAD is a file that holds the name of the current branch, or, in "detached HEAD", a commit's id directly. What that changes for the next commit, why the detached state is not a breakdown, and what HEAD~1, HEAD^ and HEAD@{1} mean.
level: debutant
gitVersion: "2.50"
verified: 2026-10-07
published: 2026-10-07
sidebar:
  order: 8
---

## The idea

`HEAD` is "where I am". Concretely, it's a file, `.git/HEAD`, which usually holds the **name of a branch**: `ref: refs/heads/main`. The branch, for its part, holds a commit's id. When you commit, Git creates the commit and moves forward the branch `HEAD` points to; `HEAD` itself doesn't change. When you change branch, it's `HEAD` that changes, and nothing else.

Sometimes `HEAD` holds a commit's id directly, with no branch in between: that's the "detached HEAD". Nothing is broken, but a commit made in that state moves no branch forward, and it will need a name before you leave.

## See for yourself

`HEAD` points to a branch, which points to a commit:

```console
$ cat .git/HEAD
ref: refs/heads/main

$ git symbolic-ref HEAD
refs/heads/main

$ git rev-parse --abbrev-ref HEAD
main

$ git rev-parse --short HEAD
d0a0b32
```

After a commit, `HEAD` is identical; it's the branch that moved forward:

```console
$ cat .git/HEAD
ref: refs/heads/main

$ cat .git/refs/heads/main
8952b33d4bb2fc8dd5d65355e72668b17d4ae56a

$ git log --oneline -2
8952b33 feat: a
d0a0b32 Premier commit
```

Changing branch changes only `HEAD`:

```console
$ git switch feature/x
Switched to branch 'feature/x'

$ cat .git/HEAD
ref: refs/heads/feature/x

$ git log --oneline -1
8952b33 feat: a
```

In "detached HEAD", the file holds an id, not a name. `symbolic-ref` can no longer answer, `--abbrev-ref` says `HEAD`, and `status` announces it:

```console
$ git switch --detach HEAD~1
HEAD is now at d0a0b32 Premier commit

$ cat .git/HEAD
d0a0b32921f0e3e6484b075d9ff287b1f409cc5c

$ git symbolic-ref HEAD
fatal: ref HEAD is not a symbolic ref

$ git rev-parse --abbrev-ref HEAD
HEAD

$ git status
HEAD detached at d0a0b32
nothing to commit, working tree clean
```

A commit made there moves no branch forward, and Git says so as you leave:

```console
$ git log --oneline -1
9a9a9e9 feat: z

$ git branch --contains HEAD
* (HEAD detached from d0a0b32)

$ git switch main
Warning: you are leaving 1 commit behind, not connected to
any of your branches:

  9a9a9e9 feat: z

If you want to keep it by creating a new branch, this may be a good time
to do so with:

 git branch <new-branch-name> 9a9a9e9

Switched to branch 'main'
Your branch is ahead of 'origin/main' by 1 commit.
  (use "git push" to publish your local commits)
```

Three addresses relative to `HEAD`, which don't mean the same thing: `HEAD~1` and `HEAD^` are the current commit's parent; `HEAD@{1}` is where `HEAD` was just before, here the commit left behind.

```console
$ git log --oneline -1 HEAD
8952b33 feat: a

$ git log --oneline -1 HEAD~1
d0a0b32 Premier commit

$ git log --oneline -1 HEAD^
d0a0b32 Premier commit

$ git log --oneline -1 HEAD@{1}
9a9a9e9 feat: z
```

## What it changes in practice

- **The next commit will go to the branch `HEAD` points to.** `git status` says it on its first line; reading it before committing avoids [the commit on the wrong branch](/en/situations/reparer/commit-sur-la-mauvaise-branche/).
- **"detached HEAD" is the normal state for looking** at a tag, an old commit, a server reference. You look, you leave: `git switch main`.
- **A commit in "detached HEAD" must receive a name** before you leave: `git switch -c name`. Otherwise, only the reflog remembers it, and Git gives the id as you leave.
- **`HEAD~1` goes down the history, `HEAD@{1}` goes back up the journal.** Mixing them up in a `reset --hard` leads to the wrong commit.
- **`HEAD^` and `HEAD~1` are identical** for an ordinary commit; they diverge on a merge commit, where `HEAD^2` is the second parent and `HEAD~2` the grandparent through the first.
- **CI is always in "detached HEAD"**: it checks out a specific commit, not a branch. That's normal.

## Where it's used

- [I am in "detached HEAD"](/en/situations/reparer/detached-head/)
- [I committed on the wrong branch](/en/situations/reparer/commit-sur-la-mauvaise-branche/)
- [Finding a lost commit](/en/situations/reparer/retrouver-un-commit-perdu/)
- [A branch is a bookmark](/en/comprendre/une-branche-est-un-marque-page/)
- [The reflog, your safety net](/en/comprendre/le-reflog-ton-filet-de-securite/)
- Commands: [`git switch`](/en/commandes/switch/), [`git checkout`](/en/commandes/checkout/)

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/comprendre/head-ou-ou-je-suis.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/comprendre/head-ou-ou-je-suis.sh), run with Git 2.50 on 7 October 2026. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
