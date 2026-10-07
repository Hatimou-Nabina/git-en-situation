---
title: The index, the step between your folder and the commit
description: Between your working folder and the commit, there is a step, the index, where git add puts the version of a file that the next commit will take. It's what makes it possible to commit part of what you changed, and what git status shows in two columns.
level: debutant
gitVersion: "2.50"
verified: 2026-10-07
published: 2026-10-07
sidebar:
  order: 7
---

## The idea

A file exists in three places: in your **working folder**, as you edit it; in the **last commit**, as it was recorded; and between the two, in the **index**, the list of what the next commit will contain. `git add` saves nothing and sends nothing: it copies a file's current version into the index. `git commit` takes the index, and only the index. What you changed after the `git add` isn't in the commit.

That's what makes it possible to commit part of what you changed, and leave the rest for later. And that's what `git status --short` shows in two columns: on the left the index compared to the last commit, on the right the folder compared to the index.

## See for yourself

`config.js` contains `v1` in the last commit. We write `v2` in the folder: the file is modified, and the index still points to the `v1` object, the same as the commit.

```console
$ echo "v2" > config.js && git status --short
 M config.js

$ git ls-files -s config.js
100644 626799f0f85326a8c1fc522db584e86cdfccd51f 0	config.js

$ git rev-parse HEAD:config.js
626799f0f85326a8c1fc522db584e86cdfccd51f
```

`git add` creates a new object with the content `v2` and puts it in the index. The `M` moves to the left column:

```console
$ git add config.js

$ git status --short
M  config.js

$ git ls-files -s config.js
100644 8c1384d825dbbe41309b7dc18ee7991a9085c46e 0	config.js

$ git cat-file -p $(git ls-files -s config.js | cut -d" " -f2)
v2
```

We modify again: three versions coexist, `v1` in the commit, `v2` in the index, `v3` on the disk. `git diff` compares the folder to the index, `git diff --staged` the index to the commit:

```console
$ echo "v3" > config.js && git status --short
MM config.js

$ git diff
diff --git a/config.js b/config.js
index 8c1384d..29ef827 100644
--- a/config.js
+++ b/config.js
@@ -1 +1 @@
-v2
+v3

$ git diff --staged
diff --git a/config.js b/config.js
index 626799f..8c1384d 100644
--- a/config.js
+++ b/config.js
@@ -1 +1 @@
-v1
+v2
```

The commit takes the index: `v2` is recorded, `v3` remains a change in progress.

```console
$ git commit -m "Passe la configuration en v2"
[main 4e72dff] Passe la configuration en v2
 1 file changed, 1 insertion(+), 1 deletion(-)

$ git show HEAD:config.js
v2

$ cat config.js
v3

$ git status --short
 M config.js
```

Removing from the index doesn't touch the disk:

```console
$ git add config.js

$ git status --short
M  config.js

$ git restore --staged config.js

$ git status --short
 M config.js

$ cat config.js
v3
```

And the index lets you choose: two new files, only one added, only one committed.

```console
$ echo "a" > a.js && echo "b" > b.js && git add a.js && git status --short
A  a.js
 M config.js
?? b.js

$ git commit -m "Ajoute a"
[main 2383c68] Ajoute a
 1 file changed, 1 insertion(+)
 create mode 100644 a.js

$ git status --short
 M config.js
?? b.js
```

## What it changes in practice

- **`git add` is not a backup.** Nothing is recorded before `git commit`, and nothing is sent before `git push`.
- **Added then modified: the commit takes the added version.** `git status --short` says so with `MM` or `AM`; a second `git add` updates the index.
- **The two columns read separately.** `M ` on the left is in the index; ` M` on the right is in the folder only; `MM`, both; `??`, Git doesn't know the file.
- **One commit, one intention** becomes possible: `git add file`, or `git add -p` hunk by hunk, and the rest waits for the next commit.
- **`git restore --staged` is the opposite of `git add`**, and never touches the disk. `git restore` without options, for its part, overwrites the folder with the index: that's the other half, and it doesn't warn.
- **`git stash` and `git commit -a` go through the index too**: the first tucks it away with the folder, the second adds the tracked files before committing.

## Where it's used

- [Setting my work in progress aside to change branch](/en/situations/quotidien/mettre-son-travail-de-cote/)
- [Undoing my last commit, not yet pushed](/en/situations/reparer/annuler-mon-dernier-commit/)
- [.gitignore doesn't work, the file is already tracked](/en/situations/fichiers/gitignore-fichier-deja-suivi/)
- [A commit is a snapshot](/en/comprendre/un-commit-est-un-instantane/)
- Commands: [`git add`](/en/commandes/add/), [`git status`](/en/commandes/status/), [`git restore`](/en/commandes/restore/), [`git diff`](/en/commandes/diff/)

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/comprendre/l-index-l-etape-entre-ton-dossier-et-le-commit.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/comprendre/l-index-l-etape-entre-ton-dossier-et-le-commit.sh), run with Git 2.50 on 7 October 2026. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
