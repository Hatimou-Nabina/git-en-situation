---
title: The files in .git/
description: A guided tour of the .git folder, to demystify. HEAD and refs are names, objects is all the content stored by fingerprint, index the list of the next commit, logs the reflog, config the servers and the tracking links. Everything is in the clear, and almost everything can be read with cat.
level: intermediaire
gitVersion: "2.50"
verified: 2026-10-07
published: 2026-10-07
sidebar:
  order: 10
---

## The idea

Everything Git knows about a repository lives in the `.git/` folder, at the root of the project. There is no opaque database: text files for the names, compressed objects for the content, one journal per reference. The previous pages of this section have already opened several of them. This one does the full tour, so that the folder stops being a black box, and so that you know what you risk, or don't, by touching it.

## See for yourself

The folder, after a clone, two commits and a branch:

```console
$ ls -F .git
COMMIT_EDITMSG
HEAD
config
description
hooks/
index
info/
logs/
objects/
refs/
```

**`HEAD` and `refs/`**: names that lead to commits. `HEAD` holds the name of the current branch; each branch is a forty-one-character file under `refs/heads/`, each server copy under `refs/remotes/`.

```console
$ cat .git/HEAD
ref: refs/heads/main

$ find .git/refs -type f | sort
.git/refs/heads/feature/x
.git/refs/heads/main
.git/refs/remotes/origin/main

$ cat .git/refs/heads/main
8952b33d4bb2fc8dd5d65355e72668b17d4ae56a
```

**`config`**: the configuration specific to this repository, including the servers and the branches' tracking links.

```console
$ git config --local --get-regexp '^(remote|branch)\.'
remote.origin.url github.com:equipe/projet.git
remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
branch.main.remote origin
branch.main.merge refs/heads/main
```

**`objects/`**: all the content, blobs, trees and commits, each object in a file named by its fingerprint, the first two characters serving as a folder. Six files are enough here for two commits.

```console
$ git rev-parse HEAD:a.js
78981922613b2afb6025042ff6bd878ac1994e85

$ ls .git/objects/$(git rev-parse HEAD:a.js | cut -c1-2)/
981922613b2afb6025042ff6bd878ac1994e85

$ git cat-file -p $(git rev-parse HEAD:a.js)
a

$ git cat-file -t HEAD
commit

$ find .git/objects -type f | wc -l
6
```

**`index`**: the list of the next commit's files, with their mode and the object they point to. It's the only binary file of the tour; `ls-files -s` reads it.

```console
$ git ls-files -s
100644 b60e1ad35025d69cbe886686e6a0b040551b9fde 0	README.md
100644 78981922613b2afb6025042ff6bd878ac1994e85 0	a.js
```

**`logs/`**: the reflog, one journal per reference, as text: where we came from, where we're going, who, when, why.

```console
$ find .git/logs -type f | sort
.git/logs/HEAD
.git/logs/refs/heads/feature/x
.git/logs/refs/heads/main
.git/logs/refs/remotes/origin/main

$ tail -n 2 .git/logs/HEAD
0000000000000000000000000000000000000000 d0a0b32921f0e3e6484b075d9ff287b1f409cc5c Awa <awa@example.com> 1791194400 +0000	commit (initial): Premier commit
d0a0b32921f0e3e6484b075d9ff287b1f409cc5c 8952b33d4bb2fc8dd5d65355e72668b17d4ae56a Awa <awa@example.com> 1791194400 +0000	commit: feat: a
```

**`info/exclude`**: ignore rules that don't leave this clone, for what concerns only you. `check-ignore` cites it like any `.gitignore`.

```console
$ echo "scratch/" >> .git/info/exclude && mkdir -p scratch && echo "x" > scratch/notes.txt && git status --short

$ git check-ignore -v scratch/notes.txt
.git/info/exclude:7:scratch/	scratch/notes.txt
```

The others: `COMMIT_EDITMSG`, the last commit message as the editor received it; `description`, a name for web interfaces, unused by GitHub; `hooks/`, scripts Git runs at certain moments, shipped as `.sample` examples and inactive until renamed. In an older repository, a `packed-refs` file gathers the references into a single list, and `objects/pack/` the objects compressed together: the individual files are then missing, but `git show-ref` and `git cat-file` read both forms without difference.

## What it changes in practice

- **Nothing is hidden.** A branch is a file, a commit an object, the reflog a text: when a command surprises you, `cat` in `.git/` says what happened.
- **`.git/` is the repository.** Copying it copies the whole history; deleting it loses everything that wasn't pushed. A corrupted `.git/` is rarely repaired: it's the clone that saves, hence the importance of pushing.
- **You don't write into it by hand**, except `info/exclude` and, knowingly, `hooks/`. For the rest, each file has its command: `git branch`, `git switch`, `git config`, `git update-ref`.
- **`config` is local to the clone**: what's in it doesn't travel. What must follow the repository goes into `.gitattributes` and `.gitignore`, versioned.
- **The repository's size is `objects/`.** A large binary file modified often leaves a complete version there at every commit, and no later deletion removes it.
- **A `.git` subfolder inside a subfolder of the project**, forgotten after a nested clone, is the classic cause of the "empty folder" on GitHub: Git sees a repository inside the repository and doesn't track its content.

## Where it's used

- [A branch is a bookmark](/en/comprendre/une-branche-est-un-marque-page/)
- [A commit is a snapshot](/en/comprendre/un-commit-est-un-instantane/)
- [HEAD, or "where am I"](/en/comprendre/head-ou-ou-je-suis/)
- [The reflog, your safety net](/en/comprendre/le-reflog-ton-filet-de-securite/)
- [Remotes and remote-tracking references](/en/comprendre/remotes-et-references-distantes/)
- Commands: [`git cat-file`](/en/commandes/cat-file/), [`git ls-files`](/en/commandes/ls-files/), [`git config`](/en/commandes/config/)

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/comprendre/les-fichiers-de-git.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/comprendre/les-fichiers-de-git.sh), run with Git 2.50 on 7 October 2026. The repository is young and has neither `packed-refs` nor `objects/pack/`, hence the individual files shown. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
