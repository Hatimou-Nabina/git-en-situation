---
title: Les commits conventionnels
description: Un format de message de commit, « type(scope) - sujet », qui rend l'historique lisible, filtrable, et exploitable pour un changelog. Les types, les règles, un garde-fou en six lignes, et ce qu'en fait GitHub.
level: debutant
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
sidebar:
  order: 2
---

## Ce que ça évite

Un historique fait de « update », « fix », « wip » et « encore un essai », où il faut ouvrir chaque commit pour savoir ce qu'il contient. Un changelog écrit à la main, donc jamais à jour. Une mise en production dont personne ne sait si elle casse quelque chose. Et des relectures qui commencent par « tu peux m'expliquer ce que fait ce commit ? ».

La convention tient en une ligne : `type(scope): sujet`. Le type dit la nature du changement, le scope la partie du projet, le sujet ce que le commit fait.

## Comment on fait

Un historique qui se lit sans ouvrir les commits :

```console
$ git log --oneline main..HEAD
e22aa48 feat(api)!: renomme le champ query en q
2b06085 docs: explique le filtre de recherche
027737a fix(recherche): ignore les espaces en debut de saisie
2d5fb23 test(recherche): couvre la recherche vide
be23af6 feat(recherche): ajoute la barre de recherche
```

**Les types**, et il n'en faut pas plus :

| Type | Pour |
|---|---|
| `feat` | une fonctionnalité nouvelle, visible par l'utilisateur |
| `fix` | une correction de défaut |
| `docs` | la documentation seule |
| `refactor` | un changement de code qui ne change ni comportement ni défaut |
| `perf` | une amélioration de performance |
| `test` | des tests ajoutés ou corrigés |
| `build`, `ci` | l'outillage de build, la CI |
| `chore` | l'entretien qui ne rentre nulle part ailleurs : dépendances, configuration |
| `revert` | l'annulation d'un commit précédent |

**Le scope** est facultatif et nomme la partie du projet : `auth`, `recherche`, `api`. **Le sujet** est à l'impératif, sans majuscule ni point final, et tient en soixante-douze caractères : il complète la phrase « ce commit va … ».

Le type sert à filtrer :

```console
$ git log --oneline --grep='^feat' main..HEAD
e22aa48 feat(api)!: renomme le champ query en q
be23af6 feat(recherche): ajoute la barre de recherche

$ git log --oneline --grep='^fix' main..HEAD
027737a fix(recherche): ignore les espaces en debut de saisie
```

**Le corps dit pourquoi**, ce que le diff ne dit jamais. **Le pied de page relie** : `Closes #12` pour une issue, `BREAKING CHANGE:` pour un changement qui casse les utilisateurs, aussi signalé par le `!` après le type :

```console
$ git log -1 --format='%B'
feat(api)!: renomme le champ query en q

Le nom query devenait ambigu avec le parametre de pagination,
qui s appelle aussi query dans la bibliotheque HTTP.

BREAKING CHANGE: les clients doivent envoyer q au lieu de query.
Closes #12
```

Et le bilan d'un lot de commits se calcule, pour un changelog ou une note de version :

```console
$ git log --format='%s' main..HEAD | sed -E 's/^([a-z]+).*/\1/' | sort | uniq -c
      1 docs
      2 feat
      1 fix
      1 test
```

**Un garde-fou local**, en six lignes, dans `.git/hooks/commit-msg`. Git l'exécute avant chaque commit et refuse ce qui ne suit pas le format :

```console
$ cat .git/hooks/commit-msg
#!/usr/bin/env bash
# Refuse un message qui ne suit pas « type(scope): sujet ».
if ! head -1 "$1" | grep -Eq '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9-]+\))?!?: .+'; then
  echo "Message refuse. Attendu : type(scope): sujet, par exemple fix(auth): corrige la deconnexion" >&2
  exit 1
fi

$ git commit -m "update stuff"
Message refuse. Attendu : type(scope): sujet, par exemple fix(auth): corrige la deconnexion

$ git commit -m "chore: ajoute x.txt"
[feature/recherche 550549b] chore: ajoute x.txt
 1 file changed, 1 insertion(+)
 create mode 100644 x.txt
```

Un hook n'est pas versionné : chacun l'installe, ou l'équipe passe par un outil partagé, `commitlint` avec `husky` dans un projet Node, qui fait la même chose depuis le dépôt.

## Sur GitHub

- **Le titre de la pull request** suit le même format. Avec « Squash and merge », il devient le message du commit unique sur `main` : c'est lui qu'on lira ensuite.
- **`Closes #12`** dans un commit ou une description de PR ferme l'issue à la fusion.
- **Les notes de version automatiques** de GitHub regroupent par étiquette de PR, pas par type de commit. Des outils comme `release-please` ou `semantic-release` lisent les types pour calculer le numéro de version et écrire le changelog : [Tenir un changelog](/equipe/tenir-un-changelog/).

## Pièges

- **`chore` comme fourre-tout.** Si tu hésites, c'est souvent un `refactor`, un `build` ou un `docs`. Un historique où un commit sur trois est `chore` n'informe plus.
- **Un commit, deux natures.** « feat(recherche): ajoute le filtre et corrige le tri » cache un `fix` dans un `feat`. Deux commits.
- **Mentir sur le type**, un `refactor` qui change le comportement, un `fix` qui ajoute une option : la convention ne vaut que par la confiance qu'on peut lui accorder.
- **Oublier le `!`** sur un changement qui casse les utilisateurs : c'est précisément l'information qui doit sauter aux yeux.
- **Deux langues dans le même historique.** Choisir une fois, pour tout le projet ; ce site a choisi le français, à l'impératif.
- **Retoucher un message après le push** réécrit le commit : voir [Annuler mon dernier commit, pas encore poussé](/situations/reparer/annuler-mon-dernier-commit/) et ses limites.

## Voir aussi

- [La pull request, de l'ouverture à la fusion](/equipe/la-pull-request/)
- [Un commit, c'est un instantané](/comprendre/un-commit-est-un-instantane/)
- La spécification : [conventionalcommits.org](https://www.conventionalcommits.org/fr/)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/equipe/commits-conventionnels.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/equipe/commits-conventionnels.sh), exécuté avec Git 2.50 le 5 octobre 2026, hook compris. Seuls les identifiants de commit sont ceux du dépôt d'exemple.
:::
