// Gera priv/icons.json (todos os ícones Lucide, com tags e aliases) a partir do lucide-static.
// Uso: `mix icons.sync` (requer `npm install` para ter o lucide-static).
import { mkdirSync, readdirSync, readFileSync, writeFileSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import { buildIconsJson } from './lib/build_icons_json.mjs'

const root = join(dirname(fileURLToPath(import.meta.url)), '..')
const pkg = join(root, 'node_modules/lucide-static')
const read = (file) => JSON.parse(readFileSync(join(pkg, file), 'utf8'))

const svgDir = join(pkg, 'icons')
const svgs = Object.fromEntries(
  readdirSync(svgDir)
    .filter((file) => file.endsWith('.svg'))
    .map((file) => [file.slice(0, -4), readFileSync(join(svgDir, file), 'utf8')]),
)

const catalog = buildIconsJson({
  version: read('package.json').version,
  nodes: read('icon-nodes.json'),
  tags: read('tags.json'),
  svgs,
})

// Pós-condição: nenhum ícone perdido entre a entrada e a saída.
const total = Object.keys(catalog.icons).length
const aliases = Object.values(catalog.icons).reduce((n, i) => n + i.aliases.length, 0)
if (total + aliases !== Object.keys(svgs).length) throw new Error('pós-condição violada: ícones perdidos')

mkdirSync(join(root, 'priv'), { recursive: true })
const json = JSON.stringify(catalog)
writeFileSync(join(root, 'priv/icons.json'), json + '\n')
console.log(`icons.json: ${total} ícones, ${aliases} aliases, v${catalog.version} (${json.length} bytes)`)
