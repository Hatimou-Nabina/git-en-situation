# Changelog — git-en-situation

Ce fichier suit les évolutions du site et de son contenu. Format inspiré de [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/).

- **[Non publié]** : ce qui est sur `main` et pas encore annoncé.
- Chaque entrée dit ce qui change pour le lecteur ou pour le contributeur.

---

## [Non publié] — La page « pull request » sans appel à GitHub

- **Retrait de la liste `gh pr list`** à la fin de « La pull request, de l'ouverture à la fusion », remplacée par un lien vers les PR du dépôt. Cette sortie changeait à chaque fusion et dépendait d'un `gh` connecté, à rebours de la règle du site : des scripts reproductibles à l'identique, partout et à toute date. Règle ajoutée au `CLAUDE.md`.

---

## 5 octobre 2026 · Phase 1, lot 6 : travailler en équipe — en ligne le 5 octobre 2026

Branche `equipe/lot-6`, partie de `main` (`9778ef0`), fusionnée par la PR #9.

### Contenu

- **Deux pages « Travailler en équipe »**, chacune avec son script dans `scripts/equipe/` et ses sorties réelles (Git 2.50, 5 octobre 2026) :
  - « La pull request, de l'ouverture à la fusion » (branche, commits, push, ce que la PR contiendra, une remarque en relecture, la fusion, le nettoyage ; les dernières PR fusionnées de ce site vues par `gh`) ;
  - « Les commits conventionnels » (format, types, corps et pied de page, filtrage par type, bilan par type, hook `commit-msg` qui refuse un message hors format).
- La page d'entrée « Travailler en équipe » devient un sommaire : les deux pages, puis les dix prévues.
- **Fin de la phase 1** : 23 situations dans quatre thèmes, 4 pages « Comprendre », 2 pages « Travailler en équipe », toutes adossées à un script rejoué sur Windows et sur Ubuntu.

### Pour les contributeurs

- Gabarit des pages « Travailler en équipe » dans `CONTRIBUTING.md` : ce que ça évite, comment on fait, sur GitHub, pièges.
- Le workflow « Rejouer les situations » exécute aussi `scripts/equipe/`.

### Suite prévue

- **Phase 2** : la section « Travailler en équipe » complète (dix pages prévues), puis les fiches « Commandes ».
- **Phase 3** : vérification automatique en CI que les sorties des pages correspondent toujours aux scripts ; exercices dans un dépôt bac à sable.
- **Phase 4** : traduction anglaise, animation de la communauté.

---

## 5 octobre 2026 · Phase 1, lot 5 : comprendre — en ligne le 5 octobre 2026

Branche `comprendre/lot-5`, partie de `main` (`d725d91`), fusionnée par la PR #8 (`9778ef0`).

### Contenu

- **Quatre pages « Comprendre »**, chacune avec son script dans `scripts/comprendre/` et ses sorties réelles (Git 2.50, 5 octobre 2026) :
  - « Un commit, c'est un instantané » (`cat-file -p`, l'arbre, un même fichier stocké une fois, l'amend qui change l'identifiant) ;
  - « Une branche, c'est un marque-page » (`.git/HEAD`, `.git/refs/heads/`, `branch --contains`, la suppression qui ne supprime pas le commit) ;
  - « Les remotes et les références distantes » (les trois `main`, `show-ref`, le lien de suivi, `fetch` qui ne bouge que la copie, `switch origin/main` refusé) ;
  - « Fast-forward, fusion, rebase » (les trois cas sur le même état, `merge-base`, les deux parents d'un commit de merge, `--no-ff`, les boutons de GitHub).
- La page d'entrée « Comprendre » devient un sommaire : les quatre pages dans l'ordre de lecture, puis les six prévues.
- Dans les situations, les mentions « (à venir) » de ces pages deviennent des liens.

### Pour les contributeurs

- Gabarit des pages « Comprendre » dans `CONTRIBUTING.md` : l'idée, voir par soi-même, ce que ça change dans la pratique, où ça sert.
- Le workflow « Rejouer les situations » exécute aussi `scripts/comprendre/`.

---

## 5 octobre 2026 · Phase 1, lot 4 : fichiers et dépôt — en ligne le 5 octobre 2026

Branche `situations/lot-4-fichiers`, partie de `main` (`7c511ae`), fusionnée par la PR #7 (`d725d91`).

### Contenu

- **Nouveau thème « Fichiers et dépôt »** (`situations/fichiers/`), avec sa vue d'ensemble.
- **Quatre situations**, avec leurs scripts et leurs sorties réelles (Git 2.50, 5 octobre 2026) :
  - « .gitignore ne marche pas : le fichier est déjà suivi » (`check-ignore`, `rm --cached`, et le cas du `.gitignore` en UTF-16 que Git ne lit pas) ;
  - « J'ai poussé un secret par erreur » (révoquer d'abord, retirer du suivi, et pourquoi l'historique reste à nettoyer) ;
  - « Mes scripts cassent sur le serveur : fins de ligne » (`$'\r': command not found`, `ls-files --eol`, `.gitattributes`, `add --renormalize`) ;
  - « Git voit tous mes fichiers comme modifiés » (`autocrlf`, `ls-files --eol`, renormalisation et réécriture du dossier de travail).

### Vérification sur Linux

- **Workflow « Rejouer les situations »** (`.github/workflows/situation.yml`) : à chaque push qui touche un script, tous les scripts sont rejoués sur Ubuntu et leurs sorties sont dans le journal du workflow ; à la demande (`gh workflow run situation.yml -f script=<slug>`), un seul. Première brique de la vérification automatique prévue en phase 3.
- Pourquoi maintenant : sous Windows, le bash de Git Bash tolère les fins de ligne CRLF dans un script, et l'erreur montrée par « Mes scripts cassent sur le serveur » n'y apparaît pas. Ses sorties viennent du rejeu sur Ubuntu.

---

## 5 octobre 2026 · Correction du filtre du catalogue — en ligne le 5 octobre 2026 (PR #6)

### 🐛 Correction

- **Le filtre par niveau du catalogue ne masquait rien** : les boutons changeaient d'état, la liste restait entière. Cause : la règle `display: grid` des entrées de liste l'emportait sur l'attribut `hidden` posé par le script. Une règle `li[hidden] { display: none }` règle le problème. Repéré par le mainteneur sur le site en ligne, le 5 octobre 2026.
- Leçon pour le guide : un comportement qui demande un clic se vérifie par un clic, pas par une capture de la page au chargement.

---

## 5 octobre 2026 · Phase 1, lot 3 : avec les autres — en ligne le 5 octobre 2026

Branche `situations/lot-3-avec-les-autres`, partie de `main` (`c447868`), fusionnée par la PR #5 (`df7d14b`).

### Contenu

- **Nouveau thème « Avec les autres »** (`situations/avec-les-autres/`), avec sa vue d'ensemble.
- **Quatre situations**, avec leurs scripts et leurs sorties réelles (Git 2.50, 5 octobre 2026) :
  - « Mettre ma branche à jour avec main » (rebase ou merge, comparés sur le même état ; `push --force-with-lease`, et ce qu'il empêche quand un collègue a poussé entre-temps) ;
  - « Ma branche locale est en retard après une fusion sur GitHub » (`pull --ff-only`, ménage de la branche fusionnée, et le cas où `--ff-only` refuse) ;
  - « Deux comptes GitHub sur le même poste » (`includeIf gitdir`, alias d'hôte SSH avec `IdentitiesOnly`, `remote set-url` ; la connexion SSH est citée, pas rejouée) ;
  - « Travailler sur le même projet depuis deux machines » (ce qui voyage et ce qui ne voyage pas, `git log --branches --not --remotes`, routines en partant et en arrivant).

---

## 5 octobre 2026 · Catalogue par thèmes — en ligne le 5 octobre 2026

Branche `site/catalogue-par-themes`, partie de `main` (`0487e6f`), fusionnée par la PR #4 (`c447868`).

### Site

- **Situations classées par thème** : `situations/quotidien/` (9 pages) et `situations/reparer/` (6 pages), chacun avec une vue d'ensemble. Les adresses changent (`/situations/<theme>/<slug>/`) ; les 15 anciennes adresses redirigent (`src/redirects.mjs`).
- **Catalogue** (`/situations/`) : toutes les situations par thème, avec un filtre par niveau sans rechargement, et le nombre de pages par thème et par niveau. Le mode d'emploi est déplacé sur `/situations/comment-lire/`.
- **Barre latérale** : un groupe repliable par thème, au lieu d'une liste plate.
- **Accueil** : les trois situations les plus récentes (nouveau champ `published`) et un lien vers le catalogue, au lieu de la liste complète.
- Pas de pagination, par choix : un référentiel se parcourt par thème, par niveau et par recherche, pas par numéro de page.

### Pour les contributeurs

- Une page va dans le dossier de son thème ; un thème nouveau = un dossier avec `index.mdx` + une entrée dans `src/themes.mjs`. Champ `published` obligatoire dans le gabarit.

---

## 5 octobre 2026 · Phase 1, lot 2 : réparer — en ligne le 5 octobre 2026

Branche `situations/lot-2-reparer`, partie de `main` (`7253656`), fusionnée par la PR #3 (`0487e6f`).

### Contenu

- **Six situations**, avec leurs scripts et leurs sorties réelles (Git 2.50, 5 octobre 2026) :
  - « J'ai commité sur la mauvaise branche » (`branch` + `reset --keep`, `cherry-pick`, et le cas du commit déjà poussé) ;
  - « Annuler mon dernier commit, pas encore poussé » (`commit --amend`, `reset --soft` / `--hard`, retour par le reflog ; marquée *destructif*) ;
  - « Annuler un commit déjà poussé » (pourquoi le reset + push est refusé, `revert`, commit plus ancien, merge avec `-m 1`) ;
  - « Je suis en « detached HEAD » » (`switch --detach`, commit dans cet état, `switch -c`, l'avertissement au départ et `HEAD@{1}`) ;
  - « Retrouver un commit perdu » (branche supprimée, `reset --hard` trop loin, reflog, délais de conservation) ;
  - « Un conflit pendant un merge ou un rebase » (marqueurs, `rebase --continue` / `--abort`, variante merge, ours et theirs inversés en rebase).

---

## 5 octobre 2026 · Phase 1, lot 1 : au quotidien — en ligne le 5 octobre 2026

Branche `situations/lot-1-quotidien`, partie de `main` (`7e6a90e`), fusionnée par la PR #2 (`7253656`).

### Contenu

- **Six situations**, avec leurs scripts et leurs sorties réelles (Git 2.50, 5 octobre 2026) :
  - « Premier push d'une branche, « has no upstream branch » » (`push -u`, `push.autoSetupRemote`) ;
  - « Après un clone, je ne vois pas les branches des autres » (références distantes, `git switch` qui crée la branche locale, `fetch`) ;
  - « git pull me demande de choisir entre merge et rebase » (les deux options comparées sur l'historique, `pull.rebase`, `pull.ff only`) ;
  - « Mettre mon travail en cours de côté pour changer de branche » (`stash push -u`, `list`, `pop`) ;
  - « Voir ce qui a changé entre ma branche et main » (`log A..B`, `log A...B --left-right`, `diff A...B`, et pourquoi `..` et `...` diffèrent entre `log` et `diff`) ;
  - « Renommer une branche, en local et sur le serveur » (`branch -m`, `push -u`, `push --delete`, `branch -u`, renommage depuis GitHub et effet sur les PR).
- Scripts : `GIT_EDITOR=true` dans `_lib.sh`, pour qu'un merge ou un rebase n'ouvre jamais d'éditeur.

---

## 5 octobre 2026 · Phase 0 : fondations — en ligne le 5 octobre 2026

Squelette poussé directement sur `main`, puis identité visuelle par la PR #1. Site : https://hatimou-nabina.github.io/git-en-situation/

### Contenu

- **Trois premières situations**, avec leurs scripts dans `scripts/situations/` et leurs sorties réelles (Git 2.50) :
  - « Une branche distante a été supprimée, mais je la vois encore » (`git fetch --prune`, `[gone]`) ;
  - « Mon push est refusé, « rejected », « fetch first » » (divergence, `rebase`, `pull --rebase`, pourquoi pas `--force`) ;
  - « Supprimer une vieille branche sans rien perdre » (`main..branche`, `--merged`, `-d` et `-D`, tag d'archive, cas du squash).
- **Pages d'entrée des sections** « Situations » (comment lire une page, garantie sur les sorties), « Comprendre », « Travailler en équipe », « Commandes » (liste des pages prévues), et **À propos** (origine, promesses, licence).
- **Accueil** en français ; accueil anglais annonçant la traduction à venir.

### Site

- **Identité visuelle** : polices IBM Plex Sans et Mono auto-hébergées (Fontsource, rien n'est chargé depuis un service tiers), palette terre cuite sur neutres chauds dans les deux thèmes, logo. Accueil refait : titre et promesse, un vrai extrait de terminal en guise d'illustration, les quatre étapes d'une page, la liste des situations publiées générée depuis le contenu (`SituationsList.astro`), les quatre entrées du site.
- **Sessions de terminal** : blocs ` ```console ` rendus dans un cadre de terminal ; les lignes de commande (`$ …`) sont marquées par un petit plugin Expressive Code (`src/plugins/expressive-code-prompts.mjs`) et ressortent des sorties.
- Astro 7 + Starlight 0.42, français en locale racine, anglais préparé avec repli sur le français.
- En-tête de page étendu : `level`, `risk`, `gitVersion`, `verified`, affichés en badges sous le titre.
- Liens internes écrits depuis la racine et préfixés au build (`src/plugins/base-links.mjs`, plugin pour le processeur Markdown Sätteri d'Astro 7), pour que le contenu ne dépende pas de l'adresse d'hébergement.
- Validation des liens internes au build (`starlight-links-validator`).

### Dépôt

- Licences : MIT pour le code (`LICENSE`), CC BY-SA 4.0 pour le contenu (`LICENSE-CONTENT.md`).
- `CONTRIBUTING.md` (processus, gabarit de page, style, commits), `CODE_OF_CONDUCT.md`, `CLAUDE.md`.
- Gabarits d'issue « Proposer une situation » et « Signaler une erreur », gabarit de pull request, `CODEOWNERS`.
- CI GitHub Actions : `astro check` et `astro build` sur chaque PR et sur `main`. Déploiement GitHub Pages à chaque changement de `main`.

### ⚠️ Actions requises

1. ✅ *Fait le 5 octobre 2026.* **GitHub → Settings → Pages → Source : « GitHub Actions »**, une seule fois, avant ou juste après le premier push. Sans ce réglage, le workflow de déploiement échoue (la CI, elle, reste verte).
2. ✅ *Fait le 5 octobre 2026 (ruleset `main`, actif).* **GitHub → Settings → Rules → protéger `main`** : pull request obligatoire (0 approbation tant qu'il n'y a qu'un mainteneur), check « Vérifier et construire le site » requis, suppressions et push forcé interdits. Tout passe désormais par des pull requests.
3. **Sur chaque poste de travail** : `npm ci`.
4. ✅ *Fait le 5 octobre 2026.* `gh` (GitHub CLI) installé et connecté sur le poste principal : les PR peuvent être ouvertes depuis le terminal.

### Suite prévue

- **Phase 1** : une vingtaine de situations, dont une dizaine tirées de cas réels récents ; le modèle mental de la section « Comprendre » ; les pages « pull request » et « commits conventionnels » de la section équipe ; mise en ligne.
- **Phase 2** : section équipe complète, fiches commandes.
- **Phase 3** : exercices dans un dépôt bac à sable ; vérification automatique en CI que les sorties des pages correspondent toujours aux scripts.
- **Phase 4** : traduction anglaise, animation de la communauté.
