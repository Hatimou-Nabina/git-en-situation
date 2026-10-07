---
title: Git sees all my files as modified
description: You touched nothing, and git status reports every file modified. Almost always line endings, sometimes permissions. How to check with git ls-files --eol, and how to set the repository straight without committing a hundred fake changes.
level: intermediaire
risk: destructif
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
---

## Symptom

The repository had just been cloned on Windows, everything was clean. A setting changed, by you or by a tool, and suddenly:

```console
$ git config core.autocrlf false

$ git status --short
 M README.md
 M a.txt
 M b.txt
 M c.txt

$ git diff --stat
 README.md | 2 +-
 a.txt     | 4 ++--
 b.txt     | 4 ++--
 c.txt     | 2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)
```

Every line of every file would be modified. Yet `git diff` shows nothing readable, except by making the invisible characters visible:

```console
$ git diff a.txt | cat -A | tail -4
-a$
-b$
+a^M$
+b^M$
```

## Diagnosis

`^M` is a carriage return: the files on your disk end their lines with CRLF, the Windows convention, while the repository stores them as LF. Until then, `core.autocrlf=true` did the conversion both ways and Git saw no difference. With the setting disabled, Git compares the bytes as they are: everything differs. `git ls-files --eol` says it file by file, `i/` for the index, `w/` for the working folder:

```console
$ git ls-files --eol
i/lf    w/crlf  attr/                 	README.md
i/lf    w/crlf  attr/                 	a.txt
i/lf    w/crlf  attr/                 	b.txt
i/lf    w/crlf  attr/                 	c.txt
```

Nothing is really modified. Above all, don't commit that: you would send a hundred fake changes, and the problem to everyone else.

:::caution[One command on this page throws uncommitted changes away]
Step 3 uses `git reset --hard`. Before it, `git status`: if real work in progress remains, commit it or [set it aside](/en/situations/quotidien/mettre-son-travail-de-cote/).
:::

## Solution

**1. Set the rule in the repository**, so that everyone has it, whatever their personal setting:

```console
$ printf "* text=auto eol=lf\n" > .gitattributes
```

**2. Renormalise.** Git recomputes what each file must be in the index according to the rule. Here, the index was already LF: only the `.gitattributes` shows up.

```console
$ git add --renormalize .

$ git status --short
?? .gitattributes

$ git add .gitattributes && git commit -q -m "Fins de ligne LF pour tout le depot"
```

**3. Rewrite the working folder according to the rule.** Git doesn't rewrite on its own the files it considers clean; you empty the index and rebuild it:

```console
$ git rm -r -q --cached . && git reset -q --hard

$ git ls-files --eol
i/lf    w/lf    attr/text=auto eol=lf 	.gitattributes
i/lf    w/lf    attr/text=auto eol=lf 	README.md
i/lf    w/lf    attr/text=auto eol=lf 	a.txt
i/lf    w/lf    attr/text=auto eol=lf 	b.txt
i/lf    w/lf    attr/text=auto eol=lf 	c.txt

$ git status --short
```

Everything is LF, on the disk as in the repository, and the status is clean.

## Why it works

Git stores text files with LF line endings and can convert them on the fly: on the way out to the disk, and on the way in to the index. `core.autocrlf` is the **machine's** setting; `.gitattributes` is the **repository's** rule, and it wins. `text=auto` asks Git to recognise text files itself, `eol=lf` sets what the disk must contain. `git add --renormalize` applies the rule to the index without waiting for a modification; emptying the index then `reset --hard` forces Git to rewrite every file on the disk with the new attributes.

## Pitfalls

- **Another cause, permissions.** After a copy between systems, or on a shared drive, Git may see "old mode 100644, new mode 100755" on every file. There, it's `git config core.fileMode false` for that repository.
- **Binary files.** `text=auto` recognises them almost always; to be sure, declare them: `*.png binary`, `*.pdf binary`. A "normalised" binary is a corrupted binary.
- **On colleagues' machines**, after pulling the `.gitattributes` commit, the same symptom may appear. Same remedy, step 3.
- **The three values of `core.autocrlf`**: `true` converts to CRLF on the disk and LF in the repository, `input` leaves the disk as is and stores LF, `false` touches nothing. With a `.gitattributes`, that setting no longer matters: that's the point.
- **Why LF everywhere, even on Windows**: the server's scripts and tools require it, and modern editors cope with it. See [My scripts break on the server, line endings](/en/situations/fichiers/fins-de-ligne-crlf-lf/).

## See also

- [My scripts break on the server, line endings](/en/situations/fichiers/fins-de-ligne-crlf-lf/)
- [Setting my work in progress aside to change branch](/en/situations/quotidien/mettre-son-travail-de-cote/)

:::note[Try it yourself]
This page's script can create the problem on your machine. From a clone of the [site's repository](https://github.com/Hatimou-Nabina/git-en-situation), in Git Bash on Windows:

```bash
EXERCICE=1 bash scripts/situations/tous-les-fichiers-modifies.sh
```

It stops right after the symptom, tells you which folder to go to and what to do. Fix it, then run it again without `EXERCICE=1` to compare with the solution.
:::

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/situations/tous-les-fichiers-modifies.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/tous-les-fichiers-modifies.sh), run with Git 2.50 on 6 October 2026, on a clone made with `core.autocrlf=true` to reproduce a Windows machine. After the setting change, the files are refreshed with `touch`: Git trusts their dates and wouldn't reread their content otherwise, which on a real machine the first save in the editor does. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
