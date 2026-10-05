---
title: Fast-forward, fusion, rebase
description: Trois façons de réunir deux lignes de travail. Le fast-forward déplace un marque-page, la fusion crée un commit à deux parents, le rebase recopie des commits. Ce que chacune laisse dans l'historique, et quand choisir laquelle.
level: intermediaire
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
sidebar:
  order: 4
---

## L'idée

Deux branches, et l'on veut que l'une contienne le travail de l'autre. Git a trois réponses, et le bon choix dépend d'une seule question : **les deux ont-elles avancé depuis qu'elles se sont séparées ?**

- Si une seule a avancé, il n'y a rien à réunir : Git déplace le marque-page de l'autre jusqu'au bout. C'est le **fast-forward**.
- Si les deux ont avancé, soit on crée un commit qui a les deux pour parents, la **fusion**, soit on recopie les commits de l'une par-dessus l'autre, le **rebase**.

## Voir par soi-même

**Cas 1 : `main` n'a pas bougé depuis la création de la branche.**

```console
$ git log --oneline --graph --all
* 56c300b Ajoute a
* d0a0b32 Premier commit

$ git merge feature/a
Updating d0a0b32..56c300b
Fast-forward
 a.txt | 1 +
 1 file changed, 1 insertion(+)
 create mode 100644 a.txt

$ git log --oneline --graph --all
* 56c300b Ajoute a
* d0a0b32 Premier commit
```

Aucun commit créé. `main` était sur `d0a0b32`, elle est maintenant sur `56c300b`, et l'historique est exactement le même qu'avant.

**Cas 2 : les deux ont avancé.** Git retrouve d'abord leur dernier point commun :

```console
$ git log --oneline --graph --all
* ec93f91 Ajoute b
| * fe06073 Ajoute c
|/
* 56c300b Ajoute a
* d0a0b32 Premier commit

$ git merge-base main feature/b
56c300b2b7d2a2b596607ce7c6454b0b731de9ce
```

**La fusion** crée un commit à deux parents. Les deux lignes restent visibles :

```console
$ git merge feature/b
Merge made by the 'ort' strategy.
 b.txt | 1 +
 1 file changed, 1 insertion(+)
 create mode 100644 b.txt

$ git log --oneline --graph --all
*   753cba5 Merge branch 'feature/b'
|\
| * ec93f91 Ajoute b
* | fe06073 Ajoute c
|/
* 56c300b Ajoute a
* d0a0b32 Premier commit

$ git log --format='%h  parents: %p  %s' -1
753cba5  parents: fe06073 ec93f91  Merge branch 'feature/b'
```

**Le rebase**, sur le même état de départ, recopie les commits de la branche par-dessus `main`. `ec93f91` devient `71f6422` : même contenu, autre parent, autre commit. Ensuite, `main` peut avancer en fast-forward :

```console
$ git switch feature/b
Switched to branch 'feature/b'

$ git rebase main
Rebasing (1/1)Successfully rebased and updated refs/heads/feature/b.

$ git log --oneline --graph --all
* 71f6422 Ajoute b
* fe06073 Ajoute c
* 56c300b Ajoute a
* d0a0b32 Premier commit

$ git switch main
Your branch is ahead of 'origin/main' by 2 commits.
  (use "git push" to publish your local commits)
Switched to branch 'main'

$ git merge feature/b
Updating fe06073..71f6422
Fast-forward
 b.txt | 1 +
 1 file changed, 1 insertion(+)
 create mode 100644 b.txt
```

Une ligne droite, comme si `b` avait été écrit après `c`. C'est faux chronologiquement, et c'est voulu : l'historique raconte un ordre lisible, pas la réalité des horaires.

**Forcer un commit de fusion** même quand le fast-forward est possible, pour garder la trace qu'une branche a existé :

```console
$ git merge --no-ff feature/d
Merge made by the 'ort' strategy.
 d.txt | 1 +
 1 file changed, 1 insertion(+)
 create mode 100644 d.txt

$ git log --oneline --graph -4
*   818ae05 Merge branch 'feature/d'
|\
| * 03f353c Ajoute d
|/
* 71f6422 Ajoute b
* fe06073 Ajoute c
```

## Ce que ça change dans la pratique

- **Sur une branche partagée que tu ne fais que suivre**, comme `main`, tu veux uniquement des fast-forward : `git pull --ff-only`. Si ça échoue, c'est que tu as commité dessus par erreur, et c'est bon à savoir.
- **Sur ta propre branche, avant de demander la relecture**, le rebase sur `main` donne une pull request propre, sans commits de merge parasites. Comme il recopie tes commits, le push suivant est forcé, avec `--force-with-lease`.
- **Quand une branche est partagée**, ou quand l'histoire du croisement compte, la fusion : rien n'est réécrit, personne n'a besoin de forcer.
- **Les trois boutons de GitHub** font exactement ça : « Create a merge commit » est un `merge --no-ff`, « Rebase and merge » un rebase suivi d'un fast-forward, « Squash and merge » fabrique un seul commit neuf avec tout le contenu de la branche.
- **Les conflits sont les mêmes** dans les trois cas, seule la façon de reprendre diffère : `git commit` après une fusion, `git rebase --continue` après un rebase.

## Où ça sert

- [git pull me demande de choisir entre merge et rebase](/situations/quotidien/git-pull-merge-ou-rebase/)
- [Mettre ma branche à jour avec main](/situations/avec-les-autres/mettre-ma-branche-a-jour-avec-main/)
- [Mon push est refusé, « rejected », « fetch first »](/situations/quotidien/push-refuse-fetch-first/)
- [Un conflit pendant un merge ou un rebase](/situations/reparer/resoudre-un-conflit/)
- [Ma branche locale est en retard après une fusion sur GitHub](/situations/avec-les-autres/branche-locale-en-retard-apres-fusion/)
- [Un commit, c'est un instantané](/comprendre/un-commit-est-un-instantane/)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/comprendre/fast-forward-fusion-rebase.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/comprendre/fast-forward-fusion-rebase.sh), exécuté avec Git 2.50 le 5 octobre 2026. La fusion et le rebase sont joués sur deux copies du même état. Seuls les identifiants de commit sont ceux du dépôt d'exemple.
:::
