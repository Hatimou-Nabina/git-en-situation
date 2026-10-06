---
title: Une branche, c'est un marque-page
description: Une branche est un fichier qui contient l'identifiant d'un commit, rien de plus. Commiter déplace ce marque-page, en créer un est gratuit, en supprimer un ne supprime aucun commit. Une fois ce modèle en tête, reset, detached HEAD et branches perdues deviennent évidents.
level: debutant
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
sidebar:
  order: 2
---

## L'idée

Une branche n'est pas une « copie du code » ni une « ligne de développement » rangée quelque part. C'est un fichier de quarante et un caractères : l'identifiant d'un commit, et un retour à la ligne. Un marque-page posé sur un commit. `HEAD`, c'est le marque-page qui dit sur quelle branche tu es. Quand tu commites, Git crée le commit, puis avance la branche courante dessus. Rien d'autre ne bouge.

## Voir par soi-même

```console
$ cat .git/HEAD
ref: refs/heads/main

$ cat .git/refs/heads/main
d0a0b32921f0e3e6484b075d9ff287b1f409cc5c

$ git log --oneline -1
d0a0b32 Premier commit
```

Créer une branche, c'est écrire le même identifiant dans un nouveau fichier :

```console
$ git branch feature/recherche

$ cat .git/refs/heads/feature/recherche
d0a0b32921f0e3e6484b075d9ff287b1f409cc5c

$ ls -R .git/refs/heads
.git/refs/heads:
feature
main

.git/refs/heads/feature:
recherche
```

Basculer dessus change `HEAD`. Commiter fait avancer cette branche, et elle seule :

```console
$ git switch feature/recherche
Switched to branch 'feature/recherche'

$ cat .git/HEAD
ref: refs/heads/feature/recherche

$ cat .git/refs/heads/feature/recherche
5b5dda8e7458ad1406b35f8e2ec6a00141f5f0f3

$ cat .git/refs/heads/main
d0a0b32921f0e3e6484b075d9ff287b1f409cc5c

$ git log --oneline --graph --all
* 5b5dda8 Ajoute la recherche
* d0a0b32 Premier commit
```

« Sur quelle branche est ce commit ? » n'a pas de réponse unique : un commit est contenu par toutes les branches dont il est un ancêtre.

```console
$ git branch --contains HEAD
* feature/recherche

$ git branch --contains main
* feature/recherche
  main
```

Supprimer la branche efface le marque-page. Le commit, lui, est toujours là :

```console
$ git switch main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.

$ git branch -D feature/recherche
Deleted branch feature/recherche (was 5b5dda8).

$ ls -R .git/refs/heads
.git/refs/heads:
main

$ git cat-file -t 5b5dda8
commit

$ git log --oneline -1 5b5dda8
5b5dda8 Ajoute la recherche
```

## Ce que ça change dans la pratique

- **Une branche pour chaque chose, sans compter.** Créer, renommer, supprimer : ce sont des opérations sur un fichier de quarante et un caractères.
- **Supprimer une branche ne perd rien, tant qu'un autre nom mène au commit.** S'il n'y en a plus, le commit reste un temps dans le dépôt, et le reflog garde son identifiant.
- **« Déplacer un commit » revient à déplacer des marque-pages** : `git branch` en pose un, `git reset` recule celui de la branche courante.
- **Le « detached HEAD »**, c'est `HEAD` qui contient directement un identifiant de commit au lieu de `ref: refs/heads/…`. Un commit fait dans cet état n'avance aucun marque-page.
- **Les branches du serveur sont les mêmes fichiers**, rangés sous `refs/remotes/origin/`, et Git ne les avance que lors d'un `fetch` ou d'un `push`.

## Où ça sert

- [Supprimer une vieille branche sans rien perdre](/situations/quotidien/supprimer-une-vieille-branche-sans-rien-perdre/)
- [J'ai commité sur la mauvaise branche](/situations/reparer/commit-sur-la-mauvaise-branche/)
- [Renommer une branche, en local et sur le serveur](/situations/quotidien/renommer-une-branche/)
- [Je suis en « detached HEAD »](/situations/reparer/detached-head/)
- [Retrouver un commit perdu](/situations/reparer/retrouver-un-commit-perdu/)
- [Les remotes et les références distantes](/comprendre/remotes-et-references-distantes/)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/comprendre/une-branche-est-un-marque-page.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/comprendre/une-branche-est-un-marque-page.sh), exécuté avec Git 2.50 le 6 octobre 2026. Dans un dépôt plus ancien, Git compacte les marque-pages dans `.git/packed-refs` et les fichiers individuels peuvent manquer ; `git show-ref` les liste dans tous les cas.
:::
