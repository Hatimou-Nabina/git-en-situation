---
title: Le reflog, ton filet de sécurité
description: Git tient un journal de tout ce que HEAD et chaque branche ont fait sur ton poste, pendant des semaines. Un commit « perdu » par un reset, un branch -D ou un rebase y est presque toujours. Ce que le journal contient, ce qu'il ne contient pas, et quand il s'efface.
level: intermediaire
gitVersion: "2.50"
verified: 2026-10-07
published: 2026-10-07
sidebar:
  order: 6
---

## L'idée

Chaque fois que `HEAD` ou une branche change de position, par un commit, un changement de branche, un reset, un rebase, Git ajoute une ligne à un journal local : d'où l'on venait, où l'on va, et pourquoi. C'est le **reflog**. Un commit que plus aucune branche n'atteint a disparu de `git log`, mais pas du dépôt : tant qu'une ligne du journal le cite, il existe, et son identifiant suffit à le retrouver. Le journal est gardé quatre-vingt-dix jours, trente pour les lignes qui mènent à des commits que plus rien d'autre n'atteint.

Deux limites, et elles comptent : le reflog ne contient que des commits, jamais du travail non commité ; et il est propre à ton poste, ni poussé, ni cloné.

## Voir par soi-même

Trois commits, trois lignes :

```console
$ git log --oneline
4b99ea3 feat: b
8952b33 feat: a
d0a0b32 Premier commit

$ git reflog
4b99ea3 HEAD@{0}: commit: feat: b
8952b33 HEAD@{1}: commit: feat: a
d0a0b32 HEAD@{2}: commit (initial): Premier commit
```

Un `reset --hard` fait reculer la branche. « feat: b » disparaît de `log` ; le journal, lui, note le reset et garde la ligne du commit :

```console
$ git reset --hard HEAD~1
HEAD is now at 8952b33 feat: a

$ git log --oneline
8952b33 feat: a
d0a0b32 Premier commit

$ git reflog -3
8952b33 HEAD@{0}: reset: moving to HEAD~1
4b99ea3 HEAD@{1}: commit: feat: b
8952b33 HEAD@{2}: commit: feat: a
```

`HEAD@{1}`, « là où `HEAD` était juste avant », n'est pas `HEAD~1`, « le parent du commit courant ». Ici l'un est le commit perdu, l'autre le premier commit :

```console
$ git log --oneline -1 HEAD@{1}
4b99ea3 feat: b

$ git log --oneline -1 HEAD~1
d0a0b32 Premier commit

$ git reset --hard HEAD@{1}
HEAD is now at 4b99ea3 feat: b

$ git log --oneline
4b99ea3 feat: b
8952b33 feat: a
d0a0b32 Premier commit
```

Une branche supprimée de force : son dernier commit est dans le journal, avec son identifiant, et une branche se recrée dessus.

```console
$ git branch -D experimentation
Deleted branch experimentation (was ae0fb9e).

$ git reflog -4
4b99ea3 HEAD@{0}: checkout: moving from experimentation to main
ae0fb9e HEAD@{1}: commit: feat: x
4b99ea3 HEAD@{2}: checkout: moving from main to experimentation
4b99ea3 HEAD@{3}: reset: moving to HEAD@{1}

$ git branch experimentation ae0fb9e

$ git log --oneline experimentation -1
ae0fb9e feat: x
```

Chaque branche a son propre journal, et `main@{1}` n'est pas `HEAD@{1}` : la première est la position précédente de `main`, la seconde celle de `HEAD`, qui bouge aussi à chaque changement de branche.

```console
$ git reflog show main -3
4b99ea3 main@{0}: reset: moving to HEAD@{1}
8952b33 main@{1}: reset: moving to HEAD~1
4b99ea3 main@{2}: commit: feat: b

$ git log --oneline -1 main@{1}
8952b33 feat: a

$ git log --oneline -1 HEAD@{1}
ae0fb9e feat: x
```

Le journal est local. Chez un collègue qui vient de cloner, il ne contient que le clone :

```console
$ git reflog
d0a0b32 HEAD@{0}: clone: from github.com:equipe/projet.git
```

Et il ne contient que des commits. Une modification jamais commitée, jetée par un `reset --hard`, ne laisse aucune trace :

```console
$ echo "modif" >> a.js && git status --short
 M a.js

$ git reset --hard
HEAD is now at 4b99ea3 feat: b

$ git reflog -1
4b99ea3 HEAD@{0}: reset: moving to HEAD

$ cat a.js
a
```

Enfin, le journal expire. Quand ses lignes ont disparu, le nettoyage emporte les commits que plus rien n'atteint. Ici, l'expiration est forcée pour le montrer ; en vrai, elle met des semaines :

```console
$ git branch -D experimentation
Deleted branch experimentation (was ae0fb9e).

$ git cat-file -t ae0fb9e
commit

$ git reflog expire --expire=now --all && git gc --prune=now -q

$ git cat-file -t ae0fb9e
fatal: Not a valid object name ae0fb9e
```

## Ce que ça change dans la pratique

- **Un commit se perd rarement.** `reset --hard` trop loin, `branch -D` trop vite, rebase raté : `git reflog`, l'identifiant, et une branche ou un `reset --hard HEAD@{n}` dessus.
- **Vite, pas dans six mois.** Trente jours pour ce que plus rien n'atteint, puis le nettoyage passe. Un commit perdu se récupère la semaine même.
- **Le travail non commité n'a pas de filet.** `reset --hard`, `restore`, `checkout -- fichier` sur des modifications non commitées : aucune ligne nulle part. Commiter souvent, même en brouillon, c'est se donner ce filet.
- **Le reflog ne quitte pas ton poste.** Un disque qui meurt emporte les commits jamais poussés, reflog compris. Pousser tôt, même sur une branche de brouillon, est la vraie assurance.
- **`HEAD@{1}` et `HEAD~1` ne désignent le même commit que par hasard.** Les accolades parlent du journal, le tilde de l'historique.
- **Ne jamais « faire de la place » avec `gc --prune=now`** quand on cherche quelque chose : c'est précisément le filet qu'on coupe.

## Où ça sert

- [Retrouver un commit perdu](/situations/reparer/retrouver-un-commit-perdu/)
- [Annuler mon dernier commit, pas encore poussé](/situations/reparer/annuler-mon-dernier-commit/)
- [Supprimer une vieille branche sans rien perdre](/situations/quotidien/supprimer-une-vieille-branche-sans-rien-perdre/)
- [Je suis en « detached HEAD »](/situations/reparer/detached-head/)
- [Ce que Git supprime, et quand](/comprendre/ce-que-git-supprime-et-quand/)
- Commandes : [`git reflog`](/commandes/reflog/), [`git reset`](/commandes/reset/)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/comprendre/le-reflog-ton-filet-de-securite.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/comprendre/le-reflog-ton-filet-de-securite.sh), exécuté avec Git 2.50 le 7 octobre 2026. L'expiration du journal y est forcée avec `--expire=now`, dans le bac à sable seulement. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
