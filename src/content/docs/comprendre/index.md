---
title: Comprendre Git
description: Le modèle mental de Git en quelques pages courtes, commits, branches, remotes, fusion. Une fois en place, les commandes deviennent prévisibles.
sidebar:
  order: 0
---

Git paraît compliqué parce qu'on apprend ses commandes sans son modèle. Ce modèle tient en peu de choses, et une fois en place, les commandes deviennent prévisibles : on devine ce qu'elles font, et pourquoi elles refusent.

Chaque page suit le même plan : l'idée en quelques phrases, puis « voir par soi-même » avec des commandes réellement exécutées, ce que ça change dans la pratique, et les situations où ça sert.

Dans l'ordre de lecture conseillé :

1. [Un commit, c'est un instantané](/comprendre/un-commit-est-un-instantane/) : ce que contient un commit, pourquoi il a un identifiant, pourquoi on ne le modifie jamais.
2. [Une branche, c'est un marque-page](/comprendre/une-branche-est-un-marque-page/) : un fichier de quarante et un caractères, qui avance quand on commite.
3. [Les remotes et les références distantes](/comprendre/remotes-et-references-distantes/) : `origin`, `origin/main`, et pourquoi ce n'est pas la même chose que `main`.
4. [Fast-forward, fusion, rebase](/comprendre/fast-forward-fusion-rebase/) : trois façons de réunir deux lignes de travail, et ce qu'elles laissent dans l'historique.

À venir :

- **HEAD, ou « où je suis »** : la branche courante, et l'état « detached HEAD » qui fait peur pour rien.
- **L'index, l'étape entre ton dossier et le commit** : ce que `git add` fait vraiment.
- **Upstream, la branche que la tienne suit** : `-u`, « ahead », « behind », « gone ».
- **Le reflog, ton filet de sécurité** : pourquoi on perd rarement un commit, et comment le retrouver.
- **Ce que Git supprime, et quand** : objets inaccessibles, nettoyage automatique, délais.
- **Les fichiers de `.git/`** : une visite guidée, pour démystifier.

Tu veux écrire l'une de ces pages ? Le gabarit est dans le `CONTRIBUTING.md` du dépôt.
