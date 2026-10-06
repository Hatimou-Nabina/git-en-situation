---
title: Les commandes qui comptent
description: Une fiche par commande, limitée aux formes utiles, avec leurs vraies sorties, qui renvoie aux pages où elle sert. Huit fiches disponibles, une quinzaine prévues.
sidebar:
  order: 0
---

Git compte plus de 150 commandes. Une vingtaine servent vraiment, et pour chacune, trois à six formes couvrent l'essentiel. Cette section s'en tient là, avec une règle : une fiche existe si au moins deux pages de ce site exécutent la commande. Pour le reste, `git help <commande>` fait référence, et chaque fiche y renvoie.

Une fiche n'est pas une copie du manuel. Elle répond à trois questions : à quoi sert cette commande, quelles formes valent la peine d'être connues, avec leurs vraies sorties, et dans quelles pages de ce site on la rencontre. Cette dernière liste est calculée depuis le contenu du site : elle est toujours à jour.

Disponibles :

- **Voir et se déplacer** : [`git log`](/commandes/log/), [`git diff`](/commandes/diff/), [`git branch`](/commandes/branch/), [`git switch`](/commandes/switch/).
- **Le serveur** : [`git fetch`](/commandes/fetch/), [`git pull`](/commandes/pull/), [`git push`](/commandes/push/), [`git remote`](/commandes/remote/).

À venir, dans cet ordre :

- **Le quotidien** : `status`, `add`, `commit`, `stash`.
- **Réparer** : `reset`, `restore`, `revert`, `reflog`.
- **Réunir** : `merge`, `rebase`, `cherry-pick`, `tag`.
- **Régler et inspecter** : `config`, `show`, `ls-files`, `check-ignore`, et une fiche `gh` pour GitHub en ligne de commande, signalée comme telle.

Tu veux écrire l'une de ces fiches ? Le gabarit est dans le `CONTRIBUTING.md` du dépôt.
