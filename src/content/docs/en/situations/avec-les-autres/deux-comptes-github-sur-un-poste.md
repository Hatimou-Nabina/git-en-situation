---
title: Two GitHub accounts on the same machine
description: A work account, a personal account, one machine. How to give each folder its identity, each account its SSH key, and each repository the right address, without ever mixing them up.
level: intermediaire
risk: aucun
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptom

You have one GitHub account for work and one for your own projects. Two classic symptoms, often together: your commits on a personal repository show up with your work address, and a push to a personal repository is refused with `Permission denied` or `repository not found`, although the repository exists.

```console
$ git config user.email
awa@example.com
```

That's the work address, in a personal folder.

## Diagnosis

Two distinct things get mixed up. **The identity** written in the commits, `user.name` and `user.email`, is mere configuration: Git writes it, nobody checks it. **Authentication** with GitHub, by SSH key, is what authorises the push. GitHub ties each key to a single account, and when you connect to `github.com`, SSH offers your usual key, the work account's. Each repository has to know which key to present, and which identity to write.

## Solution

**1. One identity per folder.** Keep personal projects under one folder, and give it its own configuration:

```console
$ cat ~/.gitconfig-perso
[user]
	name = Hatimou Nabina
	email = perso@example.com

$ git config --global includeIf."gitdir:~/perso/".path ~/.gitconfig-perso
```

In a repository under `~/perso/`, the personal identity applies; elsewhere, the global configuration stays the work one:

```console
$ git config user.email
perso@example.com

$ git config user.email
awa@example.com
```

The first command was run in `~/perso/git-en-situation`, the second in `~/travail/projet-client`.

**2. One SSH key per account, and a host alias.** Create a second key, and add its public part to the personal account on GitHub (Settings → SSH and GPG keys):

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_perso -C "compte perso"
```

Then declare in `~/.ssh/config` a made-up host name, `github.com-perso`, which points to GitHub with that key:

```console
$ cat ~/.ssh/config
# Compte pro : l'adresse habituelle
Host github.com
	HostName github.com
	User git
	IdentityFile ~/.ssh/id_ed25519_pro
	IdentitiesOnly yes

# Compte perso : un nom d'hôte inventé, qui pointe vers GitHub avec l'autre clé
Host github.com-perso
	HostName github.com
	User git
	IdentityFile ~/.ssh/id_ed25519_perso
	IdentitiesOnly yes
```

The two comments, in French, read "Work account: the usual address" and "Personal account: a made-up host name, which points to GitHub with the other key". To check, `ssh -T git@github.com-perso` must answer with the personal account's name:

```text
Hi Hatimou-Nabina! You've successfully authenticated, but GitHub does not provide shell access.
```

**3. Personal repositories use the alias** instead of `github.com` in their address:

```console
$ git remote -v
origin	git@github.com:Hatimou-Nabina/git-en-situation.git (fetch)
origin	git@github.com:Hatimou-Nabina/git-en-situation.git (push)

$ git remote set-url origin git@github.com-perso:Hatimou-Nabina/git-en-situation.git

$ git remote -v
origin	git@github.com-perso:Hatimou-Nabina/git-en-situation.git (fetch)
origin	git@github.com-perso:Hatimou-Nabina/git-en-situation.git (push)
```

For a new personal repository, clone directly with the alias: `git clone git@github.com-perso:Hatimou-Nabina/projet.git`.

## Why it works

`includeIf "gitdir:…"` loads an extra configuration file only when the repository is under the given path; the trailing `/` means "this folder and everything in it". Since that file is read after the global configuration, its values win.

On the SSH side, a `Host` is a nickname: when Git connects to `github.com-perso`, SSH reads that block, actually connects to `github.com` (`HostName`), and presents the given key. `IdentitiesOnly yes` stops it from trying the other keys it knows first: without that line, it would often offer the work key first, GitHub would accept it, and you would be authenticated on the wrong account, hence the `repository not found` on a private personal repository.

Commits, for their part, carry no authentication. GitHub ties a commit to an account solely through the email address it contains: it must be among the right account's addresses.

## Pitfalls

- **A commit already made with the wrong address**: once the `includeIf` is in place, `git commit --amend --reset-author --no-edit` rewrites the author of the last commit, if it isn't pushed. To check before pushing: `git log -1 --format='%an <%ae>'`.
- **The `gitdir` path**: `~` is understood by Git; on Windows, a path of the form `C:/Users/…/perso/` works too. The trailing `/` is mandatory to target a folder.
- **Over HTTPS rather than SSH**, it's the credential manager that must tell the accounts apart: with Git Credential Manager, `git config --global credential.useHttpPath true` allows one credential per repository.
- **`gh`, GitHub's command-line tool**, handles several accounts on its side: `gh auth login` for each, `gh auth switch` to change.
- **Two accounts in the same organisation** are not something GitHub plans for: in that case, it's one account with several email addresses.

## See also

- [Working on the same project from two machines](/en/situations/avec-les-autres/travailler-depuis-deux-machines/)
- [Undoing my last commit, not yet pushed](/en/situations/reparer/annuler-mon-dernier-commit/)
- [Working as a team: secrets never go into the repository](/en/equipe/secrets-jamais-dans-le-depot/)

:::tip[Verified outputs]
The outputs of the `git` commands on this page come from the script [`scripts/situations/deux-comptes-github-sur-un-poste.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/deux-comptes-github-sur-un-poste.sh), run with Git 2.50 on 5 October 2026, in a fake home folder. The SSH connection to GitHub cannot be replayed in a sandbox: the answer of `ssh -T` is quoted, not run by the script.
:::
