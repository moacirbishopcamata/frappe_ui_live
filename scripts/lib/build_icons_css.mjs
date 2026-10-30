// Função pura: { nome -> svg } -> CSS de máscara (um `.lucide-<nome>` por ícone).
const license = '/* Ícones: Lucide (ISC) — https://lucide.dev/license. Gerado por scripts/sync_icons.mjs. */\n'

const strip = (svg) =>
  svg
    .replace(/<!--[\s\S]*?-->/g, '')
    .replace(/\s+/g, ' ')
    .replace(/> </g, '><')
    .replace(/class="[^"]*"\s?/, '')
    .trim()

export function buildIconsCss(icons) {
  const rules = Object.entries(icons)
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([name, svg]) => {
      const uri = encodeURIComponent(strip(svg)).replace(/'/g, '%27').replace(/"/g, '%22')
      const mask = `url("data:image/svg+xml,${uri}") no-repeat center / 100% 100%`
      return `.lucide-${name} {\n  display: inline-block;\n  width: 1em;\n  height: 1em;\n  background-color: currentColor;\n  -webkit-mask: ${mask};\n  mask: ${mask};\n}`
    })
  return license + rules.join('\n') + '\n'
}
