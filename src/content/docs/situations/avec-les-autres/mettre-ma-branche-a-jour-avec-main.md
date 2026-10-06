---
title: Mettre ma branche à jour avec main
description: main a avancé pendant que tu travaillais sur ta branche. Rebase ou merge, comparés sur le même état, le push forcé qui suit un rebase, et ce que --force-with-lease empêche quand un collègue a poussé entre-temps.
level: intermediaire
risk: reversible
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptôme

Tu travailles depuis quelques jours sur `feature/recherche`, poussée régulièrement. Pendant ce temps, `main` a reçu d'autres choses, et ta pull request affiche « This branch is out-of-date with the base branch ». Tu veux repartir d'un `main` à jour avant de demander la relecture.

```console
$ git fetch
From github.com:equipe/projet
   d0a0b32..6ccbbac  main       -> origin/main

$ git log --oneline --left-right origin/main...feature/recherche
< 6ccbbac Ajoute la page contact
> df6e2e1 Filtre les resultats
> 5b5dda8 Ajoute la recherche
```

Un commit à gauche, sur `main` ; deux à droite, les tiens.

## Diagnostic

Deux façons de faire entrer `main` dans ta branche. Le **rebase** rejoue tes commits par-dessus le `main` à jour : historique en ligne droite, mais tes commits sont réécrits, et il faudra remplacer ceux que le serveur a. La **fusion** amène `main` dans ta branche par un commit de merge : rien n'est réécrit, le push est ordinaire, mais l'historique de la branche garde la trace du croisement. Les deux sont corrects. Le choix est une convention d'équipe ; ce qui suit montre les deux sur exactement le même état.

## Solution

**Option 1 : rebase, ma branche repart du `main` à jour.**

```console
$ git rebase origin/main
Rebasing (1/2)Rebasing (2/2)Successfully rebased and updated refs/heads/feature/recherche.

$ git log --oneline --graph -4
* b44c2d1 Filtre les resultats
* 1ea02d2 Ajoute la recherche
* 6ccbbac Ajoute la page contact
* d0a0b32 Premier commit
```

Tes deux commits ont changé d'identifiant. Le push ordinaire est refusé, c'est attendu :

```console
$ git push
To github.com:equipe/projet.git
 ! [rejected]        feature/recherche -> feature/recherche (non-fast-forward)
error: failed to push some refs to 'github.com:equipe/projet.git'
hint: Updates were rejected because the tip of your current branch is behind
hint: its remote counterpart. If you want to integrate the remote changes,
hint: use 'git pull' before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
```

Surtout pas de `git pull` ici, malgré le conseil : il remélangerait l'ancienne version de tes commits avec la nouvelle. Sur **ta** branche, après **ton** rebase, le bon geste est de remplacer la version du serveur, avec la protection qui va bien :

```console
$ git push --force-with-lease
To github.com:equipe/projet.git
 + df6e2e1...b44c2d1 feature/recherche -> feature/recherche (forced update)

$ git status
On branch feature/recherche
Your branch is up to date with 'origin/feature/recherche'.

nothing to commit, working tree clean
```

**Option 2 : merge, `main` entre dans ma branche.**

```console
$ git merge origin/main
Merge made by the 'ort' strategy.
 contact.html | 1 +
 1 file changed, 1 insertion(+)
 create mode 100644 contact.html

$ git log --oneline --graph -5
*   d8fe638 Merge remote-tracking branch 'origin/main' into feature/recherche
|\
| * 6ccbbac Ajoute la page contact
* | df6e2e1 Filtre les resultats
* | 5b5dda8 Ajoute la recherche
|/
* d0a0b32 Premier commit

$ git push
To github.com:equipe/projet.git
   df6e2e1..d8fe638  feature/recherche -> feature/recherche
```

Rien de forcé : la branche a seulement avancé d'un commit.

**Ce que `--force-with-lease` empêche.** Reprenons après le rebase de l'option 1. Sans que tu le saches, Bakary a poussé une retouche sur ta branche. Toi, tu corriges le message de ton dernier commit et tu forces à nouveau :

```console
$ git push --force-with-lease
To github.com:equipe/projet.git
 ! [rejected]        feature/recherche -> feature/recherche (stale info)
error: failed to push some refs to 'github.com:equipe/projet.git'
```

« Stale info » : la branche sur le serveur n'est plus là où tu l'avais vue. Quelqu'un a poussé. Un `--force` nu aurait écrasé son travail sans un mot. Regarde ce qui est arrivé :

```console
$ git fetch
From github.com:equipe/projet
   b44c2d1..b79ce61  feature/recherche -> origin/feature/recherche

$ git log --oneline feature/recherche..origin/feature/recherche
b79ce61 Retouche de Bakary
b44c2d1 Filtre les resultats
```

Le serveur a deux commits que ta branche n'a plus : la retouche de Bakary, et ton propre commit d'avant la correction du message. Reprends la retouche sur ta branche, puis force à nouveau, en connaissance de cause :

```console
$ git cherry-pick origin/feature/recherche
[feature/recherche 61dce8e] Retouche de Bakary
 Author: Bakary <bakary@example.com>
 Date: Mon Oct 5 10:00:00 2026 +0000
 1 file changed, 1 insertion(+)

$ git push --force-with-lease
To github.com:equipe/projet.git
 + b79ce61...61dce8e feature/recherche -> feature/recherche (forced update)

$ git log --oneline --graph -5
* 61dce8e Retouche de Bakary
* 0acb0d2 Filtre les resultats de recherche
* 1ea02d2 Ajoute la recherche
* 6ccbbac Ajoute la page contact
* d0a0b32 Premier commit
```

Le commit de Bakary garde son auteur. Rien n'est perdu.

## Pourquoi ça marche

Un rebase crée de nouveaux commits : même contenu, autre parent, donc autre identifiant (`df6e2e1` est devenu `b44c2d1`). Le commit que le serveur connaît n'est plus un ancêtre du tien : le *fast-forward* est impossible, et le push ordinaire est refusé, comme pour n'importe quelle divergence.

`--force` dit « remplace, quoi qu'il y ait ». `--force-with-lease` dit « remplace, **à condition** que la branche du serveur soit encore là où mon dernier `fetch` l'a vue ». Cette condition est vérifiée côté serveur, contre ta référence `origin/feature/recherche`. Si quelqu'un a poussé entre-temps, elle n'est plus vraie, et le push est refusé : c'est le « stale info ».

La fusion, elle, ne réécrit rien : un commit de plus, avec deux parents, et le serveur fait un fast-forward ordinaire.

## Pièges

- **`git fetch` annule la protection.** Après un `fetch`, ta référence `origin/feature/recherche` est à jour, et le `--force-with-lease` suivant passe, même si tu n'as pas repris le travail arrivé entre-temps. Entre le `fetch` et le push forcé, regarde toujours ce qui est arrivé, comme ci-dessus.
- **Jamais de push forcé sur une branche partagée.** `main`, `develop`, la branche d'une PR à plusieurs : si ton rebase y est nécessaire, c'est le signe qu'il faut parler avant.
- **Un rebase peut s'arrêter sur un conflit**, commit par commit : [Un conflit pendant un merge ou un rebase](/situations/reparer/resoudre-un-conflit/). `git rebase --abort` ramène à l'état d'avant.
- **Le bouton « Update branch » de GitHub** fait une fusion par défaut, et peut faire un rebase si le dépôt est configuré ainsi. Même choix, même conséquence.
- **`git pull --rebase origin main`** enchaîne le `fetch` et le `rebase origin/main` en une commande ; le reste de la page est identique.

## Voir aussi

- [Mon push est refusé, « rejected », « fetch first »](/situations/quotidien/push-refuse-fetch-first/)
- [git pull me demande de choisir entre merge et rebase](/situations/quotidien/git-pull-merge-ou-rebase/)
- [Un conflit pendant un merge ou un rebase](/situations/reparer/resoudre-un-conflit/)
- [Ma branche locale est en retard après une fusion sur GitHub](/situations/avec-les-autres/branche-locale-en-retard-apres-fusion/)

:::note[Essaie-le toi-même]
Le script de cette page sait fabriquer la panne sur ton poste. Depuis un clone du [dépôt du site](https://github.com/Hatimou-Nabina/git-en-situation), dans Git Bash sous Windows :

```bash
EXERCICE=1 bash scripts/situations/mettre-ma-branche-a-jour-avec-main.sh
```

Il s'arrête juste après le symptôme, te dit dans quel dossier aller et quoi faire. Répare, puis relance sans `EXERCICE=1` pour comparer avec la solution.
:::

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/situations/mettre-ma-branche-a-jour-avec-main.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/mettre-ma-branche-a-jour-avec-main.sh), exécuté avec Git 2.50 le 5 octobre 2026. Les deux options sont jouées sur deux copies du même état, le serveur étant remis à l'identique entre les deux. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
