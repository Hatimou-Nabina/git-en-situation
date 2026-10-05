import { defineHastPlugin } from 'satteri';

/**
 * Préfixe les liens écrits depuis la racine (`/situations/...`) avec la base
 * du site (`/git-en-situation`), pour que le contenu n'ait jamais à connaître
 * l'adresse où il est publié. Les liens externes, les ancres et les liens déjà
 * préfixés ne sont pas touchés.
 *
 * Plugin pour Sätteri, le processeur Markdown d'Astro 7, à l'étape HAST
 * (le HTML sous forme d'arbre, juste avant le rendu).
 *
 * @param {{ base?: string }} options
 * @returns {import('satteri').HastPluginEntry}
 */
export function baseLinksPlugin({ base = '/' } = {}) {
  const prefix = base.replace(/\/+$/, '');
  if (prefix === '') return null;

  return defineHastPlugin({
    name: 'git-en-situation-base-links',
    element: {
      filter: ['a'],
      visit(node, ctx) {
        const href = node.properties?.href;
        if (typeof href !== 'string') return;
        const isRootRelative = href.startsWith('/') && !href.startsWith('//');
        const alreadyPrefixed = href === prefix || href.startsWith(`${prefix}/`);
        if (isRootRelative && !alreadyPrefixed) ctx.setProperty(node, 'href', `${prefix}${href}`);
      },
    },
  });
}
