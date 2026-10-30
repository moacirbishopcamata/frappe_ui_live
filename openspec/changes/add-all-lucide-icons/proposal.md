## Why

Hoje a biblioteca traz só 82 ícones Lucide curados, renderizados por máscara CSS (`.lucide-<nome>`), com tamanho e traço fixos. Quem precisa de um ícone fora da lista tem de editar `scripts/icons.txt` e regerar o CSS. Lucide tem ~1.998 ícones e propriedades próprias (tamanho, cor, espessura do traço, traço absoluto); a biblioteca deve oferecê-los todos, como componentes LiveView, com essas propriedades.

## What Changes

- Todos os ícones do `lucide-static` (versão fixada) passam a existir como **function components do LiveView**: um por ícone (`<Lucide.plus />`, importável via `use FrappeUILive`) mais o genérico `<.icon name="plus" />`.
- Propriedades Lucide como `attr` de todo ícone: `size` (padrão 24), `color` (padrão `currentColor`), `stroke_width` (padrão 2), `absolute_stroke_width` (traço constante independente do tamanho), `class`, `title` (acessibilidade) e `rest` global.
- Renderização como `<svg>` inline gerado no servidor a partir de `priv/icons.json` (nós SVG de `icon-nodes.json`), sem JavaScript e sem CSS de ícones.
- Metadados consultáveis via `FrappeUILive.Icons`: `names/0`, `get/1`, `tags/1`, `search/1`, `aliases`.
- `IconResolver` e as props `icon="..."` dos demais componentes (Button, Input etc.) continuam aceitando nomes Lucide, agora cobrindo todos os ícones.
- Mostruário ganha a página **Ícones**: grade com busca por nome/tag e controles ao vivo de `size`, `color`, `stroke_width` e `absolute_stroke_width`.
- Script `mix icons.sync` passa a gerar `priv/icons.json` (e o módulo é compilado dele); `lucide-static` segue fixado e auditado.
- **BREAKING (menor)**: as classes `.lucide-*` por máscara e `priv/static/frappe_ui_icons.css` deixam de ser necessários; ficam deprecados por uma versão e removidos depois. `scripts/icons.txt` deixa de existir.

## Capabilities

### New Capabilities
- `lucide-icons`: catálogo completo de ícones Lucide como componentes LiveView, suas propriedades, metadados e busca.

### Modified Capabilities
- `feedback-display-components`: o requisito "Ícones Lucide" passa a exigir todos os ícones, com propriedades de tamanho, cor e traço.
- `component-showcase`: nova página de ícones com busca e controles de propriedades.
- `phoenix-package-distribution`: pacote inclui `priv/icons.json`, tira o CSS de ícones e a geração passa a ser reprodutível.

## Impact

- Código: `lib/frappe_ui_live/components/icon.ex`, `icon_resolver.ex` (+ `IconResolver.Lucide`), novo `lib/frappe_ui_live/icons.ex` e módulo gerado de componentes; `use FrappeUILive`; `Components` (catálogo).
- Build: `scripts/sync_icons.mjs`, `scripts/lib/build_icons_css.mjs` (substituídos por gerador de JSON), `mix.exs` (`files`, `@external_resource`), tempo de compilação com ~2.000 funções.
- Tamanho: `priv/icons.json` ≈ 0,8 MB (vs. ~2 MB de CSS completo).
- Dependências: `lucide-static` (ISC) continua só como devDependency; atribuição mantida em LICENSE/README.
- Testes: seams (todo ícone listado tem nós; todo nome do `tags.json` resolve), propriedades, a11y, showcase.
