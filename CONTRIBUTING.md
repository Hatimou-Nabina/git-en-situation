# Contribuer à git-en-situation

Merci de t'y intéresser. Ce projet vit des situations que les gens rencontrent vraiment : la tienne a sa place ici.

## Trois façons de contribuer

1. **Proposer une situation** que tu as vécue, même sans en connaître la solution : [ouvre une issue](https://github.com/Hatimou-Nabina/git-en-situation/issues/new?template=proposer-une-situation.yml). Ce que tu as vu et ce que tu essayais de faire suffisent.
2. **Signaler une erreur** : une commande fausse, une sortie qui ne correspond pas à la tienne, une explication trompeuse, une faute : [ouvre une issue](https://github.com/Hatimou-Nabina/git-en-situation/issues/new?template=signaler-une-erreur.yml).
3. **Écrire ou corriger une page**, par une pull request. La suite de ce document explique comment.

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

Crée `src/content/docs/situations/<slug>.md`. Le `<slug>` est celui du script : des mots en minuscules séparés par des tirets, sans accents, qui disent la situation (`push-refuse-fetch-first`, pas `probleme-push`).

```markdown
---
title: Ce que la personne taperait dans un moteur de recherche
description: Une ou deux phrases : le symptôme, puis ce que la page apporte. C'est ce que Google affiche.
level: debutant | intermediaire | avance
risk: aucun | reversible | destructif
gitVersion: "2.50"
verified: 2026-10-05
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

### 4. Le style

- **Tutoiement**, phrases courtes, un seul sujet par page. Si la page dépasse cinq minutes de lecture, c'est deux pages.
- **Le titre est une recherche**, pas un intitulé de cours : « Mon push est refusé », pas « Gestion des divergences ».
- **Les sessions de terminal** sont des blocs ` ```console ` avec le prompt `$ ` : les commandes sont mises en valeur, les sorties restent telles quelles. Pas de capture d'écran de terminal.
- **Ce qui est propre à GitHub** est dit comme tel (« Sur GitHub, … »). Le reste vaut pour tout serveur Git.
- **Les liens internes** s'écrivent depuis la racine, avec le slash final : `/situations/mon-slug/`. Le site ajoute lui-même son préfixe d'hébergement.
- **Les termes** : on dit « référence distante » pour `origin/x`, « branche locale », « serveur » plutôt que « remote » quand on parle de GitHub, « fusion » pour merge, « rebase » reste « rebase ».

### 5. Vérifier, puis proposer

```bash
npm run build     # doit passer : liens valides, en-têtes conformes au schéma
```

Ouvre la pull request depuis une branche nommée `situation/<slug>` (ou `fix/<sujet>`, `site/<sujet>`). Le gabarit de PR liste ce qu'on vérifie. Une PR = une page, ou une correction cohérente.

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
