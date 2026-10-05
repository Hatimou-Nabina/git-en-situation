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

À venir :

- **Relire une pull request** : ce qu'on regarde, comment formuler une remarque, quand approuver.
- **Branche de travail et branche de production** : quand deux branches longues suffisent, et comment les faire avancer.
- **Tenir un changelog** : pour qui, à quel moment, et ce qu'il contient.
- **Versions et tags** : versionnage sémantique, `git tag`, releases GitHub.
- **CODEOWNERS, gabarits d'issue et de PR** : les automatismes GitHub qui font gagner du temps à tout le monde.
- **Une CI qui vérifie ce que les postes ne voient pas** : fins de ligne, permissions, tests sur Linux.
- **Forker et contribuer à un projet open source** : fork, branche, PR, suivre l'upstream.

Tu veux écrire l'une de ces pages ? Le gabarit est dans le `CONTRIBUTING.md` du dépôt.
