# frappe_ui_live

Componentes **Phoenix LiveView** com a identidade visual do [Frappe UI](https://ui.frappe.io):
mesmos design tokens (`surface-*`, `ink-*`, `outline-*`, dark mode), mesmo markup e classes,
sem Vue — estado autoritativo no servidor, JS só onde `Phoenix.LiveView.JS` e o HTML nativo não chegam.

> **Status: v0.1 (fase 1).** 24 componentes portados (formulários, feedback, overlays, navegação),
> integrações com Ecto e Plug, e um **mostruário navegável**. Charts, editores, List/Tree, DatePicker,
> Combobox etc. estão planejados em `openspec/changes/frappe-ui-phoenix-components`.

## Componentes

| Categoria | Componentes |
|---|---|
| Formulários | `button`, `text_input`, `textarea`, `select`, `checkbox`, `switch`, `form_control`, `form_label` |
| Feedback e exibição | `badge`, `alert`, `progress`, `skeleton`, `spinner`, `avatar`, `icon`, `error_message`, `toast_container` |
| Overlays | `dialog` (`<dialog>` nativo), `dropdown` (Popover API + CSS Anchor Positioning), `tooltip` |
| Navegação e layout | `tabs`, `breadcrumbs`, `page_header`, `divider` |

A especificação de cada um (atributos, tipos, valores permitidos, slots) está no mostruário e é
**lida do código** (`FrappeUILive.Spec`), então não diverge.

## Mostruário (navegável, com formulários)

```sh
cd showcase
mix setup          # deps, baixa Tailwind/esbuild, gera CSS e JS
mix phx.server     # http://localhost:4010
```

- **Índice** por categoria; menu lateral para navegar.
- **Playground**: um *formulário gerado dos `attr` reais* altera a prévia ao vivo e o trecho de uso.
- **Especificação**: tabela de atributos e slots.
- Valor fora do contrato (ex.: `variant` inválido) aparece como **"Contrato violado"**, sem derrubar a página.
- Tema claro/escuro via `?theme=dark` (usa `FrappeUILive.Plug.Theme`).

## Instalação em um app Phoenix 1.8

Requisitos: `phoenix_live_view ~> 1.2` (colocated hooks, LV ≥ 1.1), Tailwind v4 (padrão do Phoenix 1.8).

```elixir
# mix.exs
compilers: [:phoenix_live_view] ++ Mix.compilers(),   # necessário para os colocated hooks
deps: [{:frappe_ui_live, path: "../frappe_ui_live"}]
```

```css
/* assets/css/app.css */
@import "../../deps/frappe_ui_live/priv/static/frappe_ui.css";        /* tokens, tema, utilitários */
@import "../../deps/frappe_ui_live/priv/static/frappe_ui_icons.css";  /* ícones Lucide */
@source "../../deps/frappe_ui_live/lib";   /* para o Tailwind enxergar as classes dos componentes */
```

```js
// assets/js/app.js
import {hooks as frappeUiHooks} from "phoenix-colocated/frappe_ui_live"
const liveSocket = new LiveSocket("/live", Socket, {
  hooks: {...colocatedHooks, ...frappeUiHooks}, ...
})
```

```elixir
# lib/my_app_web.ex — em html_helpers
use FrappeUILive, except: [button: 1, icon: 1]   # `except` evita conflito com o core_components
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

## Integrações Ecto e Plug

| Módulo | Para quê |
|---|---|
| `FrappeUILive.Ecto.Duration` | `Ecto.Type`: `"1h 30m"`, `"1:30"`, `"90m"` ⇄ segundos (`humanize/1` faz a volta) |
| `FrappeUILive.Ecto.Rating` | `Ecto.ParameterizedType`: avaliação `0..max` (`max: 5`) |
| `FrappeUILive.Ecto.StringList` | `Ecto.Type`: lista de textos a partir de `"a, b"` ou lista (tags/MultiSelect) |
| `FrappeUILive.Ecto.Options.from_enum/2` | opções de `Select` a partir de um `Ecto.Enum` |
| `FrappeUILive.Ecto.Errors` / `FrappeUILive.ErrorTranslator` | tradução de erros de changeset (troque por Gettext via config) |
| `FrappeUILive.Plug.Theme` | resolve `light`/`dark` (param → sessão → cookie → padrão) |
| `FrappeUILive.Plug.Static` | serve `frappe_ui.css` direto da dependência |
| `FrappeUILive.Live.ThemeHook` | `on_mount` que leva o tema da sessão aos assigns |
| `FrappeUILive.Toast` | `put_toast(socket, :success, "Salvo!")` (substitui o `toast()` do Frappe UI) |

Os controles aceitam `field={@form[:campo]}` e mostram erros de changeset **só depois que o campo foi usado**.

## Engenharia (SOLID, DbC, testes)

- **DbC**: `FrappeUILive.Contract` — `require!/3` (pré-condição: `variant: :sombrio` levanta `ArgumentError`,
  não renderiza errado em silêncio) e `ensure!/2` (pós-condição/invariante). Entrada de usuário nunca levanta:
  vira `errors` do `FormField`.
- **SOLID**: um módulo por componente; extensão por `@behaviour` (`IconResolver`, `ToastSink`, `ErrorTranslator`),
  sem herança de implementação; classes de estilo em funções puras (`InputStyle`, `Button.classes/1`).
- **Testes**: `mix test --cover` (limite mínimo 90%). Inclui testes de **costura**:
  tokens do Frappe UI (lidos por Node, da fonte) ⇄ CSS gerado; ícones renderizados ⇄ CSS de ícones;
  Ecto changeset ⇄ `FormField` ⇄ componente; sessão ⇄ tema.

```sh
mix quality   # format --check-formatted, compile --warnings-as-errors, test --cover, deps.audit
```

## Tokens e ícones (geração)

```sh
mix tokens.sync   # lê vendor/frappe-ui-tokens (frappe-ui 1.1.0, MIT) -> priv/static/frappe_ui.css
npm install && mix icons.sync   # scripts/icons.txt + lucide-static -> priv/static/frappe_ui_icons.css
```

Os tokens são **dados vendorizados** do pacote `frappe-ui` (sem dependências npm, sem CVE).
`priv/tokens.provenance.json` registra versão e hash.

## Paridade com o Frappe UI (limites conhecidos)

- Tipografia usa `fui-text-*` (não `text-sm`/`text-base`) para não colidir com o Tailwind do host.
- Foco preso, Esc e backdrop do `Dialog` vêm do `<dialog>` nativo; o Reka UI (Vue) não tem equivalente em Elixir.
- Dropdown usa CSS Anchor Positioning (navegadores recentes); sem suporte, o menu aparece sem ancoragem.
- Classes de `Tabs`, `Breadcrumbs`, `Tooltip` e `Dialog` foram aproximadas dos tokens, não copiadas 1:1 do original.
- Fora do escopo: data fetching (`useCall`/`useDoc`/`useList`) — no LiveView o dado chega pelos assigns.

## Licença

MIT. Contém tokens e markup derivados do [Frappe UI](https://github.com/frappe/frappe-ui) (MIT,
© Frappe Technologies Pvt. Ltd. — veja `vendor/frappe-ui-tokens/LICENSE.md`) e ícones do
[Lucide](https://lucide.dev) (ISC).
