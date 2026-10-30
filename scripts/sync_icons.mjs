// Gera priv/static/frappe_ui_icons.css a partir de scripts/icons.txt + lucide-static.
// Uso: `mix icons.sync` (requer `npm install` para ter o lucide-static).
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import { buildIconsCss } from './lib/build_icons_css.mjs'

const root = join(dirname(fileURLToPath(import.meta.url)), '..')
const names = readFileSync(join(root, 'scripts/icons.txt'), 'utf8')
  .split('\n')
  .map((line) => line.trim())
  .filter((line) => line && !line.startsWith('#'))

const icons = {}
for (const entry of names) {
  // `nome:filled` gera `.lucide-nome-filled` com preenchimento (ex.: estrela cheia).
  const [name, variant] = entry.split(':')
  const file = join(root, 'node_modules/lucide-static/icons', `${name}.svg`)
  // Pré-condição: o nome existe no Lucide; erro de digitação falha alto.
  if (!existsSync(file)) throw new Error(`ícone Lucide inexistente: ${name}`)
  const svg = readFileSync(file, 'utf8')
  icons[variant === 'filled' ? `${name}-filled` : name] = variant === 'filled' ? svg.replace('fill="none"', 'fill="currentColor"') : svg
}

const css = buildIconsCss(icons)
if (Object.keys(icons).length !== names.length) throw new Error('pós-condição violada: ícones perdidos')

mkdirSync(join(root, 'priv/static'), { recursive: true })
writeFileSync(join(root, 'priv/static/frappe_ui_icons.css'), css)
console.log(`frappe_ui_icons.css: ${names.length} ícones (${css.length} bytes)`)
