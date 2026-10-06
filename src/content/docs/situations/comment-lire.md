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

Aucune sortie n'est écrite à la main. Chaque situation a un script dans le dossier `scripts/situations/` du dépôt, qui rejoue le scénario dans des dépôts jetables, avec une configuration Git neutre, et imprime chaque commande suivie de sa sortie. La page recopie ce résultat, et un vérificateur rejoue tous les scripts à chaque changement du site pour s'assurer que les pages y correspondent toujours, avec la version de Git que chacune déclare.

Trois simplifications, et seulement celles-là : l'adresse du serveur est remplacée par `github.com:equipe/projet.git` ; les identifiants de commit sont ceux du dépôt d'exemple ; et pour une commande qui écrit à la fois des messages et des résultats, les messages (`Switched to branch…`, `hint:`…) sont affichés avant les résultats, dans un ordre fixe, alors que ton terminal peut les entremêler autrement. Chez toi, ces détails changent ; tout le reste doit être identique, à version de Git égale. Si ce n'est pas le cas, [signale-le](https://github.com/Hatimou-Nabina/git-en-situation/issues/new?template=signaler-une-erreur.yml) : c'est précieux.

## Essaie-le toi-même

Lire une solution et la faire ne sont pas la même chose. Chaque situation se termine par un encadré « Essaie-le toi-même » : le script de la page sait fabriquer la panne sur ton poste, dans un dossier jetable, et s'arrêter juste après le symptôme. Il te dit dans quel dossier aller et quoi obtenir, sans donner la commande. Tu répares, puis tu relances le script sans la variable pour comparer avec la solution. Il faut un clone du [dépôt du site](https://github.com/Hatimou-Nabina/git-en-situation) et, sous Windows, Git Bash :

```bash
EXERCICE=1 bash scripts/situations/premier-push-no-upstream.sh
```

Rien n'est envoyé nulle part : le « serveur » est un dossier à côté, et tout se supprime en effaçant `exercices/`.

## Il manque ta situation ?

[Propose-la](https://github.com/Hatimou-Nabina/git-en-situation/issues/new?template=proposer-une-situation.yml), même sans connaître la réponse. Ce que tu as vu et ce que tu essayais de faire suffisent pour commencer.
