# git-en-situation

« Git et GitHub, à partir des situations que tu vis vraiment. »

Personne ne cherche « fetch prune ». On cherche « je vois encore une branche qui a été supprimée ». Ce site part de là : chaque page répond à une situation, du symptôme au pourquoi, en moins de cinq minutes, avec des commandes **réellement exécutées** dont la sortie affichée est la vraie.

Site : https://hatimou-nabina.github.io/git-en-situation/

[![CI](https://github.com/Hatimou-Nabina/git-en-situation/actions/workflows/ci.yml/badge.svg)](https://github.com/Hatimou-Nabina/git-en-situation/actions/workflows/ci.yml)
[![Vérifier les sorties](https://github.com/Hatimou-Nabina/git-en-situation/actions/workflows/verifier-sorties.yml/badge.svg)](https://github.com/Hatimou-Nabina/git-en-situation/actions/workflows/verifier-sorties.yml)
[![Déploiement GitHub Pages](https://github.com/Hatimou-Nabina/git-en-situation/actions/workflows/deploy.yml/badge.svg)](https://github.com/Hatimou-Nabina/git-en-situation/actions/workflows/deploy.yml)

## Ce qu'on y trouve

| Section | Contenu |
|---|---|
| **Situations** | Le cœur du site. Symptôme, diagnostic, solution, pourquoi ça marche, pièges. Chaque page est adossée à un script qui rejoue le scénario. |
| **Comprendre** | Le modèle mental de Git en quelques pages courtes : commits, références, branches, remotes, HEAD, reflog. |
| **Travailler en équipe** | Branches, pull requests, revue, commits conventionnels, changelog, protections, secrets, plusieurs machines. |
| **Commandes** | Une fiche par commande, limitée aux options utiles, qui renvoie aux situations où elle sert. |

En français d'abord, pour les développeurs francophones de tous niveaux. Une version anglaise est en préparation.

## Les sorties sont vraies

Aucune sortie de commande n'est écrite à la main. Chaque page a un script dans [`scripts/`](scripts/) qui rejoue le scénario dans des dépôts jetables, avec une configuration Git neutre et des dates figées, et imprime chaque commande suivie de sa sortie. La page recopie ce résultat et indique la version de Git et la date. Un vérificateur rejoue les scripts et compare avec les pages, sur chaque pull request, avec la version de Git que chaque page déclare.

```bash
bash scripts/situations/push-refuse-fetch-first.sh              # rejoue une situation
EXERCICE=1 bash scripts/situations/push-refuse-fetch-first.sh   # fabrique la panne, à toi de réparer
npm run verifier                                                # rejoue tout et compare avec les pages
```

Les mêmes scripts servent d'exercices : avec `EXERCICE=1`, le script s'arrête juste après le symptôme, dans un dossier jetable, et dit quoi obtenir. Chaque situation du site se termine par cet encadré.

## Contribuer

Une situation vécue, une correction, une page : tout est bienvenu. Le [guide de contribution](CONTRIBUTING.md) explique comment, du gabarit de page aux conventions de commit. Le [code de conduite](CODE_OF_CONDUCT.md) dit ce qu'on attend les uns des autres.

- [Proposer une situation](https://github.com/Hatimou-Nabina/git-en-situation/issues/new?template=proposer-une-situation.yml)
- [Signaler une erreur](https://github.com/Hatimou-Nabina/git-en-situation/issues/new?template=signaler-une-erreur.yml)
- [Poser une question](https://github.com/Hatimou-Nabina/git-en-situation/discussions), dans les Discussions

Pour suivre le projet : une étoile, et « Watch », puis « Custom » et « Releases », pour être prévenu des nouvelles versions. Elles sont annoncées dans les [releases](https://github.com/Hatimou-Nabina/git-en-situation/releases) et consignées dans le [changelog](CHANGELOG.md).

## Lancer le site en local

Node.js 22 et Git. Sous Windows, les scripts s'exécutent dans Git Bash.

```bash
npm ci
npm run dev        # http://localhost:4321/git-en-situation/
npm run build      # construit le site et valide les liens internes
```

Le site est construit avec [Astro](https://astro.build) et [Starlight](https://starlight.astro.build), et publié sur GitHub Pages par GitHub Actions à chaque changement de `main`.

## Licences

- Contenu (pages de `src/content/`) : [CC BY-SA 4.0](LICENSE-CONTENT.md). Réutilise, traduis, adapte, y compris en formation payante, en citant la source et en partageant sous la même licence.
- Code du site : [MIT](LICENSE).

Le suivi des changements est dans [CHANGELOG.md](CHANGELOG.md).
