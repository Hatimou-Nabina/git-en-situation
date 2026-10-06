---
title: Ma branche locale est en retard après une fusion sur GitHub
description: La pull request est fusionnée sur GitHub, mais sur ton poste main n'a pas bougé et git status finit par dire « behind ». Ce que ça veut dire, git pull --ff-only, et le ménage de la branche fusionnée.
level: debutant
risk: aucun
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptôme

Ta pull request vient d'être fusionnée sur GitHub. Sur ton poste, `main` ne montre rien de nouveau, et `git status` est même rassurant :

```console
$ git status
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

Après un `git fetch`, le ton change :

```console
$ git fetch
From github.com:equipe/projet
   d0a0b32..e86885d  main       -> origin/main

$ git status
On branch main
Your branch is behind 'origin/main' by 2 commits, and can be fast-forwarded.
  (use "git pull" to update your local branch)

nothing to commit, working tree clean

$ git branch -vv
  feature/recherche 5b5dda8 [origin/feature/recherche] Ajoute la recherche
* main              d0a0b32 [origin/main: behind 2] Premier commit
```

## Diagnostic

La fusion a eu lieu **sur le serveur** : GitHub a créé un commit de merge sur `main`, là-bas. Ton `main` local n'en sait rien tant que tu ne demandes pas des nouvelles. Le premier `git status` compare ta branche à la copie locale de l'état du serveur, `origin/main`, qui datait de ton dernier `fetch` : d'où « up to date ». Le `fetch` a rafraîchi cette copie.

« Behind 2, can be fast-forwarded » est la meilleure situation possible : ta branche est un simple ancêtre de celle du serveur. Il n'y a rien à fusionner, seulement un marque-page à avancer.

## Solution

**1. Avance `main`, sans rien créer.**

```console
$ git pull --ff-only
Updating d0a0b32..e86885d
Fast-forward
 recherche.js | 1 +
 1 file changed, 1 insertion(+)
 create mode 100644 recherche.js

$ git log --oneline --graph -4
*   e86885d Merge pull request #12 from equipe/feature/recherche
|\
| * 5b5dda8 Ajoute la recherche
|/
* d0a0b32 Premier commit
```

Le commit de merge créé par GitHub est maintenant chez toi.

**2. Fais le ménage de la branche fusionnée.** GitHub l'a supprimée sur le serveur, ou tu l'as fait depuis la PR ; ton poste l'a toujours :

```console
$ git fetch --prune
From github.com:equipe/projet
 - [deleted]         (none)     -> origin/feature/recherche

$ git branch -vv
  feature/recherche 5b5dda8 [origin/feature/recherche: gone] Ajoute la recherche
* main              e86885d [origin/main] Merge pull request #12 from equipe/feature/recherche

$ git branch -d feature/recherche
Deleted branch feature/recherche (was 5b5dda8).
```

**Si `--ff-only` refuse**, c'est que ton `main` a un commit que le serveur n'a pas :

```console
$ git pull --ff-only
hint: Diverging branches can't be fast-forwarded, you need to either:
hint:
hint: 	git merge --no-ff
hint:
hint: or:
hint:
hint: 	git rebase
hint:
hint: Disable this message with "git config set advice.diverging false"
fatal: Not possible to fast-forward, aborting.

$ git status
On branch main
Your branch and 'origin/main' have diverged,
and have 1 and 1 different commits each, respectively.
  (use "git pull" if you want to integrate the remote branch with yours)

nothing to commit, working tree clean
```

Ce commit avait-il sa place sur `main` ? Rarement : voir [J'ai commité sur la mauvaise branche](/situations/reparer/commit-sur-la-mauvaise-branche/). S'il y est à sa place, c'est une divergence ordinaire : [git pull me demande de choisir entre merge et rebase](/situations/quotidien/git-pull-merge-ou-rebase/).

## Pourquoi ça marche

Un *fast-forward* ne crée aucun commit : Git déplace le marque-page `main` jusqu'au commit du serveur, et met les fichiers à jour. `--ff-only` est une garantie : si un fast-forward n'est pas possible, la commande échoue au lieu de fabriquer un commit de merge ou de lancer un rebase sans te demander. Sur une branche où tu ne commites jamais directement, comme `main`, c'est le réglage qui ne surprend pas : `git config --global pull.ff only` le rend permanent.

## Pièges

- **« Up to date » ne veut pas dire que le serveur n'a pas bougé.** Ça veut dire « à jour par rapport à ce que je sais du serveur ». `git fetch` d'abord, toujours.
- **Un `git pull` sans option** aurait fait la même chose ici, un fast-forward. Mais sur un `main` qui a divergé, il fusionnerait ou rebaserait selon ta configuration, sans que tu l'aies demandé.
- **PR fusionnée en « squash » ou en « rebase »** : GitHub crée des commits neufs, et ta branche locale n'est plus un ancêtre de `main`. `git branch -d` refuse alors de la supprimer, alors que tout est bien fusionné. Vérifie l'état de la PR, puis `-D` : voir [Supprimer une vieille branche sans rien perdre](/situations/quotidien/supprimer-une-vieille-branche-sans-rien-perdre/).
- **Sur GitHub**, Settings → General → « Automatically delete head branches » supprime la branche à chaque fusion ; il ne reste que le `fetch --prune` de ton côté.

## Voir aussi

- [Une branche distante a été supprimée, mais je la vois encore](/situations/quotidien/branche-distante-supprimee-encore-visible/)
- [git pull me demande de choisir entre merge et rebase](/situations/quotidien/git-pull-merge-ou-rebase/)
- [Travailler en équipe : la pull request, de l'ouverture à la fusion](/equipe/la-pull-request/)

:::note[Essaie-le toi-même]
Le script de cette page sait fabriquer la panne sur ton poste. Depuis un clone du [dépôt du site](https://github.com/Hatimou-Nabina/git-en-situation), dans Git Bash sous Windows :

```bash
EXERCICE=1 bash scripts/situations/branche-locale-en-retard-apres-fusion.sh
```

Il s'arrête juste après le symptôme, te dit dans quel dossier aller et quoi faire. Répare, puis relance sans `EXERCICE=1` pour comparer avec la solution.
:::

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/situations/branche-locale-en-retard-apres-fusion.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/branche-locale-en-retard-apres-fusion.sh), exécuté avec Git 2.50 le 5 octobre 2026. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple ; la fusion « par GitHub » y est jouée par un second poste.
:::
