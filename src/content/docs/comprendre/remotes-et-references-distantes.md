---
title: Les remotes et les références distantes
description: origin est un surnom pour une adresse, origin/main est ta copie locale de la branche du serveur, et ton main lui est lié. Trois choses s'appellent main, et presque toutes les surprises de fetch, pull et push viennent de leur confusion.
level: debutant
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
sidebar:
  order: 3
---

## L'idée

Un **remote**, c'est un surnom pour une adresse de serveur : `origin` est celui que `git clone` donne au dépôt d'origine. Une **référence distante**, `origin/main`, c'est ta copie locale de la branche `main` du serveur, **telle que tu l'as vue la dernière fois** : elle ne bouge que quand tu parles au serveur, par `fetch` ou `push`. Et ta branche `main` est **liée** à elle, ce qui permet à Git de te dire « ahead » ou « behind ».

Trois choses s'appellent donc `main` : la tienne, ta copie de celle du serveur, et celle du serveur. Seules les deux premières sont sur ton disque.

## Voir par soi-même

```console
$ git remote -v
origin	github.com:equipe/projet.git (fetch)
origin	github.com:equipe/projet.git (push)

$ git branch -a
* main
  remotes/origin/main

$ git show-ref main
d0a0b32921f0e3e6484b075d9ff287b1f409cc5c refs/heads/main
d0a0b32921f0e3e6484b075d9ff287b1f409cc5c refs/remotes/origin/main

$ git config --get branch.main.remote && git config --get branch.main.merge
origin
refs/heads/main
```

Deux fichiers, `refs/heads/main` et `refs/remotes/origin/main`, et deux lignes de configuration qui les lient. Une collègue pousse sur le serveur. Chez toi, rien ne change tant que tu ne demandes rien :

```console
$ git status
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean

$ git fetch
From github.com:equipe/projet
   d0a0b32..6ccbbac  main       -> origin/main

$ git status
On branch main
Your branch is behind 'origin/main' by 1 commit, and can be fast-forwarded.
  (use "git pull" to update your local branch)

nothing to commit, working tree clean

$ git log --oneline main..origin/main
6ccbbac Ajoute la page contact

$ git branch -vv
* main d0a0b32 [origin/main: behind 1] Premier commit
```

Le premier `git status` ne mentait pas : il comparait `main` à `origin/main`, qui n'avait pas bougé. `fetch` a mis la copie à jour, et seulement elle : `main` est toujours sur `d0a0b32`.

La copie est en lecture seule. On n'y travaille pas :

```console
$ git switch origin/main
fatal: a branch is expected, got remote branch 'origin/main'
hint: If you want to detach HEAD at the commit, try again with the --detach option.
```

`pull`, c'est `fetch` suivi de l'intégration dans ta branche. Après, les deux `main` locaux sont au même endroit :

```console
$ git pull --ff-only
Updating d0a0b32..6ccbbac
Fast-forward
 contact.html | 1 +
 1 file changed, 1 insertion(+)
 create mode 100644 contact.html

$ git branch -vv
* main 6ccbbac [origin/main] Ajoute la page contact
```

Dans l'autre sens, un commit local met ta branche en avance ; `push` l'envoie au serveur et avance la copie en même temps :

```console
$ git branch -vv
* main 8f1e53a [origin/main: ahead 1] Ajoute a.txt

$ git push
To github.com:equipe/projet.git
   6ccbbac..8f1e53a  main -> main

$ git branch -vv
* main 8f1e53a [origin/main] Ajoute a.txt
```

## Ce que ça change dans la pratique

- **`git fetch` est toujours sans risque** : il ne touche qu'aux copies `origin/*`. Le lancer souvent, c'est voir le serveur tel qu'il est.
- **« Up to date » veut dire « à jour par rapport à ma copie »**, pas par rapport au serveur. Avant de conclure, `fetch`.
- **Une branche du serveur supprimée reste dans tes copies** jusqu'à un `fetch --prune` ; une branche locale dont la copie a disparu est marquée `gone`.
- **Le lien de suivi est une configuration** : deux lignes par branche. `git push -u` les écrit, `git branch -u` les change.
- **Plusieurs remotes** sont possibles : sur un fork, `origin` est ta copie sur GitHub et `upstream` le projet d'origine, chacun avec ses références `origin/*` et `upstream/*`.

## Où ça sert

- [Une branche distante a été supprimée, mais je la vois encore](/situations/quotidien/branche-distante-supprimee-encore-visible/)
- [Après un clone, je ne vois pas les branches des autres](/situations/quotidien/branches-invisibles-apres-clone/)
- [Premier push d'une branche, « has no upstream branch »](/situations/quotidien/premier-push-no-upstream/)
- [Ma branche locale est en retard après une fusion sur GitHub](/situations/avec-les-autres/branche-locale-en-retard-apres-fusion/)
- [Travailler sur le même projet depuis deux machines](/situations/avec-les-autres/travailler-depuis-deux-machines/)
- [Une branche, c'est un marque-page](/comprendre/une-branche-est-un-marque-page/)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/comprendre/remotes-et-references-distantes.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/comprendre/remotes-et-references-distantes.sh), exécuté avec Git 2.50 le 5 octobre 2026. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
