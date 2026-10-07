---
title: Ce que Git supprime, et quand
description: Git ne supprime presque jamais rien tout de suite. Un fichier retiré reste dans les commits, un commit sans nom reste dans le dépôt, retenu par le reflog, et le nettoyage ne passe qu'après des semaines. Ce qui disparaît, ce qui reste, et ce que Git ne touche jamais de lui-même.
level: intermediaire
gitVersion: "2.50"
verified: 2026-10-07
published: 2026-10-07
sidebar:
  order: 9
---

## L'idée

Git range tout ce qu'il enregistre dans une base d'objets, et ne supprime presque jamais rien directement. Supprimer un fichier, c'est faire un commit qui ne le contient plus : les commits précédents l'ont toujours. Supprimer une branche, c'est retirer un nom : le commit reste. Un objet ne disparaît que par le **nettoyage**, `git gc`, qui n'emporte que ce que plus rien n'atteint, ni branche, ni tag, ni ligne du reflog, et le reflog garde ses lignes des semaines.

Il y a une exception, et elle est importante : ce qui n'a jamais été commité n'est dans aucun objet. Là, Git n'a rien à garder.

## Voir par soi-même

Un fichier retiré du dossier et commité comme tel est toujours lisible dans le commit précédent :

```console
$ git rm -q a.js && git commit -q -m "Retire a.js" && git show HEAD~1:a.js
a
```

Un `reset --hard` retire ce commit de la branche. Il n'est plus dans `log`, mais il est dans le dépôt :

```console
$ git reset --hard HEAD~1
HEAD is now at 8952b33 feat: a

$ git log --oneline
8952b33 feat: a
d0a0b32 Premier commit

$ git cat-file -t 0076ed7
commit

$ git log --oneline -1 0076ed7
0076ed7 Retire a.js
```

Ce qui le retient, c'est une ligne du reflog. `fsck --unreachable` ne le liste pas, parce que le journal l'atteint ; en ignorant le journal, il apparaît :

```console
$ git reflog -2
8952b33 HEAD@{0}: reset: moving to HEAD~1
0076ed7 HEAD@{1}: commit: Retire a.js

$ git fsck --unreachable

$ git fsck --unreachable --no-reflogs
unreachable commit 0076ed7bbc24d22541e5dbe29e229d201b03ab72
```

Quand la ligne du journal expire, le nettoyage emporte l'objet. Ici l'expiration est forcée pour le montrer ; en vrai, trente jours passent d'abord :

```console
$ git reflog expire --expire-unreachable=now --all && git gc --prune=now -q

$ git cat-file -t 0076ed7
fatal: Not a valid object name 0076ed7
```

Un stash supprimé suit la même règle : plus de nom, mais l'objet est là, et `drop` donne son identifiant :

```console
$ echo "b" > b.js && git add b.js && git stash push -q -m "brouillon" && git stash list
stash@{0}: On main: brouillon

$ git stash drop
Dropped refs/stash@{0} (87af157283b150c3dd859345e4673466cae69c42)

$ git cat-file -t 87af157
commit

$ git stash apply 87af157
On branch main
Your branch is ahead of 'origin/main' by 1 commit.
  (use "git push" to publish your local commits)

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	new file:   b.js

```

À l'inverse, ce que Git ne supprime jamais de lui-même : tes copies des branches du serveur, même quand la branche n'y existe plus. Il faut le lui demander.

```console
$ git branch -r
  origin/HEAD -> origin/main
  origin/feature/ancienne
  origin/main

$ git fetch --prune
From github.com:equipe/projet
 - [deleted]         (none)     -> origin/feature/ancienne

$ git branch -r
  origin/HEAD -> origin/main
  origin/main
```

## Ce que ça change dans la pratique

- **Supprimer un fichier ne le retire pas de l'historique.** Un secret commité se lit dans tous les commits passés : [J'ai poussé un secret par erreur](/situations/fichiers/secret-pousse-par-erreur/) explique la seule vraie réponse, réécrire l'historique, et pourquoi elle ne suffit pas.
- **Supprimer une branche ne supprime aucun commit.** `-d` refuse quand des commits n'existeraient plus nulle part ; `-D` passe outre, et le reflog garde l'identifiant trente jours.
- **Le nettoyage est lent et prudent** : `git gc` tourne tout seul de temps en temps, et n'emporte que ce que plus rien n'atteint depuis des semaines. Forcer `--prune=now` est le seul moyen de perdre quelque chose vite.
- **Le travail non commité n'est protégé par rien** : pas d'objet, pas de reflog. Un `reset --hard` ou un `restore` le jette pour de bon.
- **Les copies du serveur et tes branches locales sont à toi** : Git ne les retire que sur ordre, `fetch --prune` pour les unes, `branch -d` pour les autres.
- **Le serveur n'a pas de reflog** : ce qu'un push forcé efface là-bas ne se retrouve que chez quelqu'un qui l'avait récupéré.

## Où ça sert

- [Retrouver un commit perdu](/situations/reparer/retrouver-un-commit-perdu/)
- [J'ai poussé un secret par erreur](/situations/fichiers/secret-pousse-par-erreur/)
- [Supprimer une vieille branche sans rien perdre](/situations/quotidien/supprimer-une-vieille-branche-sans-rien-perdre/)
- [Une branche distante a été supprimée, mais je la vois encore](/situations/quotidien/branche-distante-supprimee-encore-visible/)
- [Le reflog, ton filet de sécurité](/comprendre/le-reflog-ton-filet-de-securite/)
- [Un commit, c'est un instantané](/comprendre/un-commit-est-un-instantane/)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/comprendre/ce-que-git-supprime-et-quand.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/comprendre/ce-que-git-supprime-et-quand.sh), exécuté avec Git 2.50 le 7 octobre 2026. L'expiration du journal y est forcée, dans le bac à sable seulement ; la branche du serveur est créée puis supprimée par un second poste. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
