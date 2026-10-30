// Funções puras: dados do lucide-static -> catálogo de ícones (priv/icons.json).
// Entrada: nodes { nome: [[tag, attrs], ...] }, tags { nome: [tag, ...] }, svgs { nome: "<svg ...>" }.

// Forma canônica de um nó, para comparar desenhos independente da formatação.
const canon = ([tag, attrs]) =>
  tag + '|' + Object.keys(attrs).sort().map((k) => `${k}=${attrs[k]}`).join(';')

const canonAll = (nodes) => nodes.map(canon).join('\n')

// Extrai os nós de um arquivo SVG do Lucide (`<path d="..." />` dentro do <svg>).
export function parseSvgNodes(svg) {
  const inner = svg.replace(/<!--[\s\S]*?-->/g, '').replace(/^[\s\S]*?<svg[^>]*>/, '').replace(/<\/svg>\s*$/, '')
  const nodes = []
  for (const [, tag, rest] of inner.matchAll(/<([a-zA-Z]+)([^>]*?)\/?>/g)) {
    const attrs = {}
    for (const [, k, v] of rest.matchAll(/([\w:-]+)="([^"]*)"/g)) attrs[k] = v
    nodes.push([tag, attrs])
  }
  return nodes
}

const sortObject = (o) => Object.fromEntries(Object.keys(o).sort().map((k) => [k, o[k]]))

export function buildIconsJson({ version, nodes, tags, svgs }) {
  // Pós-condição de entrada: todo ícone com tags tem nós.
  for (const name of Object.keys(tags)) {
    if (!nodes[name]) throw new Error(`tags.json cita ícone sem nós: ${name}`)
  }

  const byShape = new Map()
  for (const name of Object.keys(nodes)) byShape.set(canonAll(nodes[name]), name)

  // Arquivos SVG que não estão em icon-nodes.json são nomes antigos (aliases).
  const aliases = {}
  const orphans = []
  for (const name of Object.keys(svgs)) {
    if (nodes[name]) continue
    const target = byShape.get(canonAll(parseSvgNodes(svgs[name])))
    if (target) (aliases[target] ||= []).push(name)
    else orphans.push(name)
  }
  if (orphans.length) {
    throw new Error(`SVG antigo sem ícone equivalente (decida o alias à mão): ${orphans.sort().join(', ')}`)
  }

  const icons = {}
  for (const name of Object.keys(nodes).sort()) {
    icons[name] = {
      nodes: nodes[name],
      tags: tags[name] || [],
      aliases: (aliases[name] || []).sort(),
    }
  }
  return { version, icons: sortObject(icons) }
}
