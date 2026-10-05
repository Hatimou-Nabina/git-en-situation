import { defineCollection } from 'astro:content';
import { z } from 'astro/zod';
import { docsLoader } from '@astrojs/starlight/loaders';
import { docsSchema } from '@astrojs/starlight/schema';

export const collections = {
  docs: defineCollection({
    loader: docsLoader(),
    schema: docsSchema({
      extend: z.object({
        /** Qui peut suivre la page sans préparation. */
        level: z.enum(['debutant', 'intermediaire', 'avance']).optional(),
        /** Ce que risquent les commandes de la page : rien, un retour en arrière possible, ou une perte de travail. */
        risk: z.enum(['aucun', 'reversible', 'destructif']).optional(),
        /** Version de Git avec laquelle les sorties affichées ont été obtenues. */
        gitVersion: z.string().optional(),
        /** Date de la dernière exécution réelle des commandes de la page (script dans scripts/situations/). */
        verified: z.coerce.date().optional(),
        /** Date de publication de la page : l'accueil montre les plus récentes. */
        published: z.coerce.date().optional(),
      }),
    }),
  }),
};
