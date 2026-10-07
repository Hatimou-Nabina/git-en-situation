---
title: Retrouver un commit perdu
description: Une branche supprimée trop vite, un reset --hard trop loin, et le commit a disparu de git log. Le reflog l'a gardé. Comment le retrouver, et combien de temps Git le conserve.
level: intermediaire
risk: aucun
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptôme

Tu as supprimé une branche d'expérimentation, et tu réalises qu'elle contenait un commit que tu voulais garder :

```console
$ git branch -D experimentation
Deleted branch experimentation (was e08efa9).

$ git log --oneline --all
d0a0b32 Premier commit
```

Même avec `--all`, le commit n'apparaît plus nulle part.

## Diagnostic

Git ne supprime pas les commits : il supprime les **noms** qui y mènent. Un commit sans branche ni tag devient invisible pour `git log`, mais il est encore dans le dépôt. Et Git tient un journal de tout ce que HEAD a visité, le **reflog**. Retrouver un commit, c'est y trouver son identifiant et lui redonner un nom.

## Solution

**Cas 1 : une branche supprimée.** Git t'a même donné l'identifiant dans le message, « was e08efa9 ». Si le terminal est déjà loin, le reflog l'a :

```console
$ git reflog -4
d0a0b32 HEAD@{0}: checkout: moving from experimentation to main
e08efa9 HEAD@{1}: commit: Essai prometteur
d0a0b32 HEAD@{2}: checkout: moving from main to experimentation
d0a0b32 HEAD@{3}: commit (initial): Premier commit
```

Recrée la branche sur ce commit :

```console
$ git branch experimentation e08efa9

$ git log --oneline experimentation -1
e08efa9 Essai prometteur
```

**Cas 2 : un `reset --hard` trop loin.** Deux commits de la journée, effacés d'un coup :

```console
$ git reset --hard HEAD~2
HEAD is now at d0a0b32 Premier commit

$ git log --oneline -1
d0a0b32 Premier commit
```

Le reflog montre où la branche était juste avant, et un second reset y retourne :

```console
$ git reflog -3
d0a0b32 HEAD@{0}: reset: moving to HEAD~2
b15abe4 HEAD@{1}: commit: Travail de l apres-midi
81ceaf2 HEAD@{2}: commit: Travail du matin

$ git reset --hard HEAD@{1}
HEAD is now at b15abe4 Travail de l apres-midi

$ git log --oneline -3
b15abe4 Travail de l apres-midi
81ceaf2 Travail du matin
d0a0b32 Premier commit
```

## Pourquoi ça marche

À chaque fois que HEAD change de position, par un commit, un changement de branche, un reset, un rebase, Git ajoute une ligne au reflog, avec l'identifiant du commit et la raison. Les entrées sont gardées **90 jours**, et **30 jours** pour celles qui mènent à des commits que plus rien d'autre n'atteint. Pendant ce temps, le commit est protégé du nettoyage automatique.

`HEAD@{1}` se lit « la position de HEAD juste avant la dernière », `HEAD@{2}` celle d'avant, et ainsi de suite. Ce sont des positions dans le journal, pas des parents dans l'historique.

Chaque branche a aussi son propre reflog : `git reflog show feature/recherche` montre uniquement les positions qu'elle a occupées.

## Pièges

- **Le reflog est local.** Il n'est ni poussé ni cloné. Un commit jamais poussé, perdu sur un disque mort ou dans un dossier supprimé, est perdu pour de bon. Pousser tôt, même sur une branche de brouillon, est la vraie assurance.
- **`HEAD@{1}` n'est pas `HEAD~1`** : position dans le journal contre parent du commit. Un `reset --hard` sur le mauvais des deux t'envoie ailleurs. Le reflog est là pour recommencer, mais autant lire avant de taper.
- **Un stash supprimé** n'est pas dans le reflog de HEAD. `git fsck --unreachable | grep commit` liste les commits que plus rien n'atteint, et `git show` sur chacun permet de reconnaître le bon.
- **`git gc --prune=now` ou `git reflog expire --expire=now`** suppriment le filet de sécurité immédiatement. Ne les lance pas pour « faire de la place » quand tu cherches quelque chose.

## Voir aussi

- [Annuler mon dernier commit, pas encore poussé](/situations/reparer/annuler-mon-dernier-commit/)
- [Je suis en « detached HEAD »](/situations/reparer/detached-head/)
- [Supprimer une vieille branche sans rien perdre](/situations/quotidien/supprimer-une-vieille-branche-sans-rien-perdre/)
- [Comprendre : le reflog, ton filet de sécurité](/comprendre/le-reflog-ton-filet-de-securite/) et [ce que Git supprime, et quand](/comprendre/ce-que-git-supprime-et-quand/)

:::note[Essaie-le toi-même]
Le script de cette page sait fabriquer la panne sur ton poste. Depuis un clone du [dépôt du site](https://github.com/Hatimou-Nabina/git-en-situation), dans Git Bash sous Windows :

```bash
EXERCICE=1 bash scripts/situations/retrouver-un-commit-perdu.sh
```

Il s'arrête juste après le symptôme, te dit dans quel dossier aller et quoi faire. Répare, puis relance sans `EXERCICE=1` pour comparer avec la solution.
:::

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/situations/retrouver-un-commit-perdu.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/retrouver-un-commit-perdu.sh), exécuté avec Git 2.50 le 5 octobre 2026. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
