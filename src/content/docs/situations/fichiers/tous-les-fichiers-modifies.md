---
title: Git voit tous mes fichiers comme modifiés
description: Tu n'as rien touché, et git status annonce chaque fichier modifié. Presque toujours les fins de ligne, parfois les permissions. Comment le vérifier avec git ls-files --eol, et comment remettre le dépôt d'équerre sans commiter cent faux changements.
level: intermediaire
risk: destructif
gitVersion: "2.50"
verified: 2026-10-06
published: 2026-10-05
---

## Symptôme

Le dépôt venait d'être cloné sous Windows, tout était propre. Un réglage a changé, par toi ou par un outil, et d'un coup :

```console
$ git config core.autocrlf false

$ git status --short
 M README.md
 M a.txt
 M b.txt
 M c.txt

$ git diff --stat
 README.md | 2 +-
 a.txt     | 4 ++--
 b.txt     | 4 ++--
 c.txt     | 2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)
```

Chaque ligne de chaque fichier serait modifiée. `git diff` ne montre pourtant rien de lisible, sauf en rendant les caractères invisibles visibles :

```console
$ git diff a.txt | cat -A | tail -4
-a$
-b$
+a^M$
+b^M$
```

## Diagnostic

`^M`, c'est un retour chariot : les fichiers sur ton disque finissent leurs lignes par CRLF, convention Windows, alors que le dépôt les stocke en LF. Jusque-là, `core.autocrlf=true` faisait la conversion dans les deux sens et Git ne voyait pas de différence. Le réglage désactivé, Git compare les octets tels quels : tout diffère. `git ls-files --eol` le dit fichier par fichier, `i/` pour l'index, `w/` pour le dossier de travail :

```console
$ git ls-files --eol
i/lf    w/crlf  attr/                 	README.md
i/lf    w/crlf  attr/                 	a.txt
i/lf    w/crlf  attr/                 	b.txt
i/lf    w/crlf  attr/                 	c.txt
```

Rien n'est réellement modifié. Surtout, ne commite pas ça : tu enverrais cent faux changements, et le problème chez tous les autres.

:::caution[Une commande de cette page jette les modifications non commitées]
L'étape 3 utilise `git reset --hard`. Avant, `git status` : s'il reste du vrai travail en cours, commite-le ou [mets-le de côté](/situations/quotidien/mettre-son-travail-de-cote/).
:::

## Solution

**1. Fixe la règle dans le dépôt**, pour que tout le monde l'ait, quel que soit son réglage personnel :

```console
$ printf "* text=auto eol=lf\n" > .gitattributes
```

**2. Renormalise.** Git recalcule ce que chaque fichier doit être dans l'index selon la règle. Ici, l'index était déjà en LF : seul le `.gitattributes` apparaît.

```console
$ git add --renormalize .

$ git status --short
?? .gitattributes

$ git add .gitattributes && git commit -q -m "Fins de ligne LF pour tout le depot"
```

**3. Réécris le dossier de travail selon la règle.** Git ne réécrit pas de lui-même les fichiers qu'il considère propres ; on vide l'index et on le refait :

```console
$ git rm -r -q --cached . && git reset -q --hard

$ git ls-files --eol
i/lf    w/lf    attr/text=auto eol=lf 	.gitattributes
i/lf    w/lf    attr/text=auto eol=lf 	README.md
i/lf    w/lf    attr/text=auto eol=lf 	a.txt
i/lf    w/lf    attr/text=auto eol=lf 	b.txt
i/lf    w/lf    attr/text=auto eol=lf 	c.txt

$ git status --short
```

Tout est en LF, sur le disque comme dans le dépôt, et le statut est propre.

## Pourquoi ça marche

Git stocke les fichiers texte avec des fins de ligne LF et peut les convertir à la volée : à la sortie vers le disque, et à l'entrée vers l'index. `core.autocrlf` est le réglage **de la machine** ; `.gitattributes` est la règle **du dépôt**, et elle l'emporte. `text=auto` demande à Git de reconnaître les fichiers texte lui-même, `eol=lf` fixe ce que le disque doit contenir. `git add --renormalize` applique la règle à l'index sans attendre une modification ; vider l'index puis `reset --hard` force Git à réécrire chaque fichier du disque avec les nouveaux attributs.

## Pièges

- **Une autre cause, les permissions.** Après une copie entre systèmes, ou sur un disque partagé, Git peut voir « old mode 100644, new mode 100755 » sur tous les fichiers. Là, c'est `git config core.fileMode false` pour ce dépôt.
- **Les fichiers binaires.** `text=auto` les reconnaît presque toujours ; pour être sûr, déclare-les : `*.png binary`, `*.pdf binary`. Un binaire « normalisé » est un binaire corrompu.
- **Chez les collègues**, après avoir tiré le commit du `.gitattributes`, le même symptôme peut apparaître. Même remède, étape 3.
- **Les trois valeurs de `core.autocrlf`** : `true` convertit en CRLF sur le disque et en LF dans le dépôt, `input` laisse le disque tel quel et stocke en LF, `false` ne touche à rien. Avec un `.gitattributes`, ce réglage n'a plus d'importance : c'est l'intérêt.
- **Pourquoi LF partout, même sous Windows** : les scripts et les outils du serveur l'exigent, et les éditeurs modernes s'en accommodent. Voir [Mes scripts cassent sur le serveur, fins de ligne](/situations/fichiers/fins-de-ligne-crlf-lf/).

## Voir aussi

- [Mes scripts cassent sur le serveur, fins de ligne](/situations/fichiers/fins-de-ligne-crlf-lf/)
- [Mettre mon travail en cours de côté pour changer de branche](/situations/quotidien/mettre-son-travail-de-cote/)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/situations/tous-les-fichiers-modifies.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/tous-les-fichiers-modifies.sh), exécuté avec Git 2.50 le 6 octobre 2026, sur un clone fait avec `core.autocrlf=true` pour reproduire un poste Windows. Après le changement de réglage, les fichiers sont rafraîchis par `touch` : Git fait confiance à leurs dates et ne relirait pas leur contenu sinon, ce que fait sur un vrai poste le premier enregistrement dans l'éditeur. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
