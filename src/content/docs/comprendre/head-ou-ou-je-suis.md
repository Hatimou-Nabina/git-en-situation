---
title: HEAD, ou « où je suis »
description: HEAD est un fichier qui contient le nom de la branche courante, ou, en « detached HEAD », directement l'identifiant d'un commit. Ce que ça change pour le prochain commit, pourquoi l'état détaché n'est pas une panne, et ce que veulent dire HEAD~1, HEAD^ et HEAD@{1}.
level: debutant
gitVersion: "2.50"
verified: 2026-10-07
published: 2026-10-07
sidebar:
  order: 8
---

## L'idée

`HEAD`, c'est « là où je suis ». Concrètement, c'est un fichier, `.git/HEAD`, qui contient d'habitude le **nom d'une branche** : `ref: refs/heads/main`. La branche, elle, contient l'identifiant d'un commit. Quand tu commites, Git crée le commit et fait avancer la branche que `HEAD` désigne ; `HEAD` lui-même ne change pas. Quand tu changes de branche, c'est `HEAD` qui change, et rien d'autre.

Parfois `HEAD` contient directement un identifiant de commit, sans branche entre les deux : c'est le « detached HEAD ». Rien n'est cassé, mais un commit fait dans cet état n'avance aucune branche, et il faudra lui donner un nom avant de repartir.

## Voir par soi-même

`HEAD` désigne une branche, qui désigne un commit :

```console
$ cat .git/HEAD
ref: refs/heads/main

$ git symbolic-ref HEAD
refs/heads/main

$ git rev-parse --abbrev-ref HEAD
main

$ git rev-parse --short HEAD
d0a0b32
```

Après un commit, `HEAD` est identique ; c'est la branche qui a avancé :

```console
$ cat .git/HEAD
ref: refs/heads/main

$ cat .git/refs/heads/main
8952b33d4bb2fc8dd5d65355e72668b17d4ae56a

$ git log --oneline -2
8952b33 feat: a
d0a0b32 Premier commit
```

Changer de branche ne change que `HEAD` :

```console
$ git switch feature/x
Switched to branch 'feature/x'

$ cat .git/HEAD
ref: refs/heads/feature/x

$ git log --oneline -1
8952b33 feat: a
```

En « detached HEAD », le fichier contient un identifiant, pas un nom. `symbolic-ref` ne sait plus répondre, `--abbrev-ref` dit `HEAD`, et `status` l'annonce :

```console
$ git switch --detach HEAD~1
HEAD is now at d0a0b32 Premier commit

$ cat .git/HEAD
d0a0b32921f0e3e6484b075d9ff287b1f409cc5c

$ git symbolic-ref HEAD
fatal: ref HEAD is not a symbolic ref

$ git rev-parse --abbrev-ref HEAD
HEAD

$ git status
HEAD detached at d0a0b32
nothing to commit, working tree clean
```

Un commit fait là n'avance aucune branche, et Git le dit au moment de repartir :

```console
$ git log --oneline -1
9a9a9e9 feat: z

$ git branch --contains HEAD
* (HEAD detached from d0a0b32)

$ git switch main
Warning: you are leaving 1 commit behind, not connected to
any of your branches:

  9a9a9e9 feat: z

If you want to keep it by creating a new branch, this may be a good time
to do so with:

 git branch <new-branch-name> 9a9a9e9

Switched to branch 'main'
Your branch is ahead of 'origin/main' by 1 commit.
  (use "git push" to publish your local commits)
```

Trois adresses relatives à `HEAD`, qui ne désignent pas la même chose : `HEAD~1` et `HEAD^` sont le parent du commit courant ; `HEAD@{1}` est là où `HEAD` était juste avant, ici le commit laissé derrière.

```console
$ git log --oneline -1 HEAD
8952b33 feat: a

$ git log --oneline -1 HEAD~1
d0a0b32 Premier commit

$ git log --oneline -1 HEAD^
d0a0b32 Premier commit

$ git log --oneline -1 HEAD@{1}
9a9a9e9 feat: z
```

## Ce que ça change dans la pratique

- **Le prochain commit ira sur la branche que `HEAD` désigne.** `git status` la dit en première ligne ; la lire avant de commiter évite [le commit sur la mauvaise branche](/situations/reparer/commit-sur-la-mauvaise-branche/).
- **« detached HEAD » est l'état normal pour regarder** un tag, un ancien commit, une référence du serveur. On regarde, on repart : `git switch main`.
- **Un commit en « detached HEAD » doit recevoir un nom** avant qu'on reparte : `git switch -c nom`. Sinon, seul le reflog s'en souvient, et Git donne l'identifiant au moment de partir.
- **`HEAD~1` descend dans l'historique, `HEAD@{1}` remonte dans le journal.** Les confondre dans un `reset --hard` mène au mauvais commit.
- **`HEAD^` et `HEAD~1` sont identiques** pour un commit ordinaire ; ils divergent sur un commit de merge, où `HEAD^2` est le second parent et `HEAD~2` le grand-parent par le premier.
- **La CI est toujours en « detached HEAD »** : elle récupère un commit précis, pas une branche. C'est normal.

## Où ça sert

- [Je suis en « detached HEAD »](/situations/reparer/detached-head/)
- [J'ai commité sur la mauvaise branche](/situations/reparer/commit-sur-la-mauvaise-branche/)
- [Retrouver un commit perdu](/situations/reparer/retrouver-un-commit-perdu/)
- [Une branche, c'est un marque-page](/comprendre/une-branche-est-un-marque-page/)
- [Le reflog, ton filet de sécurité](/comprendre/le-reflog-ton-filet-de-securite/)
- Commandes : [`git switch`](/commandes/switch/), [`git checkout`](/commandes/checkout/)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/comprendre/head-ou-ou-je-suis.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/comprendre/head-ou-ou-je-suis.sh), exécuté avec Git 2.50 le 7 octobre 2026. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
