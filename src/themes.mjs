/**
 * Les thèmes des situations : un dossier par thème dans
 * src/content/docs/situations/, et une entrée ici. La barre latérale
 * (astro.config.mjs), le catalogue et les pages de thème lisent cette liste,
 * dans les deux langues (labelEn, descriptionEn pour la version anglaise).
 * L'ordre ci-dessous est l'ordre d'affichage.
 */
export const themes = {
  quotidien: {
    label: 'Au quotidien',
    labelEn: 'Everyday',
    description: "Ce qu'on rencontre dès la première semaine : branches, push, pull, travail en cours.",
    descriptionEn: 'What you run into in the first week: branches, push, pull, work in progress.',
  },
  reparer: {
    label: 'Réparer',
    labelEn: 'Repair',
    description: "Quand on croit avoir cassé quelque chose : mauvais commit, mauvaise branche, conflit, commit perdu.",
    descriptionEn: 'When you think you broke something: wrong commit, wrong branch, conflict, lost commit.',
  },
  'avec-les-autres': {
    label: 'Avec les autres',
    labelEn: 'With others',
    description: "Quand le travail des autres rencontre le tien : branche à mettre à jour, fusion faite sur GitHub, deux comptes, deux machines.",
    descriptionEn: "When other people's work meets yours: a branch to update, a merge done on GitHub, two accounts, two machines.",
  },
  fichiers: {
    label: 'Fichiers et dépôt',
    labelEn: 'Files and repository',
    description: "Ce qui touche aux fichiers eux-mêmes : .gitignore, secrets, fins de ligne, fichiers vus comme modifiés sans raison.",
    descriptionEn: 'What concerns the files themselves: .gitignore, secrets, line endings, files shown as modified for no reason.',
  },
};
