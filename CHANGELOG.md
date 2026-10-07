# Changelog — git-en-situation

Ce fichier suit les évolutions du site et de son contenu. Format inspiré de [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/).

- **[Non publié]** : ce qui est sur `main` et pas encore annoncé.
- Chaque entrée dit ce qui change pour le lecteur ou pour le contributeur.

---

## [Non publié] — Phase 4, lot 22 : les situations « Réparer » en anglais

Branche `en/lot-22-reparer`, partie de `main` (`f3da0ca`).

### Contenu

- **Les six situations du thème « Réparer », en anglais** : « Undoing my last commit, not yet pushed », « Undoing a commit already pushed », « I committed on the wrong branch », « I am in "detached HEAD" », « A conflict during a merge or a rebase », « Finding a lost commit ». Le thème est entièrement traduit. Mêmes blocs de terminal que les pages françaises, vérifiés par les mêmes scripts ; l'encadré d'avertissement de « Undoing my last commit » est traduit.

### Pour les contributeurs

- `CLAUDE.md` : **aucune mention d'outil nulle part**, ni en pied de description de PR, ni `Co-Authored-By`, ni dans les releases, les discussions ou les issues. Les seize PR qui portaient une telle ligne ont été nettoyées le 7 octobre 2026.

### Suite prévue

- **Lot 23** : « Avec les autres » et « Fichiers et dépôt », huit situations ; la section « Situations » sera alors entièrement traduite.

---

## 7 octobre 2026 · Phase 4, lot 21 : les situations « Au quotidien » en anglais — en ligne le 7 octobre 2026

Branche `en/lot-21-quotidien`, partie de `main` (`8e98cab`), fusionnée par la PR #32 (`f3da0ca`).

### Contenu

- **Les huit situations restantes du thème « Au quotidien », en anglais** : « A remote branch was deleted, but I still see it », « After cloning, I don't see the other people's branches », « git pull asks me to choose between merge and rebase », « Setting my work in progress aside to change branch », « First push of a branch, "has no upstream branch" », « Renaming a branch, locally and on the server », « Deleting an old branch without losing anything », « Seeing what changed between my branch and main ». Avec la pilote du lot 20, le thème est entièrement traduit : sa page anglaise ne porte plus aucune marque « in French ». Mêmes blocs de terminal que les pages françaises, vérifiés par les mêmes scripts.
- **Un message de bienvenue** dans les Discussions ([#31](https://github.com/Hatimou-Nabina/git-en-situation/discussions/31)), publié dans « Ideas » faute de catégorie « Annonces », que l'API ne sait pas créer ; à déplacer le jour où la catégorie existera.

### Suite prévue

- **Lot 22** : les six situations « Réparer ». **Lot 23** : « Avec les autres » et « Fichiers et dépôt ».

---

## 7 octobre 2026 · Phase 4, lot 20 : la version anglaise, sans encore de pages — en ligne le 7 octobre 2026

Branche `en/lot-20-infrastructure`, partie de `main` (`37eb41e`), fusionnée par la PR #30 (`8e98cab`).

### Contenu

- **L'accueil anglais** est un vrai accueil : les quatre étapes, les trois dernières situations, la promesse sur les sorties, les quatre entrées, et un encart « English version in progress » qui dit qu'une page non traduite s'affiche en français avec un bandeau.
- **Les pages d'entrée en anglais** : catalogue, « How to read a situation », les quatre thèmes, Understand, Working as a team, Commands, About. Elles listent toutes les pages du site ; celles qui ne sont pas encore traduites apparaissent avec leur titre français, marquées « in French », et Starlight les sert en français avec un bandeau.
- **Une première situation traduite**, « My push is rejected, “rejected”, “fetch first” », pour éprouver toute la chaîne : mêmes blocs de terminal que la page française, vérifiés par le même script, encadrés « Try it yourself » et « Verified outputs ».
- « How to read a situation » dit que les messages de commit du dépôt d'exemple sont en français, et que les messages du mode exercice le sont aussi.
- « Mon push est refusé » renvoie désormais à « Un conflit pendant un merge ou un rebase » au lieu de l'annoncer « à venir ».

### Pour les contributeurs

- **Les composants lisent la locale** (`src/i18n.ts`) : `SituationsList`, `SituationsCatalogue` et `CommandUsages` partent des pages françaises, qui font référence pour le niveau, la version de Git et les dates, prennent le titre et la description de la traduction quand elle existe, et pointent vers `/en/…` dans la version anglaise. Les libellés et descriptions des thèmes existent dans les deux langues (`themes.mjs`).
- **Le vérificateur couvre `en/`** : une page anglaise cite le même script que la française, qui n'est rejoué qu'une fois pour les deux. `npm run verifier en/` ne vérifie que les pages anglaises.
- **Le validateur de liens tolère les liens vers des pages de repli** (`errorOnFallbackPages: false`) le temps de la traduction ; à remettre à la fin (lot 30).
- **`CONTRIBUTING.md`, « Traduire »** : la méthode, ce qui se traduit et ce qui ne se traduit pas, les deux encadrés en anglais, un glossaire, le scope de commit `en`.
- **`.mailmap`** : 80 commits du 5 au 7 octobre 2026 portaient par erreur l'adresse d'un poste fictif des scripts, restée dans la configuration locale du clone ; le fichier corrige l'affichage dans `git log` et `git shortlog`. GitHub, lui, ne le lit pas : ces commits y restent sans lien vers le compte. Le piège et la vérification à faire avant chaque lot sont dans `CLAUDE.md`.

### Suite prévue

- **Lots 21 à 23** : les situations, par thème (Au quotidien, Réparer, Avec les autres et Fichiers).
- Puis Comprendre (lot 24), Travailler en équipe (25 et 26), Commandes (27 à 29), clôture en 1.1.0 (lot 30).

---

## [1.0.0] — 7 octobre 2026 · Phase 4, lot 19 : ouvrir les portes — en ligne le 7 octobre 2026

Branche `communaute/ouvrir-les-portes`, partie de `main` (`305e917`), fusionnée par la PR #29 (`37eb41e`) ; tag `v1.0.0` et [release](https://github.com/Hatimou-Nabina/git-en-situation/releases/tag/v1.0.0) publiés le même jour. **Première version numérotée** : le site est complet en français, vérifié et déployé, et des gens vont s'en servir. À partir d'ici, le changelog suit [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/) à la lettre, comme la page « Tenir un changelog » le recommande : une section par version, numérotée et datée, et un tag annoté `v1.0.0` sur le commit de fusion.

### Ce que contient la version 1.0.0

- **68 pages** : 23 situations en quatre thèmes (au quotidien, réparer, avec les autres, fichiers et dépôt), 4 pages « Comprendre », 12 pages « Travailler en équipe », 29 fiches « Commandes ».
- **Des sorties vraies** : chaque page est adossée à un script qui rejoue le scénario dans des dépôts jetables ; un vérificateur compare les pages aux scripts à chaque pull request, avec la version de Git que chaque page déclare.
- **Des exercices** : `EXERCICE=1 bash scripts/situations/<slug>.sh` fabrique la panne et s'arrête au symptôme.
- **Un site** : recherche, catalogue par thème et par niveau, badges de niveau, de risque et de version de Git ; français en locale racine, anglais préparé.
- **Un dépôt ouvert** : guide de contribution, code de conduite, gabarits d'issue et de PR, Discussions, cinq tâches « bonne première contribution ».

### Site

- **Image de partage** : `public/og-image.png` (1200 × 630), rendue depuis `src/assets/og-image.html` avec les polices du site, et les balises `og:image` et `twitter:image` sur toutes les pages. Un lien du site posté sur une messagerie ou un réseau affiche désormais une carte avec une image ; Starlight pose `twitter:card` mais pas `og:image`.
- « À propos » dit où suivre les versions, et que la version anglaise est en préparation.

### Dépôt

- README : le site n'est plus « en construction » ; badges de la CI, de la vérification des sorties et du déploiement ; comment suivre le projet.
- `CLAUDE.md` : décisions de la phase 4 (la communauté avant la traduction, procédure de version, image de partage, messages de commit du dépôt d'exemple gardés en français dans la version anglaise).

### Actions requises après la fusion

Par le mainteneur, ou par l'assistant avec son feu vert explicite : elles engagent le compte.

1. ✅ *Fait le 7 octobre 2026.* **Le tag et la release** : tag annoté `v1.0.0` sur le commit de fusion de `main`, poussé, puis release GitHub reprenant cette section.
2. ✅ *Fait le 7 octobre 2026.* **Le dépôt** : adresse du site et sujets ; Wiki et Projects, non utilisés, désactivés.
3. ✅ *Fait le 7 octobre 2026, dans « Ideas ».* **Les Discussions** : le message de bienvenue est publié ([#31](https://github.com/Hatimou-Nabina/git-en-situation/discussions/31)). La catégorie « Annonces » ne se crée que dans l'interface ; le message y sera déplacé, et épinglé, quand elle existera.
4. ✅ *Fait le 7 octobre 2026.* **Un ruleset de tags `v*`**, pour que personne ne supprime ni ne déplace une version.

### Suite prévue

- **Lot 20** : la version anglaise sans encore de pages : composants qui lisent la locale, vérificateur sur `en/`, pages d'index anglaises, section « Traduire » du CONTRIBUTING avec un glossaire, une situation pilote.
- **Lots 21 à 30** : situations par thème, Comprendre, Travailler en équipe, Commandes, puis clôture en 1.1.0. Et, au fil des contributions, les pages « Comprendre » prévues (#11, #24, #25).

---

## 6 octobre 2026 · Phase 3, lot 18 : les exercices — en ligne le 6 octobre 2026

Branche `situations/exercices-1`, partie de `main` (`0432e13`), fusionnée par la PR #28 (`305e917`).

### Contenu

- **Chaque situation se termine par un encadré « Essaie-le toi-même »**, sauf « Deux comptes GitHub sur le même poste », dont le scénario dépend du dossier personnel et de SSH. Avec `EXERCICE=1 bash scripts/situations/<slug>.sh`, le script de la page fabrique la panne dans `exercices/<slug>/` à la racine d'un clone du dépôt, s'arrête juste après le symptôme et affiche le dossier où aller et l'objectif, formulé sans donner la commande. On répare, puis on relance sans la variable pour comparer avec la solution. Rien n'est envoyé nulle part : le serveur est un dossier à côté.
- « Comment lire une situation » explique les exercices.

### Pour les contributeurs

- `_lib.sh` : le mode exercice et la fonction `exercice <poste> '<objectif>'`, une ligne par script de situation, juste après le symptôme ; `exercices/` est ignoré par Git. Gabarit mis à jour dans `CONTRIBUTING.md`. En mode normal, la ligne ne fait rien : le vérificateur confirme que les 22 pages donnent les mêmes 126 blocs.

### Suite prévue

- **Phase 4** : traduction anglaise, animation de la communauté. Et, au fil des contributions, les pages « Comprendre » prévues (#11, #24, #25).

---

## 6 octobre 2026 · Phase 3, lot 17 : la vérification automatique des sorties — en ligne le 6 octobre 2026

Branche `site/verifier-sorties`, partie de `main` (`8add348`), fusionnée par la PR #27 (`0432e13`).

### Pour les contributeurs

- **`npm run verifier`** : `scripts/verifier-sorties.mjs` rejoue le script de chaque page et vérifie que chaque bloc de terminal s'y retrouve tel quel, commande par commande et dans l'ordre, retours chariot et espaces de fin retirés. C'est une inclusion, pas une égalité : une page montre un extrait de son script. Les blocs `text`, `bash` et `yaml` sont cités par nature et ne sont pas vérifiés ; une page sans script est ignorée. Par défaut, seules les pages dont le `gitVersion` est celui du poste sont vérifiées ; `--toutes`, `--git-version 2.50`, ou un morceau de chemin pour n'en vérifier qu'une.
- **Workflow « Vérifier les sorties »**, bloquant sur chaque PR et sur `main` : une version de Git par job, celle du runner telle quelle, les autres construites depuis les sources et mises en cache. Chaque page est vérifiée avec la version qu'elle déclare.
- **La bibliothèque des scripts** : l'adresse d'`origin` est relative, `../github.com/equipe/projet.git`, la même sur tous les postes et tous les systèmes, pour que les commits de merge créés par `git pull`, dont le message cite l'adresse, aient partout le même identifiant ; les durées (`in 0.21 seconds`) sont remplacées par `N.NN` ; un script ajoute ses règles de nettoyage par `CLEAN_PRE` et `CLEAN_EXTRA` au lieu de redéfinir `clean`.
- **Les deux flux de sortie sont imprimés dans un ordre fixe, `stderr` puis `stdout`.** Le premier passage du workflow sur Linux a échoué sur 23 pages qui passaient sur Windows : mélangés par `2>&1`, les deux flux n'arrivent pas dans le même ordre selon le système, Git pour Windows mettant `stderr` en tampon. Les 23 pages sont réécrites dans l'ordre fixe, qui est celui d'un terminal pour `git switch`, `git pull` et `git push -u` ; pour un rebase ou un cherry-pick en conflit, les lignes « CONFLICT » viennent après les `hint:`. La page « Comment lire une page » l'explique au lecteur.

### Ce que le premier passage a trouvé, et corrigé

- « Les remotes et les références distantes » omettait une ligne de la sortie de `git status`.
- « J'ai poussé un secret par erreur » montrait des durées de `filter-repo` que personne ne peut reproduire.
- « Git voit tous mes fichiers comme modifiés » dépendait de la vitesse d'exécution : après un changement de `core.autocrlf`, Git fait confiance aux dates des fichiers et ne relit pas leur contenu, sauf quand le clone et l'index datent de la même seconde. Le script rafraîchit les fichiers, et la page le dit.
- « git pull me demande de choisir entre merge et rebase » et « Un conflit pendant un merge ou un rebase » montraient des identifiants de commit de merge qui changeaient à chaque exécution, le chemin du bac à sable étant dans leur message. Avec l'adresse relative, ils sont stables ; mis à jour.
- 65 pages et 351 blocs vérifiés sur le poste, en Git 2.50 ; les deux pages en Git 2.55 le sont en CI.

### Suite prévue

- Lot 18 : le mode exercice des scripts de situation, et l'encadré « Essaie-le toi-même » dans chaque situation.

---

## 6 octobre 2026 · Phase 2, lots 15 et 16 : les fiches « Commandes » sont complètes, fin de la phase 2 — en ligne le 6 octobre 2026

Branche `commandes/lots-15-16`, partie de `main` (`9cbd2d4`), fusionnée par la PR #26 (`8add348`). Les deux lots sur une seule branche et une seule PR, à la demande du mainteneur.

### Contenu

- **Lot 15, régler et inspecter** : `git config`, `git show`, `git ls-files`, `git check-ignore`, chacune avec son script dans `scripts/commandes/` et ses sorties réelles (Git 2.50, 6 octobre 2026) ; et `gh`, la seule fiche sans script ni sorties vérifiées, parce qu'un script ne peut pas exécuter `gh` sans compte connecté. Elle rassemble les commandes `gh` que les pages du site citent, et le dit dans un encadré.
- **Lot 16, les quatre fiches proposées le 6 octobre 2026** : `git checkout`, la commande qu'on tape encore, chaque forme avec son équivalent `switch` ou `restore`, et la différence entre `checkout commit -- fichier`, qui passe par l'index, et `restore --source`, qui ne touche que le dossier ; `git cat-file` ; `git merge-base` ; `git rm`.
- **La section « Commandes » est complète** : vingt-neuf fiches, en sept groupes d'usage. Pas de fiche pour `blame`, `bisect`, `worktree`, `mv`, `clean`, qu'aucune page n'emploie.
- **Fin de la phase 2** : 23 situations, 4 pages « Comprendre », 12 pages « Travailler en équipe », 29 fiches « Commandes », soit 68 pages, toutes sauf une adossées à un script rejoué sur Windows et sur Ubuntu.

### Pour les contributeurs

- `CommandUsages.astro` accepte `prefix` et `mode="cited"` : la liste « Où ça sert » peut compter les pages qui citent une commande entre accents graves, pour les outils qu'aucun script n'exécute.
- `CONTRIBUTING.md` et `CLAUDE.md` consignent l'exception `gh`.
- Issues : #13 (rejeu sur macOS) couvre désormais `scripts/commandes/` ; #24 et #25 ouvertes pour deux pages « Comprendre » que les situations citent encore « (à venir) », « Le reflog, ton filet de sécurité » et « L'index, l'étape entre ton dossier et le commit », étayées par les fiches `reflog`, `add` et `status`.

### Suite prévue

- **Phase 3** : vérification automatique en CI que les sorties des pages correspondent toujours aux scripts ; exercices dans un dépôt bac à sable. Et, au fil des contributions, les six pages « Comprendre » encore prévues (dont #11, #24, #25), qui feront disparaître les dernières mentions « (à venir) » des situations.
- **Phase 4** : traduction anglaise, animation de la communauté.

---

## 6 octobre 2026 · Phase 2, lot 14 : les fiches pour réunir — en ligne le 6 octobre 2026

Branche `commandes/lot-14`, partie de `main` (`9af69e3`), fusionnée par la PR #23 (`9cbd2d4`).

### Contenu

- **Quatre fiches « Commandes »**, `git merge`, `git rebase`, `git cherry-pick`, `git tag`, chacune avec son script dans `scripts/commandes/` et ses sorties réelles (Git 2.50, 6 octobre 2026) :
  - `merge` : l'avance rapide, le commit de merge, `--no-ff`, `--ff-only`, `--squash`, le conflit et `--abort` ;
  - `rebase` : la mise à jour sur `origin/main`, `-i` joué sans terminal grâce à `GIT_SEQUENCE_EDITOR`, le conflit avec `--abort` puis `--continue`, le `--force-with-lease` qui suit ; marquée *réversible* ;
  - `cherry-pick` : un commit, `-x`, une plage, `--no-commit`, le conflit et `--abort` ;
  - `tag` : annoté et léger, lister, filtrer et trier, l'envoi au serveur, la suppression en local puis sur le serveur, `show` et `describe`.
- La page d'entrée « Commandes » passe à vingt fiches disponibles, cinq prévues.

### Suite proposée

- Lot 15, convenu : `config`, `show`, `ls-files`, `check-ignore`, et `gh` en fiche sans script, l'unique exception, parce qu'un script ne peut pas exécuter `gh` sans compte connecté. À confirmer.
- Lot 16, proposé le 6 octobre 2026 : `checkout` (cité dans neuf pages, exécuté dans aucune, la commande qu'on tape encore), `cat-file`, `merge-base`, `rm`. À confirmer. Hors règle, pas de fiche : `blame`, `bisect`, `worktree`, `mv`, `clean`, et les commandes exécutées dans une seule page.

---

## 6 octobre 2026 · Phase 2, lot 13 : les fiches pour réparer — en ligne le 6 octobre 2026

Branche `commandes/lot-13`, partie de `main` (`c33f8b8`), fusionnée par la PR #22 (`9af69e3`).

### Contenu

- **Quatre fiches « Commandes »**, `git reset`, `git restore`, `git revert`, `git reflog`, chacune avec son script dans `scripts/commandes/` et ses sorties réelles (Git 2.50, 6 octobre 2026) :
  - `reset` : `--soft`, sans option, `--hard` et le retour par le reflog, `--keep` avec une branche posée d'abord, `reset fichier` ; marquée *destructif* ;
  - `restore` : `--staged`, sans option, `--staged --worktree`, `--source`, `restore .` ; marquée *destructif*, parce qu'une modification jetée n'est nulle part ;
  - `revert` : un commit, un commit de merge avec `-m 1` et l'erreur sans `-m`, le revert du revert que Git 2.50 nomme « Reapply », le push qui passe ;
  - `reflog` : le journal de `HEAD`, le retour après un `reset --hard`, la branche supprimée recréée, le journal d'une branche avec `--date=iso`.
- La page d'entrée « Commandes » passe à seize fiches disponibles.
- **Règle de sélection précisée** : une fiche existe si au moins deux pages du site s'appuient sur la commande, en l'exécutant ou en la recommandant. La formulation initiale, « l'exécutent », aurait écarté `restore`, qu'aucune page n'exécute, et `revert`, qu'une seule exécute, alors que le site les recommande en toutes lettres à la place de `checkout` et de `reset` sur une branche partagée. À confirmer par le mainteneur.

---

## 6 octobre 2026 · Phase 2, lot 12 : les fiches du quotidien — en ligne le 6 octobre 2026

Branche `commandes/lot-12`, partie de `main` (`73574ad`), fusionnée par la PR #21 (`c33f8b8`).

### Contenu

- **Quatre fiches « Commandes »**, `git status`, `git add`, `git commit`, `git stash`, chacune avec son script dans `scripts/commandes/` et ses sorties réelles (Git 2.50, 6 octobre 2026) :
  - `status` : les trois états d'un fichier, la forme courte et ses codes, `-sb`, ce que `status` dit pendant un conflit, `--ignored` ;
  - `add` : un fichier, un dossier, `--dry-run`, `-p` joué sans terminal avec ses deux questions, les suppressions, `-A`, le fichier ignoré refusé ;
  - `commit` : `-m`, le refus sans rien dans l'index, `-a`, le corps avec un second `-m`, `--amend` avec et sans `--no-edit`, `--allow-empty` ;
  - `stash` : les fichiers suivis seulement sauf `-u`, `-m`, `list` et `show`, `pop` après un passage sur une autre branche, `apply` et `drop`.
- La page d'entrée « Commandes » passe à douze fiches disponibles.
- Point d'étape du 6 octobre 2026 : les fiches continuent, décision du mainteneur. Restent `reset`, `restore`, `revert`, `reflog` ; `merge`, `rebase`, `cherry-pick`, `tag` ; `config`, `show`, `ls-files`, `check-ignore`, `gh`.

---

## 6 octobre 2026 · Phase 2, lot 11 : les fiches du serveur — en ligne le 6 octobre 2026

Branche `commandes/lot-11`, partie de `main` (`74bd1d7`), fusionnée par la PR #20 (`73574ad`).

### Contenu

- **Quatre fiches « Commandes »**, `git fetch`, `git pull`, `git push`, `git remote`, chacune avec son script dans `scripts/commandes/` et ses sorties réelles (Git 2.50, 6 octobre 2026) :
  - `fetch` : `--dry-run`, ce qu'un `fetch` rapporte, ce qu'il ne change pas, `--prune`, `fetch.prune` ;
  - `pull` : l'avance rapide, le refus de deviner quand les deux côtés ont avancé, `--ff-only`, `--rebase`, `pull.ff only`, la branche sans suivi ;
  - `push` : `-u`, le refus « fetch first », `--force-with-lease` refusé pour « stale info » puis accepté après une réécriture, `--delete`, `push.autoSetupRemote` ;
  - `remote` : `-v`, `show`, `prune`, `add` et `remove` d'un second serveur, `set-url`.
- La page d'entrée « Commandes » passe à huit fiches disponibles.

### Point d'étape

- Huit fiches en ligne, comme convenu le 5 octobre 2026 : à décider si les fiches continuent, avec les lots `status`, `add`, `commit`, `stash` ; `reset`, `restore`, `revert`, `reflog` ; `merge`, `rebase`, `cherry-pick`, `tag` ; `config`, `show`, `ls-files`, `check-ignore`, `gh`.

---

## 5 octobre 2026 · Phase 2, lot 10 : les premières fiches « Commandes » — en ligne le 5 octobre 2026

Branche `commandes/lot-10`, partie de `main` (`4ef1fb3`), fusionnée par la PR #19 (`74bd1d7`).

### Contenu

- **Quatre fiches « Commandes »**, `git log`, `git diff`, `git branch`, `git switch`, chacune avec son script dans `scripts/commandes/` et ses sorties réelles (Git 2.50, 5 octobre 2026). Une fiche s'en tient aux formes que les pages du site emploient, et renvoie aux pages où la commande sert.
- **« Où ça sert » est calculé** : le composant `CommandUsages.astro` liste, au build, les pages dont une ligne de terminal commence par `$ git <commande>`. La liste ne se périme pas.
- La page d'entrée « Commandes » liste les fiches disponibles et les vingt prévues, par usage, avec la règle de sélection : une fiche existe si au moins deux pages du site exécutent la commande. La mention « (à venir) » de « Voir ce qui a changé » devient deux liens.

### Pour les contributeurs

- Gabarit des fiches « Commandes » dans `CONTRIBUTING.md` : à quoi ça sert, les formes qui servent, pièges, où ça sert.
- Le workflow « Rejouer les situations » exécute aussi `scripts/commandes/`.

### Suite prévue

- Fiches par lots de quatre, dans cet ordre : `fetch`, `pull`, `push`, `remote` ; `status`, `add`, `commit`, `stash` ; `reset`, `restore`, `revert`, `reflog` ; `merge`, `rebase`, `cherry-pick`, `tag` ; `config`, `show`, `ls-files`, `check-ignore` et `gh`. Point d'étape après le second lot : si les fiches n'apportent rien de plus que les situations, on s'arrête à huit.

---

## 5 octobre 2026 · Phase 2, lot 9 : la section « Travailler en équipe » est complète — en ligne le 5 octobre 2026

Branche `equipe/lot-9`, partie de `main` (`4e0b6d4`), fusionnée par la PR #18 (`4ef1fb3`).

### Contenu

- **Quatre pages « Travailler en équipe »**, chacune avec son script dans `scripts/equipe/` et ses sorties réelles :
  - « Versions et tags » (tag annoté, `push` qui n'emporte pas les tags, `describe`, `tag --contains` pour savoir dans quelle version un correctif est arrivé, retour à une version, les tags chez un collègue ; Git 2.50) ;
  - « CODEOWNERS, gabarits d'issue et de PR » (`shortlog` pour savoir qui connaît quoi, les trois fichiers de `.github/` et leurs pièges silencieux ; Git 2.50) ;
  - « Une CI qui vérifie ce que les postes ne voient pas » (bit d'exécution, casse des noms, fichier qui n'existe que sur le poste, un script de vérification et le workflow qui le lance ; sorties du rejeu sur Ubuntu, Git 2.55, parce que le bit d'exécution et la casse n'existent pas sous Windows) ;
  - « Forker et contribuer à un projet open source » (`origin` et `upstream`, une branche par contribution partie d'`upstream/main`, rebase et `--force-with-lease` pendant la relecture, le fork remis au niveau ; Git 2.50).
- **La section « Travailler en équipe » est complète** : douze pages. Le sommaire n'a plus de « à venir » ; la dernière mention « (à venir) » des situations vers cette section (« Mes scripts cassent sur le serveur » vers la page CI) devient un lien, ainsi que celles des pages « prod » et « changelog » vers « Versions et tags ».
- `CONTRIBUTING.md` renvoie à la page « Forker et contribuer » pour aller plus loin que la première contribution.

### Pour les contributeurs

- `_lib.sh` : la ligne de commande affichée par `run` et `run_sh` est nettoyée comme la sortie. Un chemin du bac à sable passé en argument (`git remote add upstream …`) s'affiche en adresse de serveur.

### Suite prévue

- **Phase 2, fin** : les fiches « Commandes », à cadrer avec le mainteneur avant de commencer.
- **Phase 3** : vérification automatique en CI que les sorties des pages correspondent toujours aux scripts ; exercices dans un dépôt bac à sable.
- **Phase 4** : traduction anglaise, animation de la communauté.

---

## 5 octobre 2026 · Phase 2, lot 8 : travailler en équipe, trois pages — en ligne le 5 octobre 2026

Branche `equipe/lot-8`, partie de `main` (`25d9589`), fusionnée par la PR #17 (`4e0b6d4`).

### Contenu

- **Trois pages « Travailler en équipe »**, chacune avec son script dans `scripts/equipe/` et ses sorties réelles (Git 2.50, 5 octobre 2026) :
  - « Relire une pull request » (la branche de la PR sur son poste, l'ensemble puis commit par commit, `git grep` qui trouve l'appel oublié que les tests ne voient pas, ne relire que ce qui a changé après le correctif, quand approuver) ;
  - « Branche de travail et branche de production » (`main` et `prod`, la mise en production en avance rapide, le correctif urgent parti de `prod` et reporté sur `main`, `prod..main` et `main..prod` pour savoir ce qui est où) ;
  - « Tenir un changelog » (le format Keep a Changelog, la ligne qui voyage avec le commit, le conflit sur la section « Non publié » et `merge=union` qui l'évite, le brouillon depuis les commits conventionnels, la version qui prend un numéro et une date).
- Le sommaire « Travailler en équipe » passe à huit pages disponibles, quatre prévues. Deux mentions « (à venir) » vers la page « pull request », oubliées au lot 6, deviennent des liens (« Ma branche locale est en retard après une fusion », « Supprimer une vieille branche »).

---

## 5 octobre 2026 · Phase 2, lot 7 : travailler en équipe, trois pages — en ligne le 5 octobre 2026

Branche `equipe/lot-7`, partie de `main` (`c559e5b`), fusionnée par la PR #16 (`25d9589`).

### Contenu

- **Trois pages « Travailler en équipe »**, chacune avec son script dans `scripts/equipe/` et ses sorties réelles (Git 2.50, 5 octobre 2026) :
  - « Une branche par changement » (nommer, une intention par branche, voir ce que `main` a reçu entre-temps, hook `pre-commit` qui refuse le commit sur `main`, `branch -d` qui refuse une branche non fusionnée) ;
  - « Protéger la branche principale » (le push forcé qui efface le commit d'un collègue, `receive.denyNonFastForwards` et `receive.denyDeletes` sur le serveur, hook `update` qui impose la pull request, le commit déplacé sur une branche) ;
  - « Les secrets ne vont jamais dans le dépôt » (`.env` ignoré et `.env.example` versionné, `check-ignore -v`, l'application qui lit l'environnement, hook `pre-commit` qui refuse un `.env` ou une clé, recherche dans l'historique avec `log -S`).
- Le sommaire « Travailler en équipe » passe à cinq pages disponibles, six prévues. Dans les pages qui les citaient « (à venir) », les mentions deviennent des liens : « Mon push est refusé », « Annuler un commit déjà poussé », « J'ai poussé un secret par erreur », « .gitignore ne marche pas », « Deux comptes GitHub », et la page « pull request ».

### Pour les contributeurs

- Les étiquettes `situation`, `à trier` et `erreur`, que les gabarits d'issue déclaraient sans qu'elles existent sur le dépôt, sont créées : les issues ouvertes depuis un gabarit les portent désormais.
- `CLAUDE.md` : dans le shell de l'outil, `$'\r'` n'est pas interprété ; les fins de ligne se vérifient avec `file` ou `git ls-files --eol`.

---

## 5 octobre 2026 · Les Discussions pour les questions — en ligne le 5 octobre 2026

Branche `docs/discussions`, partie de `main` (`0fd47ac`), fusionnée par la PR #15 (`c559e5b`).

### Pour les contributeurs

- **Les Discussions sont ouvertes**, pour les questions et les idées pas encore mûres ; les issues restent pour ce qui est actionnable. Lien dans le `CONTRIBUTING.md`, le `README.md`, et dans « New issue » (`contact_links` de `.github/ISSUE_TEMPLATE/config.yml`).

---

## 5 octobre 2026 · Ouvrir le projet aux contributions — en ligne le 5 octobre 2026

Branche `docs/premiere-contribution`, partie de `main` (`4c361e6`), fusionnée par la PR #14 (`0fd47ac`).

### Pour les contributeurs

- **« Première contribution, sans installer Git »**, en tête du `CONTRIBUTING.md` : corriger une page depuis le lien « Modifier cette page » du site, le crayon sur GitHub, le fork que GitHub crée tout seul, jusqu'à « Propose changes » et la pull request. Avec, en deux phrases, ce qu'est un fork et pourquoi on n'a pas besoin d'être membre du projet.
- **Étiquette « bonne première contribution »** sur le dépôt, et trois premières issues qui la portent : une page « Comprendre » courte à écrire (« Upstream, la branche que la tienne suit », #11), une relecture de « Deux comptes GitHub sur le même poste » avec deux vrais comptes (#12), et le rejeu des scripts sur macOS, où ils n'ont encore jamais tourné (#13).

---

## 5 octobre 2026 · La page « pull request » sans appel à GitHub — en ligne le 5 octobre 2026

Branche `fix/pr-page-sans-gh`, partie de `main` (`e528200`), fusionnée par la PR #10 (`4c361e6`).

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

[Non publié]: https://github.com/Hatimou-Nabina/git-en-situation/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/Hatimou-Nabina/git-en-situation/releases/tag/v1.0.0
