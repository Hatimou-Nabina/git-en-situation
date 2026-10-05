import { definePlugin } from '@expressive-code/core';

/**
 * Dans les sessions de terminal (blocs ```console ou ```shellsession), ajoute
 * la classe `is-prompt` aux lignes qui commencent par « $ » : ce sont les
 * commandes tapées, le reste est leur sortie. Le style est dans
 * src/styles/custom.css. Sans ce plugin, le thème colore tout pareil.
 */
export function pluginConsolePrompts() {
  return definePlugin({
    name: 'Console prompts',
    hooks: {
      postprocessRenderedLine: ({ codeBlock, line, renderData }) => {
        if (!['console', 'shellsession'].includes(codeBlock.language)) return;
        if (!line.text.startsWith('$ ')) return;
        const properties = renderData.lineAst.properties ?? (renderData.lineAst.properties = {});
        const className = Array.isArray(properties.className)
          ? properties.className
          : properties.className
            ? [String(properties.className)]
            : [];
        properties.className = [...className, 'is-prompt'];
      },
    },
  });
}
