/**
 * Les thèmes des situations : un dossier par thème dans
 * src/content/docs/situations/, et une entrée ici. La barre latérale
 * (astro.config.mjs), le catalogue et les pages de thème lisent cette liste.
 * L'ordre ci-dessous est l'ordre d'affichage.
 */
export const themes = {
  quotidien: {
    label: 'Au quotidien',
    labelEn: 'Everyday',
    description: "Ce qu'on rencontre dès la première semaine : branches, push, pull, travail en cours.",
  },
  reparer: {
    label: 'Réparer',
    labelEn: 'Repair',
    description: "Quand on croit avoir cassé quelque chose : mauvais commit, mauvaise branche, conflit, commit perdu.",
  },
  'avec-les-autres': {
    label: 'Avec les autres',
    labelEn: 'With others',
    description: "Quand le travail des autres rencontre le tien : branche à mettre à jour, fusion faite sur GitHub, deux comptes, deux machines.",
  },
};
