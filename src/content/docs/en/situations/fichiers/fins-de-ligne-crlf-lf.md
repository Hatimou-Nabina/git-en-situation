---
title: My scripts break on the server, line endings
description: A script that works on your Windows machine fails on the Linux server with "$'\r' - command not found". CRLF line endings, how to see them, and the .gitattributes that fixes the problem for the whole team.
level: intermediaire
risk: aucun
gitVersion: "2.55"
verified: 2026-10-06
published: 2026-10-05
---

## Symptom

A deployment script written on Windows, tested on your machine, committed, pushed. On the Linux server:

```console
$ bash deploy.sh
deploy.sh: line 2: $'\r': command not found
ls: cannot access 'deploy.sh'$'\r': No such file or directory
Deploiement en cours
```

An empty line becomes an unknown command, and a file name ends with an invisible character. The two errors are shown before the script's message, as every page of this site does; in your terminal, "Deploiement en cours" appears between the two.

## Diagnosis

Windows ends its lines with two characters, `\r\n`, carriage return then line feed. Linux expects only one, `\n`. The extra `\r` is invisible in the editor, but bash on Linux reads it as part of the command. To see it:

```console
$ od -c deploy.sh | head -3
0000000   #   !   /   u   s   r   /   b   i   n   /   e   n   v       b
0000020   a   s   h  \r  \n  \r  \n   e   c   h   o       "   D   e   p
0000040   l   o   i   e   m   e   n   t       e   n       c   o   u   r
```

On your machine, Git Bash's bash tolerates those `\r`, hence the "works on my machine". And Git, for its part, stored the file as is:

```console
$ git ls-files --eol deploy.sh
i/crlf  w/crlf  attr/                 	deploy.sh
```

`i/` is the index, what the repository contains; `w/` is the working folder. CRLF on both sides: the server receives the `\r`.

## Solution

**1. Impose LF in the repository, for everyone.** A `.gitattributes` file at the root, committed, applies to every machine whatever its setting:

```console
$ printf "* text=auto eol=lf\n" > .gitattributes
```

**2. Renormalise what is already committed.** Git recomputes the index according to the rule; the script shows up as modified, that's the `\r` going away:

```console
$ git add --renormalize .

$ git status --short
M  deploy.sh
?? .gitattributes

$ git ls-files --eol deploy.sh
i/lf    w/crlf  attr/text=auto eol=lf 	deploy.sh

$ git commit -q -m "Fins de ligne LF pour tout le depot"
```

**3. Rewrite your working copy.** Git doesn't rewrite a file it considers clean; you delete it and take it back from the repository:

```console
$ rm deploy.sh && git checkout -- deploy.sh

$ git ls-files --eol deploy.sh
i/lf    w/lf    attr/text=auto eol=lf 	deploy.sh
```

On the server, after the next deployment:

```console
$ bash deploy.sh
Deploiement en cours
deploy.sh
```

## Why it works

Git can convert line endings on the way in, towards the index, and on the way out, towards the disk. By default, it touches nothing, or follows the machine's `core.autocrlf` setting, different from one machine to the next: that's the source of the mess. `.gitattributes` sets the rule **in the repository**: `text=auto` lets Git recognise text files, `eol=lf` imposes LF on the disk as in the index. That rule wins over everyone's configuration. `git add --renormalize` applies it to files already tracked, which would otherwise keep their `\r` until their next modification.

## Pitfalls

- **Windows files that need CRLF**, `.bat` and `.cmd`, are declared separately: `*.bat text eol=crlf`.
- **The `.gitattributes` must reach colleagues before their next commits**, otherwise they keep pushing CRLF. On their machines, after the `pull`, Git may report every file as modified: [Git sees all my files as modified](/en/situations/fichiers/tous-les-fichiers-modifies/).
- **The editor has its setting too.** In VS Code, `"files.eol": "\n"` avoids reintroducing `\r` at every save; with `.gitattributes`, Git would remove them at commit anyway.
- **A `\r` after the shebang** gives a different message, `bad interpreter: No such file or directory`, for the same cause.
- **`dos2unix` on the server** fixes a file, not the repository: the next deployment brings the problem back. The fix happens at the source.

## See also

- [Git sees all my files as modified](/en/situations/fichiers/tous-les-fichiers-modifies/)
- [.gitignore doesn't work, the file is already tracked](/en/situations/fichiers/gitignore-fichier-deja-suivi/)
- [Working as a team: a CI that checks what the machines don't see](/en/equipe/ci-ce-que-les-postes-ne-voient-pas/)

:::note[Try it yourself]
This page's script can create the problem on your machine. From a clone of the [site's repository](https://github.com/Hatimou-Nabina/git-en-situation), in Git Bash on Windows:

```bash
EXERCICE=1 bash scripts/situations/fins-de-ligne-crlf-lf.sh
```

It stops right after the symptom, tells you which folder to go to and what to do. Fix it, then run it again without `EXERCICE=1` to compare with the solution.
:::

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/situations/fins-de-ligne-crlf-lf.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/fins-de-ligne-crlf-lf.sh), replayed **on Ubuntu** by the repository's "Rejouer les situations" workflow, with Git 2.55, on 6 October 2026. On Windows, Git Bash's bash tolerates CRLF and the error doesn't show up there: that is precisely the subject of the page. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
