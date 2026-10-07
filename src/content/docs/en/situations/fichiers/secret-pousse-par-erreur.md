---
title: I pushed a secret by mistake
description: An API key in a committed and pushed .env. In what order to act, revoke first, why deleting the file is not enough, and how to erase the secret from the history with git filter-repo.
level: avance
risk: destructif
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
---

## Symptom

A `.env` file with an API key went to the server, two commits ago. Maybe GitHub already sent you a "secret detected" alert.

```console
$ git log --oneline -3
fea6687 Corrige un bug
b5078f3 Ajoute l application
d0a0b32 Premier commit

$ git show --stat --oneline HEAD~1
b5078f3 Ajoute l application
 .env   | 1 +
 app.js | 1 +
 2 files changed, 2 insertions(+)
```

## Diagnosis

From the moment of the push, consider the secret **compromised**. On a public repository, bots scan GitHub continuously and a key is exploited within minutes. On a private repository, it's on the machine of everyone who cloned, in caches, in forks. Deleting the file removes nothing of what has already been seen. The order of priorities is therefore fixed: first make the secret unusable, only then clean up.

:::danger[This page rewrites the history]
Step 2 changes the id of every commit after the secret, and step 3 replaces the server's history. The whole team must be warned and re-clone.
:::

## Solution

**0. Revoke the key.** In the console of the service concerned, delete it and generate a new one, which you put in place where it's used. That doesn't go through Git, and it's the only step that truly protects.

**1. Untrack the file and ignore it**, so that it doesn't happen again:

```console
$ git rm --cached .env
rm '.env'

$ echo ".env" > .gitignore && git add .gitignore && git commit -q -m "Retire le fichier .env du suivi" && git push -q origin main

$ git status --short
```

The file is no longer tracked. But it's still in the history, and anyone can read it again:

```console
$ git log --oneline --all -- .env
d796dfc Retire le fichier .env du suivi
b5078f3 Ajoute l application

$ git show HEAD~2:.env
API_KEY=sk-live-123456
```

**2. Rewrite the history without that file.** The maintained tool for this is `git filter-repo`, which doesn't come with Git:

```bash
pip install git-filter-repo
```

Then, from the root of the repository:

```console
$ git filter-repo --quiet --invert-paths --path .env --force
NOTICE: Removing 'origin' remote; see 'Why is my origin removed?'
        in the manual if you want to push back there.
        (was github.com:equipe/projet.git)
New history written in N.NN seconds; now repacking/cleaning...
Completely finished after N.NN seconds.

$ git log --oneline --all -- .env

$ git log --oneline -3
9521054 Retire le fichier .env du suivi
4df6761 Corrige un bug
86601e7 Ajoute l application

$ git show HEAD~2:.env
fatal: path '.env' exists on disk, but not in 'HEAD~2'
```

The file never existed in this new history. Every commit from `b5078f3` onwards has a new id.

**3. Replace the server's history.** `filter-repo` removed the remote, out of caution; you put it back, and this time the force push is the right move:

```console
$ git remote -v

$ git remote add origin github.com:equipe/projet.git

$ git push --force --all
To github.com:equipe/projet.git
 + d796dfc...9521054 main -> main (forced update)
```

Add `git push --force --tags` if there are tags.

**4. Warn the team.** On colleagues' machines, the old history has diverged; the safest is to re-clone:

```console
$ git fetch
From github.com:equipe/projet
 + fea6687...9521054 main       -> origin/main  (forced update)

$ git status
On branch main
Your branch and 'origin/main' have diverged,
and have 2 and 3 different commits each, respectively.
  (use "git pull" if you want to integrate the remote branch with yours)

nothing to commit, working tree clean
```

Without local work in progress, `git reset --hard origin/main` is enough; otherwise, set the work aside first, or re-clone and carry the changes over.

## Why it works

A commit is immutable and contains its parent: "removing a file from a commit" means making a new commit, then new commits for all its descendants. That's what `filter-repo` does, by replaying the whole history without the given path. The old commits are not modified, they become orphans, and `filter-repo` cleans the local repository so that nothing of them remains. On the server, only a force push can replace a branch with another that doesn't descend from it: that's the exception that justifies `--force`.

None of this removes the secret from the memory of those who saw it. Hence step 0.

## Pitfalls

- **A protected branch refuses the force push.** The rule has to be suspended for the duration of the operation, then put back.
- **GitHub keeps the old commits for a while**, reachable by their id, in pull request views and caches. To purge them, GitHub asks you to contact support, with the list of commits. Forks have their own copy: to clean or delete too.
- **CI logs** may have displayed the secret. To check and delete.
- **Check every branch and every tag**, not just `main`: `--all` in the `git log` command above, and in the push.
- **Commit ids change**: links to commits, "Fixes abc1234" messages, changelog, everything that quoted an old id now points to nothing.
- **So that it doesn't happen again**: `.env` in `.gitignore` from the first commit, a versioned `.env.example`, and on GitHub, "Push protection" in Settings → Code security, which refuses a push containing a recognised secret.

## See also

- [.gitignore doesn't work, the file is already tracked](/en/situations/fichiers/gitignore-fichier-deja-suivi/)
- [Undoing a commit already pushed](/en/situations/reparer/annuler-un-commit-deja-pousse/), for everything that isn't a secret
- [Working as a team: secrets never go into the repository](/en/equipe/secrets-jamais-dans-le-depot/), so that it never happens again

:::note[Try it yourself]
This page's script can create the problem on your machine. From a clone of the [site's repository](https://github.com/Hatimou-Nabina/git-en-situation), in Git Bash on Windows:

```bash
EXERCICE=1 bash scripts/situations/secret-pousse-par-erreur.sh
```

It stops right after the symptom, tells you which folder to go to and what to do. Fix it, then run it again without `EXERCICE=1` to compare with the solution.
:::

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/situations/secret-pousse-par-erreur.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/secret-pousse-par-erreur.sh), run with Git 2.50 and git-filter-repo on 6 October 2026. Only the server address and the commit ids are those of the example repository, whose commit messages are in French; the durations displayed by `filter-repo`, which change at every run, are replaced by `N.NN`. Revoking the key, outside Git, is not played.
:::
