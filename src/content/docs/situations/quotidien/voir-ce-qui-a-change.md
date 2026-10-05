---
title: Voir ce qui a changé entre ma branche et main
description: Avant d'ouvrir une pull request, savoir quels commits ta branche apporte et quels fichiers elle touche. Les commandes, et le piège des deux points et trois points, qui ne veulent pas dire la même chose pour log et pour diff.
level: debutant
risk: aucun
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptôme

Pas d'erreur ici. Tu as travaillé quelques jours sur `feature/recherche`, `main` a bougé entre-temps, et avant d'ouvrir ta pull request tu veux répondre à trois questions : quels commits ma branche apporte-t-elle, quels fichiers touche-t-elle, et qu'est-ce que `main` a reçu pendant ce temps ?

## Diagnostic

Git a deux outils pour deux questions. `git log` répond en **commits**, `git diff` répond en **contenu**. Les deux acceptent une « plage » entre deux branches, écrite avec deux points ou trois points. Et c'est là que ça se complique : `..` et `...` n'ont pas le même sens selon qu'on parle à `log` ou à `diff`. Une fois ce point compris, tout le reste est simple.

## Solution

**Les commits de ma branche que `main` n'a pas** : deux points, la branche de référence d'abord.

```console
$ git log --oneline main..feature/recherche
df6e2e1 Filtre les resultats
5b5dda8 Ajoute la recherche
```

**Et l'inverse**, ce que `main` a reçu pendant ce temps :

```console
$ git log --oneline feature/recherche..main
40cf319 Ajoute la page contact
```

**Les deux côtés d'un coup**, trois points et `--left-right` : `<` pour le côté gauche, `>` pour le droit.

```console
$ git log --oneline --left-right main...feature/recherche
< 40cf319 Ajoute la page contact
> df6e2e1 Filtre les resultats
> 5b5dda8 Ajoute la recherche
```

**Les fichiers que ma branche a touchés**, depuis le point où elle a quitté `main`. Ici, trois points avec `diff` :

```console
$ git diff --stat main...feature/recherche
 recherche.js | 2 ++
 1 file changed, 2 insertions(+)
```

**Le détail d'un fichier** :

```console
$ git diff main...feature/recherche -- recherche.js
diff --git a/recherche.js b/recherche.js
new file mode 100644
index 0000000..f7aabde
--- /dev/null
+++ b/recherche.js
@@ -0,0 +1,2 @@
+recherche
+filtre
```

**Ce que j'ai modifié et pas encore commité**, sans aucune plage :

```console
$ git diff --stat
 recherche.js | 1 +
 1 file changed, 1 insertion(+)

$ git diff
diff --git a/recherche.js b/recherche.js
index f7aabde..093f8ac 100644
--- a/recherche.js
+++ b/recherche.js
@@ -1,2 +1,3 @@
 recherche
 filtre
+tri
```

## Pourquoi ça marche

Pour **`git log`**, `A..B` veut dire « les commits atteignables depuis B mais pas depuis A » : ce que B a en plus. `A...B` veut dire « les commits qui sont d'un seul côté », les deux différences réunies ; `--left-right` indique de quel côté est chacun.

Pour **`git diff`**, il n'y a pas de liste de commits, seulement deux états à comparer. `git diff A B` compare A et B tels quels. `git diff A...B` compare **l'ancêtre commun** de A et B avec B : c'est « ce que B a changé depuis qu'il a quitté A », sans tenir compte de ce que A a fait depuis. C'est presque toujours ce qu'on veut avant une pull request, et c'est exactement ce que GitHub affiche dans l'onglet « Files changed ».

Les deux notations sont nées séparément, pour des commandes différentes, et Git n'a jamais pu les réconcilier sans tout casser. Retenir : avec `log`, deux points ; avec `diff`, trois points.

## Pièges

- **`git diff main feature/recherche`**, sans points, compare les deux branches telles quelles : la page contact ajoutée sur `main` apparaît comme **supprimée** par ta branche, alors que tu n'y as pas touché. C'est l'erreur classique, et la raison d'être des trois points.
- **`git diff` seul** montre les modifications pas encore ajoutées à l'index ; `git diff --staged` montre celles déjà ajoutées par `git add`, prêtes à être commitées.
- **`--stat`** d'abord, pour une vue d'ensemble ; `-- chemin` ensuite, pour un fichier ou un dossier.
- **`git log -p main..feature/recherche`** montre les commits avec leur diff, commit par commit : utile pour relire son travail avant de le soumettre.

## Voir aussi

- [Supprimer une vieille branche sans rien perdre](/situations/quotidien/supprimer-une-vieille-branche-sans-rien-perdre/), qui utilise `main..branche` pour vérifier qu'il ne reste rien
- [Mettre mon travail en cours de côté pour changer de branche](/situations/quotidien/mettre-son-travail-de-cote/)
- Commandes : *log*, *diff* (à venir)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/situations/voir-ce-qui-a-change.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/voir-ce-qui-a-change.sh), exécuté avec Git 2.50 le 5 octobre 2026. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
