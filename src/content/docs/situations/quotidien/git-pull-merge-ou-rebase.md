---
title: git pull me demande de choisir entre merge et rebase
description: « fatal - Need to specify how to reconcile divergent branches ». Ce que Git te demande vraiment, ce que donnent les deux options sur l'historique, et comment régler ça une fois pour toutes.
level: debutant
risk: aucun
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
---

## Symptôme

Tu récupères le travail des autres, comme tous les jours, et Git refuse :

```console
$ git pull
From github.com:equipe/projet
   d0a0b32..40cf319  main       -> origin/main
hint: You have divergent branches and need to specify how to reconcile them.
hint: You can do so by running one of the following commands sometime before
hint: your next pull:
hint:
hint:   git config pull.rebase false  # merge
hint:   git config pull.rebase true   # rebase
hint:   git config pull.ff only       # fast-forward only
hint:
hint: You can replace "git config" with "git config --global" to set a default
hint: preference for all repositories. You can also pass --rebase, --no-rebase,
hint: or --ff-only on the command line to override the configured default per
hint: invocation.
fatal: Need to specify how to reconcile divergent branches.
```

## Diagnostic

Quelqu'un a poussé sur `main` pendant que tu y faisais un commit : les deux historiques ont **divergé**. Il y a deux façons de les réunir, et elles ne laissent pas le même historique. Depuis Git 2.33, `git pull` refuse de choisir à ta place tant que tu ne lui as pas dit ta préférence. La première partie de la sortie montre d'ailleurs que les nouveautés ont bien été récupérées : seul le « réunir » est en attente.

## Solution

**Option 1, le rebase** : tes commits sont rejoués par-dessus ceux du serveur. L'historique reste en ligne droite.

```console
$ git pull --rebase
Rebasing (1/1)Successfully rebased and updated refs/heads/main.

$ git log --oneline --graph -4
* db0c9ee Corrige le titre du README
* 40cf319 Ajoute la page contact
* d0a0b32 Premier commit
```

**Option 2, la fusion** : un commit de merge relie les deux lignes.

```console
$ git pull --no-rebase
Merge made by the 'ort' strategy.
 contact.html | 1 +
 1 file changed, 1 insertion(+)
 create mode 100644 contact.html

$ git log --oneline --graph -4
*   8e0725f Merge branch 'main' of github.com:equipe/projet
|\
| * 40cf319 Ajoute la page contact
* | 0e03633 Corrige le titre du README
|/
* d0a0b32 Premier commit
```

Les deux résultats contiennent le même code. La différence est dans l'histoire racontée : avec le rebase, on dirait que tu as travaillé après ta collègue ; avec la fusion, on voit que vous avez travaillé en parallèle.

**Choisis, puis enregistre ton choix** pour que `git pull` ne pose plus la question :

```console
$ git config --global pull.rebase true

$ git config --global --get pull.rebase
true
```

Pour un ou deux commits à toi sur une branche partagée, le rebase est ce que la plupart des équipes préfèrent : pas de commits de merge « Merge branch 'main' of … » qui n'apportent rien. Si ton équipe a une convention, c'est elle qui tranche.

## Pourquoi ça marche

`git pull` enchaîne deux opérations : `git fetch`, qui récupère les commits du serveur, puis l'intégration de ces commits dans ta branche. Quand ta branche n'a rien de nouveau, l'intégration est un simple *fast-forward* : Git avance ton marque-page, aucun choix à faire. Quand les deux côtés ont avancé, il faut soit rejouer tes commits sur la nouvelle base, le rebase, soit créer un commit qui a deux parents, la fusion. Les anciennes versions de Git fusionnaient en silence ; beaucoup de gens se retrouvaient avec des commits de merge sans comprendre d'où ils venaient. Git demande maintenant.

La troisième option du message, `pull.ff only`, est la plus stricte : `git pull` ne fait que des *fast-forward* et échoue sinon, à toi de lancer le rebase ou la fusion à la main. C'est un bon réglage quand on veut toujours voir la divergence avant d'agir.

## Pièges

- **Le rebase réécrit tes commits locaux** : `0e03633` est devenu `db0c9ee`. C'est sans conséquence tant que ces commits n'avaient pas été poussés. Et c'est précisément le cas ici : `git pull --rebase` ne rejoue que les commits que le serveur n'a pas.
- **Un conflit** arrête le rebase ou la fusion de la même façon : corriger les fichiers, `git add`, puis `git rebase --continue` ou `git commit`. `git rebase --abort` ou `git merge --abort` ramène à l'état d'avant.
- **`pull.rebase` est un réglage de ton poste**, à refaire sur chaque machine. Il peut aussi être posé par dépôt, sans `--global`.
- **Si c'est le push qui est refusé** plutôt que le pull, c'est la même divergence vue de l'autre côté : [Mon push est refusé, « rejected », « fetch first »](/situations/quotidien/push-refuse-fetch-first/).

## Voir aussi

- [Mon push est refusé, « rejected », « fetch first »](/situations/quotidien/push-refuse-fetch-first/)
- [Comprendre : fast-forward, fusion, rebase](/comprendre/fast-forward-fusion-rebase/)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/situations/git-pull-merge-ou-rebase.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/git-pull-merge-ou-rebase.sh), exécuté avec Git 2.50 le 6 octobre 2026. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
