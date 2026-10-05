---
title: Je suis en « detached HEAD »
description: git status annonce « HEAD detached at … ». Ce que ça veut dire, pourquoi ce n'est pas une erreur, et comment ne pas perdre un commit fait dans cet état.
level: debutant
risk: reversible
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptôme

Tu voulais regarder la version 1.0 du projet, marquée par un tag :

```console
$ git switch v1.0
fatal: a branch is expected, got tag 'v1.0'
hint: If you want to detach HEAD at the commit, try again with the --detach option.

$ git switch --detach v1.0
HEAD is now at ea6d02e Version 1

$ git status
HEAD detached at v1.0
nothing to commit, working tree clean

$ git branch
* (HEAD detached at v1.0)
  main
```

Le mot « detached » inquiète. Rien n'est cassé.

## Diagnostic

`HEAD`, c'est « là où je suis ». D'habitude, HEAD désigne une branche, et la branche désigne un commit. Là, tu as demandé à te placer sur un commit précis, celui du tag : HEAD le désigne **directement**, sans branche entre les deux. C'est l'état normal pour regarder une ancienne version, et Git te l'a même proposé avec `--detach`.

Le seul risque : un commit fait dans cet état n'est sur aucune branche. Personne ne s'en souviendra, sauf le reflog.

## Solution

**Tu regardes seulement.** Quand tu as fini, retourne sur une branche : `git switch main`. Rien d'autre à faire.

**Tu as commité sans y penser.** `git status` le signale discrètement, « detached from » au lieu de « detached at » :

```console
$ git log --oneline -1
36e3dd0 Corrige la version 1

$ git status
HEAD detached from v1.0
nothing to commit, working tree clean
```

Donne une branche à ce commit, et tout rentre dans l'ordre :

```console
$ git switch -c hotfix/v1
Switched to a new branch 'hotfix/v1'

$ git status
On branch hotfix/v1
nothing to commit, working tree clean
```

**Tu es déjà reparti sur une branche.** Git te prévient au moment de partir, et te donne l'identifiant du commit laissé derrière :

```console
$ git switch main
Your branch is up to date with 'origin/main'.
Warning: you are leaving 1 commit behind, not connected to
any of your branches:

  45dba92 Autre correction de la version 1

If you want to keep it by creating a new branch, this may be a good time
to do so with:

 git branch <new-branch-name> 45dba92

Switched to branch 'main'
```

Fais ce qu'il dit. `HEAD@{1}`, « là où j'étais juste avant », désigne le même commit que `45dba92` :

```console
$ git branch hotfix/v1-bis HEAD@{1}

$ git log --oneline -1 hotfix/v1-bis
45dba92 Autre correction de la version 1
```

## Pourquoi ça marche

Dans `.git/HEAD`, il y a soit un nom de branche, soit un identifiant de commit. Avec un nom de branche, chaque nouveau commit fait avancer la branche : c'est elle qui retient où tu en es. Avec un identifiant, HEAD avance seul ; dès que tu le déplaces ailleurs, plus aucun nom ne mène à ce commit. Il reste dans le dépôt, retrouvable par le reflog pendant un temps, mais invisible dans `git log` et dans les branches.

`git switch -c` crée une branche sur le commit courant et y rattache HEAD : le commit a de nouveau un nom.

## Pièges

- **On y entre sans le vouloir** avec `git checkout <identifiant>`, `git checkout origin/main`, ou `git switch origin/feature/x` avec le préfixe `origin/`. Pour travailler sur la branche d'un collègue, utilise son nom court : [Après un clone, je ne vois pas les branches des autres](/situations/quotidien/branches-invisibles-apres-clone/).
- **La CI est toujours en detached HEAD.** GitHub Actions et les autres récupèrent un commit précis, pas une branche. C'est normal, et sans importance tant qu'on ne commite pas depuis la CI.
- **Le long message « You are in 'detached HEAD' state »** de `git checkout` dit la même chose que cette page, en anglais et en dix lignes. `git switch --detach` est plus sobre.
- **Un commit laissé derrière et oublié** reste récupérable un temps : [Retrouver un commit perdu](/situations/reparer/retrouver-un-commit-perdu/).

## Voir aussi

- [Retrouver un commit perdu](/situations/reparer/retrouver-un-commit-perdu/)
- [Après un clone, je ne vois pas les branches des autres](/situations/quotidien/branches-invisibles-apres-clone/)
- Comprendre : *HEAD, ou « où je suis »* (à venir)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/situations/detached-head.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/detached-head.sh), exécuté avec Git 2.50 le 5 octobre 2026. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
