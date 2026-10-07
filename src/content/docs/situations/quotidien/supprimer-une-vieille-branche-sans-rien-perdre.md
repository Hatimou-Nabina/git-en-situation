---
title: Supprimer une vieille branche sans rien perdre
description: Le dépôt traîne des branches dont plus personne ne se souvient. Comment savoir si l'une d'elles contient encore du travail unique, la supprimer en confiance, et garder une trace quand on hésite.
level: intermediaire
risk: reversible
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptôme

Pas de message d'erreur ici, juste un dépôt encombré :

```console
$ git fetch --prune
$ git branch -a
  brouillon
  experimentation
* main
  refonte-header
  remotes/origin/HEAD -> origin/main
  remotes/origin/experimentation
  remotes/origin/main
  remotes/origin/refonte-header
```

`refonte-header` date de plusieurs mois. Tu voudrais faire le ménage, mais sans perdre un travail que quelqu'un aurait oublié de fusionner.

## Diagnostic

La bonne question n'est pas « cette branche est-elle vieille ? » mais « **contient-elle des commits qui n'existent nulle part ailleurs ?** ». Si tous ses commits sont déjà dans `main`, la supprimer ne supprime qu'un nom. Git sait répondre à cette question à coup sûr.

Commence toujours par `git fetch --prune`, pour que ta vue du serveur soit à jour (voir [Une branche distante a été supprimée, mais je la vois encore](/situations/quotidien/branche-distante-supprimee-encore-visible/)).

## Solution

**1. Vérifie que `main` contient tout.** Trois façons de poser la même question :

```console
$ git log --oneline main..refonte-header

$ git rev-list --count main..refonte-header
0

$ git merge-base --is-ancestor refonte-header main && echo "tout est dans main" || echo "des commits manquent dans main"
tout est dans main
```

`main..refonte-header` désigne les commits atteignables depuis `refonte-header` mais pas depuis `main`. Le premier `log` n'affiche rien et le compte vaut zéro : aucun commit ne manque.

Pour examiner toutes les branches d'un coup, demande celles qui sont entièrement contenues dans `main` :

```console
$ git branch --merged main
* main
  refonte-header

$ git branch -r --merged origin/main
  origin/HEAD -> origin/main
  origin/main
  origin/refonte-header
```

**2. Supprime, sur le serveur puis en local.**

```console
$ git push origin --delete refonte-header
To github.com:equipe/projet.git
 - [deleted]         refonte-header

$ git branch -d refonte-header
Deleted branch refonte-header (was c4bc016).
```

Le serveur d'abord : les collègues verront la branche disparaître à leur prochain `git fetch --prune`. Sur GitHub, le bouton « Delete branch » d'une pull request fusionnée fait la même chose que ce `push --delete`.

### Quand la branche a encore des commits uniques

`experimentation` est poussée sur le serveur et contient un commit que `main` n'a pas :

```console
$ git rev-list --count main..experimentation
1

$ git log --oneline main..experimentation
ba5b93a Essai non termine
```

Trois choix : la terminer et l'intégrer par une pull request, la supprimer en sachant ce qu'on abandonne, ou l'archiver (ci-dessous). Un détail qui surprend : ici, `git branch -d` accepte quand même, avec un avertissement.

```console
$ git branch -d experimentation
warning: deleting branch 'experimentation' that has been merged to
         'refs/remotes/origin/experimentation', but not yet merged to HEAD
Deleted branch experimentation (was ba5b93a).
```

Rien n'est perdu : la branche existe toujours sur le serveur. `-d` ne protège que ce qui n'existe **nulle part ailleurs**.

`brouillon`, elle, n'a jamais été poussée. Là, Git refuse :

```console
$ git log --oneline main..brouillon
baf14ca Brouillon local

$ git branch -d brouillon
error: the branch 'brouillon' is not fully merged
hint: If you are sure you want to delete it, run 'git branch -D brouillon'
hint: Disable this message with "git config set advice.forceDeleteBranch false"
```

C'est le refus qui te protège : ce commit n'existe que sur ton poste.

**Garder une trace, puis supprimer pour de bon.** Un tag coûte zéro octet de plus et garde le commit accessible :

```console
$ git tag archive/brouillon brouillon

$ git branch -D brouillon
Deleted branch brouillon (was baf14ca).

$ git log --oneline -1 archive/brouillon
baf14ca Brouillon local
```

Pour retrouver ce travail un jour : `git switch -c brouillon archive/brouillon`. Pour mettre le tag sur le serveur : `git push origin archive/brouillon`.

## Pourquoi ça marche

Une branche n'est qu'un marque-page posé sur un commit. Supprimer la branche supprime le marque-page, jamais les commits. Un commit ne disparaît que lorsque plus rien ne mène à lui, ni branche, ni tag, ni commit descendant, et même alors Git le garde un temps dans le *reflog*, trente jours par défaut, avant de le nettoyer.

`git branch -d` vérifie que la branche est contenue dans la branche courante **ou dans la branche distante qu'elle suit**. `-D` saute cette vérification. Le tag `archive/…` crée un nouveau chemin vers le commit : il ne sera jamais nettoyé tant que le tag existe.

## Pièges

- **Branches fusionnées en « squash » sur GitHub.** Le bouton « Squash and merge » crée dans `main` un commit neuf avec le même contenu : les commits de la branche, eux, ne sont pas dans `main`. `--merged` ne la liste pas et `-d` refuse, alors que rien ne serait perdu. Vérifie l'état de la pull request sur GitHub (« Merged »), puis supprime avec `-D`. Ou laisse GitHub le faire : Settings → General → « Automatically delete head branches ».
- **Supprimer sur le serveur ne supprime rien chez les collègues.** Leurs copies locales restent jusqu'à leur prochain `git fetch --prune`.
- **`-D` sans vérifier.** Le commit reste retrouvable un temps par `git reflog`, mais c'est un filet de secours, pas une méthode. Tag d'abord.
- **Branches protégées.** GitHub refuse la suppression d'une branche protégée, et c'est voulu.

## Voir aussi

- [Une branche distante a été supprimée, mais je la vois encore](/situations/quotidien/branche-distante-supprimee-encore-visible/)
- [Comprendre : une branche, c'est un marque-page](/comprendre/une-branche-est-un-marque-page/), et [le reflog, ton filet de sécurité](/comprendre/le-reflog-ton-filet-de-securite/)
- [Travailler en équipe : la pull request, de l'ouverture à la fusion](/equipe/la-pull-request/)

:::note[Essaie-le toi-même]
Le script de cette page sait fabriquer la panne sur ton poste. Depuis un clone du [dépôt du site](https://github.com/Hatimou-Nabina/git-en-situation), dans Git Bash sous Windows :

```bash
EXERCICE=1 bash scripts/situations/supprimer-une-vieille-branche-sans-rien-perdre.sh
```

Il s'arrête juste après le symptôme, te dit dans quel dossier aller et quoi faire. Répare, puis relance sans `EXERCICE=1` pour comparer avec la solution.
:::

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/situations/supprimer-une-vieille-branche-sans-rien-perdre.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/supprimer-une-vieille-branche-sans-rien-perdre.sh), exécuté avec Git 2.50 le 5 octobre 2026. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
