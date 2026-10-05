---
title: Comment lire une situation
description: Chaque page de cette section suit le même gabarit, du symptôme au pourquoi. Voici comment s'en servir, et ce que garantissent les sorties affichées.
sidebar:
  order: 0
  label: Comment lire une situation
---

Chaque page répond à **une** situation, celle qu'on tape dans un moteur de recherche à 18 h : « mon push est refusé », « je vois encore une branche supprimée ». Toutes suivent le même plan.

| Partie | Ce qu'on y trouve |
|---|---|
| **Symptôme** | Ce que tu vois à l'écran, message exact compris. Pour vérifier que tu es sur la bonne page. |
| **Diagnostic** | Ce qui s'est passé, en deux ou trois phrases. |
| **Solution** | Les commandes, dans l'ordre, avec leur vraie sortie. |
| **Pourquoi ça marche** | Le morceau de modèle mental qui fait qu'on retient, au lieu de recopier. |
| **Pièges** | Les variantes qui trompent, et ce qu'il ne faut pas faire. |
| **Voir aussi** | Les situations voisines. |

## Les badges en haut de page

- **Niveau** : *débutant* se suit sans préparation ; *intermédiaire* suppose d'être à l'aise avec les branches ; *avancé* touche à l'historique ou à la configuration.
- **Risque** : *aucun* quand rien ne peut être perdu ; *réversible* quand un retour en arrière existe et est expliqué ; *destructif* quand une commande de la page peut faire perdre du travail. Dans ce cas, la page dit où et comment.
- **Git x.y, vérifié le …** : la version de Git et la date auxquelles les commandes de la page ont été réellement exécutées.

## Les sorties affichées sont vraies

Aucune sortie n'est écrite à la main. Chaque situation a un script dans le dossier `scripts/situations/` du dépôt, qui rejoue le scénario dans des dépôts jetables, avec une configuration Git neutre, et imprime chaque commande suivie de sa sortie. La page recopie ce résultat.

Deux simplifications, et seulement celles-là : l'adresse du serveur est remplacée par `github.com:equipe/projet.git`, et les identifiants de commit sont ceux du dépôt d'exemple. Chez toi, ces deux détails changent ; tout le reste doit être identique, à version de Git égale. Si ce n'est pas le cas, [signale-le](https://github.com/Hatimou-Nabina/git-en-situation/issues/new?template=signaler-une-erreur.yml) : c'est précieux.

## Il manque ta situation ?

[Propose-la](https://github.com/Hatimou-Nabina/git-en-situation/issues/new?template=proposer-une-situation.yml), même sans connaître la réponse. Ce que tu as vu et ce que tu essayais de faire suffisent pour commencer.
