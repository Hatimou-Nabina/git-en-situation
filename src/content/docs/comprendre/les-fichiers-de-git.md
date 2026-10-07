---
title: Les fichiers de .git/
description: Une visite guidée du dossier .git, pour démystifier. HEAD et refs sont des noms, objects est tout le contenu rangé par empreinte, index la liste du prochain commit, logs le reflog, config les serveurs et les liens de suivi. Tout est en clair, et presque tout se lit avec cat.
level: intermediaire
gitVersion: "2.50"
verified: 2026-10-07
published: 2026-10-07
sidebar:
  order: 10
---

## L'idée

Tout ce que Git sait d'un dépôt tient dans le dossier `.git/`, à la racine du projet. Il n'y a pas de base de données opaque : des fichiers texte pour les noms, des objets compressés pour le contenu, un journal par référence. Les pages précédentes de cette section en ont déjà ouvert plusieurs. Celle-ci fait le tour, pour que le dossier cesse d'être une boîte noire, et pour qu'on sache ce qu'on risque, ou pas, en y touchant.

## Voir par soi-même

Le dossier, après un clone, deux commits et une branche :

```console
$ ls -F .git
COMMIT_EDITMSG
HEAD
config
description
hooks/
index
info/
logs/
objects/
refs/
```

**`HEAD` et `refs/`** : des noms qui mènent à des commits. `HEAD` contient le nom de la branche courante ; chaque branche est un fichier de quarante et un caractères sous `refs/heads/`, chaque copie du serveur sous `refs/remotes/`.

```console
$ cat .git/HEAD
ref: refs/heads/main

$ find .git/refs -type f | sort
.git/refs/heads/feature/x
.git/refs/heads/main
.git/refs/remotes/origin/main

$ cat .git/refs/heads/main
8952b33d4bb2fc8dd5d65355e72668b17d4ae56a
```

**`config`** : la configuration propre à ce dépôt, dont les serveurs et les liens de suivi des branches.

```console
$ git config --local --get-regexp '^(remote|branch)\.'
remote.origin.url github.com:equipe/projet.git
remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
branch.main.remote origin
branch.main.merge refs/heads/main
```

**`objects/`** : tout le contenu, blobs, arbres et commits, chaque objet dans un fichier nommé par son empreinte, les deux premiers caractères servant de dossier. Six fichiers suffisent ici pour deux commits.

```console
$ git rev-parse HEAD:a.js
78981922613b2afb6025042ff6bd878ac1994e85

$ ls .git/objects/$(git rev-parse HEAD:a.js | cut -c1-2)/
981922613b2afb6025042ff6bd878ac1994e85

$ git cat-file -p $(git rev-parse HEAD:a.js)
a

$ git cat-file -t HEAD
commit

$ find .git/objects -type f | wc -l
6
```

**`index`** : la liste des fichiers du prochain commit, avec leur mode et l'objet qu'ils désignent. C'est le seul fichier binaire de la visite ; `ls-files -s` le lit.

```console
$ git ls-files -s
100644 b60e1ad35025d69cbe886686e6a0b040551b9fde 0	README.md
100644 78981922613b2afb6025042ff6bd878ac1994e85 0	a.js
```

**`logs/`** : le reflog, un journal par référence, en texte : d'où l'on venait, où l'on va, qui, quand, pourquoi.

```console
$ find .git/logs -type f | sort
.git/logs/HEAD
.git/logs/refs/heads/feature/x
.git/logs/refs/heads/main
.git/logs/refs/remotes/origin/main

$ tail -n 2 .git/logs/HEAD
0000000000000000000000000000000000000000 d0a0b32921f0e3e6484b075d9ff287b1f409cc5c Awa <awa@example.com> 1791194400 +0000	commit (initial): Premier commit
d0a0b32921f0e3e6484b075d9ff287b1f409cc5c 8952b33d4bb2fc8dd5d65355e72668b17d4ae56a Awa <awa@example.com> 1791194400 +0000	commit: feat: a
```

**`info/exclude`** : des règles d'ignorance qui ne quittent pas ce clone, pour ce qui ne regarde que toi. `check-ignore` le cite comme n'importe quel `.gitignore`.

```console
$ echo "scratch/" >> .git/info/exclude && mkdir -p scratch && echo "x" > scratch/notes.txt && git status --short

$ git check-ignore -v scratch/notes.txt
.git/info/exclude:7:scratch/	scratch/notes.txt
```

Les autres : `COMMIT_EDITMSG`, le dernier message de commit tel que l'éditeur l'a reçu ; `description`, un nom pour les interfaces web, inutilisé par GitHub ; `hooks/`, des scripts que Git exécute à certains moments, livrés en exemples `.sample` et inactifs tant qu'on ne les renomme pas. Dans un dépôt plus ancien, un fichier `packed-refs` regroupe les références en une seule liste, et `objects/pack/` les objets compressés ensemble : les fichiers individuels manquent alors, mais `git show-ref` et `git cat-file` lisent les deux formes sans différence.

## Ce que ça change dans la pratique

- **Rien n'est caché.** Une branche est un fichier, un commit un objet, le reflog un texte : quand une commande surprend, `cat` dans `.git/` dit ce qui s'est passé.
- **`.git/` est le dépôt.** Le copier, c'est copier tout l'historique ; le supprimer, c'est perdre tout ce qui n'a pas été poussé. Un `.git/` corrompu se répare rarement : c'est le clone qui sauve, d'où l'importance de pousser.
- **On n'y écrit pas à la main**, sauf `info/exclude` et, en connaissance de cause, `hooks/`. Pour le reste, chaque fichier a sa commande : `git branch`, `git switch`, `git config`, `git update-ref`.
- **`config` est local au clone** : ce qui s'y trouve ne voyage pas. Ce qui doit suivre le dépôt va dans `.gitattributes` et `.gitignore`, versionnés.
- **La taille du dépôt, c'est `objects/`.** Un gros fichier binaire modifié souvent y laisse une version complète à chaque commit, et aucune suppression ultérieure ne l'en retire.
- **Un sous-dossier `.git` dans un sous-dossier du projet**, oublié après un clone imbriqué, est la cause classique du « dossier vide » sur GitHub : Git voit un dépôt dans le dépôt et n'en suit pas le contenu.

## Où ça sert

- [Une branche, c'est un marque-page](/comprendre/une-branche-est-un-marque-page/)
- [Un commit, c'est un instantané](/comprendre/un-commit-est-un-instantane/)
- [HEAD, ou « où je suis »](/comprendre/head-ou-ou-je-suis/)
- [Le reflog, ton filet de sécurité](/comprendre/le-reflog-ton-filet-de-securite/)
- [Les remotes et les références distantes](/comprendre/remotes-et-references-distantes/)
- Commandes : [`git cat-file`](/commandes/cat-file/), [`git ls-files`](/commandes/ls-files/), [`git config`](/commandes/config/)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/comprendre/les-fichiers-de-git.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/comprendre/les-fichiers-de-git.sh), exécuté avec Git 2.50 le 7 octobre 2026. Le dépôt est jeune et n'a ni `packed-refs` ni `objects/pack/`, d'où les fichiers individuels montrés. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
