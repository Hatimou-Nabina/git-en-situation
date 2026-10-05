---
title: Une CI qui vérifie ce que les postes ne voient pas
description: Le bit d'exécution, la casse des noms de fichiers, le fichier qui n'existe que sur ton poste, les fins de ligne. Pourquoi « ça marche chez moi » ne prouve rien, et un script de vérification que la CI lance à chaque push.
level: intermediaire
gitVersion: "2.55"
verified: 2026-10-05
published: 2026-10-05
sidebar:
  order: 11
---

## Ce que ça évite

« Ça marche chez moi. » Le script de déploiement qui échoue en production avec `Permission denied`. L'import qui marche sur tous les postes de l'équipe, sous Windows et macOS, et plante sur le serveur Linux parce que `Utils.js` n'est pas `utils.js`. Le fichier de configuration que tout le monde a, sauf la machine qui vient de cloner. Et les fins de ligne, [déjà vues sur ce site](/situations/fichiers/fins-de-ligne-crlf-lf/).

Un poste de travail cache beaucoup de choses : des fichiers que Git ne suit pas, des outils installés une fois, un système qui ferme les yeux sur la casse ou qui ignore les permissions. La CI, elle, part d'un clone vierge, sur Linux, avec rien d'autre que ce qui est dans le dépôt. C'est pour ça qu'elle voit ce que les postes ne voient pas, et c'est pour ça qu'il faut la laisser regarder.

## Comment on fait

**1. Un script qui marche sur ton poste et pas en CI : le bit d'exécution.** Sous Windows, les permissions Unix n'existent pas : un script commité depuis Windows arrive avec le mode `100644`, lisible mais pas exécutable. Tout le monde le lance avec `bash deploy.sh`, ce qui masque le problème ; la CI, elle, fait `./deploy.sh`.

```console
$ git ls-files -s deploy.sh
100644 5b13c5d70bcee9c5a9ab9d751c5e76e6e98b7492 0	deploy.sh

$ bash deploy.sh
deploiement ok

$ ./deploy.sh
bash: line 1: ./deploy.sh: Permission denied
```

La correction se fait dans le dépôt, pas sur le serveur. Sur Linux et macOS, `chmod +x` puis `git add` suffisent ; sous Windows, où le bit n'existe pas, `git update-index --chmod=+x` l'écrit directement dans l'index. Les deux ensemble donnent le même résultat partout :

```console
$ chmod +x deploy.sh

$ git update-index --chmod=+x deploy.sh

$ git ls-files -s deploy.sh
100755 5b13c5d70bcee9c5a9ab9d751c5e76e6e98b7492 0	deploy.sh
```

Chez un collègue, après le `pull`, le fichier arrive exécutable :

```console
$ ./deploy.sh
deploiement ok
```

**2. La casse des noms : ton poste ferme les yeux, Linux non.** Sous Windows et macOS, `Utils.js` et `utils.js` désignent le même fichier ; sous Linux, ce sont deux noms, et le second n'existe pas.

```console
$ cat app.js
import { util } from "./Utils.js";

$ test -f Utils.js && echo "trouve" || echo "introuvable"
introuvable

$ git ls-files | grep -i '^utils.js$'
utils.js
```

Sur ton poste, la deuxième commande aurait dit `trouve`. Ce que Git suit a une casse précise : `git ls-files` est la source de vérité, et le `grep -i` retrouve le vrai nom.

**3. Un fichier qui n'existe que sur ton poste.** Un fichier de configuration ignoré, un fichier généré, un fichier jamais ajouté : le code le lit, `git status` ne dit rien, et le clone de la CI ne l'a pas.

```console
$ git status --short

$ git ls-files --error-unmatch config.local.json
error: pathspec 'config.local.json' did not match any file(s) known to git
Did you forget to 'git add'?

$ ls config.local.json
ls: cannot access 'config.local.json': No such file or directory
```

`git status` est propre, et pourtant le fichier manque chez le collègue qui vient de cloner, dernière commande. `ls-files --error-unmatch` est le test à poser : il échoue si Git ne suit pas le fichier.

**4. Les vérifications qui attrapent ça, dans un script que la CI lance.** Les trois tests lisent l'index avec `git ls-files`, donc la même chose sur tous les systèmes. On le lance d'abord sur son poste :

```console
$ cat scripts/verifier.sh
#!/usr/bin/env bash
# Ce que les postes ne voient pas, la CI le vérifie à chaque push.
code=0
# 1. Fins de ligne : tout en LF dans le dépôt.
if git ls-files --eol | grep -q 'i/crlf'; then
  echo "Fichiers en CRLF dans le depot :"; git ls-files --eol | grep 'i/crlf'; code=1
fi
# 2. Les scripts shell sont exécutables.
if git ls-files -s -- '*.sh' | grep -qv '^100755'; then
  echo "Scripts sans bit d execution :"; git ls-files -s -- '*.sh' | grep -v '^100755'; code=1
fi
# 3. Pas deux fichiers dont le nom ne diffère que par la casse.
if git ls-files | sort -f | uniq -di | grep -q .; then
  echo "Noms en double a la casse pres :"; git ls-files | sort -f | uniq -di; code=1
fi
exit $code

$ bash scripts/verifier.sh; echo "code de sortie : $?"
Scripts sans bit d execution :
100644 07e2bd787cc4cf73bdb0d5644e6d55f117fd6fdc 0	scripts/verifier.sh
code de sortie : 1
```

Le script se prend lui-même la main dans le sac : il vient d'être créé sans bit d'exécution. Une fois corrigé, le code de sortie passe à zéro, et c'est ce code que la CI regarde :

```console
$ chmod +x scripts/verifier.sh

$ git update-index --chmod=+x scripts/verifier.sh

$ bash scripts/verifier.sh; echo "code de sortie : $?"
code de sortie : 0
```

Le workflow tient en huit lignes : un clone vierge sur Ubuntu, et le script.

```console
$ cat .github/workflows/verifier.yml
name: Vérifier
on: [push, pull_request]
jobs:
  verifier:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - run: bash scripts/verifier.sh
```

Ce site fait la même chose : à chaque pull request, un workflow construit le site sur Ubuntu et valide les liens, un autre rejoue tous les scripts des pages. Ce qui passe sur le poste Windows du mainteneur et pas là-bas est repéré avant la fusion. Cette page en est un exemple : ses sorties viennent de ce rejeu.

## Sur GitHub

- **Un workflow est un fichier dans `.github/workflows/`**, déclenché par `on:` : `push`, `pull_request`, un tag, une heure. Il tourne sur une machine neuve à chaque fois : rien de ce qui est sur ton poste n'y est, sauf ce que le dépôt contient.
- **Le check requis** : dans la protection de `main`, « Require status checks to pass » avec le nom du job rend la fusion impossible tant que le script échoue. [Protéger la branche principale](/equipe/proteger-la-branche-principale/).
- **La matrice** fait tourner le même job sur plusieurs systèmes : `runs-on: ${{ matrix.os }}` avec `[ubuntu-latest, windows-latest, macos-latest]`. Utile quand les utilisateurs sont sur plusieurs systèmes ; Linux seul suffit pour attraper ce que cette page décrit.
- **Les journaux** sont dans l'onglet Actions, ou `gh run view --log`. Le `echo "code de sortie"` du script n'est là que pour la page : GitHub lit le code de sortie lui-même, et marque l'étape en rouge dès qu'il n'est pas zéro.
- **`actions/checkout`** clone sans l'historique par défaut (`fetch-depth: 1`) : un script qui a besoin des tags ou des dates de commit demande `fetch-depth: 0`.

## Pièges

- **Corriger sur le serveur**, `chmod +x` en production, `dos2unix` à la main : le prochain déploiement ramène le problème. La correction est un commit.
- **`core.fileMode` et `core.ignorecase`** : Git les règle tout seul selon le système, et c'est pour ça que le poste ne voit rien. Les changer sur un poste ne change rien à ce que le dépôt contient.
- **Deux fichiers qui ne diffèrent que par la casse**, `Readme.md` et `README.md`, tous deux dans le dépôt : impossible à extraire proprement sous Windows et macOS, où l'un écrase l'autre. Le troisième test du script les repère ; on en supprime un et on corrige ce qui le citait.
- **Un outil installé globalement** sur le poste et absent de la CI : la dépendance doit être dans le dépôt, `package.json`, `requirements.txt`, ou installée par le workflow.
- **Faire taire la CI**, avec `continue-on-error` ou en retirant le test qui échoue, plutôt que corriger : elle redevient décorative.
- **Une CI lente** que plus personne n'attend. Les vérifications de cette page prennent une seconde ; les mettre en premier, avant les tests longs.

## Voir aussi

- [Mes scripts cassent sur le serveur : fins de ligne](/situations/fichiers/fins-de-ligne-crlf-lf/)
- [Git voit tous mes fichiers comme modifiés](/situations/fichiers/tous-les-fichiers-modifies/)
- [.gitignore ne marche pas, le fichier est déjà suivi](/situations/fichiers/gitignore-fichier-deja-suivi/)
- [Protéger la branche principale](/equipe/proteger-la-branche-principale/)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/equipe/ci-ce-que-les-postes-ne-voient-pas.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/equipe/ci-ce-que-les-postes-ne-voient-pas.sh), rejoué **sur Ubuntu** par le workflow « Rejouer les situations » du dépôt, avec Git 2.55, le 5 octobre 2026. Sous Windows, le bit d'exécution et la casse des noms n'existent pas : `./deploy.sh` passe et `Utils.js` est trouvé, c'est précisément le sujet de la page. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
