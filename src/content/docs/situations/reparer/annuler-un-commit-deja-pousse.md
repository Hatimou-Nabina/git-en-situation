---
title: Annuler un commit déjà poussé
description: Un commit poussé casse quelque chose. Pourquoi revenir en arrière et forcer est la mauvaise idée, et comment git revert annule proprement, en gardant l'historique intact.
level: intermediaire
risk: aucun
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptôme

Le dernier commit poussé sur `main` casse la production. Il faut l'annuler, vite, sans aggraver les choses.

```console
$ git log --oneline -3
a1f9ab1 Active le nouveau cache
40cf319 Ajoute la page contact
d0a0b32 Premier commit
```

## Diagnostic

Ce commit est sur le serveur, et peut-être déjà chez les collègues. Un historique partagé ne se réécrit pas : on ne retire pas un commit, on en ajoute un qui le **défait**. C'est le rôle de `git revert`. Le commit fautif reste visible, et c'est voulu : on saura toujours ce qui s'est passé, et quand.

## Solution

**Ce qu'il ne faut pas faire** : reculer la branche et pousser. Git refuse, parce que le serveur a un commit que ta branche n'a plus :

```console
$ git reset --hard HEAD~1
HEAD is now at 40cf319 Ajoute la page contact

$ git push
To github.com:equipe/projet.git
 ! [rejected]        main -> main (non-fast-forward)
error: failed to push some refs to 'github.com:equipe/projet.git'
hint: Updates were rejected because the tip of your current branch is behind
hint: its remote counterpart. If you want to integrate the remote changes,
hint: use 'git pull' before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
```

Le forcer avec `--force` passerait, et ferait disparaître le commit chez tout le monde, avec les dégâts qui vont avec chez ceux qui ont déjà travaillé par-dessus.

**Solution : un commit qui annule.**

```console
$ git revert --no-edit HEAD
[main c69579e] Revert "Active le nouveau cache"
 Date: Mon Oct 5 10:00:00 2026 +0000
 1 file changed, 1 deletion(-)
 delete mode 100644 cache.js

$ git log --oneline -3
c69579e Revert "Active le nouveau cache"
a1f9ab1 Active le nouveau cache
40cf319 Ajoute la page contact

$ git ls-files
README.md
contact.html

$ git push
To github.com:equipe/projet.git
   a1f9ab1..c69579e  main -> main
```

Le fichier `cache.js` a disparu, l'historique a grandi d'un commit, le push passe sans forcer.

**Annuler un commit plus ancien** marche pareil : on désigne le commit, pas forcément le dernier.

```console
$ git revert --no-edit HEAD~2
[main 0a929dd] Revert "Ajoute la page contact"
 Date: Mon Oct 5 10:00:00 2026 +0000
 1 file changed, 1 deletion(-)
 delete mode 100644 contact.html

$ git log --oneline -5
0a929dd Revert "Ajoute la page contact"
c69579e Revert "Active le nouveau cache"
a1f9ab1 Active le nouveau cache
40cf319 Ajoute la page contact
d0a0b32 Premier commit

$ git ls-files
README.md
```

## Pourquoi ça marche

Un commit, c'est un instantané du projet, et la différence avec son parent en est le « patch ». `git revert` calcule le patch inverse et l'applique sous forme d'un nouveau commit. Pour le serveur, c'est un push ordinaire : la branche avance, elle ne recule pas, donc pas de *fast-forward* refusé. Chez les collègues, le prochain `git pull` apporte le revert comme n'importe quel commit.

Ce qui est poussé est, par convention, définitif. Cette règle rend tout le reste possible : chacun peut construire sur `main` en sachant que ce qu'il a vu ne disparaîtra pas sous ses pieds.

## Pièges

- **Un commit de fusion** a deux parents : `git revert` demande lequel garder, `-m 1` pour la branche sur laquelle on a fusionné. Sur GitHub, le bouton « Revert » d'une pull request fusionnée fait exactement ça, en ouvrant une PR.
- **Un conflit** peut survenir si des commits postérieurs ont touché les mêmes lignes. Il se résout comme n'importe quel autre, puis `git revert --continue`. Voir [Un conflit pendant un merge ou un rebase](/situations/reparer/resoudre-un-conflit/).
- **Plusieurs commits d'un coup** : `git revert --no-edit HEAD~2..HEAD` les annule du plus récent au plus ancien, un commit d'annulation chacun.
- **Annuler un revert** : `git revert` du commit de revert remet le changement. Pratique quand on annule en urgence et qu'on réapplique une version corrigée plus tard.
- **Sur ta propre branche, pas encore relue**, réécrire reste acceptable : voir [Annuler mon dernier commit, pas encore poussé](/situations/reparer/annuler-mon-dernier-commit/) et `--force-with-lease`. Sur `main`, jamais.

## Voir aussi

- [Annuler mon dernier commit, pas encore poussé](/situations/reparer/annuler-mon-dernier-commit/)
- [J'ai commité sur la mauvaise branche](/situations/reparer/commit-sur-la-mauvaise-branche/)
- [Mon push est refusé, « rejected », « fetch first »](/situations/quotidien/push-refuse-fetch-first/)
- [Travailler en équipe : protéger la branche principale](/equipe/proteger-la-branche-principale/)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/situations/annuler-un-commit-deja-pousse.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/annuler-un-commit-deja-pousse.sh), exécuté avec Git 2.50 le 5 octobre 2026. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
