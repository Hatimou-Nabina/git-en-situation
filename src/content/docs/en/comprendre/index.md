---
title: Understanding Git
description: Git's mental model in a few short pages, commits, branches, remotes, merging. Once in place, the commands become predictable.
sidebar:
  order: 0
---

Git seems complicated because we learn its commands without its model. That model is small, and once in place, the commands become predictable: you can guess what they do, and why they refuse.

Every page follows the same plan: the idea in a few sentences, then "see for yourself" with commands that were actually run, what it changes in practice, and the situations where it matters.

In the recommended reading order:

1. [A commit is a snapshot](/en/comprendre/un-commit-est-un-instantane/): what a commit contains, why it has an id, why it is never modified.
2. [A branch is a bookmark](/en/comprendre/une-branche-est-un-marque-page/): a forty-one-character file that moves forward when you commit.
3. [Remotes and remote-tracking references](/en/comprendre/remotes-et-references-distantes/): `origin`, `origin/main`, and why it is not the same thing as `main`.
4. [Fast-forward, merge, rebase](/en/comprendre/fast-forward-fusion-rebase/): three ways to bring two lines of work together, and what each leaves in the history.

Coming:

- **HEAD, or "where am I"**: the current branch, and the "detached HEAD" state that scares for nothing.
- **The index, the step between your folder and the commit**: what `git add` really does.
- **Upstream, the branch yours follows**: `-u`, "ahead", "behind", "gone".
- **The reflog, your safety net**: why you rarely lose a commit, and how to get it back.
- **What Git deletes, and when**: unreachable objects, automatic cleanup, delays.
- **The files in `.git/`**: a guided tour, to demystify.

Pages not translated yet are shown in French, with a notice. Want to write or translate one of these pages? The template is in the repository's `CONTRIBUTING.md`.
