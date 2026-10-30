## Context

Hoje: 82 ícones por máscara CSS (`.lucide-<nome>`, `priv/static/frappe_ui_icons.css`), gerados por `scripts/sync_icons.mjs` a partir de `scripts/icons.txt`; `Components.Icon` + `IconResolver` (fachada → módulo configurado `class/1`). Espessura fixa (2) por causa da máscara. O `lucide-static@1.65.0` (ISC) traz `icon-nodes.json` (1.998 ícones: nome → nós `[tag, attrs]`), `tags.json` (1.998 entradas) e 2.275 SVGs em `icons/`. Os 277 SVGs a mais não estão nos JSONs: são nomes antigos (ex.: `alert-circle` → `circle-alert`). Não há categorias no pacote.

O usuário pediu: todos os ícones, com suas propriedades, **como componentes LiveView**.

## Goals / Non-Goals

**Goals:**
- Um function component por ícone + genérico por nome, com `size`, `color`, `stroke_width`, `absolute_stroke_width`, `class`, `title`, `rest`.
- Metadados (tags, aliases) e busca; página no mostruário.
- Sem JS, sem CSS de ícones, dados reprodutíveis, `IconResolver` e props `icon=` dos demais componentes cobrindo tudo.

**Non-Goals:**
- Categorias do lucide.dev (não existem no pacote; ficam fora, registrado como limitação).
- Ícones de outras bibliotecas; animação de ícones.
- Alterar o contrato de `icon=` dos outros componentes (continua nome string).

## Decisions

**D1. SVG inline gerado no servidor, não máscara CSS.** A máscara não permite `stroke_width` nem cores múltiplas e exigiria ~2 MB de CSS (ou `@source inline` do Tailwind, frágil com nomes dinâmicos). Inline SVG entrega as propriedades Lucide exatamente como `lucide-react` e não depende do Tailwind detectar classes. Alternativa descartada: manter máscara para todos (perde `stroke_width`).

**D2. Fonte de dados: `priv/icons.json`, gerado por `mix icons.sync`.** Formato: `{"version": "1.65.0", "icons": {"plus": {"nodes": [["path",{"d":"..."}]], "tags": [...], "aliases": [...]}}}`. Gerado de `icon-nodes.json` + `tags.json`. Aliases: o SVG antigo cujo conteúdo normalizado (nós) é idêntico ao de um ícone atual vira alias dele; SVG antigo sem equivalente idêntico é reportado pelo script (falha se houver, para decisão humana). Determinístico (chaves ordenadas) para "geração reprodutível". Alternativa descartada: ler os SVGs no compile do usuário (exigiria npm no consumidor).

**D3. Um módulo gerado em tempo de compilação.** `FrappeUILive.Icons.Lucide` lê `icons.json` (`@external_resource`) e define, por macro, uma função componente por ícone (`def plus(assigns)`, nomes com `-` viram `_`; nomes que começam com dígito recebem prefixo `i_`). Cada uma delega a um único `Icons.Svg.render/2` (SOLID: uma implementação de renderização; as 1.998 funções são só atalhos). Genérico: `Components.Icon.icon/1` (`name`) resolve nome/alias → atalho via mapa em tempo de compilação. Risco: tempo de compilação com ~2.000 funções com `attr` — mitigação: `attr` declarado uma vez por macro de módulo e medir; se passar de ~30 s, dividir em módulo por letra inicial. `use FrappeUILive` não importa o módulo inteiro por padrão (poluiria o namespace com `plus/1`, `search/1`…): usar `alias FrappeUILive.Icons.Lucide` e `<Lucide.plus />`; o genérico `<.icon>` continua no import padrão.

**D4. Contrato (DbC).** Pré-condições via `Contract.require!/3`: `size` e `stroke_width` números positivos finitos; `name` existente (erro lista até 3 nomes parecidos). Não é entrada de usuário final, então erro de programador (ArgumentError), coerente com o restante.

**D5. Renderização.** `<svg xmlns width height viewBox="0 0 24 24" fill="none" stroke={color} stroke-width={sw} stroke-linecap="round" stroke-linejoin="round" class aria-hidden="true">`. `absolute_stroke_width`: `sw = stroke_width * 24 / size` (igual ao `lucide-react`). Com `title`: remove `aria-hidden`, adiciona `role="img"` e `<title>`. Filhos gerados de `nodes` com escape do HEEx (atributos vindos de JSON versionado, nunca de entrada de usuário). Pré-computar por ícone o iodata dos filhos no compile para render barato.

**D6. `IconResolver`.** A fachada passa a devolver o que o `Icon` precisa para qualquer nome do catálogo. O módulo padrão (`IconResolver.Lucide`) deixa de produzir classe CSS e delega ao catálogo; o behaviour continua permitindo trocar de biblioteca. Componentes que hoje recebem `icon="plus"` renderizam via `<.icon>`. Compatibilidade: a classe `.lucide-*` e `frappe_ui_icons.css` ficam por uma versão como deprecados (aviso no README e no instalador), depois removidos. `scripts/icons.txt` e `build_icons_css.mjs` saem junto.

**D7. Metadados e busca.** `FrappeUILive.Icons`: `names/0`, `get/1` (nome ou alias → `%{name, tags, aliases}`), `search/1` (normaliza caixa/acentos, casa nome ou tag; ordem: nome exato, prefixo, tag), `version/0`. Dados em `:persistent_term` carregados no primeiro uso (ou compilados no módulo, decidir pelo tamanho do beam na task 2.x).

**D8. Mostruário.** Página `/icones` (LiveView) com grade, busca (`phx-change` com debounce), controles `size`/`color`/`stroke_width`/`absolute_stroke_width` e detalhe (nome, tags, aliases, snippet). Grade limitada por paginação/“carregar mais” (2.000 SVGs de uma vez pesam no diff do LiveView): `phx-update="stream"` com lotes de 120. Entra no índice e na home; `Showcase.Spec` do componente `icon` continua gerado do `attr`.

**D9. Segurança de dependências.** `lucide-static` segue exato e `npm audit` 0; `icons.json` guarda a versão e o teste confere contra `package.json`.

## Decisões da implementação

- `IconResolver` passou a ter callback `name/1` (apelidos do projeto -> nome do catálogo); o padrão devolve o nome. Antes era `class/1` (classe CSS).
- `-filled` (ex.: `star-filled`, usado pelo Rating) é aceito em qualquer ícone: mesmo desenho com `fill="currentColor"`. Prefixo `lucide-` também é aceito.
- O SVG leva a classe `lucide lucide-<nome atual>`, como no lucide-react.
- Compilação: ~35 s uma vez ao compilar a dependência, sem dividir o módulo (mantém `Lucide.<nome>` num único alias).
- Página de ícones: grade em lotes de 120 com "Mostrar mais" em vez de stream.

## Risks / Trade-offs

- [Compilação lenta com ~2.000 funções] → medir; dividir em módulos por letra; `only:` configurável é opção futura.
- [Tamanho do beam / memória] → ~0,8 MB de dados; aceitável; medir e preferir `persistent_term` se o beam passar de ~5 MB.
- [Aliases ambíguos entre versões] → script falha em SVG antigo sem equivalente; versão fixada.
- [Quebra para quem usa `.lucide-*`] → deprecação de uma versão, nota no README, `Icon` continua com a mesma assinatura (`name`, `class`).
- [Sem categorias] → documentado; busca por tags cobre o caso de descoberta.
- [HTML maior que máscara CSS] → ~300–500 bytes por ícone; aceitável, e sem CSS de 2 MB.

## Migration Plan

1. Gerar `icons.json` e as funções; manter CSS antigo por uma versão.
2. Trocar `Icon`/`IconResolver.Lucide` para SVG inline; testes de regressão dos componentes que usam `icon=`.
3. Mostruário + README; marcar CSS como deprecado; remover em versão seguinte. Rollback: reverter o commit (CSS antigo ainda presente).

## Open Questions (resolvidas na implementação)

- Compilar os dados no módulo ou `persistent_term`? Decidir por medição (task 2.4).
- Nomes que colidem com funções do `Phoenix.Component` (ex.: `link`, `form`, `table`, `slot`)? Mitigado por usar sempre `Lucide.<nome>` com alias; confirmar na compilação.
