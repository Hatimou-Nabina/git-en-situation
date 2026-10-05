---
title: Un conflit pendant un merge ou un rebase
description: « CONFLICT (content) - Merge conflict in README.md ». Lire les marqueurs, choisir la bonne version, continuer ou tout abandonner. Et pourquoi HEAD ne désigne pas la même chose dans un rebase et dans un merge.
level: intermediaire
risk: reversible
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptôme

Tu récupères le travail de l'équipe, et ça s'arrête en plein milieu :

```console
$ git pull --rebase
From github.com:equipe/projet
   d0a0b32..c6daf1f  main       -> origin/main
Auto-merging README.md
CONFLICT (content): Merge conflict in README.md
Rebasing (1/1)error: could not apply 0e03633... Corrige le titre du README
hint: Resolve all conflicts manually, mark them as resolved with
hint: "git add/rm <conflicted_files>", then run "git rebase --continue".
hint: You can instead skip this commit: run "git rebase --skip".
hint: To abort and get back to the state before "git rebase", run "git rebase --abort".
hint: Disable this message with "git config set advice.mergeConflict false"
Could not apply 0e03633... # Corrige le titre du README
```

## Diagnostic

Deux personnes ont modifié **les mêmes lignes** du même fichier : toi, en changeant le titre du README, et une collègue, en y ajoutant un contact. Git sait fusionner des modifications à des endroits différents ; ici, il ne peut pas deviner laquelle des deux versions de la première ligne est la bonne, ni si c'est un mélange des deux. Il te laisse le fichier avec les deux versions, et attend ta décision. Rien n'est cassé, et tu peux renoncer à tout moment.

## Solution

**1. Regarde où tu en es.** `git status` liste les fichiers en conflit et rappelle les trois sorties possibles :

```console
$ git status
interactive rebase in progress; onto c6daf1f
Last command done (1 command done):
   pick 0e03633 # Corrige le titre du README
No commands remaining.
You are currently rebasing branch 'main' on 'c6daf1f'.
  (fix conflicts and then run "git rebase --continue")
  (use "git rebase --skip" to skip this patch)
  (use "git rebase --abort" to check out the original branch)

Unmerged paths:
  (use "git restore --staged <file>..." to unstage)
  (use "git add <file>..." to mark resolution)
	both modified:   README.md

no changes added to commit (use "git add" and/or "git commit -a")
```

**2. Ouvre le fichier.** Git y a écrit les deux versions, entre des marqueurs :

```console
$ cat README.md
<<<<<<< HEAD
# Projet - plateforme de partage

Contact : contact@example.com
=======
# Projet EduShare
>>>>>>> 0e03633 (Corrige le titre du README)
```

Entre `<<<<<<< HEAD` et `=======`, la version déjà en place sur le serveur. Entre `=======` et `>>>>>>>`, ton commit. Attention, dans un rebase, c'est bien dans ce sens-là : voir « Pourquoi ça marche ».

**3. Écris la version voulue**, ici un mélange des deux, et retire les marqueurs. Le fichier doit ressembler à ce que tu veux voir commité, rien de plus :

```console
$ cat README.md
# Projet EduShare

Contact : contact@example.com
```

**4. Marque le fichier comme résolu, puis continue.**

```console
$ git add README.md

$ git rebase --continue
[detached HEAD d7f74cf] Corrige le titre du README
 1 file changed, 1 insertion(+), 1 deletion(-)
Successfully rebased and updated refs/heads/main.

$ git log --oneline -3
d7f74cf Corrige le titre du README
c6daf1f Ajoute le contact au README
d0a0b32 Premier commit
```

Ton commit a été rejoué par-dessus celui de ta collègue, avec la résolution. Le push passe ensuite normalement :

```console
$ git push
To github.com:equipe/projet.git
   c6daf1f..d7f74cf  main -> main
```

**Changer d'avis : tout abandonner.** À n'importe quel moment avant le `--continue`, tu peux revenir exactement à l'état d'avant le `pull` :

```console
$ git status --short
UU README.md

$ git rebase --abort

$ git status
On branch main
Your branch and 'origin/main' have diverged,
and have 1 and 1 different commits each, respectively.
  (use "git pull" if you want to integrate the remote branch with yours)

nothing to commit, working tree clean

$ git log --oneline -2
0e03633 Corrige le titre du README
d0a0b32 Premier commit
```

**La même chose avec une fusion.** Si tu intègres par `merge` plutôt que par `rebase`, le conflit se présente pareil, les deux côtés sont dans l'autre ordre, et c'est un `git commit` qui termine :

```console
$ git pull --no-rebase
From github.com:equipe/projet
   d0a0b32..c6daf1f  main       -> origin/main
Auto-merging README.md
CONFLICT (content): Merge conflict in README.md
Automatic merge failed; fix conflicts and then commit the result.

$ cat README.md
<<<<<<< HEAD
# Projet EduShare
=======
# Projet - plateforme de partage

Contact : contact@example.com
>>>>>>> c6daf1f164d965f9af8ddeb0ba872a9c38e11fce

$ git add README.md

$ git commit --no-edit
[main 7a35596] Merge branch 'main' of github.com:equipe/projet

$ git log --oneline --graph -4
*   7a35596 Merge branch 'main' of github.com:equipe/projet
|\
| * c6daf1f Ajoute le contact au README
* | 0e03633 Corrige le titre du README
|/
* d0a0b32 Premier commit
```

Pour renoncer dans ce cas : `git merge --abort`.

## Pourquoi ça marche

Git fusionne ligne par ligne, en comparant chaque version à l'ancêtre commun. Quand les deux côtés ont modifié la même zone, il n'y a pas de règle qui vaille pour tous les projets : Git écrit les deux versions dans le fichier, marque le fichier comme « non fusionné » dans l'index, et s'arrête. `git add` sur le fichier retire cette marque, c'est le signal « j'ai tranché ». `--continue` reprend là où ça s'était arrêté.

**HEAD n'est pas le même selon l'opération.** Dans un merge, tu es sur ta branche, et tu y amènes les commits du serveur : `HEAD` est ta version, l'autre côté est la leur. Dans un rebase, Git se place d'abord sur le commit du serveur, puis rejoue tes commits un par un dessus : `HEAD` est **leur** version, et c'est ton commit qui est « l'autre côté », nommé par son identifiant. Les options `--ours` et `--theirs` de `git checkout` suivent la même logique inversée. En cas de doute, lis les marqueurs : la ligne `>>>>>>>` dit toujours d'où vient la seconde version.

## Pièges

- **Commiter les marqueurs.** Si `<<<<<<<` reste dans un fichier, le code ne compile plus ou le texte est ruiné. Relis le fichier entier avant `git add`, pas seulement la zone en conflit.
- **Prendre un côté sans lire.** `git checkout --ours README.md` ou `--theirs` écrasent l'autre version : rapide, et faux une fois sur deux. Dans un rebase, en plus, `--ours` est la version du serveur.
- **Un rebase de plusieurs commits** peut s'arrêter plusieurs fois. Chaque arrêt se résout de la même façon ; `git rebase --skip` abandonne seulement le commit en cours.
- **Un outil visuel** aide quand le conflit est long : VS Code affiche les deux versions avec des boutons, et `git mergetool` lance celui qui est configuré. Le résultat reste à vérifier.
- **Un conflit qui revient à chaque rebase** sur la même branche longue : `git config rerere.enabled true` fait rejouer automatiquement les résolutions déjà faites.

## Voir aussi

- [git pull me demande de choisir entre merge et rebase](/situations/quotidien/git-pull-merge-ou-rebase/)
- [Mon push est refusé, « rejected », « fetch first »](/situations/quotidien/push-refuse-fetch-first/)
- [Annuler un commit déjà poussé](/situations/reparer/annuler-un-commit-deja-pousse/)
- Comprendre : *Fast-forward, fusion, rebase* (à venir)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/situations/resoudre-un-conflit.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/resoudre-un-conflit.sh), exécuté avec Git 2.50 le 5 octobre 2026. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
