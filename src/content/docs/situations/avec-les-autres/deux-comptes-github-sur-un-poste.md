---
title: Deux comptes GitHub sur le même poste
description: Un compte pro, un compte perso, une seule machine. Comment donner à chaque dossier son identité, à chaque compte sa clé SSH, et à chaque dépôt la bonne adresse, sans jamais se tromper.
level: intermediaire
risk: aucun
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptôme

Tu as un compte GitHub pour le travail et un pour tes projets. Deux symptômes classiques, souvent ensemble : tes commits sur un dépôt perso apparaissent avec ton adresse pro, et un push sur un dépôt perso est refusé avec `Permission denied` ou `repository not found`, alors que le dépôt existe.

```console
$ git config user.email
awa@example.com
```

C'est l'adresse pro, dans un dossier perso.

## Diagnostic

Deux choses distinctes se mélangent. **L'identité** écrite dans les commits, `user.name` et `user.email`, est une simple configuration : Git l'écrit, personne ne la vérifie. **L'authentification** auprès de GitHub, par clé SSH, est ce qui autorise le push. GitHub associe chaque clé à un seul compte, et quand tu te connectes à `github.com`, SSH propose ta clé habituelle, celle du compte pro. Il faut que chaque dépôt sache quelle clé présenter, et quelle identité écrire.

## Solution

**1. Une identité par dossier.** Range les projets perso sous un même dossier, et donne-lui sa propre configuration :

```console
$ cat ~/.gitconfig-perso
[user]
	name = Hatimou Nabina
	email = perso@example.com

$ git config --global includeIf."gitdir:~/perso/".path ~/.gitconfig-perso
```

Dans un dépôt sous `~/perso/`, l'identité perso s'applique ; ailleurs, la configuration globale reste la pro :

```console
$ git config user.email
perso@example.com

$ git config user.email
awa@example.com
```

La première commande a été lancée dans `~/perso/git-en-situation`, la seconde dans `~/travail/projet-client`.

**2. Une clé SSH par compte, et un alias d'hôte.** Crée une seconde clé, et ajoute sa partie publique au compte perso sur GitHub (Settings → SSH and GPG keys) :

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_perso -C "compte perso"
```

Puis déclare dans `~/.ssh/config` un nom d'hôte inventé, `github.com-perso`, qui pointe vers GitHub avec cette clé :

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

Pour vérifier, `ssh -T git@github.com-perso` doit répondre avec le nom du compte perso :

```text
Hi Hatimou-Nabina! You've successfully authenticated, but GitHub does not provide shell access.
```

**3. Les dépôts perso utilisent l'alias** à la place de `github.com` dans leur adresse :

```console
$ git remote -v
origin	git@github.com:Hatimou-Nabina/git-en-situation.git (fetch)
origin	git@github.com:Hatimou-Nabina/git-en-situation.git (push)

$ git remote set-url origin git@github.com-perso:Hatimou-Nabina/git-en-situation.git

$ git remote -v
origin	git@github.com-perso:Hatimou-Nabina/git-en-situation.git (fetch)
origin	git@github.com-perso:Hatimou-Nabina/git-en-situation.git (push)
```

Pour un nouveau dépôt perso, clone directement avec l'alias : `git clone git@github.com-perso:Hatimou-Nabina/projet.git`.

## Pourquoi ça marche

`includeIf "gitdir:…"` charge un fichier de configuration supplémentaire seulement quand le dépôt est sous le chemin indiqué ; le `/` final veut dire « ce dossier et tout ce qu'il contient ». Comme ce fichier est lu après la configuration globale, ses valeurs gagnent.

Côté SSH, un `Host` est un surnom : quand Git se connecte à `github.com-perso`, SSH lit ce bloc, se connecte en réalité à `github.com` (`HostName`), et présente la clé indiquée. `IdentitiesOnly yes` l'empêche d'essayer d'abord les autres clés qu'il connaît : sans cette ligne, il proposerait souvent la clé pro en premier, GitHub l'accepterait, et tu serais authentifié sur le mauvais compte, d'où le `repository not found` sur un dépôt perso privé.

Les commits, eux, ne transportent aucune authentification. GitHub rattache un commit à un compte uniquement par l'adresse email qu'il contient : elle doit figurer parmi les adresses du bon compte.

## Pièges

- **Un commit déjà fait avec la mauvaise adresse** : une fois le `includeIf` en place, `git commit --amend --reset-author --no-edit` réécrit l'auteur du dernier commit, s'il n'est pas poussé. Pour vérifier avant de pousser : `git log -1 --format='%an <%ae>'`.
- **Le chemin du `gitdir`** : `~` est compris par Git ; sous Windows, un chemin de la forme `C:/Users/…/perso/` fonctionne aussi. Le `/` final est obligatoire pour viser un dossier.
- **En HTTPS plutôt qu'en SSH**, c'est le gestionnaire d'identifiants qui doit distinguer les comptes : avec Git Credential Manager, `git config --global credential.useHttpPath true` permet un identifiant par dépôt.
- **`gh`, l'outil en ligne de commande de GitHub**, gère plusieurs comptes de son côté : `gh auth login` pour chacun, `gh auth switch` pour changer.
- **Deux comptes dans une même organisation** ne sont pas prévus par GitHub : dans ce cas, c'est un seul compte avec plusieurs adresses email.

## Voir aussi

- [Travailler sur le même projet depuis deux machines](/situations/avec-les-autres/travailler-depuis-deux-machines/)
- [Annuler mon dernier commit, pas encore poussé](/situations/reparer/annuler-mon-dernier-commit/)
- Travailler en équipe : *Les secrets ne vont jamais dans le dépôt* (à venir)

:::tip[Sorties vérifiées]
Les sorties des commandes `git` de cette page viennent du script [`scripts/situations/deux-comptes-github-sur-un-poste.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/deux-comptes-github-sur-un-poste.sh), exécuté avec Git 2.50 le 5 octobre 2026, dans un dossier personnel factice. La connexion SSH à GitHub ne se rejoue pas dans un bac à sable : la réponse de `ssh -T` est citée, pas exécutée par le script.
:::
