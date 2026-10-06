---
title: Travailler sur le même projet depuis deux machines
description: Le soir, à la maison, le travail de l'après-midi n'est pas là. Ce que Git synchronise et ce qu'il ne synchronise jamais, et la routine de deux commandes qui évite la mauvaise surprise.
level: debutant
risk: aucun
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
---

## Symptôme

Au bureau, tu as avancé : un commit sur une branche neuve, un brouillon mis de côté, un fichier `.env` configuré.

```console
$ git log --oneline -3
77e300c Ignore le fichier .env
5b5dda8 Ajoute la recherche
d0a0b32 Premier commit

$ git stash list
stash@{0}: On feature/recherche: Brouillon

$ ls -a
.
..
.env
.git
.gitignore
README.md
recherche.js
```

Le soir, à la maison, rien de tout ça :

```console
$ git fetch

$ git branch -a
* main
  remotes/origin/HEAD -> origin/main
  remotes/origin/main
```

## Diagnostic

Git ne synchronise que ce que tu **pousses** : les commits des branches poussées. Tout le reste appartient à la machine où il a été fait. Les commits non poussés, les stashes, les fichiers ignorés comme `.env`, la configuration globale, le reflog : aucun ne voyage. Ce n'est pas un oubli de Git, c'est son modèle : chaque poste a son dépôt complet, et le serveur ne reçoit que ce qu'on lui envoie.

## Solution

**La routine en partant : vérifier ce qui n'existe que sur ce poste, puis pousser.** Trois commandes, dans cet ordre.

```console
$ git status --short --branch
## feature/recherche

$ git log --branches --not --remotes --oneline
77e300c Ignore le fichier .env
5b5dda8 Ajoute la recherche
```

La première dit sur quelle branche tu es et s'il reste des modifications non commitées. La seconde liste les commits qui ne sont **sur aucun serveur** : ceux-là seraient invisibles ailleurs.

```console
$ git push -u origin feature/recherche
To github.com:equipe/projet.git
 * [new branch]      feature/recherche -> feature/recherche
branch 'feature/recherche' set up to track 'origin/feature/recherche'.

$ git log --branches --not --remotes --oneline
```

Plus rien : tout est sur le serveur. Reste le stash, qui ne partira pas : vois « Pièges ».

**La routine en arrivant : récupérer, puis se placer.**

```console
$ git fetch --prune
From github.com:equipe/projet
 * [new branch]      feature/recherche -> origin/feature/recherche

$ git switch feature/recherche
Switched to a new branch 'feature/recherche'
branch 'feature/recherche' set up to track 'origin/feature/recherche'.

$ git log --oneline -3
77e300c Ignore le fichier .env
5b5dda8 Ajoute la recherche
d0a0b32 Premier commit

$ ls -a
.
..
.git
.gitignore
README.md
recherche.js

$ git stash list
```

Les commits sont là. Le `.env` et le stash, non.

**Ce qui ne voyage pas non plus : la configuration de Git.** Un réglage fait sur un poste n'existe pas sur l'autre :

```console
$ git config --global pull.rebase true
```

```console
$ git config --global --get pull.rebase
```

La première commande a été lancée au bureau, la seconde à la maison, qui ne répond rien.

## Pourquoi ça marche

Un dépôt Git, c'est des commits et des **noms** qui les désignent, les branches. `git push` envoie au serveur les commits atteignables depuis la branche poussée, et rien d'autre. Un stash est un commit rangé sous un nom local, `refs/stash`, que `push` ne regarde jamais. Un fichier ignoré est, par définition, hors de Git. La configuration vit dans `.git/config` pour le dépôt et dans `~/.gitconfig` pour la machine : deux fichiers qui ne sont jamais poussés. `git log --branches --not --remotes` demande précisément « les commits de mes branches qui ne sont dans aucune branche distante » : la liste de ce qui serait perdu si ce disque mourait.

## Pièges

- **Le stash ne voyage pas.** Pour emporter un travail en cours, commite-le sur ta branche avec un message franc, `wip: filtre en cours`, pousse, et retouche le commit plus tard. Sur une branche à toi, c'est sans conséquence.
- **Les fichiers d'environnement** se recréent sur chaque poste, à partir d'un `.env.example` versionné. Ne les pousse jamais pour « synchroniser » : ce sont des secrets. Le README du projet doit dire ce qu'il faut installer et créer sur une machine neuve.
- **Deux postes sur la même branche sans `pull`** avant de commiter : les deux divergent, et le second push est refusé. Voir [Mon push est refusé, « rejected », « fetch first »](/situations/quotidien/push-refuse-fetch-first/).
- **La configuration à refaire** : identité, `fetch.prune`, `pull.rebase`, `push.autoSetupRemote`, alias. Tiens la liste quelque part, ou versionne ton `.gitconfig` dans un dépôt de « dotfiles ».
- **Le reflog aussi est local** : un commit perdu se retrouve seulement sur le poste où il a été fait. [Retrouver un commit perdu](/situations/reparer/retrouver-un-commit-perdu/).

## Voir aussi

- [Deux comptes GitHub sur le même poste](/situations/avec-les-autres/deux-comptes-github-sur-un-poste/)
- [Mettre mon travail en cours de côté pour changer de branche](/situations/quotidien/mettre-son-travail-de-cote/)
- [Premier push d'une branche, « has no upstream branch »](/situations/quotidien/premier-push-no-upstream/)

:::note[Essaie-le toi-même]
Le script de cette page sait fabriquer la panne sur ton poste. Depuis un clone du [dépôt du site](https://github.com/Hatimou-Nabina/git-en-situation), dans Git Bash sous Windows :

```bash
EXERCICE=1 bash scripts/situations/travailler-depuis-deux-machines.sh
```

Il s'arrête juste après le symptôme, te dit dans quel dossier aller et quoi faire. Répare, puis relance sans `EXERCICE=1` pour comparer avec la solution.
:::

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/situations/travailler-depuis-deux-machines.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/travailler-depuis-deux-machines.sh), exécuté avec Git 2.50 le 6 octobre 2026, avec deux clones et deux configurations globales distinctes pour jouer les deux postes. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
