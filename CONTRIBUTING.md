# Contribuer à git-en-situation

Merci de t'y intéresser. Ce projet vit des situations que les gens rencontrent vraiment : la tienne a sa place ici.

## Première contribution, sans installer Git

Une faute, une phrase obscure, un lien cassé : tu peux corriger une page depuis ton navigateur, sans rien installer et sans être membre du projet.

1. **Sur le site**, en bas de la page concernée, clique sur « Modifier cette page ». Le fichier de la page s'ouvre sur GitHub.
2. **Sur GitHub**, clique sur le crayon en haut à droite du fichier. Comme tu n'as pas le droit d'écrire dans ce dépôt, GitHub te propose d'en créer une copie sur ton compte : accepte (« Fork this repository »). Ça prend quelques secondes, et tu arrives dans l'éditeur.
3. **Corrige**, puis clique sur « Commit changes… ». Décris le changement en une ligne, par exemple `fix(situations): corrige une faute dans « Mon push est refusé »`, et valide avec « Propose changes ».
4. **Ouvre la pull request** : GitHub te montre la différence et te propose « Create pull request ». Le gabarit pose trois questions, quoi, pourquoi, qu'est-ce qui a été vérifié ; pour une faute, une ligne à chaque fois suffit.

Le mainteneur relit, et fusionne ou te répond sur la pull request. Si tu veux ensuite aller plus loin, la suite de ce document explique comment faire la même chose depuis ton poste, et la page [Forker et contribuer à un projet open source](https://hatimou-nabina.github.io/git-en-situation/equipe/forker-et-contribuer/) du site détaille le fork, la branche et la pull request entre deux dépôts.

**Ce qu'est un fork.** Un fork est une copie du dépôt sur ton compte GitHub, où tu as tous les droits. Tu écris dans ta copie et tu *proposes* au projet de reprendre ta modification : personne n'a besoin de te donner accès au dépôt d'origine, et le projet reste protégé.

Les issues étiquetées [« bonne première contribution »](https://github.com/Hatimou-Nabina/git-en-situation/issues?q=is%3Aissue+is%3Aopen+label%3A%22bonne+premi%C3%A8re+contribution%22) sont des tâches cadrées, pensées pour un premier pas.

## Trois façons de contribuer

1. **Proposer une situation** que tu as vécue, même sans en connaître la solution : [ouvre une issue](https://github.com/Hatimou-Nabina/git-en-situation/issues/new?template=proposer-une-situation.yml). Ce que tu as vu et ce que tu essayais de faire suffisent.
2. **Signaler une erreur** : une commande fausse, une sortie qui ne correspond pas à la tienne, une explication trompeuse, une faute : [ouvre une issue](https://github.com/Hatimou-Nabina/git-en-situation/issues/new?template=signaler-une-erreur.yml).
3. **Écrire ou corriger une page**, par une pull request. La suite de ce document explique comment.

**Une question, plutôt qu'une contribution ?** « Par où je commence ? », « est-ce que cette situation vaut une page ? » : les [Discussions](https://github.com/Hatimou-Nabina/git-en-situation/discussions) sont faites pour ça. Les issues restent pour ce qui est actionnable : une situation précise, une erreur repérée.

Les traductions viendront après la version française : voir « Traduire » en fin de document.

## Installer le projet

Il faut Node.js 22 et Git. Sous Windows, les scripts s'exécutent dans Git Bash.

```bash
git clone https://github.com/<ton-compte>/git-en-situation.git
cd git-en-situation
npm ci
npm run dev      # http://localhost:4321/git-en-situation/
```

| Commande | Rôle |
|---|---|
| `npm run dev` | Serveur de développement, rechargement à chaud |
| `npm run build` | Construit le site et **valide tous les liens internes** : une page qui pointe vers une page absente fait échouer le build |
| `npm run check` | Vérifie les types des composants et de la configuration |
| `bash scripts/situations/<slug>.sh` | Rejoue une situation et affiche ses vraies sorties |

## Écrire une situation

### 1. Une issue d'abord

Vérifie que la situation n'existe pas déjà, puis ouvre une issue « Proposer une situation ». Ça évite deux personnes sur la même page, et ça permet de cadrer le titre ensemble.

### 2. Le script, avant la page

Chaque page de situation est adossée à un script `scripts/situations/<slug>.sh`, qui rejoue le scénario dans des dépôts jetables et affiche chaque commande suivie de sa vraie sortie. **Aucune sortie n'est écrite à la main.**

Pars d'un script existant. La bibliothèque `_lib.sh` fournit :

- `setup_team` : un « serveur » (`github.com:equipe/projet.git`) et deux postes clonés, `awa` et `bakary` ;
- `run <poste> <commande>` : affiche `$ commande` puis sa sortie ;
- `run_sh <poste> '<ligne>'` : pareil, pour une ligne avec `&&` ou `|` ;
- `quiet` et `quiet_sh` : la mise en place, sans affichage ;
- `note '<titre>'` : un repère dans la sortie.

La configuration Git est neutre et les dates figées : le script donne les mêmes identifiants de commit à chaque exécution, chez tout le monde.

```bash
bash scripts/situations/<slug>.sh
```

### 3. La page

Crée `src/content/docs/situations/<theme>/<slug>.md`. Le `<slug>` est celui du script : des mots en minuscules séparés par des tirets, sans accents, qui disent la situation (`push-refuse-fetch-first`, pas `probleme-push`). Le `<theme>` est l'un des dossiers existants (`quotidien`, `reparer`…) : la barre latérale, le catalogue et la page du thème se mettent à jour tout seuls. Un thème nouveau se crée en ajoutant un dossier avec son `index.mdx`, et une entrée dans `src/themes.mjs`.

```markdown
---
title: Ce que la personne taperait dans un moteur de recherche
description: Une ou deux phrases : le symptôme, puis ce que la page apporte. C'est ce que Google affiche.
level: debutant | intermediaire | avance
risk: aucun | reversible | destructif
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

## Symptôme
Ce que la personne voit à l'écran, message exact compris.

## Diagnostic
Ce qui s'est passé, en deux ou trois phrases.

## Solution
Les commandes dans l'ordre, chacune avec sa vraie sortie, numérotées en gras : **1. …**

## Pourquoi ça marche
Le morceau de modèle mental qui fait qu'on retient.

## Pièges
Les variantes qui trompent, ce qu'il ne faut pas faire.

## Voir aussi
Les situations voisines. Les pages qui n'existent pas encore sont citées en italique avec « (à venir) », sans lien.

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/situations/<slug>.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/situations/<slug>.sh), exécuté avec Git X.Y le JJ mois AAAA. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
```

Les champs de l'en-tête :

- **`level`** : *debutant* se suit sans préparation ; *intermediaire* suppose d'être à l'aise avec les branches ; *avance* touche à l'historique ou à la configuration.
- **`risk`** : *aucun* si rien ne peut être perdu ; *reversible* si un retour en arrière existe et est expliqué dans la page ; *destructif* si une commande peut faire perdre du travail. Dans ce cas, la page dit précisément quoi, et comment s'en prémunir.
- **`gitVersion`** et **`verified`** : la version de Git et la date de l'exécution du script dont viennent les sorties. Si tu relances le script plus tard et que rien ne change, mets la date à jour.
- **`published`** : la date de publication, qui ne change plus ensuite. L'accueil montre les situations les plus récentes.

### 4. Le style

- **Tutoiement**, phrases courtes, un seul sujet par page. Si la page dépasse cinq minutes de lecture, c'est deux pages.
- **Le titre est une recherche**, pas un intitulé de cours : « Mon push est refusé », pas « Gestion des divergences ».
- **Les sessions de terminal** sont des blocs ` ```console ` avec le prompt `$ ` : les commandes sont mises en valeur, les sorties restent telles quelles. Pas de capture d'écran de terminal.
- **Ce qui est propre à GitHub** est dit comme tel (« Sur GitHub, … »). Le reste vaut pour tout serveur Git.
- **Les liens internes** s'écrivent depuis la racine, avec le slash final : `/situations/<theme>/mon-slug/`. Le site ajoute lui-même son préfixe d'hébergement. Si une page change de thème, son ancienne adresse est ajoutée à `src/redirects.mjs` : une adresse publiée ne répond jamais « introuvable ».
- **Les termes** : on dit « référence distante » pour `origin/x`, « branche locale », « serveur » plutôt que « remote » quand on parle de GitHub, « fusion » pour merge, « rebase » reste « rebase ».

### 5. Vérifier, puis proposer

```bash
npm run build     # doit passer : liens valides, en-têtes conformes au schéma
```

Ouvre la pull request depuis une branche nommée `situation/<slug>` (ou `fix/<sujet>`, `site/<sujet>`). Le gabarit de PR liste ce qu'on vérifie. Une PR = une page, ou une correction cohérente.

## Écrire une page « Comprendre »

Ces pages expliquent le modèle de Git, pas une panne. Elles ont aussi un script, dans `scripts/comprendre/`, qui utilise la même bibliothèque (`source "$(dirname "$0")/../situations/_lib.sh"`) : montrer l'intérieur d'un commit ou d'une branche avec de vraies sorties vaut mieux qu'un schéma. Plan fixe :

```markdown
---
title: L'idée en une phrase, à l'affirmative (« Une branche, c'est un marque-page »)
description: Deux phrases qui disent l'idée et ce qu'elle rend évident.
level: debutant | intermediaire | avance
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
sidebar:
  order: 5      # ordre de lecture dans la section
---

## L'idée
Le concept nu, en quelques phrases, sans commande.

## Voir par soi-même
Les commandes qui montrent le concept, avec leurs vraies sorties.

## Ce que ça change dans la pratique
Les conséquences, en liste : ce qui devient évident, ce qu'on ne fait plus.

## Où ça sert
Les situations qui reposent sur cette idée.
```

Pas de champ `risk` : on ne répare rien ici. Même règle que pour les situations : toute sortie vient du script, et le bloc « Sorties vérifiées » le cite.

## Écrire une page « Travailler en équipe »

Ces pages décrivent une façon de travailler, et commencent toujours par ce qu'elle évite : c'est l'argument, le reste est la méthode. Script dans `scripts/equipe/`, même bibliothèque. Ce qui est propre à GitHub est dans sa propre section, pour que le reste vaille sur tout serveur Git. Plan fixe :

```markdown
## Ce que ça évite
Le problème concret, vécu, que cette pratique fait disparaître.

## Comment on fait
Les étapes, avec les commandes et leurs vraies sorties.

## Sur GitHub
Ce qui est propre à GitHub : boutons, réglages, gh.

## Pièges
Les dérives habituelles de la pratique.

## Voir aussi
```

## Écrire une fiche « Commandes »

Une fiche n'est pas une copie du manuel : elle s'en tient aux formes de la commande que les pages du site emploient, avec leurs vraies sorties, et renvoie aux pages où la commande sert. Une fiche existe si au moins deux pages du site s'appuient sur la commande, en l'exécutant ou en la recommandant. Script dans `scripts/commandes/<commande>.sh`, même bibliothèque ; page en `.mdx`, parce que la liste « Où ça sert » est un composant. Une seule fiche n'a pas de script, `gh`, qui demande un compte connecté : elle le dit dans un encadré, et sa liste « Où ça sert » compte les pages qui la citent (`<CommandUsages command="gh" prefix="" mode="cited" />`). Plan fixe :

```mdx
---
title: git log
description: Deux phrases : ce que la commande lit, compare ou change, et les formes couvertes.
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
---

import CommandUsages from '../../../components/CommandUsages.astro';

## À quoi ça sert
Trois phrases, l'idée, puis « Le manuel complet : `git help log`. »

## Les formes qui servent
Trois à six formes, chacune en gras (**`git log A..B`**), une phrase, sa vraie sortie.

## Pièges
Les formes qui trompent, les commandes voisines qu'on confond.

## Où ça sert
« À lire d'abord : » deux ou trois pages, puis la liste calculée :

<CommandUsages command="log" />
```

Pas de `level`. `risk` seulement si une forme peut faire perdre du travail (`reset --hard`, `push --force`), et la fiche dit alors comment revenir en arrière. Le titre est `git <commande>`, l'adresse `/commandes/<commande>/` ; la barre latérale est alphabétique, la page d'entrée groupe par usage. `<CommandUsages>` liste au build les pages dont une ligne de terminal commence par `$ git <commande>` : rien à tenir à jour.

## Les commits

Format conventionnel, en français, à l'impératif, sans point final. Le scope dit la section touchée.

```text
feat(situations): ajoute « Mon push est refusé »
fix(situations): corrige la sortie de git branch -vv (Git 2.51)
docs: précise l'installation sous Windows
feat(site): affiche les badges de niveau et de risque
chore(deps): met à jour Starlight
ci: valide les liens internes au build
```

Types : `feat` (nouvelle page ou fonctionnalité), `fix` (correction), `docs` (documents du dépôt : README, CONTRIBUTING…), `refactor`, `chore`, `ci`. Scopes : `situations`, `comprendre`, `equipe`, `commandes`, `site`, `scripts`, `deps`.

Pas de ligne `Co-Authored-By` générée automatiquement. Si plusieurs personnes ont écrit la page, elles sont citées dans la description de la PR.

## La relecture

Chaque PR est relue par le mainteneur (fichier `CODEOWNERS`). La relecture porte d'abord sur l'exactitude : le relecteur relance le script et compare. Puis sur la clarté : est-ce qu'une personne qui vit cette situation s'y reconnaît dès le symptôme, et comprend le pourquoi ? Les remarques de forme viennent en dernier.

## Traduire

La version anglaise vivra dans `src/content/docs/en/`, avec les mêmes slugs. Une page absente en anglais affiche automatiquement le français, avec un bandeau. On commencera à traduire quand la structure française sera stable ; d'ici là, les propositions sont bienvenues en issue.

## Licence

En proposant une contribution, tu acceptes qu'elle soit publiée sous les licences du projet : CC BY-SA 4.0 pour le contenu, MIT pour le code. Tu restes l'auteur de ce que tu écris.
