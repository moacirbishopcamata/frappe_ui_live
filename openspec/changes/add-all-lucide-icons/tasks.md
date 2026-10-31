## 1. Dados dos ícones

- [x] 1.1 Reescrever `scripts/sync_icons.mjs` para gerar `priv/icons.json` (nós de `icon-nodes.json`, tags de `tags.json`, versão do `lucide-static`), com chaves ordenadas (saída determinística)
- [x] 1.2 Calcular aliases: SVG antigo de `icons/` com nós idênticos a um ícone atual vira alias; falhar listando os que não tiverem equivalente (esperado: 277 antigos reconciliados)
- [x] 1.3 Teste de seam do gerador: todo nome de `tags.json` tem nós; todo alias aponta para ícone existente; rodar duas vezes gera o mesmo arquivo; versão confere com `package.json`
- [x] 1.4 Remover `scripts/icons.txt` e `scripts/lib/build_icons_css.mjs` (após 3.4); `mix icons.sync` e README atualizados

## 2. Núcleo em Elixir

- [x] 2.1 `FrappeUIPhx.Icons` (`names/0`, `get/1`, `search/1`, `version/0`) lendo `priv/icons.json` com `@external_resource`; busca normaliza caixa/acentos e ordena (exato, prefixo, tag)
- [x] 2.2 `Icons.Svg.render/2`: SVG com `size`, `color`, `stroke_width`, `absolute_stroke_width`, `class`, `title`, `rest`; pré-condições com `Contract.require!/3` (número positivo finito; nome existente com sugestões)
- [x] 2.3 `FrappeUIPhx.Icons.Lucide`: macro que define um function component por ícone (nomes `-` → `_`, prefixo `i_` se começar com dígito), todos delegando ao `Svg.render/2`; resolver colisões de nome
- [x] 2.4 Medir tempo de compilação e tamanho do beam; se compilação > ~30 s, dividir por letra inicial; decidir dados compilados vs `persistent_term` (medido: ~35 s uma vez, beam de `Icons.Lucide` 8 MB por metadados de `attr`, dados em `Icons` 1,4 MB; mantido compilado e em módulo único)
- [x] 2.5 `Components.Icon.icon/1` genérico por nome/alias com as novas propriedades; `IconResolver` (+ `IconResolver.Lucide`) cobrindo todo o catálogo; componentes com prop `icon=` renderizam via `<.icon>`
- [x] 2.6 Catálogo `Components`/`use FrappeUIPhx`: manter `icon` no import padrão; documentar `alias FrappeUIPhx.Icons.Lucide`

## 3. Testes

- [x] 3.1 Cobertura completa: todo ícone de `Icons.names/0` tem componente em `Icons.Lucide` e vice-versa
- [x] 3.2 Propriedades: `size`, `color`, `stroke_width`, `absolute_stroke_width` (48 → traço 0,5·… conforme fórmula), `class`, `rest`
- [x] 3.3 A11y (`aria-hidden` padrão; `title` expõe `role="img"`/`<title>`), alias, nome inexistente com sugestão, valores inválidos (`size 0`, `-1`, `"x"`)
- [x] 3.4 Regressão: Button/Input/demais com `icon=` (inclusive ícone fora dos 82 originais); seam existente do mostruário (`frappe_ui_icons.css`) trocado por checagem contra `Icons`
- [x] 3.5 Busca: por nome, por tag, sem resultado, acentos/caixa
- [x] 3.6 `mix quality` verde (format, warnings-as-errors, cobertura ≥ 90, deps.audit) e `npm audit` limpo

## 4. Mostruário

- [x] 4.1 Página `/icones`: grade em lotes de 120 com "Mostrar mais" (stream não ajuda: toda mudança de propriedade re-renderiza os ícones visíveis), busca com debounce, controles de `size`/`color`/`stroke_width`/`absolute_stroke_width`
- [x] 4.2 Detalhe do ícone: nome, tags, aliases, snippet (`<Lucide.nome />` e `<.icon name="..." />`)
- [x] 4.3 Entrada no índice e na home; testes LiveView (busca, propriedades, detalhe, sem resultado)

## 5. Distribuição e documentação

- [x] 5.1 `mix.exs`: `files` com `priv/icons.json`; ícones funcionam sem importar CSS de ícones; instalador deixa de adicionar o `@import` do CSS de ícones
- [x] 5.2 Marcar `priv/static/frappe_ui_icons.css` e `.lucide-*` como deprecados (README, aviso) e remover na versão seguinte
- [x] 5.3 README: uso (`<Lucide.plus size={16} />`, `<.icon name=... />`), propriedades, busca, limitação de categorias; atribuição ISC mantida em LICENSE/README
- [x] 5.4 `openspec validate --specs --strict` e `openspec validate add-all-lucide-icons --strict`
