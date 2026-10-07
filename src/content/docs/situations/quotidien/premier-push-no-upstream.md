---
title: Premier push d'une branche, « has no upstream branch »
description: git push répond « fatal - The current branch has no upstream branch ». Ce que Git attend, la commande qui règle ça, et le réglage pour ne plus jamais la taper.
level: debutant
risk: aucun
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
---

## Symptôme

Tu viens de créer une branche, tu as fait un commit, et tu pousses :

```console
$ git push
fatal: The current branch feature/recherche has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin feature/recherche

To have this happen automatically for branches without a tracking
upstream, see 'push.autoSetupRemote' in 'git help config'.
```

## Diagnostic

Ta branche existe sur ton poste, pas encore sur le serveur. `git push` sans argument pousse la branche courante vers la branche du serveur qu'elle **suit**, son *upstream*. Une branche toute neuve n'en suit aucune : Git ne sait pas où envoyer, et plutôt que de deviner, il s'arrête et te dit quoi faire. Rien n'est cassé.

## Solution

**1. Pousse en créant le lien.**

```console
$ git push -u origin feature/recherche
To github.com:equipe/projet.git
 * [new branch]      feature/recherche -> feature/recherche
branch 'feature/recherche' set up to track 'origin/feature/recherche'.
```

`-u` est le raccourci de `--set-upstream`. La branche est créée sur le serveur, et la tienne la suit désormais :

```console
$ git branch -vv
* feature/recherche 5b5dda8 [origin/feature/recherche] Ajoute la recherche
  main              d0a0b32 [origin/main] Premier commit
```

**2. Les fois suivantes, `git push` suffit.**

```console
$ git push
To github.com:equipe/projet.git
   5b5dda8..df6e2e1  feature/recherche -> feature/recherche
```

**3. Pour ne plus jamais le taper.** Depuis Git 2.37, un réglage fait le `-u` à ta place sur toute branche nouvelle :

```console
$ git config --global push.autoSetupRemote true
```

Sur la branche suivante, le premier `git push` passe directement :

```console
$ git push
To github.com:equipe/projet.git
 * [new branch]      feature/export -> feature/export
branch 'feature/export' set up to track 'origin/feature/export'.
```

## Pourquoi ça marche

Le lien entre ta branche et celle du serveur tient en deux lignes dans `.git/config` : le nom du serveur (`origin`) et le nom de la branche distante. `git push -u` écrit ces deux lignes en plus de pousser. Ensuite, `git push` et `git pull` sans argument les lisent pour savoir où aller, et `git status` s'en sert pour t'annoncer « ahead » ou « behind ».

Une branche créée depuis une branche du serveur, par exemple avec `git switch feature/x` quand `origin/feature/x` existe, a ce lien dès le départ. Une branche créée de zéro avec `git switch -c` ne l'a pas : d'où le message.

## Pièges

- **`git push origin feature/recherche` sans `-u`** pousse bien, mais ne crée pas le lien : le message reviendra au prochain `git push`, et `git pull` ne saura pas quoi récupérer.
- **Garde le même nom des deux côtés.** `git push -u origin feature/recherche:autre-nom` est possible, mais une branche qui ne s'appelle pas pareil chez toi et sur le serveur finit toujours par tromper quelqu'un.
- **`push.autoSetupRemote`** est un réglage de ton poste, pas du dépôt : à refaire sur chaque machine.
- **Un message proche, qui n'est pas celui-ci** : `! [rejected] ... (fetch first)` veut dire que la branche existe déjà sur le serveur avec des commits que tu n'as pas. Voir [Mon push est refusé, « rejected », « fetch first »](/situations/quotidien/push-refuse-fetch-first/).

## Voir aussi

- [Après un clone, je ne vois pas les branches des autres](/situations/quotidien/branches-invisibles-apres-clone/)
- [Renommer une branche, en local et sur le serveur](/situations/quotidien/renommer-une-branche/)
- [Comprendre : upstream, la branche que la tienne suit](/comprendre/upstream-la-branche-que-la-tienne-suit/)

:::note[Essaie-le toi-même]
Le script de cette page sait fabriquer la panne sur ton poste. Depuis un clone du [dépôt du site](https://github.com/Hatimou-Nabina/git-en-situation), dans Git Bash sous Windows :

```bash
EXERCICE=1 bash scripts/situations/premier-push-no-upstream.sh
```

Il s'arrête juste après le symptôme, te dit dans quel dossier aller et quoi faire. Répare, puis relance sans `EXERCICE=1` pour comparer avec la solution.
:::

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/situations/premier-push-no-upstream.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/premier-push-no-upstream.sh), exécuté avec Git 2.50 le 6 octobre 2026. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
