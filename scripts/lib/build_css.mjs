// Função pura: tokens -> texto CSS (Tailwind v4, CSS-first). Testável sem I/O.
const SEMANTIC = ['surface', 'surface-alpha', 'ink', 'outline', 'outline-alpha']
const isSemanticVar = (name) => SEMANTIC.some((c) => name.startsWith(`--${c}-`))

const block = (selector, vars) =>
  `${selector} {\n${Object.entries(vars)
    .map(([k, v]) => `  ${k}: ${v};`)
    .join('\n')}\n}\n`

const pick = (vars, pred) =>
  Object.fromEntries(Object.entries(vars).filter(([k]) => pred(k)))

export function buildCss({ cssVariables, semanticColors, radius, shadows, fontSize, focusRing, fontWeight, tracking }) {
  const out = ['/* Gerado por scripts/sync_tokens.mjs — não edite à mão. */\n']

  const light = pick(cssVariables.light, (k) => isSemanticVar(k) || k.startsWith('--focus-outline-'))
  const dark = pick(cssVariables.dark, (k) => isSemanticVar(k) || k.startsWith('--focus-outline-'))
  out.push(block(':root', light))
  out.push(block('[data-theme="dark"]', dark))

  const theme = []
  for (const [category, entries] of Object.entries(semanticColors.light)) {
    for (const name of Object.keys(entries)) {
      theme.push(`  --color-${category}-${name}: var(--${category}-${name});`)
    }
  }
  out.push(`@theme inline {\n${theme.join('\n')}\n}\n`)

  const staticTheme = []
  for (const [key, value] of Object.entries(radius)) staticTheme.push(`  --radius-${key}: ${value};`)
  for (const [key, value] of Object.entries(shadows)) {
    if (key === 'none' || key === 'DEFAULT') continue
    staticTheme.push(`  --shadow-elevation-${key}: ${value};`)
  }
  out.push(`@theme {\n${staticTheme.join('\n')}\n}\n`)

  // Escala tipográfica com prefixo fui-: não colide com text-sm/text-base do host.
  for (const [key, { fontSize: size, lineHeight, letterSpacing, fontWeight }] of Object.entries(fontSize)) {
    const lines = [`  font-size: ${size};`]
    if (lineHeight) lines.push(`  line-height: ${lineHeight};`)
    if (letterSpacing) lines.push(`  letter-spacing: ${letterSpacing};`)
    if (fontWeight) lines.push(`  font-weight: ${fontWeight};`)
    out.push(`@utility fui-text-${key} {\n${lines.join('\n')}\n}\n`)
  }

  for (const name of Object.keys(focusRing.light)) {
    const cls = name === 'default' ? 'focus-ring' : `focus-ring-${name}`
    out.push(`@utility ${cls} {\n  outline: var(--focus-outline-${name});\n  outline-offset: 0;\n}\n`)
  }
  return out.join('\n')
}

const fontWeight_ = (name, table) => String(table?.[name] ?? { medium: 500, semibold: 600, bold: 700 }[name])
