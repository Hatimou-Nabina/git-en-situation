---
title: Un commit, c'est un instantané
description: Un commit n'est pas une différence, c'est une photo complète du projet, avec son auteur, son message et son parent. Son identifiant est l'empreinte de tout ça. Voilà pourquoi on ne modifie jamais un commit, on en fabrique un autre.
level: debutant
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
sidebar:
  order: 1
---

## L'idée

Un commit, c'est une photo du projet entier à un instant donné, accompagnée de quatre informations : qui, quand, pourquoi (le message), et d'où l'on vient (le ou les commits parents). Son nom, cette suite de quarante caractères dont on cite les sept premiers, est l'empreinte de tout ça. Change un octet du contenu, une lettre du message, le parent, et l'empreinte change : c'est un autre commit.

Ce n'est **pas** une différence. La différence qu'affiche `git show`, c'est Git qui la calcule en comparant deux photos.

## Voir par soi-même

Le dernier commit, tel que Git le range :

```console
$ git log --oneline -2
86601e7 Ajoute l application
d0a0b32 Premier commit

$ git cat-file -p HEAD
tree cdc69cad0d86b74201c78b3873e94acc2019e27d
parent d0a0b32921f0e3e6484b075d9ff287b1f409cc5c
author Awa <awa@example.com> 1791194400 +0000
committer Awa <awa@example.com> 1791194400 +0000

Ajoute l application
```

Quatre lignes et un message. Le `tree`, c'est la photo : la liste de tous les fichiers du projet, avec l'empreinte de leur contenu. Celle du commit précédent n'a qu'un fichier :

```console
$ git cat-file -p HEAD^{tree}
100644 blob b60e1ad35025d69cbe886686e6a0b040551b9fde	README.md
100644 blob e14c4f2a9561ade31986f9319d5c639094509905	app.js

$ git cat-file -p HEAD~1^{tree}
100644 blob b60e1ad35025d69cbe886686e6a0b040551b9fde	README.md
```

`README.md` n'a pas changé entre les deux : même empreinte, et Git ne le stocke qu'une fois.

```console
$ git rev-parse HEAD:README.md HEAD~1:README.md
b60e1ad35025d69cbe886686e6a0b040551b9fde
b60e1ad35025d69cbe886686e6a0b040551b9fde
```

Ce que `git show` affiche comme « un fichier ajouté » est calculé en comparant les deux arbres :

```console
$ git show --stat --oneline HEAD
86601e7 Ajoute l application
 app.js | 1 +
 1 file changed, 1 insertion(+)
```

Retouche seulement le message, sans toucher à un fichier :

```console
$ git commit --amend -q -m "Ajoute l application (message retouche)"

$ git log --oneline -2
bfa6f25 Ajoute l application (message retouche)
d0a0b32 Premier commit

$ git cat-file -p HEAD
tree cdc69cad0d86b74201c78b3873e94acc2019e27d
parent d0a0b32921f0e3e6484b075d9ff287b1f409cc5c
author Awa <awa@example.com> 1791194400 +0000
committer Awa <awa@example.com> 1791194400 +0000

Ajoute l application (message retouche)
```

Même arbre, même parent, même auteur. Un autre commit : `86601e7` est devenu `bfa6f25`. L'ancien existe toujours, plus rien ne pointe dessus.

## Ce que ça change dans la pratique

- **« Modifier un commit » n'existe pas.** `--amend`, `rebase`, `cherry-pick`, `filter-repo` fabriquent de nouveaux commits. C'est pour ça qu'un commit poussé ne se retouche pas : les autres ont l'ancien, et les deux ne se reconnaissent pas.
- **Le même changement sur un autre parent, c'est un autre commit.** Un `cherry-pick` copie, il ne déplace pas.
- **Une empreinte désigne un contenu exact, pour toujours.** C'est ce qui permet de retrouver un commit « perdu » : tant que l'objet existe dans le dépôt, son nom suffit.
- **Git stocke des photos, pas des différences**, mais il ne stocke chaque fichier qu'une fois par version : un dépôt de mille commits où un fichier n'a jamais changé ne le contient qu'une fois. Un gros fichier binaire modifié souvent, en revanche, coûte sa taille à chaque version.

## Où ça sert

- [Annuler mon dernier commit, pas encore poussé](/situations/reparer/annuler-mon-dernier-commit/)
- [J'ai commité sur la mauvaise branche](/situations/reparer/commit-sur-la-mauvaise-branche/)
- [Annuler un commit déjà poussé](/situations/reparer/annuler-un-commit-deja-pousse/)
- [Retrouver un commit perdu](/situations/reparer/retrouver-un-commit-perdu/)
- [J'ai poussé un secret par erreur](/situations/fichiers/secret-pousse-par-erreur/)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/comprendre/un-commit-est-un-instantane.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/comprendre/un-commit-est-un-instantane.sh), exécuté avec Git 2.50 le 5 octobre 2026. Les dates sont figées par le script, d'où les mêmes identifiants à chaque exécution.
:::
