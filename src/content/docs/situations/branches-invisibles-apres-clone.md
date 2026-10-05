---
title: Après un clone, je ne vois pas les branches des autres
description: git branch n'affiche que main alors que l'équipe travaille sur plusieurs branches. Où elles sont, comment basculer dessus, et pourquoi un clone ne crée qu'une branche locale.
level: debutant
risk: aucun
gitVersion: "2.50"
verified: 2026-10-05
---

## Symptôme

Tu viens de cloner le projet. Une collègue te dit « regarde ma branche `feature/export-pdf` ». Chez toi :

```console
$ git branch
* main
```

## Diagnostic

Le clone a bien tout rapporté. Mais Git distingue les **branches locales**, les tiennes, des **références distantes**, sa copie de ce qui existe sur le serveur. Un clone crée une seule branche locale, celle par défaut, et range toutes les autres sous `origin/` :

```console
$ git branch -a
* main
  remotes/origin/HEAD -> origin/main
  remotes/origin/feature/export-pdf
  remotes/origin/main
```

La branche de ta collègue est là, en lecture seule. Il te manque une branche locale pour travailler dessus.

## Solution

**Bascule dessus avec son nom court.** Git comprend que tu veux une branche locale calquée sur celle du serveur, et la crée :

```console
$ git switch feature/export-pdf
branch 'feature/export-pdf' set up to track 'origin/feature/export-pdf'.
Switched to a new branch 'feature/export-pdf'

$ git branch -vv
* feature/export-pdf 7abda0a [origin/feature/export-pdf] Ajoute la fonction export PDF
  main               d0a0b32 [origin/main] Premier commit
```

Ta branche suit celle du serveur : `git pull` et `git push` sauront quoi faire.

**Si la branche a été poussée après ton clone**, Git ne la connaît pas encore :

```console
$ git switch feature/recherche
fatal: invalid reference: feature/recherche
```

Récupère d'abord l'état du serveur, puis recommence :

```console
$ git fetch
From github.com:equipe/projet
 * [new branch]      feature/recherche -> origin/feature/recherche

$ git switch feature/recherche
branch 'feature/recherche' set up to track 'origin/feature/recherche'.
Switched to a new branch 'feature/recherche'
```

## Pourquoi ça marche

`git clone` fait deux choses : il récupère tout l'historique du serveur, branches comprises, sous forme de références `origin/<nom>`, puis il crée **une** branche locale, calquée sur la branche par défaut, pour que tu aies un point de départ. Les autres branches n'ont pas de version locale tant que tu ne la demandes pas.

`git switch <nom>` a une règle de confort : si aucune branche locale ne s'appelle ainsi mais qu'une référence `origin/<nom>` existe, il crée la branche locale à partir d'elle et établit le lien de suivi. C'est exactement `git switch -c <nom> origin/<nom>` en une commande.

## Pièges

- **`git switch -c feature/export-pdf`** ou `git checkout -b feature/export-pdf` crée une branche **vide de leur travail**, à partir de là où tu es. Tu auras une branche du même nom, sans les commits de ta collègue. Pour partir de la sienne, pas de `-c`, ou alors `git switch -c feature/export-pdf origin/feature/export-pdf`.
- **`git switch origin/feature/export-pdf`**, avec le préfixe, te met en « detached HEAD » : tu regardes la référence distante au lieu d'avoir une branche. Utilise le nom court.
- **Deux serveurs configurés** (par exemple `origin` et `upstream` sur un fork) : si la branche existe sur les deux, le raccourci est ambigu et Git refuse. Précise : `git switch -c feature/x origin/feature/x`.
- **`git branch -r`** liste uniquement les références distantes, pratique pour chercher un nom sans le bruit des branches locales.

## Voir aussi

- [Premier push d'une branche, « has no upstream branch »](/situations/premier-push-no-upstream/)
- [Une branche distante a été supprimée, mais je la vois encore](/situations/branche-distante-supprimee-encore-visible/)
- Comprendre : *Les remotes et les références distantes* (à venir)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/situations/branches-invisibles-apres-clone.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/branches-invisibles-apres-clone.sh), exécuté avec Git 2.50 le 5 octobre 2026. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
