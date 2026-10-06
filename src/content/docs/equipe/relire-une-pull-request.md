---
title: Relire une pull request
description: Ce qu'on regarde, dans quel ordre, comment formuler une remarque, quand approuver. La relecture depuis ton poste, avec les commandes qui vérifient plutôt que croire, et ce que GitHub ajoute.
level: intermediaire
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
sidebar:
  order: 6
---

## Ce que ça évite

Une PR approuvée en trente secondes, « LGTM », qui casse la production le lendemain. Une remarque qui blesse, et un auteur qui n'ose plus ouvrir de PR. Un relecteur qui lit le diff sur GitHub sans jamais lancer le code, et qui laisse passer l'appel oublié que les tests ne couvrent pas. Et la PR qui attend une semaine parce que « relire, c'est pas du vrai travail ».

Relire, c'est la seconde paire d'yeux que la pull request promet. Ça se fait vite, mais pas en survol : on vérifie plutôt que croire, on dit ce qu'on voit, et on approuve quand on serait d'accord pour maintenir ce code.

## Comment on fait

**Dans quel ordre regarder.** D'abord la description : qu'est-ce que la PR dit faire, et pourquoi ? Ensuite l'exactitude : est-ce qu'elle le fait, sans casser autre chose ? Puis la clarté : est-ce que quelqu'un comprendra ce code dans six mois ? La forme en dernier, et seulement si l'équipe n'a pas d'outil qui s'en charge.

**1. Récupérer la branche sur ton poste.** Lire un diff sur GitHub ne suffit pas pour une PR qui touche à la logique : il faut pouvoir chercher, lancer, essayer.

```console
$ git fetch
From github.com:equipe/projet
 * [new branch]      feature/recherche-options -> origin/feature/recherche-options

$ git switch feature/recherche-options
Switched to a new branch 'feature/recherche-options'
branch 'feature/recherche-options' set up to track 'origin/feature/recherche-options'.
```

**2. L'ensemble, puis commit par commit.** Les commits dans l'ordre où ils ont été écrits racontent l'intention ; le diff global dit l'étendue.

```console
$ git log --oneline --reverse main..HEAD
43b273d refactor(recherche): renomme chercher en rechercher, ajoute l option sensibleCasse
dea5fe5 test(recherche): couvre la casse

$ git diff --stat main...HEAD
 recherche.js      | 5 +++--
 recherche.test.js | 1 +
 2 files changed, 4 insertions(+), 2 deletions(-)

$ git show --format='%h %s' HEAD~1
43b273d refactor(recherche): renomme chercher en rechercher, ajoute l option sensibleCasse

diff --git a/recherche.js b/recherche.js
index 7dddfee..c47c90b 100644
--- a/recherche.js
+++ b/recherche.js
@@ -1,3 +1,4 @@
-function chercher(terme) {
-  return index.filter(e => e.includes(terme));
+function rechercher(terme, options = {}) {
+  const base = options.sensibleCasse ? index : index.map(e => e.toLowerCase());
+  return base.filter(e => e.includes(terme));
 }
```

Le commit dit « refactor » et renomme une fonction. Première question de relecteur : qui l'appelait ?

**3. Vérifier plutôt que croire.** Le diff ne montre que ce qui a changé, pas ce qui aurait dû changer. Le test est vert, et pourtant :

```console
$ git grep -nw chercher
page.js:1:const resultats = chercher(saisie);
```

`page.js` appelle encore l'ancien nom. La page cassera au premier chargement, et aucun test ne le dit. C'est la remarque à faire, et GitHub ne t'aurait pas aidé à la trouver : elle porte sur un fichier que la PR ne touche pas. Lancer les tests et l'application fait partie du même geste.

**Formuler la remarque.** Sur le code, jamais sur la personne ; précise, avec le fichier et la ligne ; et qui distingue ce qui bloque de ce qui est une préférence. « `page.js` appelle encore `chercher`, la page va planter au chargement » suffit. Une question vaut souvent mieux qu'un ordre : « Est-ce voulu que la recherche devienne insensible à la casse par défaut ? » Et dire ce qui est bien n'est pas de la politesse : c'est aussi une information.

**4. Après le correctif, ne relire que ce qui a changé.** L'auteur a ajouté un commit, pas réécrit la branche : tu vois exactement ce qui a bougé depuis ta lecture.

```console
$ git fetch
From github.com:equipe/projet
   dea5fe5..7d900da  feature/recherche-options -> origin/feature/recherche-options

$ git log --oneline HEAD..origin/feature/recherche-options
7d900da fix(recherche): met a jour l appel dans page.js

$ git diff HEAD origin/feature/recherche-options
diff --git a/page.js b/page.js
index da79d5b..9a23df8 100644
--- a/page.js
+++ b/page.js
@@ -1 +1 @@
-const resultats = chercher(saisie);
+const resultats = rechercher(saisie);

$ git pull --ff-only
Updating dea5fe5..7d900da
Fast-forward
 page.js | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

$ git grep -nw chercher
```

Plus aucun appel. **Quand approuver ?** Quand tu serais d'accord pour maintenir ce code toi-même : il fait ce que la description annonce, tu l'as vu tourner, tu le comprends. Pas quand il est parfait, ni écrit comme tu l'aurais écrit.

**5. Après la fusion, le ménage** sur ton poste, comme pour tes propres branches :

```console
$ git switch main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.

$ git pull --ff-only
From github.com:equipe/projet
   eebbc04..f7979a4  main       -> origin/main
Updating eebbc04..f7979a4
Fast-forward
 page.js           | 2 +-
 recherche.js      | 5 +++--
 recherche.test.js | 1 +
 3 files changed, 5 insertions(+), 3 deletions(-)
 create mode 100644 recherche.test.js

$ git fetch --prune
From github.com:equipe/projet
 - [deleted]         (none)     -> origin/feature/recherche-options

$ git branch -d feature/recherche-options
Deleted branch feature/recherche-options (was 7d900da).
```

## Sur GitHub

- **`gh pr checkout 14`** fait les deux premières commandes d'un coup ; `gh pr diff 14` montre le diff sans changer de branche.
- **« Files changed »** : la case « Viewed » sur chaque fichier garde ta progression ; « Start a review » regroupe tes remarques, qui partent ensemble avec un verdict, plutôt qu'en rafale de notifications.
- **Les suggestions** : un bloc ` ```suggestion ` dans un commentaire propose le texte de remplacement, que l'auteur applique en un clic. Pour une faute, c'est plus court qu'une remarque.
- **Les trois verdicts** : « Comment » quand rien ne bloque, « Request changes » quand quelque chose doit changer avant la fusion, « Approve » quand tu es prêt à maintenir ce code. « Request changes » bloque la fusion tant que tu n'as pas réapprouvé.
- **« Changes since your last review »** fait, sur GitHub, ce que le `git diff` de l'étape 4 fait sur ton poste.
- **Chaque conversation se résout** quand la remarque est traitée ; la règle « Require conversation resolution » dans la protection de `main` empêche de fusionner avec une conversation ouverte.
- **`CODEOWNERS`** désigne les relecteurs automatiquement, par chemin de fichier.

## Pièges

- **Approuver ce qu'on n'a pas compris.** Si tu ne peux pas expliquer ce que fait la PR, tu ne peux pas l'approuver. Demander une explication est une relecture utile.
- **Ne relire que la forme.** Vingt remarques sur les noms de variables et aucune sur la logique : l'outil de formatage s'occupe de la forme, le relecteur de ce que l'outil ne voit pas.
- **Réécrire la PR dans les commentaires.** Si tu aurais fait autrement, dis-le une fois, et laisse l'auteur décider, sauf si c'est faux.
- **Bloquer pour une préférence.** Un « Request changes » se réserve à ce qui est incorrect, dangereux ou contraire à ce que l'équipe a décidé. Le reste est un commentaire.
- **Laisser attendre.** Une PR relue dans la journée est fusionnée avant que `main` ait bougé. Relire passe avant commencer autre chose.
- **Commiter sur la branche de l'auteur** pendant la relecture : les correctifs sont à l'auteur, sauf accord. La relecture propose, elle n'impose pas par le code.

## Voir aussi

- [La pull request, de l'ouverture à la fusion](/equipe/la-pull-request/)
- [Une branche par changement](/equipe/une-branche-par-changement/)
- [Voir ce qui a changé entre ma branche et main](/situations/quotidien/voir-ce-qui-a-change/)
- [Après un clone, je ne vois pas les branches des autres](/situations/quotidien/branches-invisibles-apres-clone/)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/equipe/relire-une-pull-request.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/equipe/relire-une-pull-request.sh), exécuté avec Git 2.50 le 6 octobre 2026. Awa y ouvre la PR, Bakary la relit depuis son poste, et la fusion « par GitHub » est jouée par Awa. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
