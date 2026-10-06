---
title: J'ai commité sur la mauvaise branche
description: Le commit est parti sur main au lieu d'une branche de travail, ou sur la branche d'à côté. Comment le déplacer sans rien perdre, tant qu'il n'est pas poussé, et quoi faire s'il l'est déjà.
level: intermediaire
risk: reversible
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptôme

Tu voulais ouvrir une branche pour la recherche. Tu as oublié, et le commit est parti sur `main` :

```console
$ git status
On branch main
Your branch is ahead of 'origin/main' by 1 commit.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean

$ git log --oneline -2
5b5dda8 Ajoute la recherche
d0a0b32 Premier commit
```

« Ahead of 'origin/main' by 1 commit » : le commit n'est pas poussé. Bonne nouvelle, tout se règle en local.

## Diagnostic

Un commit n'appartient pas à une branche. Une branche est un marque-page posé sur un commit, c'est tout. « Déplacer un commit » revient donc à déplacer des marque-pages : en poser un nouveau sur le commit, la bonne branche, puis reculer celui qui n'aurait pas dû avancer. Le commit ne bouge pas, rien n'est copié ni perdu.

## Solution

**Cas 1 : le commit est sur `main`, il aurait dû ouvrir une branche.**

1. Pose la branche sur le commit, sans y basculer :

```console
$ git branch feature/recherche
```

2. Remets `main` là où le serveur l'a :

```console
$ git reset --keep origin/main

$ git log --oneline -2
d0a0b32 Premier commit
```

3. Continue sur la branche, le commit t'y attend :

```console
$ git switch feature/recherche
Switched to branch 'feature/recherche'

$ git log --oneline -2
5b5dda8 Ajoute la recherche
d0a0b32 Premier commit
```

**Cas 2 : le commit est allé sur une autre branche de travail.** Tu étais sur `feature/export`, et un commit pour la recherche s'y est glissé :

```console
$ git log --oneline -3
4c2654e Trie les resultats de recherche
3481de9 Ajoute un export
d0a0b32 Premier commit
```

1. Copie-le sur la bonne branche. Le nom d'une branche désigne son dernier commit, c'est donc lui que `cherry-pick` reprend :

```console
$ git switch feature/recherche
Switched to branch 'feature/recherche'

$ git cherry-pick feature/export
[feature/recherche f4c3525] Trie les resultats de recherche
 Date: Mon Oct 5 10:00:00 2026 +0000
 1 file changed, 1 insertion(+)
 create mode 100644 tri.js

$ git log --oneline -3
f4c3525 Trie les resultats de recherche
5b5dda8 Ajoute la recherche
d0a0b32 Premier commit
```

2. Retire-le de la mauvaise :

```console
$ git switch feature/export
Switched to branch 'feature/export'

$ git reset --keep HEAD~1

$ git log --oneline -3
3481de9 Ajoute un export
d0a0b32 Premier commit
```

Le commit copié a un nouvel identifiant, `4c2654e` est devenu `f4c3525` : même contenu, autre parent, donc autre commit.

**Cas 3 : le commit est déjà poussé.** Ne réécris pas une branche que d'autres ont récupérée. Sur `main`, laisse-le et annule-le proprement si besoin : [Annuler un commit déjà poussé](/situations/reparer/annuler-un-commit-deja-pousse/). Sur ta propre branche de travail, pas encore relue par personne, les cas 1 et 2 s'appliquent, suivis d'un `git push --force-with-lease`.

## Pourquoi ça marche

`git branch feature/recherche` crée un marque-page sur le commit courant. `git reset origin/main` déplace le marque-page de la branche courante vers le commit visé ; avec `--keep`, Git met aussi le dossier de travail d'accord avec ce commit, mais **refuse** si des modifications non commitées devaient y passer. C'est ce qui le rend préférable à `--hard`, qui les jetterait sans un mot.

Rien n'est supprimé : après le reset, le commit `5b5dda8` reste atteignable depuis `feature/recherche`. `cherry-pick`, lui, rejoue les changements d'un commit sous forme d'un nouveau commit sur la branche courante.

## Pièges

- **Vérifie que le commit n'est pas poussé** avant de reculer une branche : `git status` doit dire « ahead ». S'il dit « up to date with 'origin/main' » alors que le commit y est, il est poussé : cas 3.
- **Oublier l'étape `git branch`** avant le reset rend le commit invisible. Il n'est pas perdu : [Retrouver un commit perdu](/situations/reparer/retrouver-un-commit-perdu/).
- **Plusieurs commits** : `git reset --keep origin/main` recule d'un coup tous les commits non poussés, et la branche posée avant les garde tous. Pour le cas 2, `cherry-pick` accepte une plage : `git cherry-pick 3481de9..feature/export`.
- **`git reset --hard`** fait la même chose que `--keep` ici, mais efface aussi tout travail non commité. Réserve-le aux cas où c'est voulu.

## Voir aussi

- [Annuler mon dernier commit, pas encore poussé](/situations/reparer/annuler-mon-dernier-commit/)
- [Annuler un commit déjà poussé](/situations/reparer/annuler-un-commit-deja-pousse/)
- [Retrouver un commit perdu](/situations/reparer/retrouver-un-commit-perdu/)
- [Comprendre : une branche, c'est un marque-page](/comprendre/une-branche-est-un-marque-page/)

:::note[Essaie-le toi-même]
Le script de cette page sait fabriquer la panne sur ton poste. Depuis un clone du [dépôt du site](https://github.com/Hatimou-Nabina/git-en-situation), dans Git Bash sous Windows :

```bash
EXERCICE=1 bash scripts/situations/commit-sur-la-mauvaise-branche.sh
```

Il s'arrête juste après le symptôme, te dit dans quel dossier aller et quoi faire. Répare, puis relance sans `EXERCICE=1` pour comparer avec la solution.
:::

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/situations/commit-sur-la-mauvaise-branche.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/commit-sur-la-mauvaise-branche.sh), exécuté avec Git 2.50 le 5 octobre 2026. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
