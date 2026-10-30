# frappe_ui_live

Componentes **Phoenix LiveView** com a identidade visual do [Frappe UI](https://ui.frappe.io):
mesmos design tokens (`surface-*`, `ink-*`, `outline-*`, dark mode), mesmo markup e classes,
sem Vue — estado autoritativo no servidor, JS só onde `Phoenix.LiveView.JS` e o HTML nativo não chegam.

> **Status: v0.1.** ~90 componentes/blocos (formulários, feedback, overlays, navegação, dados, charts, moléculas e experimentais),
> **Fundamentos** (cores, tipografia, raio, sombras, foco, cores de gráficos), integrações com Ecto e Plug, instalador e um
> **mostruário navegável**. Veja "Limites" e "Revisão de arquitetura" no fim.

## Componentes

| Categoria | Componentes |
|---|---|
| Formulários | `button`, `text_input`, `textarea`, `password`, `select`, `combobox`, `multi_select`, `checkbox`, `radio_group`, `switch`, `slider`, `rating`, `date_picker`, `time_picker`, `duration`, `file_uploader`, `form_control`, `form_label` |
| Feedback e exibição | `badge`, `alert`, `progress`, `skeleton`, `spinner`, `loading_text`, `avatar`, `icon`, `keyboard_shortcut`, `item_list_row`, `saved_indicator`, `error_message`, `toast_container` |
| Overlays | `dialog`, `bottom_sheet`, `settings_dialog`, `keyboard_shortcuts_dialog`, `dropdown`, `popover`, `context_menu`, `hover_card`, `tooltip` |
| Navegação e layout | `tabs`, `tab_buttons`, `breadcrumbs`, `page_header`, `sidebar`, `sidebar_rail`, `desktop_shell`, `mobile_shell`, `scroll_area`, `divider` |
| Dados | `tree`, `sortable` (arrastar-e-soltar) |
| Charts (SVG no servidor) | `bar_chart`, `line_chart`, `area_chart`, `donut_chart`, `percentage_bar_chart`, `funnel_chart`, `heatmap_chart`, `calendar_heatmap_chart`, `scatter_chart`, `sankey_chart`, `number_card`, `chart_card`, `chart_legend`, `chart_tooltip`, `chart_frame` (estados loading/empty/error) |
| Moléculas | `list` (seleção, ações, arrastar-e-soltar), `editor` (Markdown seguro), `code_editor` |
| Experimental | `accordion`, `calendar` (agenda), `command_palette` (Ctrl/⌘ K), `list_view` (agrupada), `stepper`, `theme_switcher` — a API ainda pode mudar |

A especificação de cada um (atributos, tipos, valores permitidos, slots) está no mostruário e é
**lida do código** (`FrappeUILive.Spec`), então não diverge.

## Fundamentos

Páginas de referência geradas da **mesma fonte do CSS** (`priv/foundations.json`, via `mix tokens.sync`), exibidas pelas
variáveis do tema (acompanham claro/escuro): **Colors** (surface/ink/outline + alpha e rampas), **Typography**,
**Radius**, **Shadows**, **Focus ring** e **Chart colors**. Em código: `FrappeUILive.Foundations`.
Um teste de costura garante que todo token documentado existe no CSS distribuído.

## Mostruário (navegável, com formulários)

```sh
cd showcase
mix setup          # deps, baixa Tailwind/esbuild, gera CSS e JS
mix phx.server     # http://localhost:4010
```

- **Índice** com Fundamentos e categorias (Formulários, Feedback, Overlays, Navegação, Dados, Charts, Moléculas, Experimental); menu lateral para navegar.
- **Playground**: um *formulário gerado dos `attr` reais* altera a prévia ao vivo e o trecho de uso.
- **Especificação**: tabela de atributos e slots.
- Estado no servidor: listas, árvore, ordenação, upload real, "salvo", abas ativas.
- Valor fora do contrato (ex.: `variant` inválido) aparece como **"Contrato violado"**, sem derrubar a página.
- Tema claro/escuro via `?theme=dark` (usa `FrappeUILive.Plug.Theme`).

## Instalação em um app Phoenix 1.8

Requisitos: `phoenix_live_view ~> 1.2` (colocated hooks, LV ≥ 1.1), Tailwind v4 (padrão do Phoenix 1.8),
`compilers: [:phoenix_live_view] ++ Mix.compilers()` no `mix.exs` (já vem no Phoenix 1.8).

```elixir
# mix.exs
{:frappe_ui_live, path: "../frappe_ui_live"}
```

```sh
mix deps.get
mix frappe_ui_live.install            # idempotente; --dry-run mostra o que faria
```

O instalador edita `assets/css/app.css` (tokens, ícones e `@source` dos componentes) e `assets/js/app.js`
(hooks colocated) e só **verifica** o `mix.exs`. Manualmente, o equivalente é:

```css
@import "../../deps/frappe_ui_live/priv/static/frappe_ui.css";        /* tokens, tema, utilitários */
@import "../../deps/frappe_ui_live/priv/static/frappe_ui_icons.css";  /* ícones Lucide */
@source "../../deps/frappe_ui_live/lib";   /* para o Tailwind enxergar as classes dos componentes */
```

```js
import {hooks as frappeUiHooks} from "phoenix-colocated/frappe_ui_live"
// ... hooks: {...colocatedHooks, ...frappeUiHooks}
```

```elixir
# lib/my_app_web.ex — em html_helpers
use FrappeUILive, except: [button: 1, icon: 1, list: 1]   # evita conflito com o core_components
```

```elixir
# router.ex
plug FrappeUILive.Plug.Theme                                  # no pipeline :browser
live_session :default, on_mount: [FrappeUILive.Live.ThemeHook] do ... end
# root layout: <html data-theme={@frappe_ui_theme}>
```

> O CSS do Frappe UI **não substitui** as escalas padrão do Tailwind (cores, `text-sm`, sombras):
> os tokens entram em namespaces próprios (`bg-surface-*`, `fui-text-*`, `shadow-elevation-*`),
> então o `daisyUI` e as classes do host continuam intactos.

**Verificado** num app gerado do zero (`mix phx.new`, Phoenix 1.8.16): instalador, `use FrappeUILive` ao lado do
`core_components`, compilação sem warnings, `assets.build` e `GET /` com os componentes renderizados.

## Integrações Ecto e Plug

| Módulo | Para quê |
|---|---|
| `FrappeUILive.Ecto.Duration` | `Ecto.Type`: `"1h 30m"`, `"1:30"`, `"90m"` ⇄ segundos (mesmo parser do componente `duration`) |
| `FrappeUILive.Ecto.Rating` | `Ecto.ParameterizedType`: avaliação `0..max` (`max: 5`) |
| `FrappeUILive.Ecto.StringList` | `Ecto.Type`: lista de textos a partir de `"a, b"` ou lista (tags/MultiSelect) |
| `FrappeUILive.Ecto.Options.from_enum/2` | opções de `Select` a partir de um `Ecto.Enum` |
| `FrappeUILive.Ecto.Errors` / `FrappeUILive.ErrorTranslator` | tradução de erros de changeset (troque por Gettext via config) |
| `FrappeUILive.Plug.Theme` | resolve `light`/`dark` (param → sessão → cookie → padrão) |
| `FrappeUILive.Plug.Static` | serve `frappe_ui.css` direto da dependência |
| `FrappeUILive.Live.ThemeHook` | `on_mount` que leva o tema da sessão aos assigns |
| `FrappeUILive.Toast` | `put_toast(socket, :success, "Salvo!")` (substitui o `toast()` do Frappe UI) |
| `FrappeUILive.Markdown` | Markdown restrito → HTML seguro (para exibir o que o `editor` salva) |
| `FrappeUILive.Components.Sortable.move/5` | reordena uma lista a partir do evento de drop |

Os controles aceitam `field={@form[:campo]}` e mostram erros de changeset **só depois que o campo foi usado**.

## Engenharia (SOLID, DbC, testes)

- **DbC**: `FrappeUILive.Contract` — `require!/3` (pré-condição: `variant: :sombrio` levanta `ArgumentError`,
  não renderiza errado em silêncio) e `ensure!/2` (pós-condição/invariante). Entrada de usuário nunca levanta:
  vira `errors` do `FormField`; eventos forjados do cliente (ex.: data fora de `min`/`max`) são ignorados.
- **SOLID**: um módulo por componente; extensão por `@behaviour` (`IconResolver`, `ToastSink`, `ErrorTranslator`),
  sem herança de implementação; estilo e geometria em funções puras (`InputStyle`, `Button.classes/1`, `Charts.Scale`...).
- **Testes**: `mix test --cover` (limite mínimo 90%; hoje ~98%). Inclui testes de **costura**:
  tokens do Frappe UI (lidos por Node, da fonte) ⇄ CSS gerado; ícones renderizados ⇄ CSS de ícones;
  Ecto changeset ⇄ `FormField` ⇄ componente; sessão ⇄ tema; DOM do editor ⇄ Markdown (executado em Node).

```sh
mix quality   # format --check-formatted, compile --warnings-as-errors, test --cover, deps.audit
```

## Tokens e ícones (geração)

```sh
mix tokens.sync   # lê vendor/frappe-ui-tokens (frappe-ui 1.1.0, MIT) -> priv/static/frappe_ui.css
npm install && mix icons.sync   # scripts/icons.txt + lucide-static -> priv/static/frappe_ui_icons.css
```

Os tokens são **dados vendorizados** do pacote `frappe-ui` (sem dependências npm, sem CVE).
`priv/tokens.provenance.json` registra versão e hash. Para um ícone novo, acrescente o nome a `scripts/icons.txt`.

## Limites conhecidos

- **Tipografia**: `fui-text-*` (não `text-sm`/`text-base`) para não colidir com o Tailwind do host.
- **Dialog**: foco preso, Esc e backdrop vêm do `<dialog>` nativo; o Reka UI (Vue) não tem equivalente em Elixir.
- **Dropdown/Popover/DatePicker/MultiSelect** usam Popover API + CSS Anchor Positioning (navegadores recentes).
- **Charts** são SVG sem animação/zoom; séries muito grandes devem ser agregadas no servidor.
- **Editor** usa `document.execCommand` (API legada, porém universal) e guarda **Markdown**; sem tabelas/imagens.
- **CodeEditor** não faz realce de sintaxe (exigiria CodeMirror e suas dependências).
- **DatePicker** usa meses e dias da semana em português.
- Classes de `Tabs`, `Breadcrumbs`, `Tooltip`, `Dialog` e dos componentes de layout foram aproximadas dos tokens,
  não copiadas 1:1 do original.
- Fora do escopo: data fetching (`useCall`/`useDoc`/`useList`) — no LiveView o dado chega pelos assigns.
- Veja "Revisão de arquitetura" abaixo para o que ainda precisa de ajuste.

## Revisão de arquitetura

Feita com três revisores (OO design, Clean Architecture, API design). Sem ciclos de dependência e sem XSS explorável; extensão
por `@behaviour`, funções puras e `Contract` estão consistentes. Veredito: **mudanças solicitadas**, com 1 ponto crítico e
20 importantes, registrados como tasks 17.x no OpenSpec. Os principais:

- **Crítico:** `mix frappe_ui_live.install` ignora opção inválida (`--dryrun`) e grava os arquivos.
- `active` vindo da URL (`?tab=lixo`) derruba Tabs/TabButtons/SettingsDialog/Sidebar; `DatePicker` sem fallback em `handle_event`.
- `id` obrigatório com erro uniforme e validação de id centralizada (hoje duplicada); acoplamento por string do hook do Sortable.
- Markdown: `/\evil.com` passa como link relativo (open-redirect); Toast: hook sem container `phx-update=ignore`.
- `use FrappeUILive` sem `only:`; `Spec` e `Samples` aumentam o custo de cada componente novo.

## Licença

MIT. Contém tokens e markup derivados do [Frappe UI](https://github.com/frappe/frappe-ui) (MIT,
© Frappe Technologies Pvt. Ltd. — veja `vendor/frappe-ui-tokens/LICENSE.md`) e ícones do
[Lucide](https://lucide.dev) (ISC).
