## Context

Ver `proposal.md` (Why). Estado observado no workspace:

- `erpnt_saude_sus` e `predman` são apps Phoenix 1.8 / LiveView 1.0–1.2 com `core_components.ex` próprio; `predman` já usa `compilers: [:phoenix_live_view]`, requisito dos colocated hooks.
- O `frappe-ui` 1.1.0 (MIT) publica no npm os tokens como dados: `tailwind/tokens.js` (cores oklch resolvidas, radius, sombras, tipografia, spacing) e `tailwind/tokens/colors.js`. Os componentes usam só classes de token (`bg-surface-gray-2`, `text-ink-gray-8`, `border-outline-gray-2`), então o markup é portável.
- Phoenix 1.8 gera apps com Tailwind **v4** (CSS-first); o preset oficial do Frappe UI é v3.
- LiveView 1.1 traz **Colocated Hooks** (`<script :type={Phoenix.LiveView.ColocatedHook} name=".Nome">`, extraídos na compilação para `phoenix-colocated/<otp_app>`), `:key` em comprehensions e `<.portal>`.

## Goals / Non-Goals

**Goals:**
- Markup e classes de token idênticos ao Frappe UI, para paridade visual.
- Zero JS escrito pelo host: hooks vivem junto do componente (colocated) e chegam ao host por um único import.
- Estado autoritativo no servidor; JS só para o que `Phoenix.LiveView.JS` e o HTML nativo não cobrem.

**Non-Goals:**
- Data fetching (`useCall`/`useDoc`/`useList`) e cliente REST do Frappe.
- Compatibilidade com Tailwind v3 nesta versão.
- Componentes experimentais do Frappe UI.

## Decisions

### D1. CSS-first, Tailwind v4, tokens gerados a partir do npm
O pacote entrega `priv/static/frappe_ui.css` com (a) variáveis CSS `--surface-*`, `--ink-*`, `--outline-*` para light e `[data-theme="dark"]`, e (b) um bloco `@theme inline` que mapeia `--color-surface-gray-2: var(--surface-gray-2)` etc., gerando as classes `bg-surface-*`, `text-ink-*`, `border-outline-*`. Um script (`scripts/sync_tokens.mjs`) lê `frappe-ui/tailwind/tokens` e regenera o CSS, garantindo paridade com a versão de referência (registrada em `priv/tokens.provenance.json`).
*Alternativas*: portar o preset v3 (obriga o host a manter Tailwind v3, contra o padrão do Phoenix 1.8); copiar valores à mão (diverge sem aviso). O host faz `@import "../../deps/frappe_ui_live/priv/static/frappe_ui.css"` e `@source` para os `.ex` da lib.

### D2. Colocated hooks como único mecanismo de JS
Cada componente com comportamento de cliente declara seu hook no próprio módulo com `Phoenix.LiveView.ColocatedHook`. O host importa `{hooks as frappeUiHooks} from "phoenix-colocated/frappe_ui_live"` e espalha em `hooks:`. Nomes com prefixo de ponto evitam colisão com hooks do host.
*Alternativas*: um `frappe_ui.js` único em `priv/` (precisa de passo de instalação e vira bundle monolítico); hooks por `npm` (traz Node para o host). Dependências JS pesadas (ECharts, TipTap, CodeMirror) ficam em hooks separados importados dinamicamente (`import()`) a partir do hook, de modo que só são buscadas quando um chart/editor monta.
Exige `phoenix_live_view ~> 1.1`, `compilers: [:phoenix_live_view]` no host e o `NODE_PATH` do esbuild apontando para `Mix.Project.build_path()` (padrão em apps Phoenix 1.8). A task de instalação checa e avisa se faltar.

### D3. Function components por padrão, LiveComponent só com estado próprio
Tudo que é apresentação (Button, Badge, Alert, Avatar, FormControl...) é function component com `attr`/`slot` declarados (documentação e warnings em compilação). `Phoenix.LiveComponent` só onde há estado de interação que o servidor deve possuir (Combobox/MultiSelect com busca, DatePicker, Tree, List com seleção). Overlays usam `<dialog>` nativo e Popover API quando possível, `Phoenix.LiveView.JS` para show/hide e hook só para posicionamento e foco.

### D4. Integração com formulários Phoenix
Controles aceitam `field={@form[:campo]}` e derivam `id`, `name`, `value`, `errors` (padrão do `core_components` gerado pelo Phoenix). Sem `field`, aceitam `name`/`value` avulsos.

### D5. Toasts e diálogos dirigidos pelo servidor
`FrappeUILive.Toast` expõe `put_toast/3` (via `push_event`) e um `<.toast_container>` que o hook exibe e remove; `<.confirm_dialog>` usa assigns. Isto substitui `FrappeUIProvider`, `toast()` e `dialog.*`.

### D6. Ícones
Lucide via classes de máscara CSS (`lucide-<nome>`), como no Frappe UI. O CSS dos ícones usados é gerado a partir do pacote `lucide-static` por script, limitado aos ícones referenciados pelos componentes mais um mapa opcional do host.

### D7. Nome e namespace
Pacote `frappe_ui_live`, módulo `FrappeUILive`, cada componente em `FrappeUILive.<Categoria>` e reexportado por `use FrappeUILive`. Classes sempre completas (Tailwind só gera o que enxerga).

## Risks / Trade-offs

- [Colocated hooks exigem LV ≥ 1.1 e `compilers: [:phoenix_live_view]`] → documentar, validar na task de instalação.
- [Macro components, base do colocated, são API privada até o LV 1.2] → usar só `ColocatedHook`/`ColocatedJS`, que são públicos; isolar num único módulo de conveniência.
- [Reka UI não existe em Elixir: foco preso, tipo-ahead e navegação por setas precisam ser reescritos] → priorizar `<dialog>` nativo, Popover API e testes de teclado; marcar paridade parcial na documentação.
- [51 componentes é muito escopo] → entrega por fases (ver `tasks.md`); a v0.1 cobre tokens, feedback, formulários básicos, Dialog e Dropdown. Charts e editores ficam por último por trazerem dependências JS.
- [Tokens podem mudar upstream] → regeneração por script e provenance; o Frappe UI promete tokens só aditivos até 2.0.
- [Posicionamento de flutuantes sem biblioteca] → CSS Anchor Positioning onde disponível, com hook de fallback.

### D8. Regras de engenharia do projeto (SOLID, DbC, testes)
- **S**: um módulo por componente (`FrappeUILive.Components.Button`), um motivo para mudar. Classes de variante ficam em módulos puros separados (`...Variants`), testáveis sem renderizar.
- **O/D**: pontos de extensão são `@behaviour`s, não herança: `FrappeUILive.IconResolver` (como um nome de ícone vira classe/markup) e `FrappeUILive.ToastSink` (como um toast chega ao cliente). Os componentes dependem do behaviour, a implementação padrão é configurável.
- **I**: behaviours pequenos, de uma ou duas callbacks.
- **L**: sem herança de implementação; composição por slots e `attr :rest, :global`.
- **DbC**: `FrappeUILive.Contract` oferece `require!/3` (pré-condição: valor de `attr` fora do domínio, ex. `variant: :sombrio`, levanta `ArgumentError` — é bug do chamador, falha alto, nunca um componente renderizado errado em silêncio), `ensure!/3` (pós-condição, usada no gerador de tokens: arquivo gerado não vazio e todo token resolvido) e invariantes nos LiveComponents com estado (guard dentro do handler de transição, devolvendo o socket inalterado em caso de violação). Entrada de usuário (valores de formulário) nunca levanta: erros viram `errors` do `FormField`.
- **Testes**: ExUnit. Cada componente tem teste de render (atributos, classes de token, acessibilidade) e teste de contrato (valor inválido levanta). A costura mais frágil da lib é **tokens.js (fonte) → CSS gerado**: o teste lê o CSS por um caminho independente e compara com os tokens carregados pelo Node, sem reler a saída do próprio gerador. LiveComponents com estado têm teste via `Phoenix.LiveViewTest` que muta e relê por outra visão do DOM.
- **Cobertura**: `mix test --cover` com `test_coverage: [summary: [threshold: 90]]`; o build falha abaixo disso. Getters e delegações triviais não ganham teste artificial.
- Todo módulo concreto de comportamento é um módulo único com `@moduledoc`; sem `use`/macro escondendo dependência além do `use FrappeUILive` documentado.

### D9. Charts em SVG renderizado no servidor (revisa a ideia inicial de ECharts)
Os gráficos são function components que calculam a geometria em módulos puros (`Charts.Scale`, `Charts.Cartesian`, funções `bars/3`, `lines/3`, `slices/1`, `layout/2`...) e emitem SVG com variáveis CSS do tema. Sem ECharts, sem npm no host, sem bundle extra e sem superfície de CVE; o dado novo chega por diff do LiveView. *Trade-off*: sem animação, zoom ou tooltips ricas (há `<title>` nativo e dica em CSS); gráficos muito grandes (milhares de pontos) exigem agregação no servidor.

### D10. Editor guarda Markdown, não HTML
`contenteditable` produz HTML arbitrário; sanitizá-lo exigiria uma dependência de sanitização e confiar nela. O hook converte o DOM para um Markdown restrito antes de enviar, e o servidor só renderiza esse subconjunto com texto escapado e links filtrados (`FrappeUILive.Markdown`). O conversor do hook é testado em Node a partir do próprio fonte. TipTap/CodeMirror ficam fora: trazem dependências JS e CVEs a acompanhar, e o ganho (tabelas, realce) não é requisito desta versão.

### D11. Seleção com busca sem estado de negócio no cliente
Combobox e MultiSelect são `radio`/`checkbox` nativos dentro de um popover: a escolha já é valor de formulário e dispara `phx-change`. O hook só filtra a lista digitada (estado efêmero de UI); para listas grandes, `on_search` envia o texto ao servidor, que devolve as `options`. DatePicker é LiveComponent porque o mês exibido é estado próprio; o valor do formulário continua sendo a fonte da verdade.
