---
title: Keeping a changelog
description: 'For whom, when, and what it contains. An "Unreleased" section every pull request feeds, the classic conflict on that section and the attribute that avoids it, the draft drawn from conventional commits, and the version that takes a number and a date.'
level: debutant
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
sidebar:
  order: 8
---

## What it avoids

"What changed since the last version?", and two hundred commits to reread to answer. Users surprised by a change that breaks their usage, announced nowhere. Release notes written from memory on the evening of the delivery, necessarily incomplete. And, for a project you pick up on another machine or after three months, losing the thread: this site keeps its own changelog first of all for that.

A changelog says what changes for the person who uses the project, not how the code moved. It is written as you go, in the pull request that brings the change, and closed at each version.

## How it's done

**1. The file.** `CHANGELOG.md` at the root, in the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format: an "Unreleased" section at the top, then one section per version, most recent first, each dated and split into "Added", "Changed", "Fixed", "Removed", "Security" according to what it contains. The example project writes it in French: « Non publié » is "Unreleased", « Ajouté » is "Added", « Corrigé » is "Fixed".

```console
$ cat CHANGELOG.md
# Changelog

Les évolutions notables du projet, pour ceux qui l'utilisent. Format : Keep a Changelog ; numéros : versionnage sémantique.

## [Non publié]

## [1.1.0] - 2026-09-20

### Ajouté
- Recherche dans les documents, avec un filtre par date.

### Corrigé
- L'export d'une liste vide ne plante plus.
```

**2. The changelog line travels in the same commit as the change.** No PR without its line, no line without its PR: the reviewer reads it with the rest, and the "Unreleased" section is always up to date.

```console
$ git show --stat --format='%h %s' HEAD
ac88ea6 feat(export): ajoute l export CSV

 CHANGELOG.md | 3 +++
 export.js    | 1 +
 2 files changed, 4 insertions(+)

$ git log --oneline -- CHANGELOG.md
ac88ea6 feat(export): ajoute l export CSV
a0cbc71 docs: ajoute le changelog
```

The line speaks to the reader: "CSV export of search results", not "refactor of the export module". If the change breaks a usage, say it in so many words.

**3. Two pull requests touch the same section: the conflict.** It's the known flaw of this method. Bakary added his line at the same place, without having Awa's commit:

```console
$ git pull --rebase
From github.com:equipe/projet
   a0cbc71..ac88ea6  main       -> origin/main
Rebasing (1/1)error: could not apply 91c1661... fix(recherche): ignore les accents
hint: Resolve all conflicts manually, mark them as resolved with
hint: "git add/rm <conflicted_files>", then run "git rebase --continue".
hint: You can instead skip this commit: run "git rebase --skip".
hint: To abort and get back to the state before "git rebase", run "git rebase --abort".
hint: Disable this message with "git config set advice.mergeConflict false"
Could not apply 91c1661... # fix(recherche): ignore les accents
Auto-merging CHANGELOG.md
CONFLICT (content): Merge conflict in CHANGELOG.md

$ sed -n "5,16p" CHANGELOG.md
## [Non publié]

<<<<<<< HEAD
### Ajouté
- Export CSV des résultats de recherche.
=======
### Corrigé
- La recherche ignore désormais les accents.
>>>>>>> 91c1661 (fix(recherche): ignore les accents)

## [1.1.0] - 2026-09-20

```

The conflict is trivial, both sides must be kept, but it comes back at every PR. [A conflict during a merge or a rebase](/en/situations/reparer/resoudre-un-conflit/) explains the manual resolution; here, we give up in order to show better:

```console
$ git rebase --abort
```

**4. Avoiding it once and for all: `merge=union` for this file.** One line in `.gitattributes`, versioned, tells Git that for this file, in case of conflict, both sides must be kept rather than asking:

```console
$ cat .gitattributes
CHANGELOG.md merge=union
```

The same `pull --rebase` goes through, and both lines are there:

```console
$ git pull --rebase
From github.com:equipe/projet
   ac88ea6..dc9a44a  main       -> origin/main
Rebasing (1/1)Successfully rebased and updated refs/heads/main.

$ sed -n "5,12p" CHANGELOG.md
## [Non publié]

### Ajouté
- Export CSV des résultats de recherche.
### Corrigé
- La recherche ignore désormais les accents.

## [1.1.0] - 2026-09-20
```

The blank line between the two blocks is gone: you tidy up at version time. `union` is only right for a file where "both" is always the right answer; on code, it would be a silent catastrophe.

**5. The version's draft, from the commits.** If the team follows [conventional commits](/en/equipe/commits-conventionnels/), the list of what changed since the last tag can be computed, and serves to check that nothing was forgotten in "Unreleased":

```console
$ git log --format='- %s' --grep='^feat' v1.1.0..HEAD
- feat(export): ajoute l export CSV

$ git log --format='- %s' --grep='^fix' v1.1.0..HEAD
- fix(recherche): ignore les accents
```

It's a draft, not the changelog: it speaks in terms of code, the changelog speaks in terms of usage.

**6. At the version, the section takes a number and a date**, an empty "Unreleased" section stays above, and a tag marks the commit:

```console
$ git diff HEAD~1 -- CHANGELOG.md
diff --git a/CHANGELOG.md b/CHANGELOG.md
index 555cd39..b4b6af2 100644
--- a/CHANGELOG.md
+++ b/CHANGELOG.md
@@ -4,8 +4,11 @@ Les évolutions notables du projet, pour ceux qui l'utilisent. Format : Keep a C

 ## [Non publié]

+## [1.2.0] - 2026-10-05
+
 ### Ajouté
 - Export CSV des résultats de recherche.
+
 ### Corrigé
 - La recherche ignore désormais les accents.


$ git log --oneline v1.1.0..v1.2.0
217f1a1 chore(release): version 1.2.0
0727b29 fix(recherche): ignore les accents
dc9a44a chore: fusion par union pour le changelog
ac88ea6 feat(export): ajoute l export CSV
```

The number follows semantic versioning: [Versions and tags](/en/equipe/versions-et-tags/) details the choice of the number and the tag.

## On GitHub

- **Automatic release notes** ("Generate release notes" in a release) list the PRs merged since the previous tag, grouped by label. A good draft, not a changelog: they speak of PRs, not of usage.
- **`release-please`** maintains `CHANGELOG.md` on its own from conventional commits, by opening a version PR that you only have to merge. For a team that writes its commits well, it's the changelog without the effort.
- **One link per version** to the GitHub comparison, at the bottom of the file: `[1.2.0]: https://github.com/equipe/projet/compare/v1.1.0...v1.2.0`. Keep a Changelog provides for it, and the reader goes from the summary to the details in one click.
- **This site's changelog** is kept this way: [CHANGELOG.md](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/CHANGELOG.md), one section per batch of work, with the number of the PR that put it online.

## Pitfalls

- **The changelog that copies `git log`.** If it's the same thing, it's useless; its value is to translate for the reader.
- **Writing it at version time**, from memory. You forget, and you get it wrong. The line goes in the PR, while the change is fresh.
- **The "Unreleased" section never emptied**, growing for six months: it's the sign there has been no version, and that one is needed.
- **The breaking change, drowned in "Changed".** It deserves a mention at the top of the section, in so many words: what will no longer work, and what to do.
- **The ambiguous date.** `2026-10-05` reads the same everywhere; `05/10/2026` reads two ways.
- **`merge=union` on anything other than a changelog**, or without having explained it in the repository: a contributor who doesn't know won't understand why this file never creates a conflict.

## See also

- [Conventional commits](/en/equipe/commits-conventionnels/)
- [The pull request, from opening to merge](/en/equipe/la-pull-request/)
- [A conflict during a merge or a rebase](/en/situations/reparer/resoudre-un-conflit/)
- Keep a Changelog: [keepachangelog.com](https://keepachangelog.com/en/1.1.0/)

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/equipe/tenir-un-changelog.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/equipe/tenir-un-changelog.sh), run with Git 2.50 on 6 October 2026, conflict and `merge=union` included. The script rewrites the files in full rather than with `sed -i`, which differs between GNU and BSD. Only the server address and the commit ids are those of the example repository, whose commit messages and changelog are in French.
:::
