---
title: Conventional commits
description: A commit message format, "type(scope) - subject", that makes the history readable, filterable, and usable for a changelog. The types, the rules, a six-line guard rail, and what GitHub does with it.
level: debutant
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
sidebar:
  order: 2
---

## What it avoids

A history made of "update", "fix", "wip" and "one more try", where you have to open each commit to know what it contains. A changelog written by hand, so never up to date. A production release nobody knows whether it breaks something. And reviews that start with "can you explain what this commit does?".

The convention fits in one line: `type(scope): subject`. The type says the nature of the change, the scope the part of the project, the subject what the commit does.

## How it's done

A history that reads without opening the commits:

```console
$ git log --oneline main..HEAD
e22aa48 feat(api)!: renomme le champ query en q
2b06085 docs: explique le filtre de recherche
027737a fix(recherche): ignore les espaces en debut de saisie
2d5fb23 test(recherche): couvre la recherche vide
be23af6 feat(recherche): ajoute la barre de recherche
```

**The types**, and no more are needed:

| Type | For |
|---|---|
| `feat` | a new feature, visible to the user |
| `fix` | a bug fix |
| `docs` | documentation only |
| `refactor` | a code change that changes neither behaviour nor bugs |
| `perf` | a performance improvement |
| `test` | tests added or fixed |
| `build`, `ci` | build tooling, CI |
| `chore` | maintenance that fits nowhere else: dependencies, configuration |
| `revert` | undoing a previous commit |

**The scope** is optional and names the part of the project: `auth`, `recherche`, `api`. **The subject** is in the imperative, without capital or final period, and fits in seventy-two characters: it completes the sentence "this commit will …".

The type is for filtering:

```console
$ git log --oneline --grep='^feat' main..HEAD
e22aa48 feat(api)!: renomme le champ query en q
be23af6 feat(recherche): ajoute la barre de recherche

$ git log --oneline --grep='^fix' main..HEAD
027737a fix(recherche): ignore les espaces en debut de saisie
```

**The body says why**, which the diff never says. **The footer links**: `Closes #12` for an issue, `BREAKING CHANGE:` for a change that breaks users, also flagged by the `!` after the type:

```console
$ git log -1 --format='%B'
feat(api)!: renomme le champ query en q

Le nom query devenait ambigu avec le parametre de pagination,
qui s appelle aussi query dans la bibliotheque HTTP.

BREAKING CHANGE: les clients doivent envoyer q au lieu de query.
Closes #12
```

And the tally of a batch of commits is computed, for a changelog or release notes:

```console
$ git log --format='%s' main..HEAD | sed -E 's/^([a-z]+).*/\1/' | sort | uniq -c
      1 docs
      2 feat
      1 fix
      1 test
```

**A local guard rail**, in six lines, in `.git/hooks/commit-msg`. Git runs it before each commit and refuses what doesn't follow the format:

```console
$ cat .git/hooks/commit-msg
#!/usr/bin/env bash
# Refuse un message qui ne suit pas « type(scope): sujet ».
if ! head -1 "$1" | grep -Eq '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9-]+\))?!?: .+'; then
  echo "Message refuse. Attendu : type(scope): sujet, par exemple fix(auth): corrige la deconnexion" >&2
  exit 1
fi

$ git commit -m "update stuff"
Message refuse. Attendu : type(scope): sujet, par exemple fix(auth): corrige la deconnexion

$ git commit -m "chore: ajoute x.txt"
[feature/recherche 550549b] chore: ajoute x.txt
 1 file changed, 1 insertion(+)
 create mode 100644 x.txt
```

The hook's message, in French, reads "Message refused. Expected: type(scope): subject, for example fix(auth): fix the logout". A hook is not versioned: everyone installs it, or the team goes through a shared tool, `commitlint` with `husky` in a Node project, which does the same thing from the repository.

## On GitHub

- **The pull request's title** follows the same format. With "Squash and merge", it becomes the message of the single commit on `main`: that's the one that will be read afterwards.
- **`Closes #12`** in a commit or a PR description closes the issue at merge.
- **GitHub's automatic release notes** group by PR label, not by commit type. Tools like `release-please` or `semantic-release` read the types to compute the version number and write the changelog: [Keeping a changelog](/en/equipe/tenir-un-changelog/).

## Pitfalls

- **`chore` as a catch-all.** If you hesitate, it's often a `refactor`, a `build` or a `docs`. A history where one commit in three is `chore` no longer informs.
- **One commit, two natures.** "feat(recherche): add the filter and fix the sort" hides a `fix` in a `feat`. Two commits.
- **Lying about the type**, a `refactor` that changes behaviour, a `fix` that adds an option: the convention is only worth the trust you can put in it.
- **Forgetting the `!`** on a change that breaks users: that's precisely the information that must jump out.
- **Two languages in the same history.** Choose once, for the whole project; this site chose French, in the imperative.
- **Reworking a message after the push** rewrites the commit: see [Undoing my last commit, not yet pushed](/en/situations/reparer/annuler-mon-dernier-commit/) and its limits.

## See also

- [The pull request, from opening to merge](/en/equipe/la-pull-request/)
- [A commit is a snapshot](/en/comprendre/un-commit-est-un-instantane/)
- The specification: [conventionalcommits.org](https://www.conventionalcommits.org/en/v1.0.0/)

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/equipe/commits-conventionnels.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/equipe/commits-conventionnels.sh), run with Git 2.50 on 5 October 2026, hook included. Only the commit ids are those of the example repository, whose commit messages are in French.
:::
