---
title: Mes scripts cassent sur le serveur, fins de ligne
description: Un script qui marche sur ton poste Windows échoue sur le serveur Linux avec « $'\r' - command not found ». Les fins de ligne CRLF, comment les voir, et le .gitattributes qui règle le problème pour toute l'équipe.
level: intermediaire
risk: aucun
gitVersion: "2.55"
verified: 2026-10-06
published: 2026-10-05
---

## Symptôme

Un script de déploiement écrit sous Windows, testé sur ton poste, commité, poussé. Sur le serveur Linux :

```console
$ bash deploy.sh
deploy.sh: line 2: $'\r': command not found
ls: cannot access 'deploy.sh'$'\r': No such file or directory
Deploiement en cours
```

Une ligne vide devient une commande inconnue, et un nom de fichier se termine par un caractère invisible. Les deux erreurs sont affichées avant le message du script, comme toutes les pages de ce site le font ; dans ton terminal, « Deploiement en cours » apparaît entre les deux.

## Diagnostic

Windows termine ses lignes par deux caractères, `\r\n`, retour chariot puis saut de ligne. Linux n'en attend qu'un, `\n`. Le `\r` en trop est invisible dans l'éditeur, mais bash sur Linux le lit comme faisant partie de la commande. Pour le voir :

```console
$ od -c deploy.sh | head -3
0000000   #   !   /   u   s   r   /   b   i   n   /   e   n   v       b
0000020   a   s   h  \r  \n  \r  \n   e   c   h   o       "   D   e   p
0000040   l   o   i   e   m   e   n   t       e   n       c   o   u   r
```

Sur ton poste, le bash de Git Bash tolère ces `\r`, d'où le « ça marche chez moi ». Et Git, lui, a stocké le fichier tel quel :

```console
$ git ls-files --eol deploy.sh
i/crlf  w/crlf  attr/                 	deploy.sh
```

`i/` est l'index, ce que le dépôt contient ; `w/` est le dossier de travail. CRLF des deux côtés : le serveur reçoit le `\r`.

## Solution

**1. Impose LF dans le dépôt, pour tout le monde.** Un fichier `.gitattributes` à la racine, commité, vaut pour chaque poste quel que soit son réglage :

```console
$ printf "* text=auto eol=lf\n" > .gitattributes
```

**2. Renormalise ce qui est déjà commité.** Git recalcule l'index selon la règle ; le script apparaît modifié, c'est le `\r` qui s'en va :

```console
$ git add --renormalize .

$ git status --short
M  deploy.sh
?? .gitattributes

$ git ls-files --eol deploy.sh
i/lf    w/crlf  attr/text=auto eol=lf 	deploy.sh

$ git commit -q -m "Fins de ligne LF pour tout le depot"
```

**3. Réécris ta copie de travail.** Git ne réécrit pas un fichier qu'il considère propre ; on le supprime et on le reprend du dépôt :

```console
$ rm deploy.sh && git checkout -- deploy.sh

$ git ls-files --eol deploy.sh
i/lf    w/lf    attr/text=auto eol=lf 	deploy.sh
```

Sur le serveur, après le prochain déploiement :

```console
$ bash deploy.sh
Deploiement en cours
deploy.sh
```

## Pourquoi ça marche

Git peut convertir les fins de ligne à l'entrée, vers l'index, et à la sortie, vers le disque. Par défaut, il ne touche à rien, ou suit le réglage `core.autocrlf` de la machine, différent d'un poste à l'autre : c'est la source du désordre. `.gitattributes` fixe la règle **dans le dépôt** : `text=auto` laisse Git reconnaître les fichiers texte, `eol=lf` impose LF sur le disque comme dans l'index. Cette règle l'emporte sur la configuration de chacun. `git add --renormalize` l'applique aux fichiers déjà suivis, qui autrement garderaient leur `\r` jusqu'à leur prochaine modification.

## Pièges

- **Les fichiers Windows qui ont besoin de CRLF**, `.bat` et `.cmd`, se déclarent à part : `*.bat text eol=crlf`.
- **Le `.gitattributes` doit arriver chez les collègues avant leurs prochains commits**, sinon ils continuent de pousser du CRLF. Chez eux, après le `pull`, Git peut annoncer tous les fichiers modifiés : [Git voit tous mes fichiers comme modifiés](/situations/fichiers/tous-les-fichiers-modifies/).
- **L'éditeur a aussi son réglage.** Dans VS Code, `"files.eol": "\n"` évite de réintroduire des `\r` à chaque enregistrement ; avec `.gitattributes`, Git les retirerait de toute façon au commit.
- **Un `\r` après le shebang** donne un message différent, `bad interpreter: No such file or directory`, pour la même cause.
- **`dos2unix` sur le serveur** répare un fichier, pas le dépôt : le prochain déploiement ramène le problème. La correction se fait à la source.

## Voir aussi

- [Git voit tous mes fichiers comme modifiés](/situations/fichiers/tous-les-fichiers-modifies/)
- [.gitignore ne marche pas, le fichier est déjà suivi](/situations/fichiers/gitignore-fichier-deja-suivi/)
- [Travailler en équipe : une CI qui vérifie ce que les postes ne voient pas](/equipe/ci-ce-que-les-postes-ne-voient-pas/)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/situations/fins-de-ligne-crlf-lf.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/fins-de-ligne-crlf-lf.sh), rejoué **sur Ubuntu** par le workflow « Rejouer les situations » du dépôt, avec Git 2.55, le 6 octobre 2026. Sous Windows, le bash de Git Bash tolère les CRLF et l'erreur n'y apparaît pas : c'est précisément le sujet de la page. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
