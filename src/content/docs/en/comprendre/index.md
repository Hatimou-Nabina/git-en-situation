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
5. [Upstream, the branch yours follows](/en/comprendre/upstream-la-branche-que-la-tienne-suit/): the two lines `push -u` writes, which say "ahead", "behind" or "gone".
6. [The reflog, your safety net](/en/comprendre/le-reflog-ton-filet-de-securite/): why you rarely lose a commit, how to get it back, and what the journal doesn't contain.
7. [The index, the step between your folder and the commit](/en/comprendre/l-index-l-etape-entre-ton-dossier-et-le-commit/): what `git add` really does, and the two columns of `git status`.
8. [HEAD, or "where am I"](/en/comprendre/head-ou-ou-je-suis/): the current branch, the "detached HEAD" state that scares for nothing, and `HEAD~1` versus `HEAD@{1}`.
9. [What Git deletes, and when](/en/comprendre/ce-que-git-supprime-et-quand/): objects nothing reaches any more, automatic cleanup, delays, and what Git never touches on its own.
10. [The files in `.git/`](/en/comprendre/les-fichiers-de-git/): a guided tour, to demystify.

The section is complete. An idea is missing, or a page looks wrong to you? [Open an issue](https://github.com/Hatimou-Nabina/git-en-situation/issues/new/choose), or fix it: the template is in the repository's `CONTRIBUTING.md`.
