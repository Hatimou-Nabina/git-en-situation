---
title: Une branche distante a été supprimée, mais je la vois encore
description: La branche a disparu de GitHub, pourtant git branch -a l'affiche toujours et git fetch n'y change rien. Ce que sont les références distantes, et comment git fetch --prune fait le ménage.
level: debutant
risk: aucun
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptôme

Une collègue a fusionné sa branche `feature/export-pdf` dans `main`, puis l'a supprimée sur GitHub. Chez toi, elle est toujours là :

```console
$ git branch -a
  feature/export-pdf
* main
  remotes/origin/HEAD -> origin/main
  remotes/origin/feature/export-pdf
  remotes/origin/main
```

Tu fais `git fetch` : rien ne change. Sur GitHub, la branche n'existe plus. Qu'est-ce que Git n'a pas compris ?

## Diagnostic

Chez toi, deux choses distinctes portent ce nom :

- `remotes/origin/feature/export-pdf` est une **référence distante** : la copie locale de ce que Git a vu sur le serveur la dernière fois. Un marque-page qui dit « la dernière fois que j'ai regardé, cette branche du serveur était ici ».
- `feature/export-pdf` est **ta branche locale**, créée quand tu as fait `git switch feature/export-pdf` pour y jeter un œil.

`git fetch` met à jour les marque-pages des branches qui existent encore sur le serveur. Il ne retire pas ceux dont la branche a disparu. Rien n'est cassé : Git est prudent, il ne supprime jamais rien de lui-même.

## Solution

**1. Demande à `fetch` de faire le ménage dans les références distantes.**

```console
$ git fetch --prune
From github.com:equipe/projet
 - [deleted]         (none)     -> origin/feature/export-pdf
```

`git branch -a` ne montre plus `remotes/origin/feature/export-pdf`. Reste ta branche locale, que Git signale maintenant comme orpheline :

```console
$ git branch -vv
  feature/export-pdf 7abda0a [origin/feature/export-pdf: gone] Ajoute la fonction export PDF
* main               61d6827 [origin/main] Fusionne feature/export-pdf
```

`gone` : cette branche locale suivait une branche distante qui n'existe plus.

**2. Supprime la branche locale.**

```console
$ git branch -d feature/export-pdf
Deleted branch feature/export-pdf (was 7abda0a).
```

Le `-d` minuscule est prudent : il refuse si la branche contient des commits qui n'existent nulle part ailleurs. S'il refuse, lis [Supprimer une vieille branche sans rien perdre](/situations/quotidien/supprimer-une-vieille-branche-sans-rien-perdre/) avant d'insister.

**3. Pour ne plus y penser.**

```console
$ git config --global fetch.prune true
```

Désormais, chaque `git fetch` et chaque `git pull` fait ce ménage tout seul. À refaire sur chacun de tes postes : cette configuration appartient à la machine, pas au dépôt.

## Pourquoi ça marche

Tout ce que Git sait du serveur tient dans des références `origin/<branche>`, rangées dans ton dossier `.git`. Un `fetch` ordinaire ne fait que deux choses : créer les références des nouvelles branches, et avancer celles des branches qui ont bougé. Il n'a aucune raison de toucher aux autres, et par prudence il ne le fait pas.

Avec `--prune`, `fetch` compare en plus la liste des branches que le serveur annonce avec tes références `origin/*`, et supprime celles qui ne correspondent plus à rien. C'est **sans risque** : une référence distante n'est qu'un marque-page, elle ne contient aucun travail à toi. `--prune` ne touche ni à tes branches locales, ni au serveur.

Ta branche locale, elle, t'appartient. Git ne la supprimera jamais sans qu'on le lui demande, d'où l'étape 2.

## Pièges

- **`--prune` ne supprime pas les branches locales.** Pour trouver celles devenues orphelines : `git branch -vv | grep ': gone]'`.
- **La branche a peut-être été supprimée par erreur.** Si `git branch -vv` montre `gone` et que ta branche locale a des commits que `main` n'a pas, tu as peut-être la seule copie : `git push -u origin feature/export-pdf` la remet sur le serveur.
- **`git remote prune origin`** fait la même chose que `git fetch --prune`, sans récupérer les nouveautés. `git fetch -p` est le raccourci.
- **Ton éditeur ou ton client graphique** a souvent sa propre option « élaguer » ou « prune » : sous le capot, c'est cette commande.

## Voir aussi

- [Supprimer une vieille branche sans rien perdre](/situations/quotidien/supprimer-une-vieille-branche-sans-rien-perdre/)
- [Comprendre : les remotes et les références distantes](/comprendre/remotes-et-references-distantes/)

:::note[Essaie-le toi-même]
Le script de cette page sait fabriquer la panne sur ton poste. Depuis un clone du [dépôt du site](https://github.com/Hatimou-Nabina/git-en-situation), dans Git Bash sous Windows :

```bash
EXERCICE=1 bash scripts/situations/branche-distante-supprimee-encore-visible.sh
```

Il s'arrête juste après le symptôme, te dit dans quel dossier aller et quoi faire. Répare, puis relance sans `EXERCICE=1` pour comparer avec la solution.
:::

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/situations/branche-distante-supprimee-encore-visible.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/branche-distante-supprimee-encore-visible.sh), exécuté avec Git 2.50 le 5 octobre 2026. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
