---
title: CODEOWNERS, issue and PR templates
description: The GitHub automations that save everyone time. Who reviews what, what a pull request must say, what an issue must contain. Three versioned files in .github/, and each one's silent pitfalls.
level: debutant
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
sidebar:
  order: 10
---

## What it avoids

A PR that waits because nobody knows who should review it. A PR without a description, "fix", that has to be opened to be understood. A "it doesn't work" issue without version or error message, which starts with three round trips. And the maintainer who explains again every time what they expect.

Three files in `.github/` settle that once and for all: `CODEOWNERS` says who reviews what, `PULL_REQUEST_TEMPLATE.md` prefills a PR's description, and `ISSUE_TEMPLATE/` turns an issue's blank page into a form. GitHub reads them; Git versions them like the rest. The example files below are in French, like the team they belong to.

## How it's done

**1. Who knows what: the history says it.** Before writing the `CODEOWNERS`, look at who really worked on each part:

```console
$ git shortlog -sn HEAD -- src/paiement/
     3	Bakary
     1	Awa

$ git shortlog -sn HEAD -- src/recherche/
     2	Awa
```

**2. `CODEOWNERS`: a path, some owners.** The syntax is that of `.gitignore`, and the last matching rule wins. Owners are requested for review automatically when a PR touches their files. The comments say that Awa reviews everything by default, that payment is reviewed by Bakary, and that what drives GitHub is reviewed by both.

```console
$ cat .github/CODEOWNERS
# Qui relit quoi. Même syntaxe que .gitignore ; la dernière règle qui correspond gagne.

# Par défaut, Awa relit tout.
*                   @awa

# Le paiement est relu par Bakary.
/src/paiement/      @bakary

# Ce qui pilote GitHub est relu par les deux.
/.github/           @awa @bakary
```

**3. The pull request template: the questions asked before they're forgotten.** It prefills every PR's description. This site's asks what, why, and what was checked; this one does the same, with three boxes: tests pass locally, the changelog line is there, what changes for the user is said in the description.

```console
$ cat .github/PULL_REQUEST_TEMPLATE.md
## Quoi

<!-- Une phrase : ce que cette PR change. -->

## Pourquoi

<!-- Le problème vécu, ou l'issue liée : « Closes #12 ». -->

## Vérifications

- [ ] Les tests passent en local.
- [ ] La ligne du changelog est là.
- [ ] Ce qui change pour l'utilisateur est dit dans la description.
```

**4. Issue templates: a form rather than a blank page.** One YAML file per issue type, with required fields; and a `config.yml` that settles the rest: forbid the blank issue, send questions elsewhere. The form below, "Report a bug", asks what you observe, what you expected, and the version.

```console
$ cat .github/ISSUE_TEMPLATE/signaler-un-bug.yml
name: Signaler un bug
description: Quelque chose ne fait pas ce qu'il devrait.
title: "[Bug] "
labels: ["bug", "à trier"]
body:
  - type: textarea
    id: observe
    attributes:
      label: Ce que tu observes
      description: Le message exact, dans un bloc de code si possible.
    validations:
      required: true
  - type: textarea
    id: attendu
    attributes:
      label: Ce que tu attendais
    validations:
      required: true
  - type: input
    id: version
    attributes:
      label: Version
      placeholder: v1.2.0

$ cat .github/ISSUE_TEMPLATE/config.yml
blank_issues_enabled: false
contact_links:
  - name: Poser une question
    url: https://github.com/mon-equipe/projet/discussions
    about: Une question, une idée pas encore mûre : les Discussions sont faites pour ça.
```

**5. All of this is versioned**, and goes through a pull request like the rest. Modifying a template is a PR, reviewed by the owners of `.github/`.

```console
$ git ls-files .github
.github/CODEOWNERS
.github/ISSUE_TEMPLATE/config.yml
.github/ISSUE_TEMPLATE/signaler-un-bug.yml
.github/PULL_REQUEST_TEMPLATE.md

$ git log --oneline -- .github/
4a55a49 chore(github): CODEOWNERS, gabarits d issue et de PR
```

## On GitHub

- **Where GitHub looks**: `CODEOWNERS` at the root, in `.github/` or in `docs/`; the PR template in the same places, or several in `.github/PULL_REQUEST_TEMPLATE/`, chosen with `?template=name.md` in the address; issue templates in `.github/ISSUE_TEMPLATE/`. All of that on the default branch: a PR that modifies them only takes effect once merged.
- **Owners must have write access** to the repository, individually or through an `@organisation/team` team. Otherwise the line is silently ignored. GitHub flags syntax errors in the file view, not unknown owners.
- **"Require review from Code Owners"**, in branch protection, makes their approval mandatory. Without the box, they are only requested.
- **Issue forms** (`.yml`) replace Markdown templates (`.md`): typed fields, required ones, drop-down lists. `blank_issues_enabled: false` forces the choice of a template; `contact_links` adds buttons to the Discussions or to another repository.
- **The template's labels must exist** in the repository, otherwise they are ignored without a word. This site declared three labels in its templates before creating them. `gh label create` creates them in one line.
- **Insights → Community Standards** lists what the repository lacks: README, CONTRIBUTING, code of conduct, licence, templates, `SECURITY.md`.

## Pitfalls

- **A single owner on everything**, `* @me`, with mandatory approval: on holiday, everything stops. Two names per rule, or no obligation.
- **The path that matches nothing.** `src/paiment/` instead of `src/paiement/`: the rule never applies, nobody is requested, nothing flags it. Check on a real PR that touches the folder.
- **The template that's too long**, which contributors erase in one go. Three questions are enough; this site's fits in fifteen lines.
- **Boxes ticked without reading.** A useful box can be checked: "`npm run build` passes" is checkable, "I tested well" isn't.
- **A form that demands too much**, and the issue is never opened. One required field per truly indispensable piece of information, the rest optional.
- **Forgetting `config.yml`**: the "New issue" page still offers the blank issue, and the templates are bypassed.

## See also

- [Reviewing a pull request](/en/equipe/relire-une-pull-request/)
- [The pull request, from opening to merge](/en/equipe/la-pull-request/)
- [Protecting the main branch](/en/equipe/proteger-la-branche-principale/)
- This site's own: [`.github/`](https://github.com/Hatimou-Nabina/git-en-situation/tree/main/.github)

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/equipe/codeowners-gabarits-issue-pr.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/equipe/codeowners-gabarits-issue-pr.sh), run with Git 2.50 on 5 October 2026. GitHub's automations cannot be replayed in a sandbox: the files that drive them are shown, their effects described. Only the server address and the commit ids are those of the example repository, whose files and commit messages are in French.
:::
