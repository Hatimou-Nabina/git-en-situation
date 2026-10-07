---
title: Versions and tags
description: Semantic versioning, the annotated tag that marks the version, the push that doesn't carry it on its own, describe to know where you stand, the version that contains a fix, and the GitHub release that builds on it.
level: debutant
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
sidebar:
  order: 9
---

## What it avoids

"It doesn't work", without knowing which version the person uses. A version in production that nobody can rebuild any more, because nobody knows which commit it was. A fix nobody knows whether it's shipped. And users who update without knowing whether it will break something on their side.

A tag is a name placed on a commit, forever. The number follows semantic versioning, `MAJOR.MINOR.PATCH`: the patch repairs without changing anything else, the minor adds without breaking, the major breaks something. With [conventional commits](/en/equipe/commits-conventionnels/), the number can be deduced: a `fix` bumps the patch, a `feat` the minor, a `!` the major.

## How it's done

**1. An annotated tag on the version's commit.** Annotated, `-a`, is a full object, with an author, a date and a message, not a mere pointer. For a version, always annotated.

```console
$ git tag -a v1.2.0 -m "Version 1.2.0 : barre de recherche, correctif de l export"

$ git show --no-patch v1.2.0
tag v1.2.0
Tagger: Awa <awa@example.com>
Date:   Mon Oct 5 10:00:00 2026 +0000

Version 1.2.0 : barre de recherche, correctif de l export

commit 52ac0b8594bd1babc13295e0aaef5760108b3275
Author: Awa <awa@example.com>
Date:   Mon Oct 5 10:00:00 2026 +0000

    fix(export): corrige l export d une liste vide

$ git cat-file -t v1.2.0
tag

$ git tag -n
v1.2.0          Version 1.2.0 : barre de recherche, correctif de l export
```

A tag without `-a` is called lightweight: `cat-file -t` would answer `commit`, it would have neither author nor date. Handy for a personal marker, not for a version.

**2. Tags don't leave on their own.** `git push` pushes the branch, not the tags. The server knows nothing about them until you tell it:

```console
$ git push
Everything up-to-date

$ git ls-remote --tags origin

$ git push origin v1.2.0
To github.com:equipe/projet.git
 * [new tag]         v1.2.0 -> v1.2.0

$ git ls-remote --tags origin
7e40c7027e23867e3a3d59f039295ea2600dc665	refs/tags/v1.2.0
52ac0b8594bd1babc13295e0aaef5760108b3275	refs/tags/v1.2.0^{}
```

The server's two lines: the tag object, and the commit it points to (`^{}`). `git push --follow-tags` pushes the branch and the annotated tags that concern it in one go; `git config --global push.followTags true` makes it the rule.

**3. Where do we stand compared to the last version?** `describe` answers in one word: the last version, the number of commits since, and the current commit.

```console
$ git describe --tags
v1.2.0-2-gb12af3f

$ git log --oneline v1.2.0..HEAD
b12af3f feat(recherche): ajoute le tri par date
e52305a feat(recherche): ajoute les filtres
```

`v1.2.0-2-gb12af3f`: two commits after 1.2.0, on `b12af3f`. That's the string to display in a `--version` or a footer, so that a bug report says exactly where it comes from.

**4. In which version did this fix arrive?** The support question, which `--contains` answers:

```console
$ git log --oneline --all --grep='fix(export)'
52ac0b8 fix(export): corrige l export d une liste vide

$ git tag --contains 52ac0b8
v1.2.0
```

**5. Going back to a version to rebuild it.** The tag is an address like any other: you go there, you build, you come back.

```console
$ git switch --detach v1.2.0
HEAD is now at 52ac0b8 fix(export): corrige l export d une liste vide

$ git describe --tags
v1.2.0

$ git switch main
Previous HEAD position was 52ac0b8 fix(export): corrige l export d une liste vide
Switched to branch 'main'
Your branch is up to date with 'origin/main'.
```

You are then in "detached HEAD", the normal state for looking without touching: [I am in "detached HEAD"](/en/situations/reparer/detached-head/).

**6. On a colleague's machine, tags arrive with `fetch`**, at least those that point to fetched commits:

```console
$ git fetch
From github.com:equipe/projet
   d0a0b32..b12af3f  main       -> origin/main
 * [new tag]         v1.2.0     -> v1.2.0

$ git tag
v1.2.0
```

## On GitHub

- **A release is a dressed-up tag**: Releases → "Draft a new release", choose or create the tag, a title, notes, files to download. "Generate release notes" drafts from the PRs merged since the previous tag. From the terminal: `gh release create v1.2.0 --generate-notes`.
- **The Tags tab** lists the tags, each with a `.zip` and `.tar.gz` archive of the code at that commit.
- **A release triggers a workflow**: `on: push: tags: ['v*']` or `on: release: types: [published]`, to build and publish automatically.
- **Tags can be protected** by a tag ruleset (Settings → Rules), so that nobody deletes or moves `v*`. A branch rule doesn't cover them: [Protecting the main branch](/en/equipe/proteger-la-branche-principale/).
- **The changelog and the release complement each other**: the release takes up the [changelog](/en/equipe/tenir-un-changelog/) section that carries the same number.

## Pitfalls

- **Forgetting to push the tag.** The machine has the version, the server doesn't, the CI builds nothing. `push.followTags` settles that once and for all.
- **Moving a tag already published.** A tag is a promise: those who fetched it keep the old one, and their `fetch` doesn't update it without an option. If the version is wrong, you publish the next one, `v1.2.1`.
- **Tagging the wrong branch**, a commit of `feature/x` rather than of `main`: the version contains unreviewed work. Tag from an up-to-date `main`.
- **A lightweight tag for a version**: no author, no date, no message. Nobody knows any more who shipped or when.
- **`0.x` forever.** As long as the major is `0`, everything can break at every minor, and users know it. Go to `1.0.0` when someone depends on the project.
- **A tag deleted on the server stays on colleagues' machines**: `git fetch --prune --prune-tags` brings them level.

## See also

- [Keeping a changelog](/en/equipe/tenir-un-changelog/)
- [Working branch and production branch](/en/equipe/branche-de-travail-et-de-production/)
- [Conventional commits](/en/equipe/commits-conventionnels/)
- [I am in "detached HEAD"](/en/situations/reparer/detached-head/)
- Semantic versioning: [semver.org](https://semver.org/)

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/equipe/versions-et-tags.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/equipe/versions-et-tags.sh), run with Git 2.50 on 6 October 2026. The GitHub release cannot be replayed in a sandbox and is described, not run. Only the server address and the commit ids are those of the example repository, whose commit and tag messages are in French.
:::
