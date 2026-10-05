---
title: Une branche par changement
description: Nommer, créer, garder courte, supprimer après fusion. Pourquoi un changement par branche rend les pull requests lisibles et les conflits rares, et un garde-fou local contre le commit sur main par habitude.
level: debutant
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
sidebar:
  order: 3
---

## Ce que ça évite

Une correction urgente coincée derrière une fonctionnalité à moitié finie, parce que les deux sont sur la même branche. Une pull request qui mélange trois sujets, et que personne ne relit vraiment. Des branches `test`, `fix2` ou `awa` dont plus personne ne sait ce qu'elles contiennent. Et le commit fait sur `main` par habitude, qu'il faut ensuite déplacer.

La règle tient en une phrase : une branche porte un changement, et un seul. Elle naît d'un `main` à jour, vit quelques jours, part en pull request, et disparaît à la fusion.

## Comment on fait

**1. Partir d'un `main` à jour, et nommer la branche par ce qu'elle change.** Le nom suit le type du changement, comme les [commits conventionnels](/equipe/commits-conventionnels/) : `fix/`, `feature/`, `docs/`, puis le sujet.

```console
$ git switch main
Your branch is up to date with 'origin/main'.
Already on 'main'

$ git pull --ff-only
Already up to date.

$ git switch -c fix/connexion-timeout
Switched to a new branch 'fix/connexion-timeout'
```

**2. Des commits qui ne parlent que de ça.** Si un commit n'a rien à voir avec le nom de la branche, il est sur la mauvaise branche.

```console
$ git log --oneline main..HEAD
ea67720 test(connexion): couvre le timeout
0ce76f1 fix(connexion): porte le timeout a 30 s

$ git diff --stat main...HEAD
 connexion.js      | 1 +
 connexion.test.js | 1 +
 2 files changed, 2 insertions(+)
```

**3. Un second changement en cours, c'est une seconde branche**, qui part elle aussi de `main`, pas de la première.

```console
$ git switch main
Your branch is up to date with 'origin/main'.
Switched to branch 'main'

$ git switch -c feature/export-csv
Switched to a new branch 'feature/export-csv'

$ git branch
* feature/export-csv
  fix/connexion-timeout
  main
```

Pour s'y retrouver quand elles s'accumulent, la date et le dernier commit de chacune :

```console
$ git for-each-ref --sort=committerdate --format='%(refname:short)  %(committerdate:short)  %(subject)' refs/heads/
feature/export-csv  2026-10-05  feat(export): ajoute l export CSV
fix/connexion-timeout  2026-10-05  test(connexion): couvre le timeout
main  2026-10-05  Premier commit
```

**4. Garder la branche courte.** Plus elle vit, plus `main` avance sans elle, et plus la fusion sera douloureuse. Deux commandes disent où on en est : ce que `main` a reçu entre-temps, et ce que la branche apporte.

```console
$ git fetch
From github.com:equipe/projet
   d0a0b32..8c3c408  main       -> origin/main

$ git log --oneline HEAD..origin/main
8c3c408 docs: complete le README

$ git log --oneline origin/main..HEAD
9e8bc55 feat(export): ajoute l export CSV
```

Un commit de retard, ça se rattrape sans douleur : [Mettre ma branche à jour avec main](/situations/avec-les-autres/mettre-ma-branche-a-jour-avec-main/). Cinquante, c'est le signe que la branche aurait dû être découpée.

**5. Un garde-fou local contre le commit sur `main` par habitude.** Cinq lignes dans `.git/hooks/pre-commit` :

```console
$ cat .git/hooks/pre-commit
#!/usr/bin/env bash
# Refuse un commit fait directement sur main.
if [ "$(git symbolic-ref --short HEAD 2>/dev/null)" = "main" ]; then
  echo "Pas de commit direct sur main : cree une branche, git switch -c type/sujet" >&2
  exit 1
fi

$ git switch main
Your branch is behind 'origin/main' by 1 commit, and can be fast-forwarded.
  (use "git pull" to update your local branch)
Switched to branch 'main'

$ git commit -m "fix: corrige un detail"
Pas de commit direct sur main : cree une branche, git switch -c type/sujet

$ git switch -c fix/detail
Switched to a new branch 'fix/detail'

$ git commit -m "fix: corrige un detail"
[fix/detail dddeb30] fix: corrige un detail
 1 file changed, 1 insertion(+)
 create mode 100644 oups.js
```

Les fichiers préparés pour le commit suivent dans la nouvelle branche : rien n'est perdu, le commit se fait au bon endroit. Un hook n'est pas versionné, chacun l'installe ; la vraie protection est [sur le serveur](/equipe/proteger-la-branche-principale/).

**6. Après la fusion, la branche disparaît.** Sur le serveur, GitHub la supprime ; sur ton poste, `git branch -d` ne supprime qu'une branche fusionnée, et refuse les autres.

```console
$ git switch main
Your branch is behind 'origin/main' by 1 commit, and can be fast-forwarded.
  (use "git pull" to update your local branch)
Switched to branch 'main'

$ git pull --ff-only
From github.com:equipe/projet
   8c3c408..4dcd567  main       -> origin/main
Updating d0a0b32..4dcd567
Fast-forward
 README.md         | 1 +
 connexion.js      | 1 +
 connexion.test.js | 1 +
 3 files changed, 3 insertions(+)
 create mode 100644 connexion.js
 create mode 100644 connexion.test.js

$ git fetch --prune
From github.com:equipe/projet
 - [deleted]         (none)     -> origin/fix/connexion-timeout

$ git branch -d fix/connexion-timeout
Deleted branch fix/connexion-timeout (was ea67720).

$ git branch -d feature/export-csv
error: the branch 'feature/export-csv' is not fully merged
hint: If you are sure you want to delete it, run 'git branch -D feature/export-csv'
hint: Disable this message with "git config set advice.forceDeleteBranch false"
```

## Sur GitHub

- **Une branche depuis une issue** : dans la colonne de droite d'une issue, « Create a branch » crée la branche nommée d'après l'issue et la relie ; la PR fermera l'issue à la fusion. Depuis le terminal : `gh issue develop 12 --checkout`.
- **Le bandeau « Compare & pull request »** apparaît sur la page du dépôt juste après le push d'une branche : c'est le chemin le plus court vers la PR.
- **« Automatically delete head branches »** (Settings → General) supprime la branche à la fusion. Il ne reste que le `fetch --prune` de ton côté.
- **L'onglet Branches** montre pour chacune son avance et son retard sur `main`, et la PR associée : c'est là qu'on repère celles qui traînent.
- **La protection de `main`** rend la règle obligatoire plutôt que volontaire : [Protéger la branche principale](/equipe/proteger-la-branche-principale/).

## Pièges

- **La branche fourre-tout**, où l'on commite tout ce qu'on fait dans la semaine. Elle devient une PR illisible, puis un conflit géant. Une intention, une branche.
- **La branche qui part d'une autre branche** sans le dire : sa PR affiche aussi les commits de la première. Si c'est voulu, la PR le dit et vise l'autre branche comme base.
- **La branche qui vit trois semaines.** Si le changement est gros, découper : une première PR qui prépare, une seconde qui livre, chacune fusionnée vite.
- **Nommer par son prénom ou par la date** : `awa-2`, `lundi`. Dans un mois, personne ne saura ce que c'était, pas même toi.
- **Le commit déjà fait sur `main`** : [J'ai commité sur la mauvaise branche](/situations/reparer/commit-sur-la-mauvaise-branche/) le déplace en trois commandes.
- **Supprimer avec `-D` pour faire taire l'erreur** : `-d` refuse pour une raison. Vérifier d'abord ce que la branche contient : [Supprimer une vieille branche sans rien perdre](/situations/quotidien/supprimer-une-vieille-branche-sans-rien-perdre/).

## Voir aussi

- [La pull request, de l'ouverture à la fusion](/equipe/la-pull-request/)
- [Les commits conventionnels](/equipe/commits-conventionnels/)
- [Mettre mon travail en cours de côté pour changer de branche](/situations/quotidien/mettre-son-travail-de-cote/)
- [Une branche, c'est un marque-page](/comprendre/une-branche-est-un-marque-page/)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/equipe/une-branche-par-changement.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/equipe/une-branche-par-changement.sh), exécuté avec Git 2.50 le 5 octobre 2026, hook compris. La fusion « par GitHub » y est jouée par un second poste. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
