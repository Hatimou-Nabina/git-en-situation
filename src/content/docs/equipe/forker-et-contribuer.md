---
title: Forker et contribuer à un projet open source
description: Fork, clone, upstream, une branche par contribution, la pull request entre deux dépôts, se mettre à jour pendant la relecture, et garder son fork au niveau du projet. Ce qu'il faut lire avant, et ce qui fait qu'une contribution est acceptée.
level: intermediaire
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
sidebar:
  order: 12
---

## Ce que ça évite

Vouloir corriger une faute dans un projet qu'on utilise, et ne pas savoir comment, puisqu'on n'a pas le droit d'y écrire. Une pull request impossible à fusionner parce que le fork a trois mois de retard. Une seconde contribution qui embarque la première, parce que tout a été fait sur `main`. Et un fork qui dérive jusqu'à ne plus ressembler au projet.

Le fork est une copie du dépôt sur ton compte, où tu as tous les droits. Tu y pousses tes branches, et tu proposes au projet d'origine de les reprendre : c'est la pull request entre deux dépôts. Le projet garde la main, tu n'as besoin d'aucune permission.

## Comment on fait

**0. Avant tout, lire.** Le `CONTRIBUTING.md` du projet dit comment il veut recevoir les contributions ; souvent, une issue d'abord, pour vérifier que le changement est bienvenu. Un projet qui a des issues « good first issue », ou « bonne première contribution » comme ce site, indique par où commencer.

**1. Forker, cloner son fork, et ajouter le projet d'origine sous le nom `upstream`.** Le bouton « Fork » sur GitHub crée la copie. Le clone vient de ta copie, `origin` ; le projet d'origine devient `upstream`, pour lire ce qui s'y passe.

```console
$ git remote -v
origin	github.com:awa/projet.git (fetch)
origin	github.com:awa/projet.git (push)

$ git remote add upstream github.com:equipe/projet.git

$ git remote -v
origin	github.com:awa/projet.git (fetch)
origin	github.com:awa/projet.git (push)
upstream	github.com:equipe/projet.git (fetch)
upstream	github.com:equipe/projet.git (push)

$ git fetch upstream
From github.com:equipe/projet
 * [new branch]      main       -> upstream/main
```

Deux serveurs : `origin`, où tu écris, `upstream`, où tu lis.

**2. Une branche par contribution, partie d'`upstream/main`**, le vrai `main` du projet, pas celui de ton fork, qui peut être en retard. La branche est poussée sur ton fork.

```console
$ git switch -c fix/typo-readme upstream/main
branch 'fix/typo-readme' set up to track 'upstream/main'.
Switched to a new branch 'fix/typo-readme'

$ git push -u origin fix/typo-readme
branch 'fix/typo-readme' set up to track 'origin/fix/typo-readme'.
To github.com:awa/projet.git
 * [new branch]      fix/typo-readme -> fix/typo-readme
```

**3. La pull request vers le projet d'origine.** Sur GitHub, le push affiche le lien ; la PR se crée depuis ton fork, base `equipe/projet:main`, compare `awa/projet:fix/typo-readme`. Tout ce qui vaut pour [une pull request](/equipe/la-pull-request/) vaut ici : une intention, une description, des commits lisibles. Laisse cochée la case « Allow edits from maintainers » : le mainteneur peut retoucher ta branche sans un aller-retour.

**4. Pendant la relecture, le projet avance : se mettre à jour.** On rebase sur `upstream/main`, et on pousse sur son fork avec `--force-with-lease`, puisque c'est sa propre branche :

```console
$ git fetch upstream
From github.com:equipe/projet
   8d5eeb7..49b270f  main       -> upstream/main

$ git log --oneline HEAD..upstream/main
49b270f chore: ajoute la licence

$ git rebase upstream/main
Rebasing (1/1)Successfully rebased and updated refs/heads/fix/typo-readme.

$ git push --force-with-lease
To github.com:awa/projet.git
 + 5180fab...d957b79 fix/typo-readme -> fix/typo-readme (forced update)
```

**5. Après la fusion : remettre son fork au niveau du projet.** Le `main` de ton fork n'a pas bougé ; il rattrape `upstream`, puis tu le pousses sur `origin`, et la branche de la contribution disparaît.

```console
$ git switch main
Your branch is up to date with 'origin/main'.
Switched to branch 'main'

$ git pull --ff-only upstream main
From github.com:equipe/projet
 * branch            main       -> FETCH_HEAD
   49b270f..2cc7037  main       -> upstream/main
Updating 8d5eeb7..2cc7037
Fast-forward
 LICENSE   | 1 +
 README.md | 3 +--
 2 files changed, 2 insertions(+), 2 deletions(-)
 create mode 100644 LICENSE

$ git push origin main
To github.com:awa/projet.git
   8d5eeb7..2cc7037  main -> main

$ git branch -d fix/typo-readme
Deleted branch fix/typo-readme (was d957b79).

$ git push origin --delete fix/typo-readme
To github.com:awa/projet.git
 - [deleted]         fix/typo-readme

$ git log --oneline origin/main..upstream/main
```

Rien entre `origin/main` et `upstream/main` : le fork est au niveau. Il n'a qu'un rôle, porter tes branches ; son `main` ne reçoit jamais de commit à toi.

## Sur GitHub

- **`gh repo fork --clone`** fait le fork, le clone, et ajoute `upstream` en une commande.
- **« Sync fork »**, sur la page de ton fork, fait l'étape 5 sans terminal : « Update branch » met le `main` du fork au niveau. Il reste à `git pull` sur ton poste.
- **« Compare across forks »**, sur la page de création d'une PR, quand GitHub ne propose pas le bon dépôt de base.
- **« Allow edits from maintainers »** : coché par défaut, à laisser.
- **Les forks n'ont ni les secrets ni toute la CI du projet** : les workflows d'une PR venant d'un fork tournent avec des droits réduits, sans accès aux secrets. C'est voulu. Une CI qui dépend d'un secret ne passera pas sur ta PR, et ce n'est pas de ta faute.
- **Supprimer le fork après la fusion** est possible : la PR fusionnée garde ses commits sur le projet. Pour contribuer encore, on reforke, ou on garde le fork à jour.

## Pièges

- **Travailler sur le `main` du fork.** La deuxième PR contient la première ; la mise à jour du fork devient un merge. `main` reste la copie d'`upstream`, point.
- **Partir du `main` du fork au lieu d'`upstream/main`** : la branche naît déjà en retard.
- **Mettre à jour par `git pull`**, donc par merge, pendant la relecture : des commits de merge dans la PR, que les mainteneurs demanderont de nettoyer. Rebase, puis `--force-with-lease`.
- **Une PR énorme.** La première contribution est petite ; elle sert d'abord à apprendre comment le projet travaille.
- **Ne pas lire le `CONTRIBUTING.md`** : conventions de commit, tests à lancer, DCO ou CLA à signer, langue. Une PR qui ne les suit pas attend.
- **Forcer sans `--with-lease`**, et écraser le commit qu'un mainteneur a poussé sur ta branche grâce à « Allow edits from maintainers ».

## Voir aussi

- [La pull request, de l'ouverture à la fusion](/equipe/la-pull-request/)
- [Une branche par changement](/equipe/une-branche-par-changement/)
- [Mettre ma branche à jour avec main](/situations/avec-les-autres/mettre-ma-branche-a-jour-avec-main/)
- [Les remotes et les références distantes](/comprendre/remotes-et-references-distantes/)
- Contribuer à ce site : [CONTRIBUTING.md](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/CONTRIBUTING.md)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/equipe/forker-et-contribuer.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/equipe/forker-et-contribuer.sh), exécuté avec Git 2.50 le 5 octobre 2026. Le fork y est un second dépôt nu, `github.com:awa/projet.git`, et la fusion « par GitHub » est jouée par Bakary, mainteneur du projet d'origine. Seuls les adresses des serveurs et les identifiants de commit sont ceux du dépôt d'exemple.
:::
