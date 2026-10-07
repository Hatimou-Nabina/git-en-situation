---
title: A CI that checks what the machines don't see
description: 'The executable bit, the case of file names, the file that only exists on your machine, line endings. Why "works on my machine" proves nothing, and a check script the CI runs at every push.'
level: intermediaire
gitVersion: "2.55"
verified: 2026-10-05
published: 2026-10-05
sidebar:
  order: 11
---

## What it avoids

"Works on my machine." The deployment script that fails in production with `Permission denied`. The import that works on every machine in the team, on Windows and macOS, and crashes on the Linux server because `Utils.js` isn't `utils.js`. The configuration file everyone has, except the machine that just cloned. And line endings, [already seen on this site](/en/situations/fichiers/fins-de-ligne-crlf-lf/).

A workstation hides many things: files Git doesn't track, tools installed once, a system that turns a blind eye to case or ignores permissions. The CI, for its part, starts from a pristine clone, on Linux, with nothing but what's in the repository. That's why it sees what the machines don't see, and that's why you have to let it look.

## How it's done

**1. A script that works on your machine and not in CI: the executable bit.** On Windows, Unix permissions don't exist: a script committed from Windows arrives with mode `100644`, readable but not executable. Everyone runs it with `bash deploy.sh`, which hides the problem; the CI, for its part, does `./deploy.sh`.

```console
$ git ls-files -s deploy.sh
100644 5b13c5d70bcee9c5a9ab9d751c5e76e6e98b7492 0	deploy.sh

$ bash deploy.sh
deploiement ok

$ ./deploy.sh
bash: line 1: ./deploy.sh: Permission denied
```

The fix happens in the repository, not on the server. On Linux and macOS, `chmod +x` then `git add` are enough; on Windows, where the bit doesn't exist, `git update-index --chmod=+x` writes it directly into the index. The two together give the same result everywhere:

```console
$ chmod +x deploy.sh

$ git update-index --chmod=+x deploy.sh

$ git ls-files -s deploy.sh
100755 5b13c5d70bcee9c5a9ab9d751c5e76e6e98b7492 0	deploy.sh
```

On a colleague's machine, after the `pull`, the file arrives executable:

```console
$ ./deploy.sh
deploiement ok
```

**2. The case of names: your machine turns a blind eye, Linux doesn't.** On Windows and macOS, `Utils.js` and `utils.js` refer to the same file; on Linux, they are two names, and the second doesn't exist.

```console
$ cat app.js
import { util } from "./Utils.js";

$ test -f Utils.js && echo "trouve" || echo "introuvable"
introuvable

$ git ls-files | grep -i '^utils.js$'
utils.js
```

On your machine, the second command would have said `trouve`, "found"; here it says `introuvable`, "not found". What Git tracks has a precise case: `git ls-files` is the source of truth, and the `grep -i` finds the real name.

**3. A file that exists only on your machine.** An ignored configuration file, a generated file, a file never added: the code reads it, `git status` says nothing, and the CI's clone doesn't have it.

```console
$ git status --short

$ git ls-files --error-unmatch config.local.json
error: pathspec 'config.local.json' did not match any file(s) known to git
Did you forget to 'git add'?

$ ls config.local.json
ls: cannot access 'config.local.json': No such file or directory
```

`git status` is clean, and yet the file is missing on the colleague's machine that just cloned, last command. `ls-files --error-unmatch` is the test to ask: it fails if Git doesn't track the file.

**4. The checks that catch all that, in a script the CI runs.** The three tests read the index with `git ls-files`, so the same thing on every system. You run it on your machine first:

```console
$ cat scripts/verifier.sh
#!/usr/bin/env bash
# Ce que les postes ne voient pas, la CI le vérifie à chaque push.
code=0
# 1. Fins de ligne : tout en LF dans le dépôt.
if git ls-files --eol | grep -q 'i/crlf'; then
  echo "Fichiers en CRLF dans le depot :"; git ls-files --eol | grep 'i/crlf'; code=1
fi
# 2. Les scripts shell sont exécutables.
if git ls-files -s -- '*.sh' | grep -qv '^100755'; then
  echo "Scripts sans bit d execution :"; git ls-files -s -- '*.sh' | grep -v '^100755'; code=1
fi
# 3. Pas deux fichiers dont le nom ne diffère que par la casse.
if git ls-files | sort -f | uniq -di | grep -q .; then
  echo "Noms en double a la casse pres :"; git ls-files | sort -f | uniq -di; code=1
fi
exit $code

$ bash scripts/verifier.sh; echo "code de sortie : $?"
Scripts sans bit d execution :
100644 07e2bd787cc4cf73bdb0d5644e6d55f117fd6fdc 0	scripts/verifier.sh
code de sortie : 1
```

The script's three checks, commented in French: line endings all LF in the repository, shell scripts executable, no two files whose names differ only by case. Its messages read "CRLF files in the repository", "Scripts without execution bit", "Duplicate names up to case"; `code de sortie` is the exit code. The script catches itself red-handed: it was just created without the executable bit. Once fixed, the exit code goes to zero, and that's the code the CI looks at:

```console
$ chmod +x scripts/verifier.sh

$ git update-index --chmod=+x scripts/verifier.sh

$ bash scripts/verifier.sh; echo "code de sortie : $?"
code de sortie : 0
```

The workflow fits in eight lines: a pristine clone on Ubuntu, and the script.

```console
$ cat .github/workflows/verifier.yml
name: Vérifier
on: [push, pull_request]
jobs:
  verifier:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - run: bash scripts/verifier.sh
```

This site does the same thing: at every pull request, one workflow builds the site on Ubuntu and validates the links, another replays every page's script. What passes on the maintainer's Windows machine and not there is caught before the merge. This page is an example: its outputs come from that replay.

## On GitHub

- **A workflow is a file in `.github/workflows/`**, triggered by `on:`: `push`, `pull_request`, a tag, a time. It runs on a brand-new machine every time: nothing that's on your machine is there, except what the repository contains.
- **The required check**: in `main`'s protection, "Require status checks to pass" with the job's name makes merging impossible as long as the script fails. [Protecting the main branch](/en/equipe/proteger-la-branche-principale/).
- **The matrix** runs the same job on several systems: `runs-on: ${{ matrix.os }}` with `[ubuntu-latest, windows-latest, macos-latest]`. Useful when users are on several systems; Linux alone is enough to catch what this page describes.
- **The logs** are in the Actions tab, or `gh run view --log`. The script's `echo "code de sortie"` is only there for the page: GitHub reads the exit code itself, and marks the step red as soon as it isn't zero.
- **`actions/checkout`** clones without the history by default (`fetch-depth: 1`): a script that needs the tags or the commit dates asks for `fetch-depth: 0`.

## Pitfalls

- **Fixing on the server**, `chmod +x` in production, `dos2unix` by hand: the next deployment brings the problem back. The fix is a commit.
- **`core.fileMode` and `core.ignorecase`**: Git sets them on its own according to the system, and that's why the machine sees nothing. Changing them on a machine changes nothing about what the repository contains.
- **Two files that differ only by case**, `Readme.md` and `README.md`, both in the repository: impossible to check out cleanly on Windows and macOS, where one overwrites the other. The script's third test spots them; you delete one and fix what referred to it.
- **A tool installed globally** on the machine and absent from the CI: the dependency must be in the repository, `package.json`, `requirements.txt`, or installed by the workflow.
- **Silencing the CI**, with `continue-on-error` or by removing the failing test, rather than fixing: it becomes decorative again.
- **A slow CI** that nobody waits for any more. This page's checks take one second; put them first, before the long tests.

## See also

- [My scripts break on the server, line endings](/en/situations/fichiers/fins-de-ligne-crlf-lf/)
- [Git sees all my files as modified](/en/situations/fichiers/tous-les-fichiers-modifies/)
- [.gitignore doesn't work, the file is already tracked](/en/situations/fichiers/gitignore-fichier-deja-suivi/)
- [Protecting the main branch](/en/equipe/proteger-la-branche-principale/)

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/equipe/ci-ce-que-les-postes-ne-voient-pas.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/equipe/ci-ce-que-les-postes-ne-voient-pas.sh), replayed **on Ubuntu** by the repository's "Rejouer les situations" workflow, with Git 2.55, on 5 October 2026. On Windows, the executable bit and the case of names don't exist: `./deploy.sh` goes through and `Utils.js` is found, which is precisely the subject of the page. Only the server address and the commit ids are those of the example repository, whose scripts and commit messages are in French.
:::
