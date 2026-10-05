---
title: Annuler mon dernier commit, pas encore poussé
description: Message faux, fichier oublié, ou commit à défaire complètement. Les trois cas, avec commit --amend et git reset, ce que chacun garde ou jette, et comment revenir en arrière même après un --hard.
level: intermediaire
risk: destructif
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptôme

Tu viens de commiter, et tu vois le problème juste après : une faute dans le message, un fichier oublié, ou un commit qui n'aurait pas dû exister. Rien n'est poussé.

```console
$ git log --oneline -1
808235f Ajoute la recherhce
```

## Diagnostic

Tant qu'un commit n'est pas poussé, il n'existe que chez toi : tu peux le remplacer ou le défaire sans gêner personne. Git propose deux outils selon le besoin. `commit --amend` **remplace** le dernier commit par une version corrigée. `reset` **recule** la branche d'un ou plusieurs commits, en gardant ou non le travail qu'ils contenaient.

:::caution[Une seule commande de cette page jette du travail]
`git reset --hard` efface les modifications. La fin de la page montre comment récupérer un commit effacé par erreur, mais pas des modifications jamais commitées.
:::

## Solution

**Cas 1 : le message est faux.**

```console
$ git commit --amend -m "Ajoute la recherche"
[feature/recherche 5b5dda8] Ajoute la recherche
 Date: Mon Oct 5 10:00:00 2026 +0000
 1 file changed, 1 insertion(+)
 create mode 100644 recherche.js

$ git log --oneline -1
5b5dda8 Ajoute la recherche
```

**Cas 1 bis : il manque un fichier.** Ajoute-le, puis amende en gardant le message :

```console
$ git add recherche.test.js

$ git commit --amend --no-edit
[feature/recherche 847c9cb] Ajoute la recherche
 Date: Mon Oct 5 10:00:00 2026 +0000
 2 files changed, 2 insertions(+)
 create mode 100644 recherche.js
 create mode 100644 recherche.test.js

$ git show --stat --oneline HEAD
847c9cb Ajoute la recherche
 recherche.js      | 1 +
 recherche.test.js | 1 +
 2 files changed, 2 insertions(+)
```

**Cas 2 : défaire le commit, garder le travail.** Les fichiers reviennent dans l'index, prêts pour un nouveau commit :

```console
$ git reset --soft HEAD~1

$ git status --short
A  recherche.js
A  recherche.test.js

$ git log --oneline -1
d0a0b32 Premier commit
```

**Cas 3 : défaire le commit et jeter le travail.**

```console
$ git reset --hard HEAD~1
HEAD is now at d0a0b32 Premier commit

$ git status --short

$ git log --oneline -1
d0a0b32 Premier commit
```

**Même après `--hard`, le commit n'est pas perdu tout de suite.** Le reflog garde la trace de chaque position de la branche :

```console
$ git reflog -3
d0a0b32 HEAD@{0}: reset: moving to HEAD~1
4bdd879 HEAD@{1}: commit: Ajoute la recherche et son test
d0a0b32 HEAD@{2}: reset: moving to HEAD~1

$ git reset --hard HEAD@{1}
HEAD is now at 4bdd879 Ajoute la recherche et son test

$ git log --oneline -1
4bdd879 Ajoute la recherche et son test

$ git ls-files
README.md
recherche.js
recherche.test.js
```

## Pourquoi ça marche

Un commit ne se modifie pas : `--amend` en crée un nouveau, avec le même parent, et déplace la branche dessus. D'où le changement d'identifiant à chaque fois, `808235f`, puis `5b5dda8`, puis `847c9cb`. L'ancien commit reste dans le dépôt, sans nom, jusqu'au nettoyage automatique.

`git reset HEAD~1` déplace la branche sur le commit précédent. Ce qui change, c'est le sort du contenu : `--soft` ne touche à rien d'autre, les changements du commit défait restent dans l'index ; `--mixed`, le défaut, les laisse dans le dossier mais hors de l'index ; `--hard` remet aussi le dossier au niveau du commit visé, donc efface ces changements. Le reflog, lui, note chaque déplacement de la branche : `HEAD@{1}` désigne « là où j'étais juste avant », quelle que soit la commande qui m'en a fait partir.

## Pièges

- **Jamais sur un commit poussé.** Amender ou reculer un commit que le serveur a déjà fait refuser le push suivant, et la tentation de forcer détruit le travail des autres. Pour un commit poussé : [Annuler un commit déjà poussé](/situations/reparer/annuler-un-commit-deja-pousse/).
- **`--hard` efface aussi ce qui n'était pas commité.** Avant un `--hard`, `git status` ; s'il y a des modifications en cours que tu veux garder, [mets-les de côté](/situations/quotidien/mettre-son-travail-de-cote/) d'abord.
- **`HEAD@{1}` n'est pas `HEAD~1`.** Le premier est une position dans le reflog, « juste avant » ; le second est le parent du commit courant. Les confondre dans un `reset --hard` mène au mauvais endroit.
- **Pour un seul fichier**, pas besoin de défaire le commit : `git restore --source HEAD~1 chemin` remet sa version précédente, à commiter ensuite.
- **`--amend` sans `-m` ni `--no-edit`** ouvre l'éditeur configuré pour retoucher le message. Si c'est Vim et que tu ne le connais pas : `:q!` sort sans rien changer.

## Voir aussi

- [J'ai commité sur la mauvaise branche](/situations/reparer/commit-sur-la-mauvaise-branche/)
- [Annuler un commit déjà poussé](/situations/reparer/annuler-un-commit-deja-pousse/)
- [Retrouver un commit perdu](/situations/reparer/retrouver-un-commit-perdu/)
- Comprendre : *Le reflog, ton filet de sécurité* (à venir)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/situations/annuler-mon-dernier-commit.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/annuler-mon-dernier-commit.sh), exécuté avec Git 2.50 le 5 octobre 2026. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
