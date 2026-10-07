---
title: Upstream, la branche que la tienne suit
description: Une branche locale peut suivre une branche du serveur. Ce lien tient en deux lignes de configuration, que push -u écrit et que push, pull et status lisent. C'est lui qui dit « ahead », « behind » ou « gone », et son absence qui fait échouer le premier push.
level: debutant
gitVersion: "2.50"
verified: 2026-10-07
published: 2026-10-07
sidebar:
  order: 5
---

## L'idée

Ta branche `main` et la branche `main` du serveur sont deux choses distinctes, et rien ne les relie par nature. Ce qui les relie, c'est un **lien de suivi**, l'*upstream* : deux lignes dans `.git/config` qui disent « cette branche locale correspond à telle branche de tel serveur ». `git push -u` écrit ces deux lignes. Ensuite, `git push` et `git pull` sans argument les lisent pour savoir où aller, et `git status` s'en sert pour comparer ta branche à sa copie de celle du serveur : « ahead » si tu as des commits en plus, « behind » si le serveur en a, « gone » si la branche du serveur a disparu.

Une branche créée en local n'a pas ce lien. Ce n'est pas une erreur, c'est l'état normal avant le premier push.

## Voir par soi-même

Une branche neuve, et `main` à côté d'elle. Les crochets de `git branch -vv` montrent le lien ; la configuration ne contient que celui de `main` :

```console
$ git branch -vv
* feature/recherche 5b5dda8 Ajoute la recherche
  main              d0a0b32 [origin/main] Premier commit

$ git config --get-regexp '^branch\.'
branch.main.remote origin
branch.main.merge refs/heads/main

$ git push
fatal: The current branch feature/recherche has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin feature/recherche

To have this happen automatically for branches without a tracking
upstream, see 'push.autoSetupRemote' in 'git help config'.
```

`push -u` pousse la branche et écrit les deux lignes :

```console
$ git push -u origin feature/recherche
To github.com:equipe/projet.git
 * [new branch]      feature/recherche -> feature/recherche
branch 'feature/recherche' set up to track 'origin/feature/recherche'.

$ git config --get-regexp '^branch\.feature'
branch.feature/recherche.remote origin
branch.feature/recherche.merge refs/heads/feature/recherche

$ git branch -vv
* feature/recherche 5b5dda8 [origin/feature/recherche] Ajoute la recherche
  main              d0a0b32 [origin/main] Premier commit
```

**« ahead »** : un commit local que le serveur n'a pas encore.

```console
$ git status -sb
## feature/recherche...origin/feature/recherche [ahead 1]

$ git branch -vv
* feature/recherche df6e2e1 [origin/feature/recherche: ahead 1] Filtre les resultats
  main              d0a0b32 [origin/main] Premier commit
```

**« behind »** : après le push, un collègue a poussé sur la même branche, et `fetch` a rafraîchi la copie.

```console
$ git fetch
From github.com:equipe/projet
   df6e2e1..6ffaf63  feature/recherche -> origin/feature/recherche

$ git status -sb
## feature/recherche...origin/feature/recherche [behind 1]

$ git branch -vv
* feature/recherche df6e2e1 [origin/feature/recherche: behind 1] Filtre les resultats
  main              d0a0b32 [origin/main] Premier commit
```

**« gone »** : la branche a été supprimée sur le serveur, `fetch --prune` a retiré la copie, mais le lien de suivi est toujours là, et pointe dans le vide.

```console
$ git fetch --prune
From github.com:equipe/projet
 - [deleted]         (none)     -> origin/feature/recherche

$ git branch -vv
* feature/recherche 6ffaf63 [origin/feature/recherche: gone] Trie les resultats
  main              d0a0b32 [origin/main] Premier commit

$ git status -sb
## feature/recherche...origin/feature/recherche [gone]
```

Le lien se retire, et se pose après coup sur une branche qui existe déjà des deux côtés :

```console
$ git branch --unset-upstream

$ git branch -vv
* feature/recherche 6ffaf63 Trie les resultats
  main              d0a0b32 [origin/main] Premier commit

$ git push origin feature/recherche
To github.com:equipe/projet.git
 * [new branch]      feature/recherche -> feature/recherche

$ git branch -vv
* feature/recherche 6ffaf63 Trie les resultats
  main              d0a0b32 [origin/main] Premier commit

$ git branch -u origin/feature/recherche
branch 'feature/recherche' set up to track 'origin/feature/recherche'.

$ git branch -vv
* feature/recherche 6ffaf63 [origin/feature/recherche] Trie les resultats
  main              d0a0b32 [origin/main] Premier commit
```

Un `push origin branche` sans `-u` pousse bien, mais ne crée pas le lien : la branche reste sans crochets.

## Ce que ça change dans la pratique

- **Le premier push d'une branche demande `-u`**, une fois. Ou le réglage `push.autoSetupRemote`, qui le fait à ta place pour toujours.
- **« Up to date » parle de ta copie du serveur**, pas du serveur : « ahead », « behind » et « up to date » comparent ta branche à `origin/<branche>`, qui ne bouge qu'au `fetch`.
- **`git push` et `git pull` sans argument** vont là où le lien pointe, et refusent de deviner quand il n'y en a pas : c'est le message du premier push.
- **« gone » n'est pas une panne** : la branche a été fusionnée et supprimée sur le serveur, ou renommée. Ta branche locale et son travail sont intacts.
- **Le lien est une configuration locale**, dans `.git/config` : il ne voyage pas avec le dépôt, et un clone ne l'a que pour la branche par défaut. Sur un autre poste, `git switch nom` le recrée depuis la branche du serveur.

## Où ça sert

- [Premier push d'une branche, « has no upstream branch »](/situations/quotidien/premier-push-no-upstream/)
- [Une branche distante a été supprimée, mais je la vois encore](/situations/quotidien/branche-distante-supprimee-encore-visible/)
- [Après un clone, je ne vois pas les branches des autres](/situations/quotidien/branches-invisibles-apres-clone/)
- [Ma branche locale est en retard après une fusion sur GitHub](/situations/avec-les-autres/branche-locale-en-retard-apres-fusion/)
- [Travailler sur le même projet depuis deux machines](/situations/avec-les-autres/travailler-depuis-deux-machines/)
- [Les remotes et les références distantes](/comprendre/remotes-et-references-distantes/)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/comprendre/upstream-la-branche-que-la-tienne-suit.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/comprendre/upstream-la-branche-que-la-tienne-suit.sh), exécuté avec Git 2.50 le 7 octobre 2026. Le commit du collègue et la suppression de la branche sur le serveur sont joués par un second poste. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
