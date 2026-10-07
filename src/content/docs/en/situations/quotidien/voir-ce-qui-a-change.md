---
title: Seeing what changed between my branch and main
description: Before opening a pull request, knowing which commits your branch brings and which files it touches. The commands, and the trap of two dots versus three dots, which don't mean the same thing for log and for diff.
level: debutant
risk: aucun
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptom

No error here. You've worked a few days on `feature/recherche`, `main` moved in the meantime, and before opening your pull request you want to answer three questions: which commits does my branch bring, which files does it touch, and what did `main` receive during that time?

## Diagnosis

Git has two tools for two questions. `git log` answers in **commits**, `git diff` answers in **content**. Both accept a "range" between two branches, written with two dots or three dots. And that's where it gets complicated: `..` and `...` don't have the same meaning depending on whether you're talking to `log` or to `diff`. Once that point is understood, everything else is simple.

## Solution

**The commits of my branch that `main` doesn't have**: two dots, the reference branch first.

```console
$ git log --oneline main..feature/recherche
df6e2e1 Filtre les resultats
5b5dda8 Ajoute la recherche
```

**And the reverse**, what `main` received in the meantime:

```console
$ git log --oneline feature/recherche..main
40cf319 Ajoute la page contact
```

**Both sides at once**, three dots and `--left-right`: `<` for the left side, `>` for the right.

```console
$ git log --oneline --left-right main...feature/recherche
< 40cf319 Ajoute la page contact
> df6e2e1 Filtre les resultats
> 5b5dda8 Ajoute la recherche
```

**The files my branch touched**, since the point where it left `main`. Here, three dots with `diff`:

```console
$ git diff --stat main...feature/recherche
 recherche.js | 2 ++
 1 file changed, 2 insertions(+)
```

**The detail of one file**:

```console
$ git diff main...feature/recherche -- recherche.js
diff --git a/recherche.js b/recherche.js
new file mode 100644
index 0000000..f7aabde
--- /dev/null
+++ b/recherche.js
@@ -0,0 +1,2 @@
+recherche
+filtre
```

**What I modified and haven't committed yet**, with no range at all:

```console
$ git diff --stat
 recherche.js | 1 +
 1 file changed, 1 insertion(+)

$ git diff
diff --git a/recherche.js b/recherche.js
index f7aabde..093f8ac 100644
--- a/recherche.js
+++ b/recherche.js
@@ -1,2 +1,3 @@
 recherche
 filtre
+tri
```

## Why it works

For **`git log`**, `A..B` means "the commits reachable from B but not from A": what B has in addition. `A...B` means "the commits that are on one side only", the two differences together; `--left-right` tells which side each one is on.

For **`git diff`**, there is no list of commits, only two states to compare. `git diff A B` compares A and B as they are. `git diff A...B` compares **the common ancestor** of A and B with B: that's "what B changed since it left A", regardless of what A did since. It's almost always what you want before a pull request, and it's exactly what GitHub shows in the "Files changed" tab.

The two notations were born separately, for different commands, and Git could never reconcile them without breaking everything. Remember: with `log`, two dots; with `diff`, three dots.

## Pitfalls

- **`git diff main feature/recherche`**, without dots, compares the two branches as they are: the contact page added on `main` appears as **deleted** by your branch, although you never touched it. It's the classic mistake, and the reason the three dots exist.
- **`git diff` alone** shows the changes not yet added to the index; `git diff --staged` shows those already added with `git add`, ready to be committed.
- **`--stat`** first, for an overview; `-- path` next, for a file or a folder.
- **`git log -p main..feature/recherche`** shows the commits with their diff, commit by commit: useful to review your own work before submitting it.

## See also

- [Deleting an old branch without losing anything](/en/situations/quotidien/supprimer-une-vieille-branche-sans-rien-perdre/), which uses `main..branch` to check that nothing is left
- [Setting my work in progress aside to change branch](/en/situations/quotidien/mettre-son-travail-de-cote/)
- Commands: [`git log`](/en/commandes/log/), [`git diff`](/en/commandes/diff/)

:::note[Try it yourself]
This page's script can create the problem on your machine. From a clone of the [site's repository](https://github.com/Hatimou-Nabina/git-en-situation), in Git Bash on Windows:

```bash
EXERCICE=1 bash scripts/situations/voir-ce-qui-a-change.sh
```

It stops right after the symptom, tells you which folder to go to and what to do. Fix it, then run it again without `EXERCICE=1` to compare with the solution.
:::

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/situations/voir-ce-qui-a-change.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/voir-ce-qui-a-change.sh), run with Git 2.50 on 5 October 2026. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
