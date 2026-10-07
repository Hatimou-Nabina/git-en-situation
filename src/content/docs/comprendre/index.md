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
5. [Upstream, la branche que la tienne suit](/comprendre/upstream-la-branche-que-la-tienne-suit/) : les deux lignes que `push -u` écrit, et qui disent « ahead », « behind » ou « gone ».
6. [Le reflog, ton filet de sécurité](/comprendre/le-reflog-ton-filet-de-securite/) : pourquoi on perd rarement un commit, comment le retrouver, et ce que le journal ne contient pas.
7. [L'index, l'étape entre ton dossier et le commit](/comprendre/l-index-l-etape-entre-ton-dossier-et-le-commit/) : ce que `git add` fait vraiment, et les deux colonnes de `git status`.
8. [HEAD, ou « où je suis »](/comprendre/head-ou-ou-je-suis/) : la branche courante, l'état « detached HEAD » qui fait peur pour rien, et `HEAD~1` contre `HEAD@{1}`.
9. [Ce que Git supprime, et quand](/comprendre/ce-que-git-supprime-et-quand/) : objets que plus rien n'atteint, nettoyage automatique, délais, et ce que Git ne touche jamais seul.
10. [Les fichiers de `.git/`](/comprendre/les-fichiers-de-git/) : une visite guidée, pour démystifier.

La section est complète. Une idée manque, ou une page te paraît fausse ? [Ouvre une issue](https://github.com/Hatimou-Nabina/git-en-situation/issues/new/choose), ou corrige-la : le gabarit est dans le `CONTRIBUTING.md` du dépôt.
