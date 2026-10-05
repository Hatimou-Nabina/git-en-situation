---
title: CODEOWNERS, gabarits d'issue et de PR
description: Les automatismes GitHub qui font gagner du temps à tout le monde. Qui relit quoi, ce qu'une pull request doit dire, ce qu'une issue doit contenir. Trois fichiers versionnés dans .github/, et les pièges silencieux de chacun.
level: debutant
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
sidebar:
  order: 10
---

## Ce que ça évite

Une PR qui attend parce que personne ne sait qui doit la relire. Une PR sans description, « fix », qu'il faut ouvrir pour comprendre. Une issue « ça marche pas » sans version ni message d'erreur, qui démarre par trois allers-retours. Et le mainteneur qui réexplique à chaque fois ce qu'il attend.

Trois fichiers dans `.github/` règlent ça une fois pour toutes : `CODEOWNERS` dit qui relit quoi, `PULL_REQUEST_TEMPLATE.md` préremplit la description d'une PR, et `ISSUE_TEMPLATE/` transforme la page blanche d'une issue en formulaire. GitHub les lit ; Git les versionne comme le reste.

## Comment on fait

**1. Qui connaît quoi : l'historique le dit.** Avant d'écrire le `CODEOWNERS`, regarder qui a réellement travaillé sur chaque partie :

```console
$ git shortlog -sn HEAD -- src/paiement/
     3	Bakary
     1	Awa

$ git shortlog -sn HEAD -- src/recherche/
     2	Awa
```

**2. `CODEOWNERS` : un chemin, des responsables.** La syntaxe est celle de `.gitignore`, et la dernière règle qui correspond l'emporte. Les propriétaires sont demandés en relecture automatiquement quand une PR touche leurs fichiers.

```console
$ cat .github/CODEOWNERS
# Qui relit quoi. Même syntaxe que .gitignore ; la dernière règle qui correspond gagne.

# Par défaut, Awa relit tout.
*                   @awa

# Le paiement est relu par Bakary.
/src/paiement/      @bakary

# Ce qui pilote GitHub est relu par les deux.
/.github/           @awa @bakary
```

**3. Le gabarit de pull request : les questions posées avant qu'on les oublie.** Il préremplit la description de chaque PR. Celui de ce site demande quoi, pourquoi, et ce qui a été vérifié ; celui-ci fait pareil.

```console
$ cat .github/PULL_REQUEST_TEMPLATE.md
## Quoi

<!-- Une phrase : ce que cette PR change. -->

## Pourquoi

<!-- Le problème vécu, ou l'issue liée : « Closes #12 ». -->

## Vérifications

- [ ] Les tests passent en local.
- [ ] La ligne du changelog est là.
- [ ] Ce qui change pour l'utilisateur est dit dans la description.
```

**4. Les gabarits d'issue : un formulaire plutôt qu'une page blanche.** Un fichier YAML par type d'issue, avec des champs obligatoires ; et un `config.yml` qui règle le reste : interdire l'issue vide, renvoyer les questions ailleurs.

```console
$ cat .github/ISSUE_TEMPLATE/signaler-un-bug.yml
name: Signaler un bug
description: Quelque chose ne fait pas ce qu'il devrait.
title: "[Bug] "
labels: ["bug", "à trier"]
body:
  - type: textarea
    id: observe
    attributes:
      label: Ce que tu observes
      description: Le message exact, dans un bloc de code si possible.
    validations:
      required: true
  - type: textarea
    id: attendu
    attributes:
      label: Ce que tu attendais
    validations:
      required: true
  - type: input
    id: version
    attributes:
      label: Version
      placeholder: v1.2.0

$ cat .github/ISSUE_TEMPLATE/config.yml
blank_issues_enabled: false
contact_links:
  - name: Poser une question
    url: https://github.com/mon-equipe/projet/discussions
    about: Une question, une idée pas encore mûre : les Discussions sont faites pour ça.
```

**5. Tout ça est versionné**, et passe par une pull request comme le reste. Modifier un gabarit, c'est une PR, relue par les propriétaires de `.github/`.

```console
$ git ls-files .github
.github/CODEOWNERS
.github/ISSUE_TEMPLATE/config.yml
.github/ISSUE_TEMPLATE/signaler-un-bug.yml
.github/PULL_REQUEST_TEMPLATE.md

$ git log --oneline -- .github/
4a55a49 chore(github): CODEOWNERS, gabarits d issue et de PR
```

## Sur GitHub

- **Où GitHub cherche** : `CODEOWNERS` à la racine, dans `.github/` ou dans `docs/` ; le gabarit de PR aux mêmes endroits, ou plusieurs dans `.github/PULL_REQUEST_TEMPLATE/`, choisis par `?template=nom.md` dans l'adresse ; les gabarits d'issue dans `.github/ISSUE_TEMPLATE/`. Tout ça sur la branche par défaut : une PR qui les modifie n'a d'effet qu'une fois fusionnée.
- **Les propriétaires doivent avoir le droit d'écrire** sur le dépôt, individuellement ou via une équipe `@organisation/equipe`. Sinon la ligne est ignorée en silence. GitHub signale les erreurs de syntaxe dans la vue du fichier, pas les propriétaires inconnus.
- **« Require review from Code Owners »**, dans la protection de branche, rend leur approbation obligatoire. Sans la case, ils sont seulement demandés.
- **Les formulaires d'issue** (`.yml`) remplacent les gabarits Markdown (`.md`) : champs typés, obligatoires, listes déroulantes. `blank_issues_enabled: false` oblige à choisir un gabarit ; `contact_links` ajoute des boutons vers les Discussions ou un autre dépôt.
- **Les étiquettes du gabarit doivent exister** dans le dépôt, sinon elles sont ignorées sans un mot. Ce site a déclaré trois étiquettes dans ses gabarits avant de les créer. `gh label create` les crée en une ligne.
- **Insights → Community Standards** liste ce qui manque au dépôt : README, CONTRIBUTING, code de conduite, licence, gabarits, `SECURITY.md`.

## Pièges

- **Un seul propriétaire sur tout**, `* @moi`, avec l'approbation obligatoire : en vacances, tout s'arrête. Deux noms par règle, ou pas d'obligation.
- **Le chemin qui ne correspond à rien.** `src/paiment/` au lieu de `src/paiement/` : la règle ne s'applique jamais, personne n'est demandé, rien ne le signale. Vérifier sur une PR réelle qui touche le dossier.
- **Le gabarit trop long**, que les contributeurs effacent d'un bloc. Trois questions suffisent ; celui de ce site tient en quinze lignes.
- **Les cases qu'on coche sans lire.** Une case utile se vérifie : « `npm run build` passe » est vérifiable, « j'ai bien testé » ne l'est pas.
- **Un formulaire qui exige trop**, et l'issue n'est jamais ouverte. Un champ obligatoire par information vraiment indispensable, le reste facultatif.
- **Oublier `config.yml`** : la page « New issue » propose toujours l'issue vide, et les gabarits sont contournés.

## Voir aussi

- [Relire une pull request](/equipe/relire-une-pull-request/)
- [La pull request, de l'ouverture à la fusion](/equipe/la-pull-request/)
- [Protéger la branche principale](/equipe/proteger-la-branche-principale/)
- Ceux de ce site : [`.github/`](https://github.com/Hatimou-Nabina/git-en-situation/tree/main/.github)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/equipe/codeowners-gabarits-issue-pr.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/equipe/codeowners-gabarits-issue-pr.sh), exécuté avec Git 2.50 le 5 octobre 2026. Les automatismes de GitHub ne se rejouent pas dans un bac à sable : les fichiers qui les pilotent sont montrés, leurs effets décrits. Seuls l'adresse du serveur et les identifiants de commit sont ceux du dépôt d'exemple.
:::
