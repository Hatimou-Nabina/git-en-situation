---
title: Working as a team
description: Branches, pull requests, review, commit conventions, protections. Ways of working that have proven themselves, explaining each time what they avoid.
sidebar:
  order: 0
---

Knowing how to use Git alone is not enough: most difficulties arrive with two people or more. This section describes ways of working that have proven themselves, explaining each time **what they avoid**. What is specific to GitHub is flagged as such.

Every page follows the same plan: what it avoids, how it's done, with commands that were actually run, what is specific to GitHub, the pitfalls.

Available:

1. [The pull request, from opening to merge](/en/equipe/la-pull-request/): the branch, the commits, the review, the merge, the cleanup, and what GitHub's three buttons do.
2. [Conventional commits](/en/equipe/commits-conventionnels/): `type(scope): subject`, the types, the body, the footer, and a six-line guard rail.
3. [One branch per change](/en/equipe/une-branche-par-changement/): naming, creating, keeping it short, deleting after merge, and a guard rail against committing on `main` out of habit.
4. [Protecting the main branch](/en/equipe/proteger-la-branche-principale/): what a force push does to `main` without protection, the two settings every Git server knows, the pull request made mandatory.
5. [Secrets never go into the repository](/en/equipe/secrets-jamais-dans-le-depot/): `.env` ignored from the first commit, `.env.example` versioned, the application reading the environment, a ten-line guard rail, and what GitHub blocks.
6. [Reviewing a pull request](/en/equipe/relire-une-pull-request/): in what order to look, the branch on your machine, checking rather than believing, phrasing the remark, reviewing only what changed, when to approve.
7. [Working branch and production branch](/en/equipe/branche-de-travail-et-de-production/): `main` and `prod`, going to production by fast-forward, the urgent fix carried over right away, and knowing what is where.
8. [Keeping a changelog](/en/equipe/tenir-un-changelog/): the "Unreleased" section every PR feeds, the recurring conflict and the `merge=union` that avoids it, the draft from the commits, the version.
9. [Versions and tags](/en/equipe/versions-et-tags/): semantic versioning, the annotated tag, the push that doesn't carry it on its own, `describe`, the version that contains a fix, the GitHub release.
10. [CODEOWNERS, issue and PR templates](/en/equipe/codeowners-gabarits-issue-pr/): who reviews what, what a PR must say, what an issue must contain, and each file's silent pitfalls.
11. [A CI that checks what the machines don't see](/en/equipe/ci-ce-que-les-postes-ne-voient-pas/): the executable bit, the case of file names, the file that only exists on your machine, and the check script the CI runs.
12. [Forking and contributing to an open source project](/en/equipe/forker-et-contribuer/): fork, `upstream`, one branch per contribution, the PR between two repositories, keeping up to date, keeping your fork level.

The section is complete; pages not translated yet are shown in French, with a notice. A practice is missing, or a page looks wrong to you? [Open an issue](https://github.com/Hatimou-Nabina/git-en-situation/issues/new/choose), or fix it: the template is in the repository's `CONTRIBUTING.md`.
