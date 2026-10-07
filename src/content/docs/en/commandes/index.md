---
title: The commands that matter
description: One page per command, limited to the useful forms, with their real outputs, pointing to the pages where it is used. Twenty-nine pages, by use.
sidebar:
  order: 0
---

Git has more than 150 commands. About twenty really matter, and for each one, three to six forms cover the essentials. This section sticks to that, with one rule: a page exists if at least two pages of this site rely on the command, by running it or by recommending it. For the rest, `git help <command>` is the reference, and every page points to it.

A command page is not a copy of the manual. It answers three questions: what the command is for, which forms are worth knowing, with their real outputs, and in which pages of this site you meet it. That last list is computed from the site's content: it is always up to date.

- **Looking around and moving**: [`git log`](/en/commandes/log/), [`git diff`](/en/commandes/diff/), [`git branch`](/en/commandes/branch/), [`git switch`](/en/commandes/switch/), and [`git checkout`](/en/commandes/checkout/), the command people still type, with what replaces it.
- **The server**: [`git fetch`](/en/commandes/fetch/), [`git pull`](/en/commandes/pull/), [`git push`](/en/commandes/push/), [`git remote`](/en/commandes/remote/).
- **Everyday**: [`git status`](/en/commandes/status/), [`git add`](/en/commandes/add/), [`git commit`](/en/commandes/commit/), [`git stash`](/en/commandes/stash/), [`git rm`](/en/commandes/rm/).
- **Repairing**: [`git reset`](/en/commandes/reset/), [`git restore`](/en/commandes/restore/), [`git revert`](/en/commandes/revert/), [`git reflog`](/en/commandes/reflog/).
- **Bringing together**: [`git merge`](/en/commandes/merge/), [`git rebase`](/en/commandes/rebase/), [`git cherry-pick`](/en/commandes/cherry-pick/), [`git tag`](/en/commandes/tag/).
- **Configuring and inspecting**: [`git config`](/en/commandes/config/), [`git show`](/en/commandes/show/), [`git ls-files`](/en/commandes/ls-files/), [`git check-ignore`](/en/commandes/check-ignore/), [`git cat-file`](/en/commandes/cat-file/), [`git merge-base`](/en/commandes/merge-base/).
- **GitHub from the command line**: [`gh`](/en/commandes/gh/), the only page without verified outputs, and the only one specific to GitHub.

The section is complete; pages not translated yet are shown in French, with a notice. No page for `blame`, `bisect`, `worktree`, `mv` or `clean`, which no page of this site uses yet: the day a situation needs one, the page will follow. A command is missing for you? [Open an issue](https://github.com/Hatimou-Nabina/git-en-situation/issues/new/choose), or write the page: the template is in the repository's `CONTRIBUTING.md`.
