---
title: Comprendre Git
description: Le modèle mental de Git en quelques pages courtes. Section en construction.
sidebar:
  order: 0
---

:::note[Section en construction]
Les pages de cette section sont en cours d'écriture. Les situations qui s'y rapportent les citent déjà, sans lien, sous la mention « à venir ».
:::

Git paraît compliqué parce qu'on apprend ses commandes sans son modèle. Ce modèle tient en peu de choses, et une fois en place, les commandes deviennent prévisibles.

Pages prévues, dans l'ordre de lecture conseillé :

1. **Un commit, c'est un instantané** : ce que contient un commit, pourquoi il a un identifiant, ce que signifie « parent ».
2. **Une branche, c'est un marque-page** : un simple pointeur vers un commit, qui avance avec toi.
3. **HEAD, ou « où je suis »** : la branche courante, et l'état « detached HEAD » qui fait peur pour rien.
4. **L'index, l'étape entre ton dossier et le commit** : ce que `git add` fait vraiment.
5. **Les remotes et les références distantes** : `origin`, `origin/main`, et pourquoi ce n'est pas la même chose que `main`.
6. **Upstream : la branche que la tienne suit** : `-u`, « ahead », « behind », « gone ».
7. **Fast-forward, fusion, rebase** : trois façons de réunir deux lignes de travail, et ce qu'elles font à l'historique.
8. **Le reflog, ton filet de sécurité** : pourquoi on perd rarement un commit, et comment le retrouver.
9. **Ce que Git supprime, et quand** : objets inaccessibles, garbage collection, délais.
10. **Les fichiers de `.git/`** : une visite guidée, pour démystifier.

Tu veux écrire l'une de ces pages ? Le gabarit est dans le `CONTRIBUTING.md` du dépôt.
