---
title: Protéger la branche principale
description: Pull request obligatoire, CI verte, push forcé et suppression interdits. Ce qu'un push forcé fait à main sans protection, les deux réglages que tout serveur Git connaît, et la règle GitHub qui rend la pull request incontournable.
level: intermediaire
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
sidebar:
  order: 4
---

## Ce que ça évite

Un `git push --force` sur `main` qui efface le commit d'un collègue poussé une heure plus tôt. Un commit poussé directement sur `main` qui casse le build pour tout le monde, un vendredi soir. Une branche publiée qui disparaît par erreur. Et, moins visible : la peur de `main`, qui fait qu'on hésite à toucher au projet.

Protéger `main`, c'est déplacer ces garde-fous de la bonne volonté de chacun vers le serveur, qui ne se fatigue pas et n'est jamais pressé. Tout passe par une pull request ; le push forcé et la suppression sont refusés ; la CI doit être verte pour fusionner. Ce site s'applique la règle depuis son premier jour.

## Comment on fait

**Sans protection, voilà ce qui arrive.** Bakary pousse un commit sur `main`. Awa, qui ne l'a pas récupéré, voit son push refusé, et « règle » le problème avec `--force` :

```console
$ git log --oneline origin/main
879e74d feat(export): ajoute l export CSV
d0a0b32 Premier commit
```

```console
$ git push
To github.com:equipe/projet.git
 ! [rejected]        main -> main (fetch first)
error: failed to push some refs to 'github.com:equipe/projet.git'
hint: Updates were rejected because the remote contains work that you do not
hint: have locally. This is usually caused by another repository pushing to
hint: the same ref. If you want to integrate the remote changes, use
hint: 'git pull' before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.

$ git push --force
To github.com:equipe/projet.git
 + 879e74d...b9b596d main -> main (forced update)
```

Le serveur a obéi. Chez Bakary, son commit n'est plus sur `main` :

```console
$ git fetch
From github.com:equipe/projet
 + 879e74d...b9b596d main       -> origin/main  (forced update)

$ git log --oneline origin/main
b9b596d feat(recherche): ajoute la barre de recherche
d0a0b32 Premier commit

$ git status
On branch main
Your branch and 'origin/main' have diverged,
and have 1 and 1 different commits each, respectively.
  (use "git pull" if you want to integrate the remote branch with yours)

nothing to commit, working tree clean
```

:::danger[Ce qui a été perdu]
Le commit de Bakary n'existe plus que sur sa machine. S'il avait fait le ménage de sa branche locale entre-temps, ou si le push venait d'un poste de CI, il aurait disparu : un dépôt de serveur ne garde pas de reflog par défaut. Ici, Bakary a de la chance : un `git rebase origin/main` puis un `git push` le remettent en place.
:::

**Deux réglages que tout serveur Git connaît.** Sur un serveur que tu administres toi-même, deux lignes de configuration du dépôt nu refusent le push forcé et la suppression de n'importe quelle branche :

```console
$ git config receive.denyNonFastForwards true

$ git config receive.denyDeletes true
```

Awa retente :

```console
$ git push --force
remote: error: denying non-fast-forward refs/heads/main (you should pull first)
To github.com:equipe/projet.git
 ! [remote rejected] main -> main (non-fast-forward)
error: failed to push some refs to 'github.com:equipe/projet.git'

$ git push origin --delete main
remote: error: denying ref deletion for refs/heads/main
To github.com:equipe/projet.git
 ! [remote rejected] main (deletion prohibited)
error: failed to push some refs to 'github.com:equipe/projet.git'
```

`remote rejected`, et non `rejected` : ce n'est plus Git sur ton poste qui refuse, c'est le serveur. Aucune option locale ne passe outre.

**Imposer la pull request.** Le serveur peut aller plus loin et refuser tout push direct sur `main`, même en avance rapide. Sur GitHub, c'est une case à cocher ; sur un serveur à soi, c'est un hook `update`, exécuté avant chaque mise à jour de branche :

```console
$ cat hooks/update
#!/usr/bin/env bash
# Refuse tout push direct sur main : les changements passent par une pull request.
if [ "$1" = "refs/heads/main" ]; then
  echo "main est protegee : passe par une branche et une pull request." >&2
  exit 1
fi
```

Awa a commité sur `main` par habitude. Son push est refusé, avec le message du hook :

```console
$ git push
remote: main est protegee : passe par une branche et une pull request.
remote: error: hook declined to update refs/heads/main
To github.com:equipe/projet.git
 ! [remote rejected] main -> main (hook declined)
error: failed to push some refs to 'github.com:equipe/projet.git'
```

**Le réflexe : le commit part sur une branche.** Rien n'est perdu, le commit existe ; il change seulement de branche, puis il part en pull request.

```console
$ git branch feature/filtre

$ git reset --keep origin/main

$ git switch feature/filtre
Switched to branch 'feature/filtre'

$ git push -u origin feature/filtre
branch 'feature/filtre' set up to track 'origin/feature/filtre'.
To github.com:equipe/projet.git
 * [new branch]      feature/filtre -> feature/filtre
```

Le détail de ces trois commandes est dans [J'ai commité sur la mauvaise branche](/situations/reparer/commit-sur-la-mauvaise-branche/).

## Sur GitHub

- **Settings → Rules → Rulesets**, « New branch ruleset », cible `main`. Les règles utiles, dans l'ordre : « Require a pull request before merging », « Require status checks to pass » (choisir le nom du job de CI, pour ce site « Vérifier et construire le site »), « Block force pushes », « Restrict deletions ». Le réglage classique « Branch protection rules » fait la même chose avec une interface plus ancienne.
- **Zéro approbation requise** quand on est seul : GitHub interdit d'approuver sa propre PR, une approbation obligatoire bloquerait tout. Dès qu'il y a deux personnes, une.
- **Ce que voit celui qui pousse sur `main`** : un `remote rejected` avec un code `GH006` (protection classique) ou `GH013` (ruleset), et la règle enfreinte en clair. Le réflexe est le même que ci-dessus : une branche, une PR.
- **« Bypass list »** : par défaut, personne, pas même l'administrateur. C'est le bon réglage ; un contournement qu'on s'accorde « juste cette fois » finit par servir toutes les semaines.
- **Les tags** ne sont pas couverts par une règle de branche : un ruleset de tags protège `v*` de la même façon.
- **« Require linear history »** interdit les commits de merge sur `main` : à n'activer que si l'équipe fusionne toujours en « Squash » ou « Rebase and merge ». Voir [Fast-forward, fusion, rebase](/comprendre/fast-forward-fusion-rebase/).

## Pièges

- **Le check requis qui n'existe plus.** La règle vise un job par son nom. Si le job est renommé, la PR attend un check qui n'arrivera jamais, et personne ne peut fusionner. Mettre à jour la règle en même temps que le workflow.
- **Protéger `main` et oublier `prod`**, ou toute autre branche déployée. La règle vaut pour chaque branche dont dépend quelqu'un.
- **Protection n'est pas sauvegarde.** Une PR relue et verte peut quand même casser quelque chose. Le retour en arrière est un `revert`, en PR lui aussi : [Annuler un commit déjà poussé](/situations/reparer/annuler-un-commit-deja-pousse/).
- **Le push forcé légitime** existe : effacer un secret de l'historique demande de suspendre la règle le temps de l'opération, puis de la remettre. [J'ai poussé un secret par erreur](/situations/fichiers/secret-pousse-par-erreur/).
- **Le hook local ne protège que ton poste**, et un hook de serveur n'existe que sur un serveur que tu administres. Sur GitHub, seules les règles du dépôt comptent.

## Voir aussi

- [Une branche par changement](/equipe/une-branche-par-changement/)
- [La pull request, de l'ouverture à la fusion](/equipe/la-pull-request/)
- [Mon push est refusé, « rejected », « fetch first »](/situations/quotidien/push-refuse-fetch-first/)
- [Retrouver un commit perdu](/situations/reparer/retrouver-un-commit-perdu/)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/equipe/proteger-la-branche-principale.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/equipe/proteger-la-branche-principale.sh), exécuté avec Git 2.50 le 5 octobre 2026. Le serveur y est un dépôt nu du bac à sable, configuré puis muni du hook montré ; les règles de GitHub elles-mêmes ne se rejouent pas, et les codes `GH006` et `GH013` sont cités, pas exécutés. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
