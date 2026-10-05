---
title: Travailler en équipe
description: Branches, pull requests, revue, conventions de commit, protections. Des façons de travailler qui ont fait leurs preuves, en expliquant à chaque fois ce qu'elles évitent.
sidebar:
  order: 0
---

Savoir se servir de Git seul ne suffit pas : la plupart des difficultés arrivent à deux ou plus. Cette section décrit des façons de travailler qui ont fait leurs preuves, en expliquant à chaque fois **ce qu'elles évitent**. Ce qui est propre à GitHub est signalé comme tel.

Chaque page suit le même plan : ce que ça évite, comment on fait, avec des commandes réellement exécutées, ce qui est propre à GitHub, les pièges.

Disponibles :

1. [La pull request, de l'ouverture à la fusion](/equipe/la-pull-request/) : la branche, les commits, la relecture, la fusion, le nettoyage, et ce que font les trois boutons de GitHub.
2. [Les commits conventionnels](/equipe/commits-conventionnels/) : `type(scope): sujet`, les types, le corps, le pied de page, et un garde-fou en six lignes.
3. [Une branche par changement](/equipe/une-branche-par-changement/) : nommer, créer, garder courte, supprimer après fusion, et un garde-fou contre le commit sur `main` par habitude.
4. [Protéger la branche principale](/equipe/proteger-la-branche-principale/) : ce qu'un push forcé fait à `main` sans protection, les deux réglages que tout serveur Git connaît, la pull request rendue obligatoire.
5. [Les secrets ne vont jamais dans le dépôt](/equipe/secrets-jamais-dans-le-depot/) : `.env` ignoré dès le premier commit, `.env.example` versionné, l'application qui lit l'environnement, un garde-fou en dix lignes, et ce que GitHub bloque.
6. [Relire une pull request](/equipe/relire-une-pull-request/) : dans quel ordre regarder, la branche sur ton poste, vérifier plutôt que croire, formuler la remarque, ne relire que ce qui a changé, quand approuver.
7. [Branche de travail et branche de production](/equipe/branche-de-travail-et-de-production/) : `main` et `prod`, la mise en production en avance rapide, le correctif urgent reporté tout de suite, et savoir ce qui est où.
8. [Tenir un changelog](/equipe/tenir-un-changelog/) : la section « Non publié » que chaque PR alimente, le conflit qui revient et `merge=union` qui l'évite, le brouillon depuis les commits, la version.
9. [Versions et tags](/equipe/versions-et-tags/) : le versionnage sémantique, le tag annoté, le push qui ne l'emporte pas tout seul, `describe`, la version qui contient un correctif, la release GitHub.
10. [CODEOWNERS, gabarits d'issue et de PR](/equipe/codeowners-gabarits-issue-pr/) : qui relit quoi, ce qu'une PR doit dire, ce qu'une issue doit contenir, et les pièges silencieux de chaque fichier.
11. [Une CI qui vérifie ce que les postes ne voient pas](/equipe/ci-ce-que-les-postes-ne-voient-pas/) : le bit d'exécution, la casse des noms, le fichier qui n'existe que sur ton poste, et le script de vérification que la CI lance.
12. [Forker et contribuer à un projet open source](/equipe/forker-et-contribuer/) : fork, `upstream`, une branche par contribution, la PR entre deux dépôts, se mettre à jour, garder son fork au niveau.

La section est complète. Une pratique manque, ou une page te paraît fausse ? [Ouvre une issue](https://github.com/Hatimou-Nabina/git-en-situation/issues/new/choose), ou corrige-la : le gabarit est dans le `CONTRIBUTING.md` du dépôt.
