---
title: Mon push est refusé, « rejected », « fetch first »
description: git push répond « ! [rejected] main -> main (fetch first) ». Quelqu'un a poussé avant toi. Ce que ça veut dire, et comment publier ton commit sans écraser le sien.
level: debutant
risk: aucun
gitVersion: "2.50"
verified: 2026-10-05
---

## Symptôme

Un commit, un push, comme d'habitude. Et cette fois :

```text
$ git push
To github.com:equipe/projet.git
 ! [rejected]        main -> main (fetch first)
error: failed to push some refs to 'github.com:equipe/projet.git'
hint: Updates were rejected because the remote contains work that you do not
hint: have locally. This is usually caused by another repository pushing to
hint: the same ref. If you want to integrate the remote changes, use
hint: 'git pull' before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
```

## Diagnostic

Entre ton dernier `pull` et maintenant, quelqu'un a poussé sur `main`. Le serveur a donc un commit que tu n'as pas, et toi un commit qu'il n'a pas : les deux historiques ont **divergé**. Git refuse d'écraser le travail de l'autre. C'est exactement ce qu'on attend de lui.

Pour le voir de tes yeux :

```text
$ git fetch
From github.com:equipe/projet
   d0a0b32..40cf319  main       -> origin/main

$ git status
On branch main
Your branch and 'origin/main' have diverged,
and have 1 and 1 different commits each, respectively.
  (use "git pull" if you want to integrate the remote branch with yours)

nothing to commit, working tree clean
```

Ce que le serveur a et que tu n'as pas, puis l'inverse :

```text
$ git log --oneline main..origin/main
40cf319 Ajoute la page contact

$ git log --oneline origin/main..main
0e03633 Corrige le titre du README
```

## Solution

Il faut placer ton commit **après** celui du serveur, puis pousser.

**1. Récupère l'état du serveur**, si ce n'est pas déjà fait : `git fetch`, comme ci-dessus.

**2. Rejoue ton commit par-dessus.**

```text
$ git rebase origin/main
Rebasing (1/1)Successfully rebased and updated refs/heads/main.

$ git log --oneline -3
db0c9ee Corrige le titre du README
40cf319 Ajoute la page contact
d0a0b32 Premier commit
```

Ton commit a changé d'identifiant, `0e03633` est devenu `db0c9ee`. C'est normal : un rebase crée un nouveau commit, de même contenu, posé sur une nouvelle base.

**3. Pousse.**

```text
$ git status
On branch main
Your branch is ahead of 'origin/main' by 1 commit.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean

$ git push
To github.com:equipe/projet.git
   40cf319..db0c9ee  main -> main
```

En une seule commande, `git pull --rebase` enchaîne les étapes 1 et 2.

### Et si les deux commits touchent la même ligne ?

Le rebase s'arrête et te dit quels fichiers sont en conflit. Tu les corriges, `git add` sur chacun, puis `git rebase --continue`. À tout moment, `git rebase --abort` te ramène exactement à l'état d'avant. Une situation dédiée aux conflits est à venir.

### Pourquoi pas simplement `git pull` ?

Avec un Git récent et sans configuration, `git pull` refuse de choisir pour toi :

```text
$ git pull
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

Deux façons de réunir des historiques divergents : la **fusion**, qui ajoute un commit « Merge branch 'main' of github.com:equipe/projet », et le **rebase**, qui garde un historique en ligne droite. Les deux sont corrects ; c'est un choix d'équipe. Pour un petit commit à toi sur une branche partagée, le rebase est ce que la plupart des équipes préfèrent. Pour en faire ton réglage par défaut : `git config --global pull.rebase true`.

## Pourquoi ça marche

Le serveur n'accepte de faire avancer une branche que si le commit qu'elle désigne actuellement est un **ancêtre** de celui que tu envoies. Il n'a alors qu'à déplacer son marque-page vers l'avant : c'est un *fast-forward*. Si les historiques ont divergé, déplacer le marque-page rendrait le commit de ta collègue inaccessible, autrement dit le ferait disparaître. Le serveur refuse.

Le rebase rend ton commit descendant de celui du serveur. Le *fast-forward* redevient possible, le push passe.

## Pièges

- **Ne force jamais sur une branche partagée.** `git push --force` ferait précisément ce que Git vient d'empêcher : effacer le commit de l'autre. Sur une branche à toi, après un rebase volontaire, utilise `git push --force-with-lease`, qui refuse si quelqu'un a poussé entre-temps.
- **« fetch first » et « non-fast-forward »** sont deux formulations de la même situation. La première quand tu n'as pas encore récupéré les commits du serveur, la seconde quand tu les as récupérés sans les intégrer.
- **Un message différent sur GitHub**, du genre `protected branch hook declined` ou `GH006`, n'est pas cette situation : la branche est protégée et attend une pull request.

## Voir aussi

- Comprendre : *Fast-forward, fusion, rebase* (à venir)
- Travailler en équipe : *Protéger la branche principale* (à venir)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/situations/push-refuse-fetch-first.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/push-refuse-fetch-first.sh), exécuté avec Git 2.50 le 5 octobre 2026. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
