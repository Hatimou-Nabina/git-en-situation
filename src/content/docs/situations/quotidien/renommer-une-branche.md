---
title: Renommer une branche, en local et sur le serveur
description: Une faute de frappe dans le nom d'une branche déjà poussée. Les trois endroits où le nom existe, les commandes pour les mettre d'accord, et le cas où il vaut mieux renommer depuis GitHub.
level: intermediaire
risk: aucun
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptôme

Tu as nommé ta branche `feautre/recherche` au lieu de `feature/recherche`, et tu ne t'en rends compte qu'après l'avoir poussée :

```console
$ git branch -vv
* feautre/recherche 5b5dda8 [origin/feautre/recherche] Ajoute la recherche
  main              d0a0b32 [origin/main] Premier commit
```

## Diagnostic

Le nom d'une branche poussée existe à trois endroits : ta branche locale, la branche sur le serveur, et le **lien de suivi** entre les deux. Git n'a pas de commande « renommer partout » : on renomme en local, on pousse le nouveau nom, on supprime l'ancien sur le serveur. Trois commandes, aucune n'est risquée, les commits ne bougent pas.

## Solution

**1. Renomme en local.** Si c'est la branche courante, le nouveau nom seul suffit : `git branch -m feature/recherche`.

```console
$ git branch -m feautre/recherche feature/recherche

$ git branch -vv
* feature/recherche 5b5dda8 [origin/feautre/recherche] Ajoute la recherche
  main              d0a0b32 [origin/main] Premier commit
```

La branche locale a changé de nom, mais elle suit toujours l'ancienne branche du serveur.

**2. Pousse le nouveau nom, puis supprime l'ancien sur le serveur.**

```console
$ git push -u origin feature/recherche
branch 'feature/recherche' set up to track 'origin/feature/recherche'.
To github.com:equipe/projet.git
 * [new branch]      feature/recherche -> feature/recherche

$ git push origin --delete feautre/recherche
To github.com:equipe/projet.git
 - [deleted]         feautre/recherche

$ git branch -vv
* feature/recherche 5b5dda8 [origin/feature/recherche] Ajoute la recherche
  main              d0a0b32 [origin/main] Premier commit
```

Le `-u` du push remplace le lien de suivi par le nouveau nom.

**3. Chez les collègues qui avaient récupéré l'ancienne branche.** Chacun fait le ménage de son côté :

```console
$ git fetch --prune
From github.com:equipe/projet
 - [deleted]         (none)            -> origin/feautre/recherche
 * [new branch]      feature/recherche -> origin/feature/recherche

$ git branch -vv
  feautre/recherche 5b5dda8 [origin/feautre/recherche: gone] Ajoute la recherche
* main              d0a0b32 [origin/main] Premier commit

$ git branch -m feautre/recherche feature/recherche

$ git branch -u origin/feature/recherche feature/recherche
branch 'feature/recherche' set up to track 'origin/feature/recherche'.

$ git branch -vv
  feature/recherche 5b5dda8 [origin/feature/recherche] Ajoute la recherche
* main              d0a0b32 [origin/main] Premier commit
```

Sur GitHub, on peut aussi renommer la branche depuis le site : page des branches du dépôt, icône crayon à côté du nom. GitHub renomme sur le serveur, met à jour les pull requests ouvertes, et affiche à chacun les commandes de l'étape 3. Il ne reste que l'étape 1 à faire chez soi, remplacée par ces commandes.

## Pourquoi ça marche

Une branche est un marque-page posé sur un commit, rangé dans `.git/refs/heads/` sous son nom. Renommer, c'est déplacer ce marque-page : `git branch -m` le fait et met à jour les deux lignes de configuration du lien de suivi, sans toucher à aucun commit. Le serveur n'en sait rien tant qu'on ne lui parle pas : d'où le push du nouveau nom et la suppression de l'ancien, qui ne sont pour lui que la création d'un marque-page et la suppression d'un autre, sur le même commit.

## Pièges

- **Une pull request ouverte depuis cette branche** : sur GitHub, supprimer la branche d'origine d'une PR **ferme la PR**. Dans ce cas, renomme depuis l'interface GitHub, qui déplace la PR avec la branche, plutôt qu'avec `push --delete`.
- **Une branche protégée** ne se supprime pas et ne se renomme pas sans toucher aux règles. `main` n'est pas faite pour être renommée à la légère.
- **`git branch -M`** force le renommage même si une branche porte déjà le nouveau nom : elle est écrasée. Préfère `-m`, qui refuse dans ce cas.
- **Des collègues qui n'ont pas fait l'étape 3** continuent de voir `[gone]` sur leur ancienne branche : voir [Une branche distante a été supprimée, mais je la vois encore](/situations/quotidien/branche-distante-supprimee-encore-visible/).

## Voir aussi

- [Premier push d'une branche, « has no upstream branch »](/situations/quotidien/premier-push-no-upstream/)
- [Une branche distante a été supprimée, mais je la vois encore](/situations/quotidien/branche-distante-supprimee-encore-visible/)
- Comprendre : *Une branche, c'est un marque-page* (à venir)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/situations/renommer-une-branche.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/renommer-une-branche.sh), exécuté avec Git 2.50 le 5 octobre 2026. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
