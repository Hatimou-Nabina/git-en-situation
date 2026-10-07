---
title: A conflict during a merge or a rebase
description: '"CONFLICT (content) - Merge conflict in README.md". Reading the markers, choosing the right version, continuing or giving it all up. And why HEAD does not mean the same thing in a rebase and in a merge.'
level: intermediaire
risk: reversible
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
---

## Symptom

You fetch the team's work, and it stops right in the middle:

```console
$ git pull --rebase
From github.com:equipe/projet
   d0a0b32..c6daf1f  main       -> origin/main
Rebasing (1/1)error: could not apply 0e03633... Corrige le titre du README
hint: Resolve all conflicts manually, mark them as resolved with
hint: "git add/rm <conflicted_files>", then run "git rebase --continue".
hint: You can instead skip this commit: run "git rebase --skip".
hint: To abort and get back to the state before "git rebase", run "git rebase --abort".
hint: Disable this message with "git config set advice.mergeConflict false"
Could not apply 0e03633... # Corrige le titre du README
Auto-merging README.md
CONFLICT (content): Merge conflict in README.md
```

## Diagnosis

Two people modified **the same lines** of the same file: you, by changing the README's title, and a colleague, by adding a contact to it. Git knows how to merge changes in different places; here, it can't guess which of the two versions of the first line is the right one, or whether it's a mix of both. It leaves you the file with both versions, and waits for your decision. Nothing is broken, and you can give up at any time.

## Solution

**1. Look at where you are.** `git status` lists the files in conflict and recalls the three ways out:

```console
$ git status
interactive rebase in progress; onto c6daf1f
Last command done (1 command done):
   pick 0e03633 # Corrige le titre du README
No commands remaining.
You are currently rebasing branch 'main' on 'c6daf1f'.
  (fix conflicts and then run "git rebase --continue")
  (use "git rebase --skip" to skip this patch)
  (use "git rebase --abort" to check out the original branch)

Unmerged paths:
  (use "git restore --staged <file>..." to unstage)
  (use "git add <file>..." to mark resolution)
	both modified:   README.md

no changes added to commit (use "git add" and/or "git commit -a")
```

**2. Open the file.** Git wrote both versions in it, between markers:

```console
$ cat README.md
<<<<<<< HEAD
# Projet - plateforme de partage

Contact : contact@example.com
=======
# Projet EduShare
>>>>>>> 0e03633 (Corrige le titre du README)
```

Between `<<<<<<< HEAD` and `=======`, the version already in place on the server. Between `=======` and `>>>>>>>`, your commit. Careful, in a rebase it really is that way round: see "Why it works".

**3. Write the version you want**, here a mix of both, and remove the markers. The file must look like what you want to see committed, nothing more:

```console
$ cat README.md
# Projet EduShare

Contact : contact@example.com
```

**4. Mark the file as resolved, then continue.**

```console
$ git add README.md

$ git rebase --continue
Successfully rebased and updated refs/heads/main.
[detached HEAD d7f74cf] Corrige le titre du README
 1 file changed, 1 insertion(+), 1 deletion(-)

$ git log --oneline -3
d7f74cf Corrige le titre du README
c6daf1f Ajoute le contact au README
d0a0b32 Premier commit
```

Your commit was replayed on top of your colleague's, with the resolution. The push then goes through normally:

```console
$ git push
To github.com:equipe/projet.git
   c6daf1f..d7f74cf  main -> main
```

**Changing your mind: giving it all up.** At any time before the `--continue`, you can go back exactly to the state before the `pull`:

```console
$ git status --short
UU README.md

$ git rebase --abort

$ git status
On branch main
Your branch and 'origin/main' have diverged,
and have 1 and 1 different commits each, respectively.
  (use "git pull" if you want to integrate the remote branch with yours)

nothing to commit, working tree clean

$ git log --oneline -2
0e03633 Corrige le titre du README
d0a0b32 Premier commit
```

**The same thing with a merge.** If you integrate by `merge` rather than by `rebase`, the conflict looks the same, the two sides are in the other order, and it's a `git commit` that finishes:

```console
$ git pull --no-rebase
From github.com:equipe/projet
   d0a0b32..c6daf1f  main       -> origin/main
Auto-merging README.md
CONFLICT (content): Merge conflict in README.md
Automatic merge failed; fix conflicts and then commit the result.

$ cat README.md
<<<<<<< HEAD
# Projet EduShare
=======
# Projet - plateforme de partage

Contact : contact@example.com
>>>>>>> c6daf1f164d965f9af8ddeb0ba872a9c38e11fce

$ git add README.md

$ git commit --no-edit
[main 89c2416] Merge branch 'main' of github.com:equipe/projet

$ git log --oneline --graph -4
*   89c2416 Merge branch 'main' of github.com:equipe/projet
|\
| * c6daf1f Ajoute le contact au README
* | 0e03633 Corrige le titre du README
|/
* d0a0b32 Premier commit
```

To give up in that case: `git merge --abort`.

## Why it works

Git merges line by line, comparing each version to the common ancestor. When both sides modified the same area, there is no rule that holds for every project: Git writes both versions in the file, marks the file as "unmerged" in the index, and stops. `git add` on the file removes that mark, it's the signal "I've decided". `--continue` picks up where it stopped.

**HEAD is not the same depending on the operation.** In a merge, you are on your branch, and you bring the server's commits into it: `HEAD` is your version, the other side is theirs. In a rebase, Git first places itself on the server's commit, then replays your commits one by one on top: `HEAD` is **their** version, and it's your commit that is "the other side", named by its id. The `--ours` and `--theirs` options of `git checkout` follow the same inverted logic. When in doubt, read the markers: the `>>>>>>>` line always says where the second version comes from.

## Pitfalls

- **Committing the markers.** If `<<<<<<<` stays in a file, the code no longer compiles or the text is ruined. Reread the whole file before `git add`, not just the conflicting area.
- **Taking one side without reading.** `git checkout --ours README.md` or `--theirs` overwrite the other version: fast, and wrong every other time. In a rebase, on top of that, `--ours` is the server's version.
- **A rebase of several commits** can stop several times. Each stop is resolved the same way; `git rebase --skip` gives up only the current commit.
- **A visual tool** helps when the conflict is long: VS Code shows both versions with buttons, and `git mergetool` launches the configured one. The result still has to be checked.
- **A conflict that comes back at every rebase** on the same long-lived branch: `git config rerere.enabled true` makes Git replay the resolutions already made.

## See also

- [git pull asks me to choose between merge and rebase](/en/situations/quotidien/git-pull-merge-ou-rebase/)
- [My push is rejected, "rejected", "fetch first"](/en/situations/quotidien/push-refuse-fetch-first/)
- [Undoing a commit already pushed](/en/situations/reparer/annuler-un-commit-deja-pousse/)
- [Understand: fast-forward, merge, rebase](/en/comprendre/fast-forward-fusion-rebase/)

:::note[Try it yourself]
This page's script can create the problem on your machine. From a clone of the [site's repository](https://github.com/Hatimou-Nabina/git-en-situation), in Git Bash on Windows:

```bash
EXERCICE=1 bash scripts/situations/resoudre-un-conflit.sh
```

It stops right after the symptom, tells you which folder to go to and what to do. Fix it, then run it again without `EXERCICE=1` to compare with the solution.
:::

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/situations/resoudre-un-conflit.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/resoudre-un-conflit.sh), run with Git 2.50 on 6 October 2026. Only the server address and the commit ids are those of the example repository, whose commit messages are in French.
:::
