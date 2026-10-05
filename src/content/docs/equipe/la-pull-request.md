---
title: La pull request, de l'ouverture à la fusion
description: La branche, les commits, le push, la relecture, la fusion, le nettoyage. Ce que chaque étape évite, les commandes qui vont avec, et ce que font vraiment les trois boutons de fusion de GitHub.
level: debutant
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
sidebar:
  order: 1
---

## Ce que ça évite

Du code qui arrive sur `main` sans qu'un second regard l'ait vu. Des semaines de travail intégrées d'un coup, avec les conflits et les surprises qui vont avec. Un historique où personne ne sait plus pourquoi un changement a été fait. Et la peur de casser `main`, qui finit par freiner tout le monde.

La pull request est l'unité de changement : une branche, une description, une relecture, une CI verte, une fusion. Le nom est celui de GitHub ; GitLab dit « merge request », c'est la même chose.

## Comment on fait

**1. Partir d'un `main` à jour, sur une branche au nom parlant.** [Une branche par changement](/equipe/une-branche-par-changement/), pas une de plus.

```console
$ git switch main
Your branch is up to date with 'origin/main'.
Already on 'main'

$ git pull --ff-only
Already up to date.

$ git switch -c feature/recherche
Switched to a new branch 'feature/recherche'
```

**2. Des commits petits et lisibles**, au format [conventionnel](/equipe/commits-conventionnels/) :

```console
$ git log --oneline main..HEAD
d3b93ce test(recherche): couvre la recherche vide
b9b596d feat(recherche): ajoute la barre de recherche
```

**3. Pousser, puis ouvrir la pull request.** GitHub affiche le lien dans la réponse au push ; `gh pr create` fait la même chose depuis le terminal.

```console
$ git push -u origin feature/recherche
branch 'feature/recherche' set up to track 'origin/feature/recherche'.
To github.com:equipe/projet.git
 * [new branch]      feature/recherche -> feature/recherche
```

Le titre suit le format des commits. La description répond à trois questions, et c'est ce que le gabarit du dépôt demande : quoi, pourquoi, qu'est-ce qui a été vérifié. Ce que la pull request contiendra, tu peux le voir avant de l'ouvrir :

```console
$ git log --oneline main..feature/recherche
d3b93ce test(recherche): couvre la recherche vide
b9b596d feat(recherche): ajoute la barre de recherche

$ git diff --stat main...feature/recherche
 recherche.js      | 1 +
 recherche.test.js | 1 +
 2 files changed, 2 insertions(+)
```

**4. Une remarque en relecture : un commit de plus, pas de réécriture.** Le relecteur retrouve son fil, et voit exactement ce qui a changé depuis sa lecture.

```console
$ git push
To github.com:equipe/projet.git
   d3b93ce..2b52f41  feature/recherche -> feature/recherche

$ git log --oneline main..feature/recherche
2b52f41 fix(recherche): ignore les espaces en debut de saisie
d3b93ce test(recherche): couvre la recherche vide
b9b596d feat(recherche): ajoute la barre de recherche
```

**5. CI verte, approbation, fusion, puis le ménage.** La fusion se fait sur GitHub, la branche y est supprimée. Sur ton poste :

```console
$ git switch main
Your branch is up to date with 'origin/main'.
Switched to branch 'main'

$ git pull --ff-only
From github.com:equipe/projet
   d0a0b32..70803f8  main       -> origin/main
Updating d0a0b32..70803f8
Fast-forward
 recherche.js      | 1 +
 recherche.test.js | 1 +
 2 files changed, 2 insertions(+)
 create mode 100644 recherche.js
 create mode 100644 recherche.test.js

$ git fetch --prune
From github.com:equipe/projet
 - [deleted]         (none)     -> origin/feature/recherche

$ git branch -d feature/recherche
Deleted branch feature/recherche (was 2b52f41).
```

Ce site s'applique la règle : chaque changement depuis son premier jour est passé par une pull request, y compris quand il n'y avait qu'une personne pour la relire. [La liste est publique](https://github.com/Hatimou-Nabina/git-en-situation/pulls?q=is%3Apr+is%3Amerged).

## Sur GitHub

- **Le gabarit** `.github/PULL_REQUEST_TEMPLATE.md` préremplit la description : les questions sont posées avant qu'on les oublie.
- **Une PR « Draft »** s'ouvre tôt, pour montrer une direction avant qu'elle soit finie ; elle ne peut pas être fusionnée par erreur.
- **« Files changed »**, c'est `git diff main...feature/recherche` : ce que la branche a changé depuis qu'elle a quitté `main`, sans ce que `main` a reçu entre-temps.
- **La relecture** a trois issues : commenter, approuver, demander des changements. Chaque conversation se résout quand la remarque est traitée.
- **Les règles de la branche** (Settings → Rules) imposent la PR, les vérifications requises et l'interdiction du push forcé. Avec une seule personne dans le projet, zéro approbation requise : GitHub interdit de s'approuver soi-même. Le détail : [Protéger la branche principale](/equipe/proteger-la-branche-principale/).
- **Les trois boutons de fusion** : « Create a merge commit » garde les commits et ajoute un commit de merge, « Squash and merge » les fond en un seul dont le message est le titre de la PR, « Rebase and merge » les recopie un par un sur `main`. Le détail est dans [Fast-forward, fusion, rebase](/comprendre/fast-forward-fusion-rebase/).
- **« Automatically delete head branches »**, dans Settings → General, supprime la branche à la fusion ; il ne reste que le `fetch --prune` sur chaque poste.
- **`gh`** fait tout depuis le terminal : `gh pr create`, `gh pr checks`, `gh pr view --web`, `gh pr merge`.

## Pièges

- **Les grosses PR.** Au-delà de ce qu'on relit en vingt minutes, la relecture devient un survol. Une PR, une intention ; si elle en a deux, c'est deux PR.
- **Réécrire la branche pendant la relecture.** Un rebase ou un `--amend` pendant qu'on te relit fait perdre au relecteur les repères de sa lecture précédente. On ajoute des commits ; on nettoie, si l'équipe le souhaite, avec « Squash and merge ».
- **Partir d'une branche qui n'est pas `main`**, ou d'une PR encore ouverte, sans le dire : la PR affiche alors les changements de l'autre branche en plus des tiens.
- **`main` a bougé pendant la relecture** : le bouton « Update branch » fusionne `main` dans la branche. Si l'équipe préfère un historique en ligne droite, c'est un rebase : [Mettre ma branche à jour avec main](/situations/avec-les-autres/mettre-ma-branche-a-jour-avec-main/).
- **Oublier le `pull` après la fusion**, puis commiter sur un `main` en retard : [Ma branche locale est en retard après une fusion sur GitHub](/situations/avec-les-autres/branche-locale-en-retard-apres-fusion/).

## Voir aussi

- [Les commits conventionnels](/equipe/commits-conventionnels/)
- [Voir ce qui a changé entre ma branche et main](/situations/quotidien/voir-ce-qui-a-change/)
- [Mettre ma branche à jour avec main](/situations/avec-les-autres/mettre-ma-branche-a-jour-avec-main/)
- [Fast-forward, fusion, rebase](/comprendre/fast-forward-fusion-rebase/)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/equipe/la-pull-request.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/equipe/la-pull-request.sh), exécuté avec Git 2.50 le 5 octobre 2026. La fusion « par GitHub » y est jouée par un second poste. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
