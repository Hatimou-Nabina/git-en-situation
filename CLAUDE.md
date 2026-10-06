# git-en-situation — guide de travail

Site open source : « Git et GitHub, à partir des situations que tu vis vraiment. » Contenu en Markdown, site statique Astro + Starlight, publié sur GitHub Pages. Dépôt : https://github.com/Hatimou-Nabina/git-en-situation

Le propriétaire travaille sur **plusieurs machines**. Tout ce qui est nécessaire pour reprendre le travail doit être dans le repo : ce fichier, `CHANGELOG.md`, `CONTRIBUTING.md`, `README.md`. La mémoire de l'assistant n'est pas partagée entre les postes.

## Décisions (5 octobre 2026)

- **Nom** : `git-en-situation`. Public et open source : contenu sous CC BY-SA 4.0 (`LICENSE-CONTENT.md`), code du site sous MIT (`LICENSE`).
- **Langue** : français d'abord (locale racine), anglais ensuite (`src/content/docs/en/`, repli automatique sur le français).
- **Public** : développeurs francophones de tous niveaux. Tutoiement.
- **Hébergement** : GitHub Pages, `https://hatimou-nabina.github.io/git-en-situation/`, d'où `base: '/git-en-situation'` dans `astro.config.mjs`. Un domaine propre viendra peut-être : il suffira de changer `site` et `base`, le contenu n'a pas à bouger.
- **Le projet s'applique à lui-même** : commits conventionnels, pull requests, `CODEOWNERS`, CI, changelog, gabarits d'issue.

## Règles de collaboration

- **Ne jamais pousser** sans autorisation explicite du propriétaire.
- Commits conventionnels en français, **sans ligne `Co-Authored-By`**. Types et scopes dans `CONTRIBUTING.md`.
- `main` est la branche publiée. Une fois protégée, tout passe par une pull request ; seul le squelette initial a été poussé directement.
- `CHANGELOG.md` à jour à chaque ajout, renommage ou retrait de page, et à chaque changement visible du site.
- Machine locale : **un seul processus lourd à la fois** (`npm ci`, `npm run build`).

## Principes éditoriaux

1. **Toute sortie affichée est vraie** : elle vient du script de la page dans `scripts/situations/`, exécuté avec la version de Git indiquée dans l'en-tête (`gitVersion`, `verified`). Jamais de sortie écrite de mémoire. Quand un script change, ses sorties dans la page et la date `verified` changent avec lui.
2. **Toujours le pourquoi** : chaque situation a sa section « Pourquoi ça marche ».
3. **Git d'abord, GitHub étiqueté** : ce qui est propre à GitHub est annoncé comme tel.
4. **Une page, une situation**, cinq minutes de lecture, gabarit fixe (`CONTRIBUTING.md`).
5. **Les commandes à risque** sont signalées (`risk`) et le moyen de revenir en arrière est expliqué.

## Commandes

```bash
npm ci
npm run dev                              # http://localhost:4321/git-en-situation/
npm run build                            # valide aussi les liens internes
npm run check                            # types des composants Astro
bash scripts/situations/<slug>.sh        # rejoue une situation (Git Bash sous Windows)
```

## Architecture

- `astro.config.mjs` : `site`, `base`, Starlight (i18n, barre latérale générée par dossier, composant `PageTitle` remplacé, plugin de validation des liens), processeur Markdown Sätteri avec le plugin qui préfixe les liens internes avec `base`.
- `src/content.config.ts` : schéma Starlight étendu avec `level`, `risk`, `gitVersion`, `verified`.
- `src/content/docs/` : contenu français. `situations/` (cœur), `comprendre/`, `equipe/`, `commandes/`, `a-propos.md`, `index.mdx` (accueil). `en/` : anglais.
  - **Les situations sont classées par thème** : un dossier par thème (`situations/quotidien/`, `situations/reparer/`…), chacun avec un `index.mdx` (vue d'ensemble générée). `situations/index.mdx` est le catalogue complet, `situations/comment-lire.md` le mode d'emploi. L'identifiant d'une situation a toujours trois parties, `situations/<theme>/<slug>` : c'est ce qui la distingue des pages d'index dans les composants.
  - `src/themes.mjs` : la liste des thèmes (libellés, descriptions), lue par la barre latérale et les composants. Un thème nouveau = un dossier + une entrée ici.
  - `src/redirects.mjs` : anciennes adresses → nouvelles (classement par thème du 5 octobre 2026). Toute page qui change d'adresse y ajoute une ligne.
- `src/components/PageTitle.astro` : titre de page suivi des badges niveau, risque, version de Git et date de vérification.
- `src/components/SituationsList.astro` : liste de situations (props `theme`, `limit`, `sort`), pour l'accueil (3 plus récentes) et les pages de thème. `src/components/SituationsCatalogue.astro` : le catalogue complet, groupé par thème, avec un filtre par niveau en JavaScript léger (sans JS, tout est affiché).
- **Tenue à l'échelle** (décision du 5 octobre 2026, à 15 situations) : pas de pagination, qui ne convient pas à un référentiel. Trois niveaux : la recherche Pagefind (Ctrl + K) quand on connaît le symptôme, le catalogue par thème et niveau pour parcourir, la barre latérale avec un groupe repliable par thème. Au-delà d'une vingtaine de pages dans un thème, le scinder.
- `src/plugins/expressive-code-prompts.mjs` : plugin Expressive Code qui ajoute la classe `is-prompt` aux lignes `$ …` des blocs ` ```console `. Le style est dans `custom.css`. Les thèmes par défaut colorent commandes et sorties pareil, d'où ce plugin.
- **Identité visuelle** (décidée le 5 octobre 2026) : IBM Plex Sans et Mono via Fontsource, listées dans `customCss` avant `custom.css` ; palette terre cuite (`--sl-color-accent*`) sur neutres chauds (`--sl-color-gray-*`), définie pour les deux thèmes dans `custom.css` ; héros de l'accueil avec un extrait de terminal réel (`hero.image.html`). Sobre, pas d'illustrations ni d'icônes décoratives.
- `src/plugins/base-links.mjs` : les liens du contenu sont écrits depuis la racine (`/situations/...`) ; ce plugin ajoute `base` au build. C'est un plugin HAST pour Sätteri (`defineHastPlugin`), pas un plugin rehype : Astro 7 n'exécute plus `markdown.rehypePlugins` sans installer l'ancien processeur `@astrojs/markdown-remark`.
- `src/styles/custom.css` : styles des badges et ajustements.
- `scripts/situations/_lib.sh` : serveur factice, deux postes (`awa`, `bakary`), configuration Git neutre, dates figées, sorties nettoyées (`github.com:equipe/projet.git`). Un script par situation, du même nom que la page.
- `scripts/comprendre/`, `scripts/equipe/` et `scripts/commandes/` : les scripts des pages « Comprendre », « Travailler en équipe » et des fiches « Commandes », mêmes règles, même bibliothèque (`../situations/_lib.sh`). Le workflow de rejeu les exécute aussi.
- **Fiches « Commandes »** (`src/content/docs/commandes/<commande>.mdx`, en MDX) : une fiche existe si au moins deux pages du site s'appuient sur la commande, en l'exécutant ou en la recommandant (règle précisée le 6 octobre 2026 pour `restore` et `revert`). `src/components/CommandUsages.astro` calcule « Où ça sert » au build : les pages dont le `body` contient une ligne `$ git <commande>` (mode `executed`, par défaut), ou qui citent la commande entre accents graves (mode `cited`, pour `gh`, la seule fiche sans script), hors fiches, index et anglais. Gabarit dans `CONTRIBUTING.md`.
- **Un script ne dépend jamais d'un service extérieur** (GitHub, réseau, compte connecté) : ses sorties doivent être identiques chez tout le monde et à toute date. Une sortie de `gh pr list` sur ce dépôt a été retirée de la page « pull request » pour cette raison (décision du propriétaire, 5 octobre 2026).
- **Shell de l'assistant** : après une interruption de session, le PATH du shell Bash de l'outil peut être vide (ni `git`, ni `ls`). Préfixer la commande par `export PATH="/mingw64/bin:/usr/bin:/c/Program Files/Git/cmd:/c/Windows/System32:/c/Program Files/nodejs:/c/Program Files/GitHub CLI:$PATH"`. Dans ce shell, `$'\r'` n'est pas interprété : `grep -c $'\r'` compte toutes les lignes et fait croire à du CRLF. Les fins de ligne se vérifient avec `file` ou `git ls-files --eol` ; les fichiers écrits par l'outil Write sont en LF.
- `.github/` : CI (`check` + `build` sur PR et `main`), déploiement Pages (`deploy.yml`), gabarits d'issue et de PR, `CODEOWNERS`.
- `.github/workflows/situation.yml`, « Rejouer les situations » : rejoue tous les scripts sur Ubuntu à chaque push qui les touche, ou un seul à la demande (`gh workflow run situation.yml --ref <branche> -f script=<slug>`, puis `gh run view --log`). **Un `workflow_dispatch` ne fonctionne que si le workflow existe sur `main`** ; sur une branche, c'est le déclencheur `push` qui sert. À utiliser pour toute sortie qui dépend de Linux : le bash de Git Bash tolère les CRLF, les permissions de fichiers n'existent pas sous Windows. La page indique alors la version de Git du runner.

## Pièges connus

- **`base`** : ne jamais écrire `/git-en-situation` dans le contenu. Les liens sont `/section/slug/`, le plugin fait le reste. Les liens de la barre latérale sont gérés par Starlight. **Une exception** : les boutons du héros (`hero.actions` dans `index.mdx` et `en/index.mdx`) ne sont pas préfixés par Starlight ni par le plugin (ils sont dans l'en-tête, pas dans le Markdown) ; ils contiennent la base en clair. À changer avec `site` et `base` le jour du domaine propre.
- **`lastUpdated`** lit l'historique Git : les workflows font un `checkout` avec `fetch-depth: 0`, sinon toutes les pages affichent la date du build.
- **i18n** : la locale racine est le français. Une page absente en anglais affiche le français avec un bandeau ; ce n'est pas une erreur.
- **Validation des liens** : un lien vers une page qui n'existe pas encore casse le build. Les pages futures se citent en italique avec « (à venir) », sans lien.
- **Scripts** : la configuration Git est isolée (`GIT_CONFIG_GLOBAL` temporaire) et les dates figées, d'où des identifiants de commit stables entre exécutions. Sous Windows, exécuter dans Git Bash ; `.gitattributes` impose LF.
- **Node** : Astro 7 demande Node ≥ 22.12 ; `.nvmrc` dit 22. Un avertissement `EBADENGINE` sur `undici` apparaît avec Node 22.17 à l'installation : il est sans effet sur le build.
- **Avertissements normaux au build** : « The collection "i18n" does not exist or is empty » (pas de traduction personnalisée de l'interface Starlight) et « Could not render `/404` from route `/[...slug]` » (la page `404.md` est servie par la route 404 de Starlight, c'est voulu). Tout autre avertissement mérite un regard.
- **Zod** : importer `z` depuis `astro/zod` ; `astro:content` et `astro:schema` sont dépréciés pour ça dans Astro 7.
- **Titres dans le contenu** : Starlight enveloppe chaque titre dans `.sl-heading-wrapper` (titre + lien d'ancre). Un sélecteur `section > h2` ne matche pas ; viser le wrapper.
- **Débordement sur mobile** : un `<pre>` dans un conteneur flex ou grid élargit la page si on ne lui met pas `min-width: 0` (et `minmax(0, 1fr)` sur la colonne). Vérifier à 420 px de large après tout changement de l'accueil.
- **L'attribut `hidden` ne suffit pas** quand une règle CSS fixe `display` sur l'élément (cas des entrées `.home-list > li` en `display: grid`) : prévoir la règle `[hidden] { display: none }` à côté. Le filtre du catalogue a été livré cassé pour cette raison le 5 octobre 2026.
- **Un comportement au clic se teste par un clic.** Recette : après le build, déposer dans `dist/` une page de test qui charge la page visée dans un `<iframe>` de même origine et déclenche le clic par script, puis la capturer avec Chrome headless et `--virtual-time-budget=4000` (le temps que le script s'exécute). Supprimer la page de test ensuite.
- **Captures d'écran** : Chrome headless (`--headless=new --screenshot`) sur `npm run preview` permet de vérifier le rendu sans navigateur ouvert. Le poste étant en thème sombre, le thème clair s'obtient en injectant `localStorage.setItem("starlight-theme","light")` dans le HTML de `dist/` avant la capture. Pour une largeur mobile, `--window-size=420,…` ne suffit pas (Chrome impose une largeur minimale de fenêtre et la capture est tronquée) : capturer une page locale qui affiche le site dans un `<iframe>` de 420 px.
