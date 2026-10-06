---
title: Mettre mon travail en cours de côté pour changer de branche
description: Git refuse de changer de branche, « Your local changes would be overwritten by checkout ». Comment mettre son travail de côté avec git stash, le retrouver intact, et ce qui se passe en dessous.
level: debutant
risk: aucun
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
---

## Symptôme

Tu es au milieu d'un développement, rien n'est fini, et on te demande de corriger un bug urgent sur `main` :

```console
$ git status --short
 M recherche.js
?? brouillon.txt

$ git switch main
error: Your local changes to the following files would be overwritten by checkout:
	recherche.js
Please commit your changes or stash them before you switch branches.
Aborting
```

## Diagnostic

Changer de branche, c'est remplacer les fichiers du dossier par ceux de l'autre branche. `recherche.js` n'existe pas sur `main` : y basculer effacerait tes modifications. Git refuse de perdre du travail qui n'est nulle part ailleurs. Il te propose deux issues : commiter, ou mettre de côté.

Commiter un travail à moitié fait est possible, mais tu te retrouves avec un commit « WIP » à nettoyer plus tard. Mettre de côté est fait pour ça.

## Solution

**1. Mets ton travail de côté.** `-u` emporte aussi les fichiers nouveaux, pas encore suivis ; le message t'aidera à t'y retrouver.

```console
$ git stash push -u -m "Filtre de recherche en cours"
Saved working directory and index state On feature/recherche: Filtre de recherche en cours

$ git status --short
```

Le dossier est propre, comme au dernier commit.

**2. Change de branche, fais le correctif, commite-le.**

```console
$ git switch main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.
```

**3. Reviens et récupère ton travail.**

```console
$ git switch feature/recherche
Switched to branch 'feature/recherche'

$ git stash list
stash@{0}: On feature/recherche: Filtre de recherche en cours

$ git stash pop
On branch feature/recherche
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   recherche.js

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	brouillon.txt

no changes added to commit (use "git add" and/or "git commit -a")
Dropped refs/stash@{0} (1908be8eec168ebcfe850c21f2d2f57f09b3e52e)

$ git status --short
 M recherche.js
?? brouillon.txt
```

Tout est revenu : la modification, et le fichier nouveau.

## Pourquoi ça marche

Un stash est un commit comme un autre, mais caché : il n'est sur aucune branche, Git le range sous une référence spéciale, `refs/stash`, en pile. `git stash push` crée ce commit avec l'état de ton dossier, puis remet le dossier au dernier commit de la branche. `git stash pop` réapplique ce commit et le retire de la pile ; `git stash apply` fait pareil sans le retirer.

Comme c'est un commit, un stash se garde indéfiniment, se liste, se montre avec `git stash show -p`, et peut même être réappliqué sur une autre branche que celle d'origine.

## Pièges

- **Sans `-u`, les fichiers nouveaux restent dans le dossier.** Ils ne gênent pas le changement de branche, mais ils te suivent partout, et tu peux les commiter par erreur sur `main`.
- **Parfois, `git switch` passe sans rien dire** : si tes modifications ne touchent pas de fichier qui diffère entre les deux branches, Git les emporte avec toi. C'est voulu, mais ça surprend : tu te retrouves avec ton travail en cours sur `main`. Dans le doute, stash.
- **Un conflit au `pop`** laisse le stash dans la pile : corrige les fichiers, puis `git stash drop` quand c'est bon.
- **Les stashes s'accumulent.** `git stash list` de temps en temps ; sans message, `stash@{3}: WIP on main: a1b2c3d …` ne dit rien un mois plus tard.
- **L'alternative pour un travail long** : un second dossier de travail sur la même copie du dépôt, avec `git worktree add`. Plus de bascule, chaque branche a son dossier. Fiche à venir.

## Voir aussi

- [Voir ce qui a changé entre ma branche et main](/situations/quotidien/voir-ce-qui-a-change/)
- Comprendre : *L'index, l'étape entre ton dossier et le commit* (à venir)

:::note[Essaie-le toi-même]
Le script de cette page sait fabriquer la panne sur ton poste. Depuis un clone du [dépôt du site](https://github.com/Hatimou-Nabina/git-en-situation), dans Git Bash sous Windows :

```bash
EXERCICE=1 bash scripts/situations/mettre-son-travail-de-cote.sh
```

Il s'arrête juste après le symptôme, te dit dans quel dossier aller et quoi faire. Répare, puis relance sans `EXERCICE=1` pour comparer avec la solution.
:::

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/situations/mettre-son-travail-de-cote.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/mettre-son-travail-de-cote.sh), exécuté avec Git 2.50 le 6 octobre 2026. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
