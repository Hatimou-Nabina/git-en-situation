---
title: 'First push of a branch, "has no upstream branch"'
description: 'git push answers "fatal - The current branch has no upstream branch". What Git expects, the command that fixes it, and the setting so you never type it again.'
level: debutant
risk: aucun
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
---

## Symptom

You just created a branch, made a commit, and you push:

```console
$ git push
fatal: The current branch feature/recherche has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin feature/recherche

To have this happen automatically for branches without a tracking
upstream, see 'push.autoSetupRemote' in 'git help config'.
```

## Diagnosis

Your branch exists on your machine, not yet on the server. `git push` without arguments pushes the current branch to the server branch it **tracks**, its *upstream*. A brand-new branch tracks none: Git doesn't know where to send, and rather than guess, it stops and tells you what to do. Nothing is broken.

## Solution

**1. Push while creating the link.**

```console
$ git push -u origin feature/recherche
To github.com:equipe/projet.git
 * [new branch]      feature/recherche -> feature/recherche
branch 'feature/recherche' set up to track 'origin/feature/recherche'.
```

`-u` is the shortcut for `--set-upstream`. The branch is created on the server, and yours now tracks it:

```console
$ git branch -vv
* feature/recherche 5b5dda8 [origin/feature/recherche] Ajoute la recherche
  main              d0a0b32 [origin/main] Premier commit
```

**2. The following times, `git push` is enough.**

```console
$ git push
To github.com:equipe/projet.git
   5b5dda8..df6e2e1  feature/recherche -> feature/recherche
```

**3. To never type it again.** Since Git 2.37, a setting does the `-u` for you on every new branch:

```console
$ git config --global push.autoSetupRemote true
```

On the next branch, the first `git push` goes straight through:

```console
$ git push
To github.com:equipe/projet.git
 * [new branch]      feature/export -> feature/export
branch 'feature/export' set up to track 'origin/feature/export'.
```

## Why it works

The link between your branch and the server's fits in two lines of `.git/config`: the server's name (`origin`) and the remote branch's name. `git push -u` writes those two lines in addition to pushing. Afterwards, `git push` and `git pull` without arguments read them to know where to go, and `git status` uses them to tell you "ahead" or "behind".

A branch created from a server branch, for instance with `git switch feature/x` when `origin/feature/x` exists, has that link from the start. A branch created from scratch with `git switch -c` doesn't: hence the message.

## Pitfalls

- **`git push origin feature/recherche` without `-u`** does push, but doesn't create the link: the message will come back on the next `git push`, and `git pull` won't know what to fetch.
- **Keep the same name on both sides.** `git push -u origin feature/recherche:autre-nom` is possible, but a branch that isn't called the same on your machine and on the server always ends up fooling someone.
- **`push.autoSetupRemote`** is a setting of your machine, not of the repository: to redo on each one.
- **A nearby message, which is not this one**: `! [rejected] ... (fetch first)` means the branch already exists on the server with commits you don't have. See [My push is rejected, "rejected", "fetch first"](/en/situations/quotidien/push-refuse-fetch-first/).

## See also

- [After cloning, I don't see the other people's branches](/en/situations/quotidien/branches-invisibles-apres-clone/)
- [Renaming a branch, locally and on the server](/en/situations/quotidien/renommer-une-branche/)
- Understand: *Upstream, the branch yours follows* (coming)

:::note[Try it yourself]
This page's script can create the problem on your machine. From a clone of the [site's repository](https://github.com/Hatimou-Nabina/git-en-situation), in Git Bash on Windows:

```bash
EXERCICE=1 bash scripts/situations/premier-push-no-upstream.sh
```

It stops right after the symptom, tells you which folder to go to and what to do. Fix it, then run it again without `EXERCICE=1` to compare with the solution.
:::

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/situations/premier-push-no-upstream.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/premier-push-no-upstream.sh), run with Git 2.50 on 6 October 2026. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
