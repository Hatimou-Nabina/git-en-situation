---
title: Travailler en équipe
description: Branches, pull requests, revue, conventions de commit, protections. Section en construction.
sidebar:
  order: 0
---

:::note[Section en construction]
Les pages de cette section sont en cours d'écriture.
:::

Savoir se servir de Git seul ne suffit pas : la plupart des difficultés arrivent à deux ou plus. Cette section décrit des façons de travailler qui ont fait leurs preuves, en expliquant à chaque fois ce qu'elles évitent. Ce qui est propre à GitHub est signalé comme tel.

Pages prévues :

- **Une branche par changement** : nommer, créer, garder courte, supprimer après fusion.
- **Branche de travail et branche de production** : quand deux branches longues suffisent, et comment les faire avancer.
- **La pull request, de l'ouverture à la fusion** : titre, description, taille, ce que fait chaque bouton de fusion (merge, squash, rebase) et ce que ça change dans l'historique.
- **Relire une pull request** : ce qu'on regarde, comment formuler une remarque, quand approuver.
- **Les commits conventionnels** : `feat`, `fix`, `docs`, `chore`…, à quoi ça sert vraiment, et comment une équipe s'y tient.
- **Tenir un changelog** : pour qui, à quel moment, et ce qu'il contient.
- **Versions et tags** : versionnage sémantique, `git tag`, releases GitHub.
- **Protéger la branche principale** : revue obligatoire, CI verte, interdiction du push forcé.
- **CODEOWNERS, gabarits d'issue et de PR** : les automatismes GitHub qui font gagner du temps à tout le monde.
- **Les secrets ne vont jamais dans le dépôt** : `.env`, `.gitignore`, variables d'environnement, et que faire quand un secret a été poussé.
- **Travailler depuis plusieurs machines** : ce qui se synchronise par Git, ce qui ne se synchronise pas, et comment ne rien oublier.
- **Forker et contribuer à un projet open source** : fork, branche, PR, suivre l'upstream.

Tu veux écrire l'une de ces pages ? Le gabarit est dans le `CONTRIBUTING.md` du dépôt.
