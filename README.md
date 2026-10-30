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
**lida do código** (`Showcase.Spec`, parte do mostruário), então não diverge.

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

- **Home**: cartão de **todos** os componentes, com prévia ao vivo, mais Fundamentos e blocos internos. **Índice** com Fundamentos e categorias (Formulários, Feedback, Overlays, Navegação, Dados, Charts, Moléculas, Experimental); menu lateral para navegar.
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

O instalador edita `assets/css/app.css` (tokens e `@source` dos componentes) e `assets/js/app.js`
(hooks colocated) e só **verifica** o `mix.exs`. Manualmente, o equivalente é:

```css
@import "../../deps/frappe_ui_live/priv/static/frappe_ui.css";        /* tokens, tema, utilitários */
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
| `FrappeUILive.ErrorTranslator` (padrão `ErrorTranslator.Default`) | tradução de erros de changeset (troque por Gettext via config) |
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
  tokens do Frappe UI (lidos por Node, da fonte) ⇄ CSS gerado; catálogo de ícones ⇄ `lucide-static` (arquivos, tags, aliases);
  Ecto changeset ⇄ `FormField` ⇄ componente; sessão ⇄ tema; DOM do editor ⇄ Markdown (executado em Node).

```sh
mix quality   # format --check-formatted, compile --warnings-as-errors, test --cover, deps.audit
```

## Textos e tradução

Rótulos de acessibilidade e mensagens auxiliares (ex.: "Fechar", "Mês anterior", erros de upload) vêm de
`FrappeUILive.Texts`, em português por padrão. Para mudar sem copiar componentes:

```elixir
config :frappe_ui_live, texts: %{close: "Close", today: "Today"}   # sobrescritas pontuais
config :frappe_ui_live, translator: MeuApp.Translator              # ou um módulo (ex.: Gettext)
```

`MeuApp.Translator` implementa `FrappeUILive.Translator` (`translate(key, default, bindings)`). Um texto passado
explicitamente ao componente (`label=`, `placeholder=`...) sempre vence o configurado. `FrappeUILive.Texts.keys/0` lista as chaves.

## Tokens e ícones (geração)

```sh
mix tokens.sync   # lê vendor/frappe-ui-tokens (frappe-ui 1.1.0, MIT) -> priv/static/frappe_ui.css
npm install && mix icons.sync   # lucide-static -> priv/icons.json (todos os ícones, tags e aliases)
```

Os tokens são **dados vendorizados** do pacote `frappe-ui` (sem dependências npm, sem CVE).
`priv/tokens.provenance.json` registra versão e hash. Os ícones vêm do `lucide-static` fixado (ISC); `mix icons.sync` é determinístico e falha se algum
SVG antigo não tiver ícone equivalente.

## Ícones Lucide

Todos os ícones do Lucide (veja `FrappeUILive.Icons.version/0`) são **componentes LiveView**, em SVG inline,
sem JavaScript e sem CSS de ícones:

```heex
alias FrappeUILive.Icons.Lucide

<Lucide.plus />
<Lucide.circle_alert size={16} color="red" stroke_width={1.5} title="Erro" />
<.icon name="alert-circle" size={20} absolute_stroke_width />   <%!-- por nome (string); aceita aliases e "-filled" --%>
```

Propriedades de todo ícone: `size` (24), `color` (`currentColor`), `stroke_width` (2), `absolute_stroke_width`
(mantém a espessura visual em qualquer tamanho), `title` (nome acessível; sem ele o ícone é decorativo,
`aria-hidden`), `class` e atributos globais. Valores inválidos (`size={0}`, nome inexistente) falham alto
com `ArgumentError`. O nome da função é o do ícone com `-` trocado por `_` (`"1-circle"` → `i_1_circle`);
a compilação do módulo com ~2.000 componentes leva ~35 s, uma vez, ao compilar a dependência.

`FrappeUILive.Icons` expõe `names/0`, `get/1` (tags e aliases), `search/1` (nome ou tag) e `version/0`.
As props `icon=` dos demais componentes aceitam qualquer ícone pelo nome. `config :frappe_ui_live, icon_resolver:`
permite apelidos do projeto (callback `name/1`). O mostruário tem a página **Ícones** (`/icones`) com busca e controles ao vivo.
O catálogo não traz as categorias do lucide.dev (o pacote não as inclui); use as tags.

**Deprecado**: `priv/static/frappe_ui_icons.css` (`.lucide-*` por máscara, 82 ícones, congelado) deixa de ser
necessário, não é mais importado pelo instalador e será removido na próxima versão.

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

Feita com três revisores (OO design, Clean Architecture, API design): sem ciclos de dependência e sem XSS explorável;
extensão por `@behaviour`, funções puras e `Contract` consistentes. Veredito inicial: mudanças solicitadas (1 crítico, 20
importantes). **Já corrigidos** (com testes de regressão):

- mix task grava arquivos mesmo com opção inválida (`--dryrun`);
- `?tab=lixo` derrubava Tabs/TabButtons/SettingsDialog/Sidebar; `DatePicker` sem fallback para evento forjado;
- `id` obrigatório com erro uniforme e validação central (`Anchor`, `Dialog`, `Field.require_id!/2`);
- protocolo de DOM do Sortable encapsulado, nome do hook derivado e Tree só reordena entre irmãos;
- Markdown (open-redirect `/\`, ordem de ênfase/links, `to_safe/1`) e Toast (contêiner `phx-update=ignore`, paleta única);
- `use FrappeUILive` com `only:` e validação de nomes; casca de painel única; `Plug.Static`/`Plug.Theme`; `Contract.require!/3`;
- item de navegação unificado: `Action` decide link ou botão (`NavItem`, `MenuItem`, `Tabs`) e os slots usam o mesmo vocabulário.

- `rest` global uniforme em todos os componentes com elemento raiz e textos fixos configuráveis (`FrappeUILive.Texts`).

- `Spec` saiu do pacote (é do mostruário); pontos de extensão (`IconResolver`, `ToastSink`, `ErrorTranslator`, `Translator`) com
  fachada e módulo configurado validado; `Field.assign_field/2` com precedência documentada; `List` com `selectable`/`selected`
  e `Tree` com `selected_id`; DatePicker alinhado aos outros campos.

Sem pendências da revisão. O tema padrão também vale no LiveView: `on_mount: [{FrappeUILive.Live.ThemeHook, default: "dark"}]`.

## Licença

MIT. Contém tokens e markup derivados do [Frappe UI](https://github.com/frappe/frappe-ui) (MIT,
© Frappe Technologies Pvt. Ltd. — veja `vendor/frappe-ui-tokens/LICENSE.md`) e ícones do
[Lucide](https://lucide.dev) (ISC).
