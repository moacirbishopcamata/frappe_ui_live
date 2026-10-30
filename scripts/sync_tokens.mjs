// Gera priv/static/frappe_ui.css e priv/tokens.provenance.json a partir dos
// tokens do frappe-ui vendorizados em vendor/frappe-ui-tokens (fonte de verdade).
// Uso: `mix tokens.sync` (ou `node scripts/sync_tokens.mjs`).
import { createHash } from 'node:crypto'
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import { buildCss } from './lib/build_css.mjs'

const root = join(dirname(fileURLToPath(import.meta.url)), '..')
const tokens = await import('../vendor/frappe-ui-tokens/tokens.js')
const pkg = JSON.parse(
  readFileSync(join(root, 'vendor/frappe-ui-tokens/VERSION.json'), 'utf8'),
)

const css = buildCss(tokens)
if (!css.includes('--surface-base') || css.length < 10_000) {
  throw new Error('pós-condição violada: CSS gerado incompleto')
}

mkdirSync(join(root, 'priv/static'), { recursive: true })
writeFileSync(join(root, 'priv/static/frappe_ui.css'), css)
writeFileSync(
  join(root, 'priv/tokens.provenance.json'),
  JSON.stringify(
    {
      source: 'frappe-ui',
      version: pkg.version,
      license: pkg.license,
      cssSha256: createHash('sha256').update(css).digest('hex'),
    },
    null,
    2,
  ) + '\n',
)
console.log(`frappe_ui.css gerado a partir de frappe-ui@${pkg.version} (${css.length} bytes)`)
