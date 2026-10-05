---
title: J'ai poussé un secret par erreur
description: Une clé d'API dans un .env commité et poussé. Dans quel ordre agir, révoquer d'abord, pourquoi supprimer le fichier ne suffit pas, et comment effacer le secret de l'historique avec git filter-repo.
level: avance
risk: destructif
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptôme

Un fichier `.env` avec une clé d'API est parti sur le serveur, il y a deux commits. Peut-être que GitHub t'a déjà envoyé une alerte « secret detected ».

```console
$ git log --oneline -3
fea6687 Corrige un bug
b5078f3 Ajoute l application
d0a0b32 Premier commit

$ git show --stat --oneline HEAD~1
b5078f3 Ajoute l application
 .env   | 1 +
 app.js | 1 +
 2 files changed, 2 insertions(+)
```

## Diagnostic

Dès l'instant du push, considère le secret comme **compromis**. Sur un dépôt public, des robots scrutent GitHub en continu et une clé est exploitée en quelques minutes. Sur un dépôt privé, elle est chez tous ceux qui ont cloné, dans les caches, dans les forks. Supprimer le fichier ne retire rien de ce qui a déjà été vu. L'ordre des priorités est donc fixe : d'abord rendre le secret inutilisable, ensuite seulement nettoyer.

:::danger[Cette page réécrit l'historique]
L'étape 2 change l'identifiant de tous les commits postérieurs au secret, et l'étape 3 remplace l'historique du serveur. Toute l'équipe doit être prévenue et recloner.
:::

## Solution

**0. Révoque la clé.** Dans la console du service concerné, supprime-la et génère-en une nouvelle, que tu mets en place là où elle sert. Ça ne passe pas par Git, et c'est la seule étape qui protège vraiment.

**1. Retire le fichier du suivi et ignore-le**, pour que ça ne se reproduise pas :

```console
$ git rm --cached .env
rm '.env'

$ echo ".env" > .gitignore && git add .gitignore && git commit -q -m "Retire le fichier .env du suivi" && git push -q origin main

$ git status --short
```

Le fichier n'est plus suivi. Mais il est toujours dans l'historique, et n'importe qui peut le relire :

```console
$ git log --oneline --all -- .env
d796dfc Retire le fichier .env du suivi
b5078f3 Ajoute l application

$ git show HEAD~2:.env
API_KEY=sk-live-123456
```

**2. Réécris l'historique sans ce fichier.** L'outil maintenu pour ça est `git filter-repo`, qui ne vient pas avec Git :

```bash
pip install git-filter-repo
```

Puis, depuis la racine du dépôt :

```console
$ git filter-repo --invert-paths --path .env --force
NOTICE: Removing 'origin' remote; see 'Why is my origin removed?'
        in the manual if you want to push back there.
        (was github.com:equipe/projet.git)
Parsed 1 commitsParsed 4 commitsHEAD is now at 9521054 Retire le fichier .env du suivi

New history written in 0.21 seconds; now repacking/cleaning...
Repacking your repo and cleaning out old unneeded objects
Completely finished after 0.58 seconds.

$ git log --oneline --all -- .env

$ git log --oneline -3
9521054 Retire le fichier .env du suivi
4df6761 Corrige un bug
86601e7 Ajoute l application

$ git show HEAD~2:.env
fatal: path '.env' exists on disk, but not in 'HEAD~2'
```

Le fichier n'a jamais existé dans ce nouvel historique. Tous les commits à partir de `b5078f3` ont un nouvel identifiant.

**3. Remplace l'historique du serveur.** `filter-repo` a retiré le remote, par prudence ; on le remet, et cette fois le push forcé est le bon geste :

```console
$ git remote -v

$ git remote add origin github.com:equipe/projet.git

$ git push --force --all
To github.com:equipe/projet.git
 + d796dfc...9521054 main -> main (forced update)
```

Ajoute `git push --force --tags` s'il y a des tags.

**4. Préviens l'équipe.** Chez les collègues, l'ancien historique a divergé ; le plus sûr est de recloner :

```console
$ git fetch
From github.com:equipe/projet
 + fea6687...9521054 main       -> origin/main  (forced update)

$ git status
On branch main
Your branch and 'origin/main' have diverged,
and have 2 and 3 different commits each, respectively.
  (use "git pull" if you want to integrate the remote branch with yours)

nothing to commit, working tree clean
```

Sans travail local en cours, `git reset --hard origin/main` suffit ; sinon, mettre le travail de côté d'abord, ou recloner et y reporter les changements.

## Pourquoi ça marche

Un commit est immuable et contient son parent : « retirer un fichier d'un commit » revient à fabriquer un nouveau commit, puis de nouveaux commits pour tous ses descendants. C'est ce que fait `filter-repo`, en rejouant tout l'historique sans le chemin indiqué. Les anciens commits ne sont pas modifiés, ils deviennent orphelins, et `filter-repo` nettoie le dépôt local pour qu'il n'en reste rien. Sur le serveur, seul un push forcé peut remplacer une branche par une autre qui n'en descend pas : c'est l'exception qui justifie `--force`.

Rien de tout cela ne retire le secret de la mémoire de ceux qui l'ont vu. D'où l'étape 0.

## Pièges

- **Une branche protégée refuse le push forcé.** Il faut suspendre la règle le temps de l'opération, puis la remettre.
- **GitHub garde les anciens commits un temps**, accessibles par leur identifiant, dans les vues de pull request et les caches. Pour les purger, GitHub demande de contacter le support, avec la liste des commits. Les forks ont leur propre copie : à nettoyer ou à supprimer aussi.
- **Les journaux de CI** peuvent avoir affiché le secret. À vérifier et à supprimer.
- **Vérifie toutes les branches et tous les tags**, pas seulement `main` : `--all` dans la commande `git log` plus haut, et dans le push.
- **Les identifiants de commit changent** : liens vers des commits, messages « Fixes abc1234 », changelog, tout ce qui citait un ancien identifiant pointe dans le vide.
- **Pour que ça ne se reproduise pas** : `.env` dans le `.gitignore` dès le premier commit, un `.env.example` versionné, et sur GitHub, « Push protection » dans Settings → Code security, qui refuse un push contenant un secret reconnu.

## Voir aussi

- [.gitignore ne marche pas, le fichier est déjà suivi](/situations/fichiers/gitignore-fichier-deja-suivi/)
- [Annuler un commit déjà poussé](/situations/reparer/annuler-un-commit-deja-pousse/), pour tout ce qui n'est pas un secret
- Travailler en équipe : *Les secrets ne vont jamais dans le dépôt* (à venir)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/situations/secret-pousse-par-erreur.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/secret-pousse-par-erreur.sh), exécuté avec Git 2.50 et git-filter-repo le 5 octobre 2026. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple. La révocation de la clé, hors Git, n'est pas jouée.
:::
