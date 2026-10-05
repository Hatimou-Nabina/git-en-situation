---
title: .gitignore ne marche pas, le fichier est déjà suivi
description: Tu as ajouté .env au .gitignore, et git status continue de le voir modifié. Pourquoi les règles d'ignorance ne s'appliquent pas à un fichier déjà suivi, comment le retirer du suivi sans l'effacer, et l'autre cause classique, un .gitignore illisible.
level: debutant
risk: aucun
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptôme

Tu ajoutes `.env` au `.gitignore`. Git continue de le voir, et `git check-ignore`, l'outil fait pour vérifier les règles, ne répond rien :

```console
$ echo ".env" > .gitignore

$ echo "SECRET=def" > .env

$ git status --short
 M .env
?? .gitignore

$ git check-ignore -v .env
```

## Diagnostic

Le `.gitignore` ne concerne que les fichiers que Git **ne suit pas encore**. Un fichier déjà commité est suivi, et les règles d'ignorance ne s'appliquent plus à lui : Git continue de surveiller ses modifications, quoi que dise le `.gitignore`. La liste des fichiers suivis le confirme :

```console
$ git ls-files
.env
README.md
app.js
```

Le silence de `git check-ignore` n'est pas une erreur : pour un fichier suivi, il ne dit rien, précisément parce que les règles ne le concernent pas.

## Solution

**Retire le fichier du suivi, sans le supprimer du disque.** C'est le rôle de `--cached` :

```console
$ git rm --cached .env
rm '.env'

$ git status --short
D  .env
?? .gitignore
```

Commite cette suppression avec le `.gitignore`. Le fichier est toujours là, et cette fois la règle s'applique :

```console
$ git add .gitignore && git commit -q -m "Ignore le fichier .env"

$ git status --short

$ ls -a
.
..
.env
.git
.gitignore
README.md
app.js

$ git check-ignore -v .env
.gitignore:1:.env	.env
```

`check-ignore -v` dit quel fichier et quelle ligne ont décidé : `.gitignore`, ligne 1.

**Autre cause : un `.gitignore` que Git ne sait pas lire.** Sous Windows, `echo node_modules/ > .gitignore` dans PowerShell 5 écrit le fichier en UTF-16. Les règles ont l'air correctes dans l'éditeur, et Git n'en applique aucune :

```console
$ git status --short
 M .gitignore
?? .env
?? node_modules/

$ git check-ignore -v node_modules/lib.js

$ od -An -c -N 8 .gitignore
 377 376   n  \0   o  \0   d  \0
```

Les deux premiers octets, `377 376`, et les `\0` entre chaque lettre trahissent l'encodage. Réenregistre le fichier en UTF-8, depuis l'éditeur ou en ligne de commande :

```console
$ iconv -f UTF-16 -t UTF-8 .gitignore > .gitignore.utf8 && mv .gitignore.utf8 .gitignore

$ od -An -c -N 8 .gitignore
   n   o   d   e   _   m   o   d

$ git check-ignore -v node_modules/lib.js
.gitignore:1:node_modules/	node_modules/lib.js

$ git status --short
 M .gitignore
?? .env
```

## Pourquoi ça marche

Git tient la liste des fichiers suivis dans l'**index**. Les règles du `.gitignore` ne sont consultées qu'au moment de décider quoi faire des fichiers qui n'y sont pas : les afficher comme « untracked », ou les taire. `git rm --cached` retire une entrée de l'index sans toucher au disque ; au commit suivant, le fichier n'est plus suivi, et il redevient un candidat aux règles d'ignorance.

`git check-ignore -v` existe pour déboguer ces règles : il rejoue la décision de Git pour un chemin et cite la ligne responsable. `--no-index` force la vérification même pour un fichier suivi.

## Pièges

- **Chez les collègues, le prochain `pull` supprime le fichier.** Le commit « retire `.env` du suivi » efface le fichier chez tous ceux qui le récupèrent, Git appliquant la suppression. Préviens-les de sauvegarder leur `.env` avant de tirer, ou de le recréer après.
- **Un secret dans ce fichier est toujours dans l'historique.** Retirer du suivi ne retire pas des commits passés : [J'ai poussé un secret par erreur](/situations/fichiers/secret-pousse-par-erreur/).
- **La syntaxe des règles** : `node_modules/` ignore un dossier partout, `/dist` seulement à la racine, `*.log` tous les journaux. `git check-ignore -v` tranche en cas de doute.
- **Ce qui ne regarde que toi**, fichiers de l'éditeur, `.DS_Store`, a sa place dans un `.gitignore` global (`git config --global core.excludesFile ~/.gitignore_global`) ou dans `.git/info/exclude`, plutôt que dans le `.gitignore` du projet.

## Voir aussi

- [J'ai poussé un secret par erreur](/situations/fichiers/secret-pousse-par-erreur/)
- [Travailler sur le même projet depuis deux machines](/situations/avec-les-autres/travailler-depuis-deux-machines/)
- [Travailler en équipe : les secrets ne vont jamais dans le dépôt](/equipe/secrets-jamais-dans-le-depot/)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/situations/gitignore-fichier-deja-suivi.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/gitignore-fichier-deja-suivi.sh), exécuté avec Git 2.50 le 5 octobre 2026. Le `.gitignore` en UTF-16 y est fabriqué avec `iconv`, tel que PowerShell 5 l'écrirait. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
