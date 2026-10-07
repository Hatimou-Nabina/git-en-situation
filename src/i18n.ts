/**
 * Ce que les composants ont besoin de savoir sur la langue de la page rendue.
 *
 * Les pages françaises font référence : identifiants, niveau, risque, version de
 * Git, dates. La version anglaise vit sous en/ avec les mêmes chemins ; une page
 * absente en anglais est servie en français par Starlight, avec un bandeau. Les
 * composants partent donc toujours des pages françaises, prennent le titre et la
 * description de la traduction quand elle existe, et pointent vers /en/… dans la
 * version anglaise.
 */
import type { AstroGlobal } from 'astro';
import type { CollectionEntry } from 'astro:content';
import { themes } from './themes.mjs';

export type Locale = 'fr' | 'en';
export type Doc = CollectionEntry<'docs'>;
type Level = NonNullable<Doc['data']['level']>;
type ThemeKey = keyof typeof themes;

/** La locale de la page rendue : « en » sous /en/, « fr » sinon (locale racine). */
export function currentLocale(Astro: Pick<AstroGlobal, 'locals' | 'url'>): Locale {
  const route = (Astro.locals as { starlightRoute?: { locale?: string } }).starlightRoute;
  if (route) return route.locale === 'en' ? 'en' : 'fr';
  return /\/en(\/|$)/.test(Astro.url.pathname) ? 'en' : 'fr';
}

/** Une page française et, dans la version anglaise, sa traduction si elle existe. */
export interface Localized {
  /** La page française, référence pour l'identifiant, le niveau, la version de Git et les dates. */
  fr: Doc;
  /** La page dont on affiche le titre et la description : la traduction, ou la française à défaut. */
  shown: Doc;
  /** Faux quand la version anglaise montre une page encore en français. */
  translated: boolean;
}

export function withTranslation(french: Doc[], all: Doc[], locale: Locale): Localized[] {
  const byId = new Map(all.map((entry) => [entry.id, entry]));
  return french.map((fr) => {
    const en = locale === 'en' ? byId.get(`en/${fr.id}`) : undefined;
    return { fr, shown: en ?? fr, translated: locale === 'fr' || en !== undefined };
  });
}

/** L'adresse d'une page dans la langue courante, à partir de son identifiant français. */
export const pageHref = (base: string, id: string, locale: Locale) => `${base}/${locale === 'en' ? 'en/' : ''}${id}/`;

export const byShownTitle = (locale: Locale) => (a: Localized, b: Localized) =>
  a.shown.data.title.localeCompare(b.shown.data.title, locale);

export const levelLabels: Record<Locale, Record<Level, string>> = {
  fr: { debutant: 'débutant', intermediaire: 'intermédiaire', avance: 'avancé' },
  en: { debutant: 'beginner', intermediaire: 'intermediate', avance: 'advanced' },
};

export const capitalize = (text: string) => text.charAt(0).toUpperCase() + text.slice(1);

export function themeLabel(key: string, locale: Locale): string | undefined {
  const theme = themes[key as ThemeKey];
  return theme && (locale === 'en' ? theme.labelEn : theme.label);
}

export function themeDescription(key: string, locale: Locale): string | undefined {
  const theme = themes[key as ThemeKey];
  return theme && (locale === 'en' ? theme.descriptionEn : theme.description);
}

/** Le niveau, la version de Git et, le cas échéant, « in French », en une ligne. */
export function metaLine({ fr, translated }: Localized, locale: Locale): string {
  return [
    fr.data.level && levelLabels[locale][fr.data.level],
    fr.data.gitVersion && `Git ${fr.data.gitVersion}`,
    !translated && strings[locale].inFrench,
  ]
    .filter(Boolean)
    .join(' · ');
}

export const strings = {
  fr: {
    inFrench: 'en français',
    sections: { situations: 'Situations', comprendre: 'Comprendre', equipe: 'Travailler en équipe' },
    catalogueSummary: (n: number, m: number) =>
      `${n} situations, ${m} thèmes. Un symptôme précis en tête ? La recherche (Ctrl + K) va plus vite.`,
    filterByLevel: 'Filtrer par niveau',
    allLevels: 'Tous les niveaux',
    emptyTheme: 'Aucune situation de ce niveau dans ce thème.',
  },
  en: {
    inFrench: 'in French',
    sections: { situations: 'Situations', comprendre: 'Understand', equipe: 'Working as a team' },
    catalogueSummary: (n: number, m: number) =>
      `${n} situations, ${m} themes. A precise symptom in mind? Search (Ctrl + K) is faster.`,
    filterByLevel: 'Filter by level',
    allLevels: 'All levels',
    emptyTheme: 'No situation at this level in this theme.',
  },
} as const;
