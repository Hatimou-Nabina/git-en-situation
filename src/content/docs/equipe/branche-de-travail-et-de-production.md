---
title: Branche de travail et branche de production
description: Quand deux branches longues suffisent, main pour le travail et prod pour ce qui tourne. Comment les faire avancer, livrer, corriger en urgence sans embarquer ce qui n'est pas prêt, et savoir à tout moment ce qui est où.
level: intermediaire
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
sidebar:
  order: 7
---

## Ce que ça évite

Déployer ce qui n'est pas fini, parce que `main` est la production et qu'une fonctionnalité à moitié prête vient d'y être fusionnée. Un correctif urgent impossible à livrer sans embarquer trois semaines de travail non validé. Et la question « qu'est-ce qui tourne en production, au juste ? », à laquelle personne ne sait répondre sans ouvrir l'outil de déploiement.

Deux branches longues suffisent : `main`, où le travail arrive par pull request et qui est toujours en état de marche, et `prod`, qui ne contient que ce qui est en production. Mettre en production, c'est faire avancer `prod` jusqu'à `main`. Rien de plus.

Ce n'est pas toujours nécessaire. Si chaque fusion sur `main` est déployée automatiquement et que l'équipe est à l'aise avec ça, une seule branche et des tags suffisent. Les deux branches servent quand déployer est une décision : un client valide sur un environnement de test, une mise en production a une date, un retour en arrière doit être simple.

## Comment on fait

**1. Créer `prod` depuis `main`, une fois**, et la protéger comme `main`.

```console
$ git switch -c prod
Switched to a new branch 'prod'

$ git push -u origin prod
branch 'prod' set up to track 'origin/prod'.
To github.com:equipe/projet.git
 * [new branch]      prod -> prod

$ git switch main
Your branch is up to date with 'origin/main'.
Switched to branch 'main'
```

**2. Le travail arrive sur `main`, par pull request ; `prod` ne bouge pas.** Deux PR ont été fusionnées depuis. Ce qui attend la mise en production, c'est ce que `main` a et que `prod` n'a pas :

```console
$ git log --oneline prod..main
c6bf1cd Merge pull request #22 from equipe/feature/export
2e51847 Merge pull request #21 from equipe/feature/recherche
57033b7 feat(export): ajoute l export CSV
b9b596d feat(recherche): ajoute la barre de recherche
```

**3. Mettre en production : `prod` rejoint `main`.** En avance rapide, toujours : `prod` ne contient rien que `main` n'ait pas, donc il n'y a jamais de commit de merge dans ce sens.

```console
$ git switch prod
Your branch is up to date with 'origin/prod'.
Switched to branch 'prod'

$ git merge --ff-only main
Updating d0a0b32..c6bf1cd
Fast-forward
 export.js    | 1 +
 recherche.js | 1 +
 2 files changed, 2 insertions(+)
 create mode 100644 export.js
 create mode 100644 recherche.js

$ git push
To github.com:equipe/projet.git
   d0a0b32..c6bf1cd  prod -> prod

$ git log --oneline prod..main
```

Plus rien en attente. Si `--ff-only` refuse, c'est que `prod` a reçu quelque chose qui n'est pas sur `main` : un correctif qui n'a pas été reporté (étape 5). Ne pas forcer, reporter d'abord.

**4. Un correctif urgent en production, pendant que `main` a déjà avancé.** Une nouvelle PR est sur `main`, pas prête à être livrée. Le correctif part de `prod`, pas de `main`, pour ne pas l'embarquer :

```console
$ git switch prod
Your branch is up to date with 'origin/prod'.
Switched to branch 'prod'

$ git switch -c hotfix/export-vide
Switched to a new branch 'hotfix/export-vide'
```

Un commit, une pull request vers `prod`, et la fusion :

```console
$ git switch prod
Your branch is up to date with 'origin/prod'.
Switched to branch 'prod'

$ git merge --ff-only hotfix/export-vide
Updating c6bf1cd..803c3c3
Fast-forward
 export.js | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

$ git push
To github.com:equipe/projet.git
   c6bf1cd..803c3c3  prod -> prod
```

**5. Reporter le correctif sur `main`, tout de suite.** Sinon la prochaine mise en production refusera de passer, ou l'écrasera si quelqu'un force.

```console
$ git switch main
Your branch is up to date with 'origin/main'.
Switched to branch 'main'

$ git log --oneline main..prod
803c3c3 fix(export): corrige l export d une liste vide

$ git merge prod
Merge made by the 'ort' strategy.
 export.js | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

$ git push
To github.com:equipe/projet.git
   c3c4f41..22f3be6  main -> main

$ git log --oneline main..prod
```

Ce sens-là produit un commit de merge, et c'est normal : `main` avait avancé. Dans un projet où ça gêne, `git cherry-pick 803c3c3` sur `main` recopie le correctif sans merge.

**6. Savoir ce qui est où.** Deux questions, deux commandes : qu'est-ce qui attend la mise en production, et dans quelles branches se trouve ce qui tourne ?

```console
$ git log --oneline prod..main
22f3be6 Merge branch 'prod'
c3c4f41 Merge pull request #23 from equipe/feature/filtres
2dcb9b0 feat(recherche): ajoute les filtres

$ git branch -r --contains origin/prod
  origin/main
  origin/prod
```

Les filtres attendent ; le correctif est partout. `main..prod` doit être vide hors correctif en cours : c'est le contrôle à faire avant chaque mise en production.

## Sur GitHub

- **La branche par défaut reste `main`** : c'est là que les PR s'ouvrent et que les contributeurs arrivent. `prod` est protégée comme `main`, avec la PR obligatoire : [Protéger la branche principale](/equipe/proteger-la-branche-principale/).
- **La mise en production est une PR** de `main` vers `prod` (base `prod`, compare `main`). Son onglet « Files changed » est la liste de ce qui part, sa description une note de version.
- **GitHub ne fusionne pas en avance rapide** : le bouton de fusion crée un commit de merge sur `prod`, même quand un `--ff-only` passerait. Ça marche aussi, à condition de vérifier `main..prod` avec `--no-merges`. Pour garder `prod` strictement en avance rapide, la mise en production se fait depuis le terminal comme ci-dessus, par quelqu'un que la règle de `prod` autorise.
- **Un correctif est une PR vers `prod`**, puis une seconde PR de `prod` vers `main`, ou un cherry-pick.
- **Les déploiements suivent les branches** : un workflow `on: push: branches: [main]` déploie l'environnement de test, un autre sur `prod` déploie la production. Les « environments » (Settings → Environments) peuvent exiger une approbation avant celui de production.
- **La vue Compare**, `github.com/<dépôt>/compare/prod...main`, répond à « qu'est-ce qui attend ? » sans terminal.

## Pièges

- **Commiter directement sur `prod`**, « juste pour ce correctif ». La protection de branche existe pour ça.
- **Oublier de reporter le correctif** sur `main`. À la mise en production suivante, `--ff-only` refuse, ou pire, le correctif disparaît si quelqu'un force. Le report fait partie du correctif, pas d'une tâche à part.
- **Laisser `prod` traîner trois mois derrière `main`.** Chaque mise en production devient un événement ; des petites, souvent, valent mieux.
- **Tout le git-flow**, `develop`, `release/*`, `hotfix/*`, `support/*`, quand deux branches suffisent. Chaque branche longue de plus est une question « où est ce commit ? » de plus.
- **Sans tags**, impossible de dire quelle version tourne quand `prod` a avancé trois fois dans la semaine : [Versions et tags](/equipe/versions-et-tags/).
- **Deux rôles, un seul nom.** `main` pour le travail ici, `main` pour la production dans le dépôt d'à côté : dans une même équipe, un nom, un rôle, partout.

## Voir aussi

- [Une branche par changement](/equipe/une-branche-par-changement/)
- [Protéger la branche principale](/equipe/proteger-la-branche-principale/)
- [Fast-forward, fusion, rebase](/comprendre/fast-forward-fusion-rebase/)
- [Voir ce qui a changé entre ma branche et main](/situations/quotidien/voir-ce-qui-a-change/)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/equipe/branche-de-travail-et-de-production.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/equipe/branche-de-travail-et-de-production.sh), exécuté avec Git 2.50 le 5 octobre 2026. Les pull requests fusionnées sur `main` y sont jouées en local, sans affichage. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
