// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import starlightLinksValidator from 'starlight-links-validator';
import { satteri } from '@astrojs/markdown-satteri';
import { baseLinksPlugin } from './src/plugins/base-links.mjs';
import { pluginConsolePrompts } from './src/plugins/expressive-code-prompts.mjs';

// Adresse du site. Sur GitHub Pages, le site vit sous /git-en-situation/.
// Avec un domaine à nous, il suffira de changer ces deux valeurs : les liens
// du contenu sont écrits depuis la racine (/situations/...) et préfixés au build.
const site = 'https://hatimou-nabina.github.io';
const base = '/git-en-situation';

const repository = 'https://github.com/Hatimou-Nabina/git-en-situation';

export default defineConfig({
  site,
  base,
  markdown: {
    processor: satteri({ hastPlugins: [baseLinksPlugin({ base })] }),
  },
  integrations: [
    starlight({
      title: 'Git en situation',
      description: 'Git et GitHub, à partir des situations que tu vis vraiment.',
      logo: { src: './src/assets/logo.svg', alt: '' },
      defaultLocale: 'root',
      locales: {
        root: { label: 'Français', lang: 'fr' },
        en: { label: 'English', lang: 'en' },
      },
      social: [{ icon: 'github', label: 'GitHub', href: repository }],
      editLink: { baseUrl: `${repository}/edit/main/` },
      lastUpdated: true,
      sidebar: [
        { label: 'Situations', translations: { en: 'Situations' }, items: [{ autogenerate: { directory: 'situations' } }] },
        { label: 'Comprendre', translations: { en: 'Understand' }, items: [{ autogenerate: { directory: 'comprendre' } }] },
        { label: 'Travailler en équipe', translations: { en: 'Working as a team' }, items: [{ autogenerate: { directory: 'equipe' } }] },
        { label: 'Commandes', translations: { en: 'Commands' }, items: [{ autogenerate: { directory: 'commandes' } }] },
        { label: 'À propos', translations: { en: 'About' }, slug: 'a-propos' },
      ],
      components: {
        PageTitle: './src/components/PageTitle.astro',
      },
      expressiveCode: {
        plugins: [pluginConsolePrompts()],
      },
      customCss: [
        // Polices auto-hébergées (Fontsource) : rien n'est chargé depuis un service tiers.
        '@fontsource/ibm-plex-sans/400.css',
        '@fontsource/ibm-plex-sans/400-italic.css',
        '@fontsource/ibm-plex-sans/500.css',
        '@fontsource/ibm-plex-sans/600.css',
        '@fontsource/ibm-plex-mono/400.css',
        '@fontsource/ibm-plex-mono/500.css',
        './src/styles/custom.css',
      ],
      plugins: [starlightLinksValidator()],
    }),
  ],
});
