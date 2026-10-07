---
title: .gitignore doesn't work, the file is already tracked
description: You added .env to .gitignore, and git status keeps seeing it modified. Why ignore rules don't apply to a file already tracked, how to untrack it without deleting it, and the other classic cause, an unreadable .gitignore.
level: debutant
risk: aucun
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptom

You add `.env` to `.gitignore`. Git keeps seeing it, and `git check-ignore`, the tool made to check the rules, answers nothing:

```console
$ echo ".env" > .gitignore

$ echo "SECRET=def" > .env

$ git status --short
 M .env
?? .gitignore

$ git check-ignore -v .env
```

## Diagnosis

`.gitignore` only concerns files that Git **doesn't track yet**. A file already committed is tracked, and the ignore rules no longer apply to it: Git keeps watching its changes, whatever `.gitignore` says. The list of tracked files confirms it:

```console
$ git ls-files
.env
README.md
app.js
```

The silence of `git check-ignore` is not an error: for a tracked file, it says nothing, precisely because the rules don't concern it.

## Solution

**Untrack the file, without deleting it from the disk.** That's what `--cached` is for:

```console
$ git rm --cached .env
rm '.env'

$ git status --short
D  .env
?? .gitignore
```

Commit that removal together with the `.gitignore`. The file is still there, and this time the rule applies:

```console
$ git add .gitignore && git commit -q -m "Ignore le fichier .env"

$ git status --short

$ ls -a
.
..
.env
.git
.gitignore
README.md
app.js

$ git check-ignore -v .env
.gitignore:1:.env	.env
```

`check-ignore -v` says which file and which line decided: `.gitignore`, line 1.

**Another cause: a `.gitignore` Git can't read.** On Windows, `echo node_modules/ > .gitignore` in PowerShell 5 writes the file in UTF-16. The rules look correct in the editor, and Git applies none of them:

```console
$ git status --short
 M .gitignore
?? .env
?? node_modules/

$ git check-ignore -v node_modules/lib.js

$ od -An -c -N 8 .gitignore
 377 376   n  \0   o  \0   d  \0
```

The first two bytes, `377 376`, and the `\0` between each letter give the encoding away. Save the file again in UTF-8, from the editor or on the command line:

```console
$ iconv -f UTF-16 -t UTF-8 .gitignore > .gitignore.utf8 && mv .gitignore.utf8 .gitignore

$ od -An -c -N 8 .gitignore
   n   o   d   e   _   m   o   d

$ git check-ignore -v node_modules/lib.js
.gitignore:1:node_modules/	node_modules/lib.js

$ git status --short
 M .gitignore
?? .env
```

## Why it works

Git keeps the list of tracked files in the **index**. The `.gitignore` rules are consulted only when deciding what to do with the files that aren't in it: show them as "untracked", or keep quiet about them. `git rm --cached` removes an entry from the index without touching the disk; at the next commit, the file is no longer tracked, and it becomes a candidate for the ignore rules again.

`git check-ignore -v` exists to debug those rules: it replays Git's decision for a path and quotes the responsible line. `--no-index` forces the check even for a tracked file.

## Pitfalls

- **On colleagues' machines, the next `pull` deletes the file.** The commit "untrack `.env`" erases the file for everyone who fetches it, Git applying the deletion. Warn them to back up their `.env` before pulling, or to recreate it afterwards.
- **A secret in that file is still in the history.** Untracking doesn't remove it from past commits: [I pushed a secret by mistake](/en/situations/fichiers/secret-pousse-par-erreur/).
- **The rules' syntax**: `node_modules/` ignores a folder everywhere, `/dist` only at the root, `*.log` every log file. `git check-ignore -v` settles it when in doubt.
- **What concerns only you**, editor files, `.DS_Store`, belongs in a global `.gitignore` (`git config --global core.excludesFile ~/.gitignore_global`) or in `.git/info/exclude`, rather than in the project's `.gitignore`.

## See also

- [I pushed a secret by mistake](/en/situations/fichiers/secret-pousse-par-erreur/)
- [Working on the same project from two machines](/en/situations/avec-les-autres/travailler-depuis-deux-machines/)
- [Working as a team: secrets never go into the repository](/en/equipe/secrets-jamais-dans-le-depot/)

:::note[Try it yourself]
This page's script can create the problem on your machine. From a clone of the [site's repository](https://github.com/Hatimou-Nabina/git-en-situation), in Git Bash on Windows:

```bash
EXERCICE=1 bash scripts/situations/gitignore-fichier-deja-suivi.sh
```

It stops right after the symptom, tells you which folder to go to and what to do. Fix it, then run it again without `EXERCICE=1` to compare with the solution.
:::

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/situations/gitignore-fichier-deja-suivi.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/gitignore-fichier-deja-suivi.sh), run with Git 2.50 on 5 October 2026. The UTF-16 `.gitignore` is made there with `iconv`, as PowerShell 5 would write it. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
