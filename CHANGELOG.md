# Changelog — git-en-situation

Ce fichier suit les évolutions du site et de son contenu. Format inspiré de [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/).

- **[Non publié]** : ce qui est sur `main` et pas encore annoncé.
- Chaque entrée dit ce qui change pour le lecteur ou pour le contributeur.

---

## [Non publié] — 5 octobre 2026 · Phase 0 : fondations

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

1. **GitHub → Settings → Pages → Source : « GitHub Actions »**, une seule fois, avant ou juste après le premier push. Sans ce réglage, le workflow de déploiement échoue (la CI, elle, reste verte).
2. **GitHub → Settings → Branches → protéger `main`** : pull request obligatoire, statut CI requis, push forcé interdit. À faire après le push du squelette.
3. **Sur chaque poste de travail** : `npm ci`.

### Suite prévue

- **Phase 1** : une vingtaine de situations, dont une dizaine tirées de cas réels récents ; le modèle mental de la section « Comprendre » ; les pages « pull request » et « commits conventionnels » de la section équipe ; mise en ligne.
- **Phase 2** : section équipe complète, fiches commandes.
- **Phase 3** : exercices dans un dépôt bac à sable ; vérification automatique en CI que les sorties des pages correspondent toujours aux scripts.
- **Phase 4** : traduction anglaise, animation de la communauté.
