---
title: Les commandes qui comptent
description: Une fiche par commande, limitée aux formes utiles, avec leurs vraies sorties, qui renvoie aux pages où elle sert. Vingt-neuf fiches, par usage.
sidebar:
  order: 0
---

Git compte plus de 150 commandes. Une vingtaine servent vraiment, et pour chacune, trois à six formes couvrent l'essentiel. Cette section s'en tient là, avec une règle : une fiche existe si au moins deux pages de ce site s'appuient sur la commande, en l'exécutant ou en la recommandant. Pour le reste, `git help <commande>` fait référence, et chaque fiche y renvoie.

Une fiche n'est pas une copie du manuel. Elle répond à trois questions : à quoi sert cette commande, quelles formes valent la peine d'être connues, avec leurs vraies sorties, et dans quelles pages de ce site on la rencontre. Cette dernière liste est calculée depuis le contenu du site : elle est toujours à jour.

- **Voir et se déplacer** : [`git log`](/commandes/log/), [`git diff`](/commandes/diff/), [`git branch`](/commandes/branch/), [`git switch`](/commandes/switch/), et [`git checkout`](/commandes/checkout/), la commande qu'on tape encore, avec ce qui la remplace.
- **Le serveur** : [`git fetch`](/commandes/fetch/), [`git pull`](/commandes/pull/), [`git push`](/commandes/push/), [`git remote`](/commandes/remote/).
- **Le quotidien** : [`git status`](/commandes/status/), [`git add`](/commandes/add/), [`git commit`](/commandes/commit/), [`git stash`](/commandes/stash/), [`git rm`](/commandes/rm/).
- **Réparer** : [`git reset`](/commandes/reset/), [`git restore`](/commandes/restore/), [`git revert`](/commandes/revert/), [`git reflog`](/commandes/reflog/).
- **Réunir** : [`git merge`](/commandes/merge/), [`git rebase`](/commandes/rebase/), [`git cherry-pick`](/commandes/cherry-pick/), [`git tag`](/commandes/tag/).
- **Régler et inspecter** : [`git config`](/commandes/config/), [`git show`](/commandes/show/), [`git ls-files`](/commandes/ls-files/), [`git check-ignore`](/commandes/check-ignore/), [`git cat-file`](/commandes/cat-file/), [`git merge-base`](/commandes/merge-base/).
- **GitHub en ligne de commande** : [`gh`](/commandes/gh/), la seule fiche sans sorties vérifiées, et la seule propre à GitHub.

La section est complète. Pas de fiche pour `blame`, `bisect`, `worktree`, `mv` ou `clean`, qu'aucune page de ce site n'emploie encore : le jour où une situation en aura besoin, la fiche suivra. Une commande te manque ? [Ouvre une issue](https://github.com/Hatimou-Nabina/git-en-situation/issues/new/choose), ou écris la fiche : le gabarit est dans le `CONTRIBUTING.md` du dépôt.
