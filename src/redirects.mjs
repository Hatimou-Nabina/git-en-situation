/**
 * Anciennes adresses des situations, d'avant le classement par thème
 * (5 octobre 2026). Chaque ancienne adresse redirige vers la nouvelle.
 * À compléter si une page change de thème : une adresse publiée ne doit
 * jamais répondre « introuvable ».
 */
const moved = {
  quotidien: [
    'branche-distante-supprimee-encore-visible',
    'push-refuse-fetch-first',
    'supprimer-une-vieille-branche-sans-rien-perdre',
    'premier-push-no-upstream',
    'branches-invisibles-apres-clone',
    'git-pull-merge-ou-rebase',
    'mettre-son-travail-de-cote',
    'voir-ce-qui-a-change',
    'renommer-une-branche',
  ],
  reparer: [
    'commit-sur-la-mauvaise-branche',
    'annuler-mon-dernier-commit',
    'annuler-un-commit-deja-pousse',
    'detached-head',
    'retrouver-un-commit-perdu',
    'resoudre-un-conflit',
  ],
};

export const redirects = Object.fromEntries(
  Object.entries(moved).flatMap(([theme, slugs]) =>
    slugs.map((slug) => [`/situations/${slug}`, `/situations/${theme}/${slug}/`]),
  ),
);
