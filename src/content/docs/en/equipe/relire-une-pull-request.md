---
title: Reviewing a pull request
description: What to look at, in what order, how to phrase a remark, when to approve. The review from your machine, with the commands that check rather than believe, and what GitHub adds.
level: intermediaire
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
sidebar:
  order: 6
---

## What it avoids

A PR approved in thirty seconds, "LGTM", that breaks production the next day. A remark that hurts, and an author who no longer dares to open a PR. A reviewer who reads the diff on GitHub without ever running the code, and lets through the forgotten call that the tests don't cover. And the PR that waits a week because "reviewing isn't real work".

Reviewing is the second pair of eyes the pull request promises. It's done quickly, but not as a skim: you check rather than believe, you say what you see, and you approve when you would agree to maintain that code.

## How it's done

**In what order to look.** First the description: what does the PR say it does, and why? Then correctness: does it do it, without breaking anything else? Then clarity: will someone understand this code in six months? Form last, and only if the team has no tool that takes care of it.

**1. Fetch the branch onto your machine.** Reading a diff on GitHub isn't enough for a PR that touches logic: you need to be able to search, run, try.

```console
$ git fetch
From github.com:equipe/projet
 * [new branch]      feature/recherche-options -> origin/feature/recherche-options

$ git switch feature/recherche-options
Switched to a new branch 'feature/recherche-options'
branch 'feature/recherche-options' set up to track 'origin/feature/recherche-options'.
```

**2. The whole, then commit by commit.** The commits in the order they were written tell the intention; the overall diff says the extent.

```console
$ git log --oneline --reverse main..HEAD
43b273d refactor(recherche): renomme chercher en rechercher, ajoute l option sensibleCasse
dea5fe5 test(recherche): couvre la casse

$ git diff --stat main...HEAD
 recherche.js      | 5 +++--
 recherche.test.js | 1 +
 2 files changed, 4 insertions(+), 2 deletions(-)

$ git show --format='%h %s' HEAD~1
43b273d refactor(recherche): renomme chercher en rechercher, ajoute l option sensibleCasse

diff --git a/recherche.js b/recherche.js
index 7dddfee..c47c90b 100644
--- a/recherche.js
+++ b/recherche.js
@@ -1,3 +1,4 @@
-function chercher(terme) {
-  return index.filter(e => e.includes(terme));
+function rechercher(terme, options = {}) {
+  const base = options.sensibleCasse ? index : index.map(e => e.toLowerCase());
+  return base.filter(e => e.includes(terme));
 }
```

The commit says "refactor" and renames a function. First reviewer's question: who was calling it?

**3. Check rather than believe.** The diff only shows what changed, not what should have changed. The test is green, and yet:

```console
$ git grep -nw chercher
page.js:1:const resultats = chercher(saisie);
```

`page.js` still calls the old name. The page will break on first load, and no test says so. That's the remark to make, and GitHub wouldn't have helped you find it: it's about a file the PR doesn't touch. Running the tests and the application is part of the same move.

**Phrasing the remark.** About the code, never about the person; precise, with the file and the line; and distinguishing what blocks from what is a preference. "`page.js` still calls `chercher`, the page will crash on load" is enough. A question is often better than an order: "Is it intended that search becomes case-insensitive by default?" And saying what's good isn't politeness: it's information too.

**4. After the fix, review only what changed.** The author added a commit, didn't rewrite the branch: you see exactly what moved since your reading.

```console
$ git fetch
From github.com:equipe/projet
   dea5fe5..7d900da  feature/recherche-options -> origin/feature/recherche-options

$ git log --oneline HEAD..origin/feature/recherche-options
7d900da fix(recherche): met a jour l appel dans page.js

$ git diff HEAD origin/feature/recherche-options
diff --git a/page.js b/page.js
index da79d5b..9a23df8 100644
--- a/page.js
+++ b/page.js
@@ -1 +1 @@
-const resultats = chercher(saisie);
+const resultats = rechercher(saisie);

$ git pull --ff-only
Updating dea5fe5..7d900da
Fast-forward
 page.js | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

$ git grep -nw chercher
```

No call left. **When to approve?** When you would agree to maintain that code yourself: it does what the description says, you've seen it run, you understand it. Not when it's perfect, nor written the way you would have written it.

**5. After the merge, the cleanup** on your machine, as for your own branches:

```console
$ git switch main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.

$ git pull --ff-only
From github.com:equipe/projet
   eebbc04..f7979a4  main       -> origin/main
Updating eebbc04..f7979a4
Fast-forward
 page.js           | 2 +-
 recherche.js      | 5 +++--
 recherche.test.js | 1 +
 3 files changed, 5 insertions(+), 3 deletions(-)
 create mode 100644 recherche.test.js

$ git fetch --prune
From github.com:equipe/projet
 - [deleted]         (none)     -> origin/feature/recherche-options

$ git branch -d feature/recherche-options
Deleted branch feature/recherche-options (was 7d900da).
```

## On GitHub

- **`gh pr checkout 14`** does the first two commands at once; `gh pr diff 14` shows the diff without changing branch.
- **"Files changed"**: the "Viewed" box on each file keeps your progress; "Start a review" groups your remarks, which go out together with a verdict, rather than as a burst of notifications.
- **Suggestions**: a ` ```suggestion ` block in a comment proposes the replacement text, which the author applies in one click. For a typo, it's shorter than a remark.
- **The three verdicts**: "Comment" when nothing blocks, "Request changes" when something must change before the merge, "Approve" when you're ready to maintain that code. "Request changes" blocks the merge until you re-approve.
- **"Changes since your last review"** does on GitHub what the `git diff` of step 4 does on your machine.
- **Each conversation is resolved** when the remark is addressed; the "Require conversation resolution" rule in `main`'s protection prevents merging with an open conversation.
- **`CODEOWNERS`** assigns reviewers automatically, by file path.

## Pitfalls

- **Approving what you haven't understood.** If you can't explain what the PR does, you can't approve it. Asking for an explanation is a useful review.
- **Reviewing only the form.** Twenty remarks on variable names and none on the logic: the formatting tool takes care of the form, the reviewer of what the tool doesn't see.
- **Rewriting the PR in the comments.** If you would have done it differently, say it once, and let the author decide, unless it's wrong.
- **Blocking for a preference.** A "Request changes" is reserved for what is incorrect, dangerous or contrary to what the team decided. The rest is a comment.
- **Letting it wait.** A PR reviewed within the day is merged before `main` has moved. Reviewing comes before starting something else.
- **Committing on the author's branch** during the review: fixes belong to the author, unless agreed. The review proposes, it doesn't impose through code.

## See also

- [The pull request, from opening to merge](/en/equipe/la-pull-request/)
- [One branch per change](/en/equipe/une-branche-par-changement/)
- [Seeing what changed between my branch and main](/en/situations/quotidien/voir-ce-qui-a-change/)
- [After cloning, I don't see the other people's branches](/en/situations/quotidien/branches-invisibles-apres-clone/)

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/equipe/relire-une-pull-request.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/equipe/relire-une-pull-request.sh), run with Git 2.50 on 6 October 2026. Awa opens the PR there, Bakary reviews it from his machine, and the merge "by GitHub" is played by Awa. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
