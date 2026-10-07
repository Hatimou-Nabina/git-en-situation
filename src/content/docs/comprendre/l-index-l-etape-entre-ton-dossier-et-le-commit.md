---
title: L'index, l'étape entre ton dossier et le commit
description: Entre ton dossier de travail et le commit, il y a une étape, l'index, où git add dépose la version d'un fichier que le prochain commit prendra. C'est ce qui permet de commiter une partie de ce qu'on a changé, et ce que git status montre en deux colonnes.
level: debutant
gitVersion: "2.50"
verified: 2026-10-07
published: 2026-10-07
sidebar:
  order: 7
---

## L'idée

Un fichier existe à trois endroits : dans ton **dossier de travail**, tel que tu l'édites ; dans le **dernier commit**, tel qu'il a été enregistré ; et entre les deux, dans l'**index**, la liste de ce que le prochain commit contiendra. `git add` ne sauvegarde rien et n'envoie rien : il copie la version actuelle d'un fichier dans l'index. `git commit` prend l'index, et seulement lui. Ce que tu as modifié après le `git add` n'est pas dans le commit.

C'est ce qui permet de commiter une partie de ce qu'on a changé, et de laisser le reste pour plus tard. Et c'est ce que `git status --short` montre en deux colonnes : à gauche l'index comparé au dernier commit, à droite le dossier comparé à l'index.

## Voir par soi-même

`config.js` contient `v1` dans le dernier commit. On écrit `v2` dans le dossier : le fichier est modifié, et l'index pointe toujours vers l'objet `v1`, le même que le commit.

```console
$ echo "v2" > config.js && git status --short
 M config.js

$ git ls-files -s config.js
100644 626799f0f85326a8c1fc522db584e86cdfccd51f 0	config.js

$ git rev-parse HEAD:config.js
626799f0f85326a8c1fc522db584e86cdfccd51f
```

`git add` crée un nouvel objet avec le contenu `v2` et le met dans l'index. Le `M` passe dans la colonne de gauche :

```console
$ git add config.js

$ git status --short
M  config.js

$ git ls-files -s config.js
100644 8c1384d825dbbe41309b7dc18ee7991a9085c46e 0	config.js

$ git cat-file -p $(git ls-files -s config.js | cut -d" " -f2)
v2
```

On modifie encore : trois versions coexistent, `v1` dans le commit, `v2` dans l'index, `v3` sur le disque. `git diff` compare le dossier à l'index, `git diff --staged` l'index au commit :

```console
$ echo "v3" > config.js && git status --short
MM config.js

$ git diff
diff --git a/config.js b/config.js
index 8c1384d..29ef827 100644
--- a/config.js
+++ b/config.js
@@ -1 +1 @@
-v2
+v3

$ git diff --staged
diff --git a/config.js b/config.js
index 626799f..8c1384d 100644
--- a/config.js
+++ b/config.js
@@ -1 +1 @@
-v1
+v2
```

Le commit prend l'index : `v2` est enregistré, `v3` reste une modification en cours.

```console
$ git commit -m "Passe la configuration en v2"
[main 4e72dff] Passe la configuration en v2
 1 file changed, 1 insertion(+), 1 deletion(-)

$ git show HEAD:config.js
v2

$ cat config.js
v3

$ git status --short
 M config.js
```

Retirer de l'index ne touche pas au disque :

```console
$ git add config.js

$ git status --short
M  config.js

$ git restore --staged config.js

$ git status --short
 M config.js

$ cat config.js
v3
```

Et l'index permet de choisir : deux fichiers nouveaux, un seul ajouté, un seul commité.

```console
$ echo "a" > a.js && echo "b" > b.js && git add a.js && git status --short
A  a.js
 M config.js
?? b.js

$ git commit -m "Ajoute a"
[main 2383c68] Ajoute a
 1 file changed, 1 insertion(+)
 create mode 100644 a.js

$ git status --short
 M config.js
?? b.js
```

## Ce que ça change dans la pratique

- **`git add` n'est pas une sauvegarde.** Rien n'est enregistré avant `git commit`, et rien n'est envoyé avant `git push`.
- **Ajouté puis modifié : le commit prend la version ajoutée.** `git status --short` le dit en `MM` ou `AM` ; un second `git add` met l'index à jour.
- **Les deux colonnes se lisent séparément.** `M ` à gauche, c'est dans l'index ; ` M` à droite, c'est dans le dossier seulement ; `MM`, les deux ; `??`, Git ne connaît pas le fichier.
- **Un commit, une intention** devient possible : `git add fichier`, ou `git add -p` morceau par morceau, et le reste attend le commit suivant.
- **`git restore --staged` est l'inverse de `git add`**, et ne touche jamais au disque. `git restore` sans option, lui, écrase le dossier avec l'index : c'est l'autre moitié, et elle ne prévient pas.
- **`git stash` et `git commit -a` passent par l'index aussi** : le premier le range avec le dossier, le second ajoute les fichiers suivis avant de commiter.

## Où ça sert

- [Mettre mon travail en cours de côté pour changer de branche](/situations/quotidien/mettre-son-travail-de-cote/)
- [Annuler mon dernier commit, pas encore poussé](/situations/reparer/annuler-mon-dernier-commit/)
- [.gitignore ne marche pas, le fichier est déjà suivi](/situations/fichiers/gitignore-fichier-deja-suivi/)
- [Un commit, c'est un instantané](/comprendre/un-commit-est-un-instantane/)
- Commandes : [`git add`](/commandes/add/), [`git status`](/commandes/status/), [`git restore`](/commandes/restore/), [`git diff`](/commandes/diff/)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/comprendre/l-index-l-etape-entre-ton-dossier-et-le-commit.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/comprendre/l-index-l-etape-entre-ton-dossier-et-le-commit.sh), exécuté avec Git 2.50 le 7 octobre 2026. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
