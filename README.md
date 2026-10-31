# Frappe UI Phx

[![CI](https://github.com/moacirbishopcamata/frappe_ui_phx/actions/workflows/ci.yml/badge.svg)](https://github.com/moacirbishopcamata/frappe_ui_phx/actions/workflows/ci.yml)

Componentes **Phoenix LiveView** com a identidade visual do [Frappe UI](https://ui.frappe.io): os mesmos
design tokens (`surface-*`, `ink-*`, `outline-*`, modo escuro), o mesmo markup e as mesmas classes, **sem Vue**.
O estado fica no servidor; JavaScript só aparece onde `Phoenix.LiveView.JS` e o HTML nativo não chegam
(hooks *colocated*, ao lado do componente).

> **Projeto independente, não oficial.** Não é mantido nem endossado pela Frappe Technologies.

- **78 componentes** em 8 categorias, mais blocos internos: formulários, feedback, overlays, navegação e layout, dados,
  charts (SVG gerado no servidor), moléculas e experimentais.
- **Ícones Lucide**: todos os ~2.000, como componentes (`<Lucide.plus />`), com `size`, `color` e `stroke_width`.
- **Fundamentos**: cores, tipografia, raio, sombras, anel de foco e cores de gráficos.
- **Integrações**: Ecto (tipos e erros), Plug (tema) e LiveView (toasts, diálogos, ordenação).
- **Mostruário navegável** com *playground* gerado dos `attr` reais e a especificação de cada componente.

Índice: [Instalação](#instalação) · [Primeiros passos](#primeiros-passos) · [Convenções](#convenções-que-valem-para-todos-os-componentes) ·
[Formulários](#formulários) · [Feedback](#feedback-e-exibição) · [Overlays](#overlays) · [Navegação](#navegação-e-layout) ·
[Dados](#dados-listas-árvores-e-ordenação) · [Charts](#charts) · [Moléculas](#moléculas-e-experimentais) · [Ícones](#ícones-lucide) ·
[PinCode e DiceBear](#pincode-e-dicebearavatar) · [Tema](#tema-claro-e-escuro) · [Ecto e Plug](#integrações-ecto-e-plug) ·
[Configuração](#configuração) · [Solução de problemas](#solução-de-problemas) · [Referência completa](docs/componentes.md)

---

## Instalação

### Requisitos

| Item | Versão |
|---|---|
| Elixir | `~> 1.18` |
| Phoenix | `~> 1.8` |
| Phoenix LiveView | `~> 1.2` (hooks *colocated* exigem LiveView ≥ 1.1) |
| Tailwind | v4 (é o padrão de um app `mix phx.new` 1.8) |
| Navegador | recente: Popover API e CSS Anchor Positioning (Dropdown, Popover, DatePicker, MultiSelect) |

O app precisa ter `compilers: [:phoenix_live_view] ++ Mix.compilers()` no `mix.exs` — já vem assim num app novo do Phoenix 1.8.

### 1. Adicione a dependência

```elixir
# mix.exs
defp deps do
  [
    # a) do GitHub (hoje o repositório é privado: exige acesso à conta)
    {:frappe_ui_phx,
     git: "https://github.com/moacirbishopcamata/frappe_ui_phx.git", branch: "worktree-componentes-fase1"},

    # b) de uma pasta local
    # {:frappe_ui_phx, path: "../frappe_ui_phx"},

    # c) do Hex, depois de publicado
    # {:frappe_ui_phx, "~> 0.3"}
  ]
end
```

```sh
mix deps.get
```

A primeira compilação demora (~35 s): o módulo `FrappeUIPhx.Icons.Lucide` tem um componente para cada ícone. Acontece uma vez.

### 2. Rode o instalador

```sh
mix frappe_ui_phx.install --dry-run   # mostra o que faria, sem escrever nada
mix frappe_ui_phx.install             # aplica; é idempotente (pode rodar de novo)
```

O instalador:

| Arquivo | O que muda |
|---|---|
| `assets/css/app.css` | importa `frappe_ui.css` (tokens) e adiciona `@source` para os componentes, logo depois de `@import "tailwindcss"` |
| `assets/js/app.js` | importa os hooks *colocated* da biblioteca e os soma ao `hooks:` do `LiveSocket` |
| `mix.exs` | **só verifica** o `compilers:`; não altera |

Opções: `--dry-run` e `--dep-path CAMINHO` (padrão: onde o Mix achou a dependência). Uma opção desconhecida (por exemplo
`--dryrun`) aborta sem escrever nada.

### 3. Equivalente manual (se preferir, ou se o instalador não reconhecer seu `app.css`)

```css
/* assets/css/app.css */
@import "tailwindcss" source(none);
@source "../css";
@source "../js";
@source "../../lib/my_app_web";

@import "../../deps/frappe_ui_phx/priv/static/frappe_ui.css";   /* tokens, tema, utilitários */
@source "../../deps/frappe_ui_phx/lib";                        /* o Tailwind precisa enxergar as classes dos componentes */
```

```js
// assets/js/app.js
import {hooks as colocatedHooks} from "phoenix-colocated/my_app"
import {hooks as frappeUiHooks} from "phoenix-colocated/frappe_ui_phx"

const liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken},
  hooks: {...colocatedHooks, ...frappeUiHooks},
})
```

> Em um app Phoenix 1.8, `phoenix-colocated/...` já resolve pelo `NODE_PATH` da configuração do esbuild gerada pelo `mix phx.new`.

### 4. Importe os componentes

```elixir
# lib/my_app_web.ex
defp html_helpers do
  quote do
    # ... imports que já existem (CoreComponents, Phoenix.HTML...)
    use FrappeUIPhx, except: [button: 1, icon: 1, list: 1]
  end
end
```

`use FrappeUIPhx` importa as funções de componente do catálogo (`<.badge>`, `<.alert>`, `<.dialog>`...) e
`show_dialog/1`/`hide_dialog/1`.

**Colisões de nome.** O `CoreComponents` gerado pelo Phoenix já define `button/1`, `icon/1`, `list/1` (e `input`, `table`, `header`, `flash`...).
Duas formas de resolver:

```elixir
use FrappeUIPhx, except: [button: 1, icon: 1, list: 1]   # importa tudo, menos estes
use FrappeUIPhx, only: [badge: 1, alert: 1, dialog: 1]    # importa só o que você usa
```

Os excluídos continuam acessíveis com o módulo: `<FrappeUIPhx.Components.Button.button label="Salvar" />`.
Um nome desconhecido em `only:`/`except:` falha na compilação, listando os nomes válidos.

### 5. Tema, toasts e layout

```elixir
# lib/my_app_web/router.ex
pipeline :browser do
  # ... plugs existentes
  plug :fetch_session
  plug FrappeUIPhx.Plug.Theme              # resolve ?theme=dark → sessão → cookie → "light"
end

scope "/", MyAppWeb do
  pipe_through :browser

  live_session :default, on_mount: [FrappeUIPhx.Live.ThemeHook] do
    live "/", HomeLive
  end
end
```

```heex
<%!-- lib/my_app_web/components/layouts/root.html.heex --%>
<html lang="pt-BR" data-theme={assigns[:frappe_ui_theme] || "light"}>
```

```heex
<%!-- lib/my_app_web/components/layouts.ex (app/1) ou no layout da página --%>
<.toast_container flash={@flash} />
```

> **Atenção com o tema do Phoenix 1.8.** O root layout gerado costuma controlar `data-theme` (daisyUI) com um pequeno script e
> `localStorage`. Se você usar o `FrappeUIPhx.Plug.Theme`, remova esse script ou mantenha **um só dono** do atributo `data-theme`
> (os dois brigando produzem tema que "pisca"). Valores aceitos: `"light"` e `"dark"`.

Tema padrão diferente de claro: `plug FrappeUIPhx.Plug.Theme, default: "dark"` e `on_mount: [{FrappeUIPhx.Live.ThemeHook, default: "dark"}]`.

> O CSS do Frappe UI **não substitui** as escalas padrão do Tailwind (cores, `text-sm`, sombras): os tokens entram em namespaces
> próprios (`bg-surface-*`, `text-ink-*`, `border-outline-*`, `fui-text-*`, `shadow-elevation-*`), então o daisyUI e as classes do seu app continuam intactos.

### 6. Confira

Crie uma LiveView (ou edite a `HomeLive`) com:

```heex
<.alert theme={:green} title="Instalado">frappe_ui_phx está funcionando.</.alert>
<.button label="Salvar" variant={:solid} icon_left="check" />
<.badge label="Novo" theme={:blue} />
```

Se os estilos não aparecerem, veja [Solução de problemas](#solução-de-problemas).

---

## Primeiros passos

Um componente é uma *function component* comum do Phoenix: atributos como `attr`, conteúdo como slots.

```heex
<.button label="Enviar" variant={:solid} theme={:blue} size={:md} phx-click="enviar" />

<.alert theme={:amber} title="Atenção">
  O prazo termina amanhã.
  <:actions><.button label="Ver detalhes" size={:xs} /></:actions>
</.alert>

<.dropdown id="acoes" label="Ações">
  <:item label="Editar" icon="pencil" click="editar" />
  <:item label="Abrir página" navigate={~p"/pedidos"} />
  <:item label="Excluir" icon="trash-2" theme={:red} click="excluir" />
</.dropdown>
```

## Convenções que valem para todos os componentes

- **Variantes, temas e tamanhos são átomos**: `variant={:solid}`, `theme={:red}`, `size={:sm}`. Os valores aceitos aparecem na
  [referência](docs/componentes.md) e no mostruário. Valor fora da lista **levanta `ArgumentError`** com a lista válida
  (falha alto em vez de renderizar errado em silêncio).
- **Atributos globais**: todo componente com elemento raiz repassa `class`, `id`, `data-*`, `aria-*` e `phx-*` (`phx-click`, `phx-hook`...).
  `class` é somado às classes do componente.
- **`id` obrigatório** nos componentes que têm estado de UI ou hook (`dialog`, `bottom_sheet`, `dropdown`, `popover`, `context_menu`, `tabs`, `date_picker`, `combobox`, `multi_select`, `password`,
  `pin_code`, `editor`, `code_editor`, `list`, `list_view`, `tree`, `sortable`, `accordion`, `calendar`, `command_palette`...).
  O `id` vira seletor e é validado: precisa ser um identificador CSS simples (letras, números, `-`, `_`).
- **Campos de formulário** aceitam `field={@form[:campo]}` (nome, id, valor e erros vêm do `Phoenix.HTML.FormField`) **ou** `name`/`value` avulsos.
  Erros de changeset só aparecem depois que o campo foi usado (`used_input?/1`), como no `CoreComponents` do Phoenix.
- **Eventos**: atributos `on_*` / `click` recebem o **nome do evento** do servidor (`on_select="sel"`). Slots de item aceitam `navigate`, `patch`,
  `href` (links) ou `click` (evento, ou um comando `JS`).
- **Entrada de usuário nunca levanta.** Contrato (`ArgumentError`) vale para quem escreve o template; o que o usuário digita vira `errors`, e
  eventos forjados do cliente (uma data fora de `min`/`max`, um id que não existe) são ignorados.
- **Ícones** são nomes Lucide em string (`icon="plus"`, `icon_left="chevron-right"`). Veja [Ícones Lucide](#ícones-lucide).
- **Textos fixos** ("Fechar", "Mês anterior"...) são configuráveis. Veja [Configuração](#configuração).

Referência de **todos** os atributos, tipos, padrões e slots: [`docs/componentes.md`](docs/componentes.md) (gerada do código).

---

## Formulários

### Um formulário completo com Ecto

```elixir
defmodule MyApp.Pedidos.Pedido do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pedidos" do
    field :cliente, :string
    field :prioridade, Ecto.Enum, values: [:baixa, :media, :alta]
    field :entrega, :date
    field :observacoes, :string
    field :urgente, :boolean, default: false
    field :codigo, :string, virtual: true
  end

  def changeset(pedido, attrs) do
    pedido
    |> cast(attrs, [:cliente, :prioridade, :entrega, :observacoes, :urgente, :codigo])
    |> validate_required([:cliente, :prioridade])
    |> validate_length(:cliente, min: 3)
  end
end
```

```elixir
defmodule MyAppWeb.PedidoLive do
  use MyAppWeb, :live_view

  alias MyApp.Pedidos.Pedido
  alias FrappeUIPhx.Ecto.Options

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:prioridades, Options.from_enum(Pedido, :prioridade))
     |> assign_form(Pedido.changeset(%Pedido{}, %{}))}
  end

  def handle_event("validar", %{"pedido" => params}, socket) do
    form = %Pedido{} |> Pedido.changeset(params) |> Map.put(:action, :validate) |> to_form()
    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("salvar", %{"pedido" => params}, socket) do
    case MyApp.Pedidos.criar(params) do
      {:ok, _pedido} ->
        {:noreply, FrappeUIPhx.Toast.put_toast(socket, :success, "Pedido salvo!")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, changeset), do: assign(socket, :form, to_form(changeset))

  def render(assigns) do
    ~H"""
    <.form for={@form} phx-change="validar" phx-submit="salvar" class="max-w-md space-y-4">
      <.form_control field={@form[:cliente]} label="Cliente" required placeholder="Nome do cliente" />
      <.form_control field={@form[:prioridade]} label="Prioridade" type="select" options={@prioridades} prompt="Escolha…" required />
      <.date_picker id="entrega" field={@form[:entrega]} min={Date.utc_today()} />
      <.form_control field={@form[:observacoes]} label="Observações" type="textarea" />
      <.checkbox field={@form[:urgente]} label="Urgente" />
      <.button type="submit" label="Salvar" variant={:solid} theme={:blue} />
    </.form>
    """
  end
end
```

`form_control` junta rótulo + controle + descrição + erros e escolhe o controle pelo `type`: `"text"` (e os demais tipos de `<input>`),
`"textarea"`, `"select"`, `"checkbox"`, `"switch"`. O `required` aqui **espelha** o `validate_required` do changeset — o servidor continua sendo a barreira real.

### Os controles, um a um

```heex
<%!-- Texto --%>
<.text_input name="busca" value="" type="search" placeholder="Buscar…" />
<.textarea name="obs" value="" placeholder="Escreva…" />
<.password field={@form[:senha]} id="senha" />              <%!-- botão de mostrar/ocultar; o valor nunca volta ao HTML --%>

<%!-- Escolha --%>
<.select name="uf" value="SP" options={[{"São Paulo", "SP"}, {"Rio", "RJ"}]} prompt="UF" />
<.combobox id="fruta" name="fruta" value="uva" options={[{"Maçã", "maca"}, {"Uva", "uva"}]} />   <%!-- com busca --%>
<.multi_select id="frutas" name="frutas" value={["maca", "uva"]} options={[{"Maçã", "maca"}, {"Uva", "uva"}]} />
<.radio_group name="plano" value="pro" label="Plano" options={[{"Básico", "basico"}, {"Pro", "pro"}]} />
<.checkbox name="aceito" label="Aceito os termos" />
<.switch name="notificacoes" label="Receber notificações" />

<%!-- Números e tempo --%>
<.slider name="volume" value={40} show_value />
<.rating name="nota" value={3} />
<.date_picker id="data" name="data" value="2026-03-09" />    <%!-- LiveComponent: exige id --%>
<.time_picker name="hora" value="08:30" />
<.duration name="tempo" value={5400} />                      <%!-- "1h 30m" ⇄ segundos --%>

<%!-- Arquivos (upload do LiveView) --%>
<.file_uploader upload={@uploads.anexos} on_cancel="cancelar-upload">
  <:hint>PNG, JPG ou PDF — até 2 arquivos</:hint>
</.file_uploader>
```

- **Button** aceita `variant` (`:solid | :subtle | :outline | :ghost`), `theme` (`:gray | :blue | :green | :red`), `size` (`:xs`…`:lg`),
  `icon_left`, `icon_right`, `icon` (botão só com ícone), `loading`/`loading_text` e vira link com `href`, `navigate` ou `patch`.
- **Select/MultiSelect/Combobox**: `options` aceita lista de textos, `{rótulo, valor}` ou keyword. `FrappeUIPhx.Ecto.Options.from_enum/2` monta as opções de um `Ecto.Enum`.
- **`Duration`** entende `"1h 30m"`, `"1:30"` e `"90m"`; o tipo Ecto `FrappeUIPhx.Ecto.Duration` guarda segundos.
- **Upload**: o `file_uploader` mostra progresso, cancelamento e os erros do LiveView (tamanho, tipo, quantidade) traduzidos.

> `pin_code` está em [PinCode e DiceBearAvatar](#pincode-e-dicebearavatar).

---

## Feedback e exibição

```heex
<.badge label="Ativo" theme={:green} />                         <%!-- :gray :blue :green :amber :red :violet --%>
<.alert theme={:red} title="Falha ao salvar">Tente novamente em instantes.</.alert>
<.progress value={40} label="Envio" show_value />
<.skeleton class="h-4 w-40" />
<.spinner />
<.loading_text />
<.avatar label="Ana" image={@user.foto_url} size={:lg} shape={:circle} />
<.keyboard_shortcut keys={["Ctrl", "K"]} />
<.error_message message={["Campo obrigatório", "Mínimo de 3 caracteres"]} />
<.saved_indicator at={@saved_at} />                            <%!-- novo valor de `at` a cada salvamento reinicia a animação --%>
```

`item_list_row` é uma linha com ícone, título, subtítulo e ações (navegável com `navigate`/`patch`/`href`):

```heex
<.item_list_row title="Contrato.pdf" subtitle="2,1 MB · ontem">
  <:icon><.icon name="file-text" /></:icon>
  <:actions><.button label="Abrir" size={:xs} /></:actions>
</.item_list_row>
```

### Toasts (mensagens do servidor)

Coloque `<.toast_container flash={@flash} />` uma vez no layout. Em qualquer LiveView:

```elixir
FrappeUIPhx.Toast.put_toast(socket, :success, "Salvo!")                    # :info | :success | :warning | :error
FrappeUIPhx.Toast.put_toast(socket, :error, "Falhou", timeout: 8_000)      # padrão: 4000 ms
```

O container também mostra as mensagens do `flash` (`put_flash`). Tipo desconhecido, mensagem vazia ou `timeout` não positivo levantam `ArgumentError`.
Para mudar o transporte, implemente o behaviour `FrappeUIPhx.ToastSink` (veja [Configuração](#configuração)).

---

## Overlays

### Dialog e folha inferior

O `<dialog>` nativo cuida de foco preso, `Esc` e backdrop. Abra/feche **sem estado de negócio no cliente**:

```heex
<.button label="Excluir" theme={:red} phx-click={show_dialog("confirmar-exclusao")} />

<.dialog id="confirmar-exclusao" title="Excluir pedido?" size={:md}>
  Esta ação não pode ser desfeita.
  <:actions>
    <.button label="Cancelar" phx-click={hide_dialog("confirmar-exclusao")} />
    <.button label="Excluir" variant={:solid} theme={:red} phx-click={hide_dialog("confirmar-exclusao") |> JS.push("excluir")} />
  </:actions>
</.dialog>
```

Ou controle pelo servidor: `<.dialog id="x" open={@mostrar?} on_close="fechou">` (o hook só reage a *mudanças* de `open`; `on_close` avisa o
servidor quando o usuário fecha por `Esc`/backdrop, para manter o assign coerente). `placement={:bottom}` vira uma folha inferior; `bottom_sheet` é o atalho.

Outros diálogos prontos: `settings_dialog` (abas laterais) e `keyboard_shortcuts_dialog`:

```heex
<.keyboard_shortcuts_dialog id="atalhos" shortcuts={[%{label: "Buscar", keys: ["Ctrl", "K"]}]} />
```

### Dropdown, Popover, ContextMenu, HoverCard, Tooltip

```heex
<.dropdown id="menu" label="Ações" icon="chevron-down">
  <:item label="Editar" icon="pencil" click="editar" />
  <:item label="Excluir" icon="trash-2" theme={:red} click="excluir" />
</.dropdown>

<.popover id="filtros">
  <:trigger><.button label="Filtros" icon_right="chevron-down" /></:trigger>
  Conteúdo livre. Fecha com Esc ou clicando fora.
</.popover>

<.context_menu id="area" class="rounded-5 border border-dashed p-8">
  Clique com o botão direito aqui
  <:item label="Copiar" icon="copy" click="copiar" />
</.context_menu>

<.hover_card><:trigger><.badge label="@ana" /></:trigger> Cartão de perfil </.hover_card>
<.tooltip text="Dica útil"><.button label="Passe o mouse ou foque" /></.tooltip>
```

Dropdown, Popover, HoverCard e ContextMenu usam a **Popover API** + **CSS Anchor Positioning** (fecham com `Esc`/clique fora e viram para cima quando falta espaço).

---

## Navegação e layout

```heex
<%!-- A aba ativa é um assign do servidor, nunca estado do cliente --%>
<.tabs id="abas" active={@aba}>
  <:tab id="geral" label="Geral" patch={~p"/pedido?aba=geral"} />
  <:tab id="itens" label="Itens" icon="list" click={JS.push("aba", value: %{aba: "itens"})} />
  Painel da aba <strong>{@aba}</strong>
</.tabs>

<.tab_buttons active={@periodo}>
  <:button id="dia" label="Dia" click={JS.push("periodo", value: %{p: "dia"})} />
  <:button id="mes" label="Mês" click={JS.push("periodo", value: %{p: "mes"})} />
</.tab_buttons>

<.page_header title="Pedidos" subtitle="Últimos 30 dias">
  <:breadcrumbs>
    <.breadcrumbs><:item label="Início" navigate={~p"/"} /><:item label="Pedidos" /></.breadcrumbs>
  </:breadcrumbs>
  <:actions><.button label="Novo" variant={:solid} icon_left="plus" /></:actions>
</.page_header>
```

**Casca da aplicação**:

```heex
<.desktop_shell>
  <:sidebar>
    <.sidebar active="pedidos">
      <:header><span class="fui-text-lg-semibold">Minha app</span></:header>
      <:item id="inicio" label="Início" icon="house" navigate={~p"/"} />
      <:item id="pedidos" label="Pedidos" icon="file-text" navigate={~p"/pedidos"} />
      <:footer><span class="fui-text-sm text-ink-gray-5">v0.1</span></:footer>
    </.sidebar>
  </:sidebar>
  <.page_header title="Conteúdo" />
  <div class="p-5">…</div>
</.desktop_shell>

<.mobile_shell active="inicio">   <%!-- cabeçalho + conteúdo + barra de navegação inferior --%>
  <:header>Mobile</:header>
  <:nav id="inicio" label="Início" icon="house" navigate={~p"/"} />
  <:nav id="perfil" label="Perfil" icon="user" navigate={~p"/perfil"} />
  Conteúdo
</.mobile_shell>
```

`sidebar_rail` é a versão compacta (só ícones) e `scroll_area` uma área rolável com barra estilizada. `divider` separa seções.

---

## Dados: listas, árvores e ordenação

Alvos de arrastar-e-soltar são hooks nativos do HTML5; **a persistência sempre termina em um evento para o servidor** (nunca no cliente).

```heex
<.list id="usuarios" rows={@rows} selectable selected={@selecionados} on_select="selecionar" on_drop="reordenar">
  <:col :let={r} label="Nome">{r.nome}</:col>
  <:col :let={r} label="Papel"><.badge label={r.papel} /></:col>
  <:action :let={r}><.button label="Ver" size={:xs} phx-click="ver" phx-value-id={r.id} /></:action>
</.list>

<.tree id="arvore" nodes={@arvore} expanded={@expandidos} selected_id={@selecionado} on_toggle="alternar" on_select="escolher" />

<.sortable id="itens" items={@itens} on_drop="reordenar_itens" class="space-y-1">
  <:item :let={item}><div class="rounded-5 border px-3 py-2">{item.nome}</div></:item>
</.sortable>
```

```elixir
def handle_event("reordenar", %{"id" => id, "to" => to, "position" => position}, socket) do
  rows = FrappeUIPhx.Components.Sortable.move(socket.assigns.rows, & &1.id, id, to, position)
  {:noreply, assign(socket, :rows, rows)}
end
```

`Sortable.move/5` reordena a lista a partir do evento de *drop*. Os nós da `tree` são mapas `%{id:, label:, icon:, children: [...]}`; o `tree` só reordena entre irmãos.

---

## Charts

SVG gerado **no servidor**: sem JavaScript, sem biblioteca de gráficos, acessível (`role="img"` e rótulo) e com as cores dos tokens.

```heex
<.bar_chart categories={~w(Jan Fev Mar)} series={[%{name: "Receita", data: [12, 19, 15]}, %{name: "Custo", data: [8, 11, 10]}]} />
<.line_chart categories={@meses} series={@series} />
<.area_chart categories={@meses} series={@series} />
<.donut_chart data={[%{label: "Web", value: 55}, %{label: "App", value: 30}]} />
<.percentage_bar_chart data={@partes} />
<.funnel_chart steps={[%{label: "Visitas", value: 1000}, %{label: "Compras", value: 130}]} />
<.heatmap_chart rows={~w(Seg Ter)} cols={~w(8h 12h)} values={[[1, 4], [2, 8]]} />
<.calendar_heatmap_chart data={%{~D[2026-03-01] => 3}} />
<.scatter_chart series={[%{name: "Lote A", points: [{1, 3}, {2, 5}]}]} />
<.sankey_chart links={[%{source: "Site", target: "Compra", value: 70}]} />
<.number_card label="Receita" value="R$ 48.230" delta={12.5} />
```

`chart_card` embrulha um gráfico com título e ações; `chart_frame` dá os estados **carregando / vazio / erro** a qualquer gráfico; `chart_legend` e
`chart_tooltip` são os blocos internos. Séries muito grandes devem ser agregadas no servidor (os gráficos não têm zoom nem animação).

---

## Moléculas e experimentais

```heex
<.editor id="texto" name="texto" value={@markdown} />                     <%!-- editor rico que guarda Markdown --%>
<.code_editor id="codigo" name="codigo" value={@json} />                   <%!-- área de código (sem realce de sintaxe) --%>
```

Para exibir o que o `editor` salvou, com HTML seguro, use `{FrappeUIPhx.Markdown.to_safe(@texto)}` direto no template
(já vem marcado como seguro; não há escape duplo).

Componentes **experimentais** (a API ainda pode mudar):

```heex
<.accordion id="faq">
  <:item id="uso" title="Como funciona?" open>Cada seção é um &lt;details&gt; nativo.</:item>
</.accordion>

<.calendar id="agenda" month={@mes} selected={@dia} events={@eventos} on_prev="mes_anterior" on_next="mes_seguinte" on_today="hoje" on_select="escolher_dia" />

<.command_palette id="paleta">                                 <%!-- Ctrl/⌘ K --%>
  <:item group="Criar" label="Novo pedido" icon="plus" keywords="adicionar" shortcut={["N"]} click="novo_pedido" />
  <:item group="Ir para" label="Início" icon="house" navigate={~p"/"} />
</.command_palette>

<.list_view id="por-papel" rows={@rows} group_by={& &1.papel} collapsed={@recolhidos} on_toggle="alternar_grupo">
  <:col :let={r} label="Nome">{r.nome}</:col>
</.list_view>

<.stepper current={@passo} on_go="ir_ao_passo">
  <:step label="Conta" description="Dados básicos" />
  <:step label="Pagamento" />
</.stepper>

<.theme_switcher current={@frappe_ui_theme} />
```

---

## Ícones Lucide

Todos os ícones do Lucide (`FrappeUIPhx.Icons.version/0`) são **componentes LiveView**, em SVG inline — sem JavaScript e sem CSS de ícones.

```heex
<%!-- uma vez, no módulo: alias FrappeUIPhx.Icons.Lucide --%>
<Lucide.plus />
<Lucide.circle_alert size={16} color="red" stroke_width={1.5} title="Erro" />

<%!-- por nome (string), útil quando o ícone vem de um dado; aceita nomes antigos e "-filled" --%>
<.icon name="alert-circle" size={20} absolute_stroke_width />
<.icon name="star-filled" color="orange" />
```

| Propriedade | Padrão | O que faz |
|---|---|---|
| `size` | `24` | largura e altura em pixels |
| `color` | `currentColor` | cor do traço (herda `text-*` do contêiner) |
| `stroke_width` | `2` | espessura do traço |
| `absolute_stroke_width` | `false` | mantém a espessura **visual** igual em qualquer tamanho |
| `title` | — | nome acessível; sem ele o ícone é decorativo (`aria-hidden`) |
| `class`, atributos globais | — | repassados ao `<svg>` |

- O nome da função é o do ícone com `-` trocado por `_` (`circle-alert` → `circle_alert`; nome que começa com dígito ganha o prefixo `i_`).
- Nome inexistente levanta `ArgumentError` citando o nome e sugerindo parecidos. `size`/`stroke_width` inválidos também.
- As props `icon=` dos demais componentes aceitam **qualquer** ícone pelo nome (`<.button icon_left="anchor" />`).
- **Catálogo**: `FrappeUIPhx.Icons.names/0`, `get/1` (tags e aliases) e `search/1` (por nome ou tag). O mostruário tem a página **Ícones** (`/icones`).
- O Lucide não publica categorias no pacote; a descoberta é por **tags**.
- Apelidos do projeto: `config :frappe_ui_phx, icon_resolver: MyApp.Icons` (behaviour `FrappeUIPhx.IconResolver`, callback `name/1`).

---

## PinCode e DiceBearAvatar

### PinCode

```heex
<.pin_code id="otp" field={@form[:codigo]} length={6} on_complete="verificar" />
```

Uma caixa por caractere (3 a 12), avanço automático, `Backspace` que volta, setas, **colar o código inteiro** e `autocomplete="one-time-code"` (SMS).

- O valor é **um campo só** (`name` do `field`); as caixas não são enviadas sozinhas — nada parcial chega ao servidor.
- `type`: `:numeric` (padrão) ou `:alphanumeric`. `mask` esconde os caracteres como uma senha.
- `on_complete="evento"` envia `%{"id" => id, "value" => código}` quando todas as caixas estão preenchidas.
- `FrappeUIPhx.Components.PinCode.sanitize/2` aplica **no servidor** a mesma regra de caracteres do cliente. O código recebido
  continua sendo entrada de usuário: valide-o (e limite tentativas) no servidor.

```elixir
def handle_event("verificar", %{"value" => value}, socket) do
  case MyApp.Auth.verificar_codigo(socket.assigns.usuario, PinCode.sanitize(value)) do
    :ok -> {:noreply, push_navigate(socket, to: ~p"/")}
    :error -> {:noreply, FrappeUIPhx.Toast.put_toast(socket, :error, "Código inválido")}
  end
end
```

### DiceBearAvatar

```heex
<.dice_bear_avatar seed={FrappeUIPhx.DiceBear.seed(@user.id)} style="thumbs" size={:xl} label={@user.name} />
```

Avatar do [DiceBear](https://www.dicebear.com/) (API 10.x, 61 estilos em `FrappeUIPhx.DiceBear.styles/0`) sobre o `avatar`, com os mesmos `size` e `shape`.
Não há biblioteca oficial para Elixir: o componente **monta a URL** da API HTTP; o navegador busca a imagem.

- **Privacidade**: a `seed` vai na URL para o servidor do DiceBear. Use `DiceBear.seed/1` (id opaco), **nunca** e-mail ou nome.
- **Uso comercial**: a API pública é gratuita **só para uso não comercial**, sem garantia de disponibilidade e com limite de requisições por segundo
  (50 para SVG, 10 para PNG/JPG/WebP/AVIF). Em produção, [hospede a API](https://www.dicebear.com/recipes/self-host-the-http-api/) e configure:
  `config :frappe_ui_phx, dice_bear_base_url: "https://avatares.meuapp.com/10.x"`.
- **Licenças**: cada estilo tem a licença do seu criador (alguns CC BY 4.0, que exigem atribuição). Veja <https://www.dicebear.com/licenses/>.
- **CSP**: libere o host da API em `img-src`. As imagens carregam sob demanda e sem `Referer`.
- **Opções do núcleo** (validadas nos intervalos da documentação): `flip`, `rotate` (-360..360), `scale` (0..10), `border_radius` (0..50),
  `translate_x`/`translate_y`, `background_color` (hex), `tags`. As do estilo (`hairVariant`...) vão em `options={%{...}}`.
  `idRandomization`, `fontFamily`, `fontWeight` e `title` só existem em instância própria e são recusados na API pública.
- **Placeholder de avatar**: `image={@user.foto_url}` mostra a foto quando existe e o avatar gerado quando não (decisão no servidor, sem `onerror` inline):

```heex
<.dice_bear_avatar seed={@user.id |> DiceBear.seed()} image={@user.foto_url} label={@user.name} />
<.dice_bear_avatar seed={DiceBear.initials(@user.name)} style="initials" label={@user.name} />   <%!-- "Ana Souza" → "AS" --%>
```

A mesma `seed` + `style` + opções dá sempre o mesmo avatar, mas a seed **não serve como segredo**. Gerar o avatar localmente (sem requisição externa)
exigiria a biblioteca JS `@dicebear/core` (Node 22+), uma dependência npm que este projeto não tem; a alternativa suportada é hospedar a API.

---

## Tema claro e escuro

- O tema vive em `data-theme="light|dark"` no `<html>`; todos os tokens trocam por variáveis CSS, então **nada é re-renderizado** na troca.
- `FrappeUIPhx.Plug.Theme` resolve (`?theme=dark` → sessão → cookie → padrão) e o `ThemeHook` leva o valor aos assigns (`@frappe_ui_theme`).
- Botão pronto: `<.theme_switcher current={@frappe_ui_theme} />` (recarrega com `?theme=…`).
- No Tailwind, use o variante `dark:` normalmente (`dark:bg-surface-gray-2`); ele segue `[data-theme="dark"]`.

### Classes de design

| Namespace | Exemplos |
|---|---|
| Superfícies | `bg-surface-white`, `bg-surface-gray-2`, `bg-surface-base` |
| Texto | `text-ink-gray-9`, `text-ink-gray-5`, `text-ink-red-4` |
| Bordas | `border-outline-gray-2` |
| Tipografia | `fui-text-base`, `fui-text-sm-medium`, `fui-text-lg-semibold` (não `text-sm`, para não colidir com o Tailwind do app) |
| Sombras | `shadow-elevation-sm`, `-md`, `-lg` |
| Raio | `rounded-4`, `rounded-5`, `rounded-6` (escala do Frappe) |

As páginas de **Fundamentos** do mostruário (`/f/colors`, `/f/typography`, `/f/radius`, `/f/shadows`, `/f/focus_ring`, `/f/chart_colors`) mostram todos os
valores, gerados da mesma fonte do CSS (`FrappeUIPhx.Foundations`). Para trocar um token, sobrescreva a variável CSS no seu `app.css`, depois do `@import`.

---

## Integrações Ecto e Plug

| Módulo | Para quê |
|---|---|
| `FrappeUIPhx.Ecto.Duration` | `Ecto.Type`: `"1h 30m"`, `"1:30"`, `"90m"` ⇄ segundos (mesmo parser do componente `duration`) |
| `FrappeUIPhx.Ecto.Rating` | `Ecto.ParameterizedType`: avaliação `0..max` (`max: 5`) |
| `FrappeUIPhx.Ecto.StringList` | `Ecto.Type`: lista de textos a partir de `"a, b"` ou de uma lista (tags / `multi_select`) |
| `FrappeUIPhx.Ecto.Options.from_enum/2` | opções de `select` a partir de um `Ecto.Enum` |
| `FrappeUIPhx.ErrorTranslator` | tradução dos erros de changeset (padrão `ErrorTranslator.Default`; troque por Gettext via config) |
| `FrappeUIPhx.Plug.Theme` | resolve `light`/`dark` |
| `FrappeUIPhx.Plug.Static` | serve `frappe_ui.css` direto da dependência, para quem prefere `<link>` a `@import` |
| `FrappeUIPhx.Live.ThemeHook` | `on_mount` que leva o tema da sessão aos assigns |
| `FrappeUIPhx.Toast` | `put_toast(socket, :success, "Salvo!")` |
| `FrappeUIPhx.Markdown` | Markdown restrito → HTML seguro (para exibir o que o `editor` salva) |

```elixir
schema "tarefas" do
  field :tempo, FrappeUIPhx.Ecto.Duration                    # "1h 30m" no formulário, 5400 no banco
  field :nota, FrappeUIPhx.Ecto.Rating, max: 5
  field :etiquetas, FrappeUIPhx.Ecto.StringList              # "a, b" → ["a", "b"]
end
```

---

## Configuração

Tudo é opcional.

```elixir
# config/config.exs
config :frappe_ui_phx,
  texts: %{close: "Close", today: "Today"},     # textos fixos: sobrescritas pontuais
  translator: MyApp.Translator,                 # ou um módulo que traduz (ex.: Gettext)
  error_translator: MyApp.ErrorTranslator,      # tradução de erros de changeset
  icon_resolver: MyApp.Icons,                   # apelidos de ícones do projeto
  toast_sink: MyApp.ToastSink,                  # como o toast chega ao cliente
  dice_bear_base_url: "https://avatares.meuapp.com/10.x"
```

| Chave | Behaviour / formato | Padrão |
|---|---|---|
| `:texts` | mapa `%{chave => texto}`; `FrappeUIPhx.Texts.keys/0` lista as chaves | português |
| `:translator` | `FrappeUIPhx.Translator` — `translate(key, default, bindings)` | sem tradutor |
| `:error_translator` | `FrappeUIPhx.ErrorTranslator` | `ErrorTranslator.Default` |
| `:icon_resolver` | `FrappeUIPhx.IconResolver` — `name(String.t()) :: String.t()` | nome inalterado |
| `:toast_sink` | `FrappeUIPhx.ToastSink` — `deliver(socket, payload)` | `push_event` |
| `:dice_bear_base_url` | `http(s)://…` ou caminho começando por `/` | `https://api.dicebear.com/10.x` |

Um módulo configurado que não implementa o callback falha **na primeira chamada**, com mensagem clara. Um texto passado explicitamente ao
componente (`label=`, `placeholder=`) **sempre vence** o configurado.

---

## Mostruário

```sh
cd showcase
mix setup          # deps, baixa Tailwind/esbuild, gera CSS e JS
mix phx.server     # http://localhost:4010
```

- **Home**: cartão de todos os componentes, com prévia ao vivo, mais Fundamentos e blocos internos.
- **Playground**: um formulário gerado dos `attr` reais altera a prévia e o trecho de uso.
- **Especificação**: tabela de atributos e slots, lida do código.
- **Ícones** (`/icones`): busca por nome ou tag e controles ao vivo de `size`, `color` e `stroke_width`.
- Valor fora do contrato aparece como **"Contrato violado"** na prévia, sem derrubar a página. Tema com `?theme=dark`.

---

## Solução de problemas

| Sintoma | Causa provável | Solução |
|---|---|---|
| Componentes sem estilo | Tailwind não vê as classes da biblioteca | confira `@source "../../deps/frappe_ui_phx/lib"` no `app.css` (caminho relativo ao arquivo) |
| Cores/tokens ausentes (`bg-surface-*` não existe) | `frappe_ui.css` não importado | `@import "../../deps/frappe_ui_phx/priv/static/frappe_ui.css"` depois de `@import "tailwindcss"` |
| Dialog, Dropdown, Toast, PinCode não reagem | hooks *colocated* não registrados | `import {hooks as frappeUiHooks} from "phoenix-colocated/frappe_ui_phx"` e `hooks: {...colocatedHooks, ...frappeUiHooks}`; rode `mix compile` e `mix assets.build` |
| `** (CompileError) imported ...button/1 conflicts with local function` | colisão com o `CoreComponents` | `use FrappeUIPhx, except: [button: 1, icon: 1, list: 1]` |
| `ArgumentError ... fora do contrato` | `variant`/`theme`/`size` inválido | use um dos valores listados na mensagem (veja [`docs/componentes.md`](docs/componentes.md)) |
| `ArgumentError ... id` | componente com estado sem `id` válido | passe `id="…"` com letras, números, `-` e `_` |
| Tema "pisca" ou não troca | dois donos do `data-theme` (script do Phoenix + `Plug.Theme`) | deixe só um; veja o aviso no passo 5 da instalação |
| Ícone não aparece / `ArgumentError ... não existe no catálogo` | nome errado | `FrappeUIPhx.Icons.search("termo")`, ou a página `/icones` do mostruário |
| Avatar DiceBear quebrado | CSP bloqueando a imagem, ou limite da API pública | libere o host em `img-src`; em produção, hospede a API |
| Primeira compilação lenta | ~2.000 componentes de ícone | normal, acontece uma vez (~35 s) |

---

## Limites conhecidos

- **Tipografia**: use `fui-text-*` (não `text-sm`/`text-base`) para não colidir com o Tailwind do seu app.
- **Dialog**: foco preso, `Esc` e backdrop vêm do `<dialog>` nativo.
- **Dropdown/Popover/DatePicker/MultiSelect**: Popover API + CSS Anchor Positioning (navegadores recentes).
- **Charts**: SVG sem animação nem zoom; agregue séries muito grandes no servidor.
- **Editor**: usa `document.execCommand` (legado, mas universal) e guarda **Markdown**; sem tabelas nem imagens.
- **CodeEditor**: sem realce de sintaxe (exigiria CodeMirror e suas dependências).
- **DatePicker**: meses e dias da semana em português.
- Classes de `Tabs`, `Breadcrumbs`, `Tooltip`, `Dialog` e dos componentes de layout foram aproximadas dos tokens, não copiadas 1:1 do original.
- Fora do escopo: busca de dados (`useCall`/`useDoc`/`useList` do Frappe UI) — no LiveView o dado chega pelos assigns.
- **PinCode**: o comportamento de teclado/colar vem de um hook JS; a regra de caracteres tem teste de paridade com o Elixir, mas o hook em si
  precisa ser exercitado num navegador real.

---

## Desenvolvimento

```sh
mix deps.get
mix quality        # format --check-formatted, compile --warnings-as-errors, test --cover (mínimo 90%), deps.audit
mix test --include node   # inclui os testes de costura que executam Node (tokens, ícones, regras de JS)
mix tokens.sync    # vendor/frappe-ui-tokens (frappe-ui 1.1.0, MIT) -> priv/static/frappe_ui.css e priv/foundations.json
npm install && mix icons.sync     # lucide-static -> priv/icons.json (determinístico)
cd showcase && mix run scripts/gen_reference.exs     # regenera docs/componentes.md a partir do código
```

Os tokens são **dados vendorizados** do pacote `frappe-ui` (sem dependências npm no pacote). Os ícones vêm do `lucide-static` fixado em versão exata.
Mais sobre contratos (DbC), SOLID, os testes de costura e a revisão de arquitetura: [`docs/arquitetura.md`](docs/arquitetura.md).
As mudanças planejadas e o histórico de requisitos estão em `openspec/`.

## Licença

MIT (veja `LICENSE`). Contém tokens e markup derivados do [Frappe UI](https://github.com/frappe/frappe-ui) (MIT, © Frappe Technologies Pvt. Ltd.) e
ícones do [Lucide](https://lucide.dev) (ISC, com ícones derivados do Feather, MIT). Os avisos completos estão em
[`THIRD_PARTY_LICENSES.md`](THIRD_PARTY_LICENSES.md). O DiceBear não é distribuído aqui (só URLs da API); veja a seção sobre licenças dos estilos acima.
