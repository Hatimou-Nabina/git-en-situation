---
title: Tenir un changelog
description: Pour qui, à quel moment, et ce qu'il contient. Une section « Non publié » que chaque pull request alimente, le conflit classique sur cette section et l'attribut qui l'évite, le brouillon tiré des commits conventionnels, et la version qui prend un numéro et une date.
level: debutant
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
sidebar:
  order: 8
---

## Ce que ça évite

« Qu'est-ce qui a changé depuis la dernière version ? », et deux cents commits à relire pour répondre. Des utilisateurs surpris par un changement qui casse leur usage, annoncé nulle part. Des notes de version écrites de mémoire le soir de la livraison, forcément incomplètes. Et, pour un projet qu'on reprend sur une autre machine ou après trois mois, la perte du fil : ce site tient son propre changelog d'abord pour ça.

Un changelog dit ce qui change pour celui qui utilise le projet, pas comment le code a bougé. Il s'écrit au fil de l'eau, dans la pull request qui apporte le changement, et se ferme à chaque version.

## Comment on fait

**1. Le fichier.** `CHANGELOG.md` à la racine, au format [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/) : une section « Non publié » en haut, puis une section par version, la plus récente d'abord, chacune datée et découpée en « Ajouté », « Modifié », « Corrigé », « Supprimé », « Sécurité » selon ce qu'elle contient.

```console
$ cat CHANGELOG.md
# Changelog

Les évolutions notables du projet, pour ceux qui l'utilisent. Format : Keep a Changelog ; numéros : versionnage sémantique.

## [Non publié]

## [1.1.0] - 2026-09-20

### Ajouté
- Recherche dans les documents, avec un filtre par date.

### Corrigé
- L'export d'une liste vide ne plante plus.
```

**2. La ligne du changelog voyage dans le même commit que le changement.** Pas de PR sans sa ligne, pas de ligne sans sa PR : le relecteur la relit avec le reste, et la section « Non publié » est toujours à jour.

```console
$ git show --stat --format='%h %s' HEAD
ac88ea6 feat(export): ajoute l export CSV

 CHANGELOG.md | 3 +++
 export.js    | 1 +
 2 files changed, 4 insertions(+)

$ git log --oneline -- CHANGELOG.md
ac88ea6 feat(export): ajoute l export CSV
a0cbc71 docs: ajoute le changelog
```

La ligne s'adresse au lecteur : « Export CSV des résultats de recherche », pas « refactor du module export ». Si le changement casse un usage, le dire en toutes lettres.

**3. Deux pull requests touchent la même section : le conflit.** C'est le défaut connu de cette méthode. Bakary a ajouté sa ligne au même endroit, sans avoir le commit d'Awa :

```console
$ git pull --rebase
From github.com:equipe/projet
   a0cbc71..ac88ea6  main       -> origin/main
Auto-merging CHANGELOG.md
CONFLICT (content): Merge conflict in CHANGELOG.md
Rebasing (1/1)error: could not apply 91c1661... fix(recherche): ignore les accents
hint: Resolve all conflicts manually, mark them as resolved with
hint: "git add/rm <conflicted_files>", then run "git rebase --continue".
hint: You can instead skip this commit: run "git rebase --skip".
hint: To abort and get back to the state before "git rebase", run "git rebase --abort".
hint: Disable this message with "git config set advice.mergeConflict false"
Could not apply 91c1661... # fix(recherche): ignore les accents

$ sed -n "5,16p" CHANGELOG.md
## [Non publié]

<<<<<<< HEAD
### Ajouté
- Export CSV des résultats de recherche.
=======
### Corrigé
- La recherche ignore désormais les accents.
>>>>>>> 91c1661 (fix(recherche): ignore les accents)

## [1.1.0] - 2026-09-20

```

Le conflit est trivial, il faut garder les deux, mais il revient à chaque PR. [Un conflit pendant un merge ou un rebase](/situations/reparer/resoudre-un-conflit/) explique la résolution à la main ; ici, on abandonne pour montrer mieux :

```console
$ git rebase --abort
```

**4. L'éviter une fois pour toutes : `merge=union` pour ce fichier.** Une ligne dans `.gitattributes`, versionnée, dit à Git que pour ce fichier, en cas de conflit, il faut garder les deux côtés plutôt que demander :

```console
$ cat .gitattributes
CHANGELOG.md merge=union
```

Le même `pull --rebase` passe, et les deux lignes sont là :

```console
$ git pull --rebase
From github.com:equipe/projet
   ac88ea6..dc9a44a  main       -> origin/main
Rebasing (1/1)Successfully rebased and updated refs/heads/main.

$ sed -n "5,12p" CHANGELOG.md
## [Non publié]

### Ajouté
- Export CSV des résultats de recherche.
### Corrigé
- La recherche ignore désormais les accents.

## [1.1.0] - 2026-09-20
```

La ligne vide entre les deux blocs a sauté : on remet en forme au moment de la version. `union` ne vaut que pour un fichier où « les deux » est toujours la bonne réponse ; sur du code, ce serait une catastrophe silencieuse.

**5. Le brouillon de la version, depuis les commits.** Si l'équipe suit les [commits conventionnels](/equipe/commits-conventionnels/), la liste de ce qui a changé depuis le dernier tag se calcule, et sert à vérifier que rien n'a été oublié dans « Non publié » :

```console
$ git log --format='- %s' --grep='^feat' v1.1.0..HEAD
- feat(export): ajoute l export CSV

$ git log --format='- %s' --grep='^fix' v1.1.0..HEAD
- fix(recherche): ignore les accents
```

C'est un brouillon, pas le changelog : il parle en termes de code, le changelog parle en termes d'usage.

**6. À la version, la section prend un numéro et une date**, une section « Non publié » vide reste au-dessus, et un tag marque le commit :

```console
$ git diff HEAD~1 -- CHANGELOG.md
diff --git a/CHANGELOG.md b/CHANGELOG.md
index 555cd39..b4b6af2 100644
--- a/CHANGELOG.md
+++ b/CHANGELOG.md
@@ -4,8 +4,11 @@ Les évolutions notables du projet, pour ceux qui l'utilisent. Format : Keep a C

 ## [Non publié]

+## [1.2.0] - 2026-10-05
+
 ### Ajouté
 - Export CSV des résultats de recherche.
+
 ### Corrigé
 - La recherche ignore désormais les accents.


$ git log --oneline v1.1.0..v1.2.0
217f1a1 chore(release): version 1.2.0
0727b29 fix(recherche): ignore les accents
dc9a44a chore: fusion par union pour le changelog
ac88ea6 feat(export): ajoute l export CSV
```

Le numéro suit le versionnage sémantique : *Versions et tags* (à venir) détaille le choix du numéro et le tag.

## Sur GitHub

- **Les notes de version automatiques** (« Generate release notes » dans une release) listent les PR fusionnées depuis le tag précédent, groupées par étiquette. Un bon brouillon, pas un changelog : elles parlent de PR, pas d'usage.
- **`release-please`** maintient `CHANGELOG.md` tout seul depuis les commits conventionnels, en ouvrant une PR de version qu'il suffit de fusionner. Pour une équipe qui écrit bien ses commits, c'est le changelog sans l'effort.
- **Un lien par version** vers la comparaison GitHub, en bas du fichier : `[1.2.0]: https://github.com/equipe/projet/compare/v1.1.0...v1.2.0`. Keep a Changelog le prévoit, et le lecteur passe du résumé au détail en un clic.
- **Le changelog de ce site** est tenu de cette façon : [CHANGELOG.md](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/CHANGELOG.md), une section par lot, avec le numéro de la PR qui l'a mis en ligne.

## Pièges

- **Le changelog qui recopie `git log`.** Si c'est la même chose, il ne sert à rien ; sa valeur est de traduire pour le lecteur.
- **L'écrire à la version**, de mémoire. On oublie, et on se trompe. La ligne se pose dans la PR, quand le changement est frais.
- **La section « Non publié » jamais vidée**, qui grossit pendant six mois : c'est le signe qu'il n'y a pas eu de version, et qu'il en faudrait une.
- **Le changement qui casse, noyé dans « Modifié ».** Il mérite une mention en tête de section, en toutes lettres : ce qui ne marchera plus, et ce qu'il faut faire.
- **La date ambiguë.** `2026-10-05` se lit partout ; `05/10/2026` se lit de deux façons.
- **`merge=union` sur autre chose qu'un changelog**, ou sans l'avoir expliqué dans le dépôt : un contributeur qui ne le sait pas ne comprendra pas pourquoi ce fichier ne crée jamais de conflit.

## Voir aussi

- [Les commits conventionnels](/equipe/commits-conventionnels/)
- [La pull request, de l'ouverture à la fusion](/equipe/la-pull-request/)
- [Un conflit pendant un merge ou un rebase](/situations/reparer/resoudre-un-conflit/)
- Keep a Changelog : [keepachangelog.com](https://keepachangelog.com/fr/1.1.0/)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/equipe/tenir-un-changelog.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/equipe/tenir-un-changelog.sh), exécuté avec Git 2.50 le 5 octobre 2026, conflit et `merge=union` compris. Le script réécrit les fichiers en entier plutôt qu'avec `sed -i`, qui diffère entre GNU et BSD. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
