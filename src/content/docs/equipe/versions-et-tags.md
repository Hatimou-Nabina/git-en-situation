---
title: Versions et tags
description: Le versionnage sémantique, le tag annoté qui marque la version, le push qui ne l'emporte pas tout seul, describe pour savoir où on en est, la version qui contient un correctif, et la release GitHub qui s'appuie dessus.
level: debutant
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
sidebar:
  order: 9
---

## Ce que ça évite

« Ça marche pas », sans savoir quelle version la personne utilise. Une version en production qu'on ne sait plus reconstruire, parce que personne ne sait quel commit c'était. Un correctif dont on ignore s'il est livré. Et des utilisateurs qui mettent à jour sans savoir si ça va casser quelque chose chez eux.

Un tag est un nom posé sur un commit, pour toujours. Le numéro suit le versionnage sémantique, `MAJEUR.MINEUR.CORRECTIF` : le correctif répare sans rien changer d'autre, le mineur ajoute sans casser, le majeur casse quelque chose. Avec des [commits conventionnels](/equipe/commits-conventionnels/), le numéro se déduit : un `fix` incrémente le correctif, un `feat` le mineur, un `!` le majeur.

## Comment on fait

**1. Un tag annoté sur le commit de la version.** Annoté, `-a`, c'est un objet à part entière, avec un auteur, une date et un message, et non un simple pointeur. Pour une version, toujours annoté.

```console
$ git tag -a v1.2.0 -m "Version 1.2.0 : barre de recherche, correctif de l export"

$ git show --no-patch v1.2.0
tag v1.2.0
Tagger: Awa <awa@example.com>
Date:   Mon Oct 5 10:00:00 2026 +0000

Version 1.2.0 : barre de recherche, correctif de l export

commit 52ac0b8594bd1babc13295e0aaef5760108b3275
Author: Awa <awa@example.com>
Date:   Mon Oct 5 10:00:00 2026 +0000

    fix(export): corrige l export d une liste vide

$ git cat-file -t v1.2.0
tag

$ git tag -n
v1.2.0          Version 1.2.0 : barre de recherche, correctif de l export
```

Un tag sans `-a` est dit léger : `cat-file -t` répondrait `commit`, il n'aurait ni auteur ni date. Pratique pour un repère personnel, pas pour une version.

**2. Les tags ne partent pas tout seuls.** `git push` pousse la branche, pas les tags. Le serveur n'en sait rien tant qu'on ne le lui dit pas :

```console
$ git push
Everything up-to-date

$ git ls-remote --tags origin

$ git push origin v1.2.0
To github.com:equipe/projet.git
 * [new tag]         v1.2.0 -> v1.2.0

$ git ls-remote --tags origin
7e40c7027e23867e3a3d59f039295ea2600dc665	refs/tags/v1.2.0
52ac0b8594bd1babc13295e0aaef5760108b3275	refs/tags/v1.2.0^{}
```

Les deux lignes du serveur : l'objet tag, et le commit qu'il désigne (`^{}`). `git push --follow-tags` pousse la branche et les tags annotés qui la concernent en un coup ; `git config --global push.followTags true` en fait la règle.

**3. Où en est-on par rapport à la dernière version ?** `describe` répond en un mot : la dernière version, le nombre de commits depuis, et le commit courant.

```console
$ git describe --tags
v1.2.0-2-gb12af3f

$ git log --oneline v1.2.0..HEAD
b12af3f feat(recherche): ajoute le tri par date
e52305a feat(recherche): ajoute les filtres
```

`v1.2.0-2-gb12af3f` : deux commits après la 1.2.0, sur `b12af3f`. C'est la chaîne à afficher dans un `--version` ou un pied de page, pour qu'un rapport de bug dise exactement d'où il vient.

**4. Dans quelle version ce correctif est-il arrivé ?** La question du support, à laquelle `--contains` répond :

```console
$ git log --oneline --all --grep='fix(export)'
52ac0b8 fix(export): corrige l export d une liste vide

$ git tag --contains 52ac0b8
v1.2.0
```

**5. Revenir à une version pour la reconstruire.** Le tag est une adresse comme une autre : on s'y place, on construit, on revient.

```console
$ git switch --detach v1.2.0
HEAD is now at 52ac0b8 fix(export): corrige l export d une liste vide

$ git describe --tags
v1.2.0

$ git switch main
Previous HEAD position was 52ac0b8 fix(export): corrige l export d une liste vide
Switched to branch 'main'
Your branch is up to date with 'origin/main'.
```

Tu es alors en « detached HEAD », l'état normal pour regarder sans toucher : [Je suis en « detached HEAD »](/situations/reparer/detached-head/).

**6. Chez un collègue, les tags arrivent avec `fetch`**, du moins ceux qui désignent des commits récupérés :

```console
$ git fetch
From github.com:equipe/projet
   d0a0b32..b12af3f  main       -> origin/main
 * [new tag]         v1.2.0     -> v1.2.0

$ git tag
v1.2.0
```

## Sur GitHub

- **Une release est un tag habillé** : Releases → « Draft a new release », choisir ou créer le tag, un titre, des notes, des fichiers à télécharger. « Generate release notes » rédige un brouillon depuis les PR fusionnées depuis le tag précédent. Depuis le terminal : `gh release create v1.2.0 --generate-notes`.
- **L'onglet Tags** liste les tags, chacun avec une archive `.zip` et `.tar.gz` du code à ce commit.
- **Une release déclenche un workflow** : `on: push: tags: ['v*']` ou `on: release: types: [published]`, pour construire et publier automatiquement.
- **Les tags se protègent** par un ruleset de tags (Settings → Rules), pour que personne ne supprime ni ne déplace `v*`. Une règle de branche ne les couvre pas : [Protéger la branche principale](/equipe/proteger-la-branche-principale/).
- **Le changelog et la release se complètent** : la release reprend la section du [changelog](/equipe/tenir-un-changelog/) qui porte le même numéro.

## Pièges

- **Oublier de pousser le tag.** Le poste a la version, le serveur non, la CI ne construit rien. `push.followTags` règle ça une fois pour toutes.
- **Déplacer un tag déjà publié.** Un tag est une promesse : ceux qui l'ont récupéré gardent l'ancien, et leur `fetch` ne le met pas à jour sans option. Si la version est fausse, on publie la suivante, `v1.2.1`.
- **Taguer la mauvaise branche**, un commit de `feature/x` plutôt que de `main` : la version contient du travail non relu. Taguer depuis `main` à jour.
- **Un tag léger pour une version** : pas d'auteur, pas de date, pas de message. On ne sait plus qui a livré ni quand.
- **`0.x` pour toujours.** Tant que le majeur est `0`, tout peut casser à chaque mineur, et les utilisateurs le savent. Passer en `1.0.0` quand quelqu'un dépend du projet.
- **Un tag supprimé sur le serveur reste chez les collègues** : `git fetch --prune --prune-tags` les met au niveau.

## Voir aussi

- [Tenir un changelog](/equipe/tenir-un-changelog/)
- [Branche de travail et branche de production](/equipe/branche-de-travail-et-de-production/)
- [Les commits conventionnels](/equipe/commits-conventionnels/)
- [Je suis en « detached HEAD »](/situations/reparer/detached-head/)
- Versionnage sémantique : [semver.org](https://semver.org/lang/fr/)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/equipe/versions-et-tags.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/equipe/versions-et-tags.sh), exécuté avec Git 2.50 le 6 octobre 2026. La release GitHub ne se rejoue pas dans un bac à sable et est décrite, pas exécutée. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
