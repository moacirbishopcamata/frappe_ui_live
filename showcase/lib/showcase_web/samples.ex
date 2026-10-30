defmodule ShowcaseWeb.Samples do
  @moduledoc """
  Como cada componente é exibido no playground: valores iniciais de amostra,
  conteúdo de slots e composições que precisam de contexto (diálogo com botão
  de abrir, menu com itens, abas, listas com estado no servidor...).

  `render/3` devolve o HTML já avaliado: uma violação de contrato (por exemplo
  `variant` inválido digitado no formulário) vira `{:error, mensagem}` em vez de
  derrubar o LiveView, mostrando o `Contract` em ação.
  """
  use Phoenix.Component
  use FrappeUILive

  alias Phoenix.LiveView.JS

  @initial %{
    button: %{label: "Salvar"},
    badge: %{label: "Novo"},
    alert: %{title: "Atenção"},
    progress: %{value: 40},
    avatar: %{label: "Ana"},
    icon: %{name: "plus"},
    tooltip: %{text: "Dica útil"},
    dialog: %{id: "demo-dialog", title: "Confirmar ação"},
    bottom_sheet: %{id: "demo-sheet", title: "Filtros"},
    settings_dialog: %{id: "demo-settings", active: "conta"},
    keyboard_shortcuts_dialog: %{id: "demo-shortcuts"},
    dropdown: %{id: "demo-dropdown", label: "Ações"},
    popover: %{id: "demo-popover"},
    context_menu: %{id: "demo-context"},
    tabs: %{id: "demo-tabs", active: "geral"},
    tab_buttons: %{active: "dia"},
    sidebar: %{active: "inicio"},
    sidebar_rail: %{active: "inicio"},
    mobile_shell: %{active: "inicio"},
    form_control: %{label: "Nome"},
    page_header: %{title: "Pedidos", subtitle: "Todos os pedidos"},
    password: %{id: "demo-senha"},
    combobox: %{id: "demo-combobox"},
    multi_select: %{id: "demo-multi"},
    date_picker: %{id: "demo-date"},
    item_list_row: %{title: "Pedido #42", subtitle: "Aguardando pagamento"},
    list: %{id: "demo-list"},
    tree: %{id: "demo-tree"},
    sortable: %{id: "demo-sortable"},
    number_card: %{label: "Receita"},
    chart_card: %{title: "Vendas por mês"},
    editor: %{id: "demo-editor"},
    code_editor: %{id: "demo-code", language: "json"}
  }

  @months ~w(Jan Fev Mar Abr Mai Jun)
  @fruits [
    {"Maçã", "maca"},
    {"Banana", "banana"},
    {"Uva", "uva"},
    {"Laranja", "laranja"},
    {"Manga", "manga"}
  ]

  @doc "Valores de amostra para atributos obrigatórios/ilustrativos do componente."
  @spec initial(atom()) :: map()
  def initial(id), do: Map.get(@initial, id, %{})

  @doc "Estado de demonstração mantido no servidor (listas, árvore, ordenação)."
  @spec demo_state() :: map()
  def demo_state do
    %{
      rows: [
        %{id: 1, nome: "Ana", papel: "Admin"},
        %{id: 2, nome: "Bia", papel: "Editora"},
        %{id: 3, nome: "Caio", papel: "Leitor"}
      ],
      selected: [2],
      expanded: [1],
      tree_selected: 2,
      items: [%{id: 1, nome: "Primeiro"}, %{id: 2, nome: "Segundo"}, %{id: 3, nome: "Terceiro"}]
    }
  end

  @doc "HTML do componente com os atributos atuais, ou o erro de contrato."
  @spec render(map(), map(), map()) :: {:ok | :live, term()} | {:error, String.t()}
  def render(spec, attrs, extras \\ %{}) do
    case sample(spec, attrs, extras) do
      # LiveComponents precisam do contexto do LiveView: seguem sem pré-avaliação
      {:live, rendered} ->
        {:live, rendered}

      rendered ->
        html = rendered |> Phoenix.HTML.Safe.to_iodata() |> IO.iodata_to_binary()
        {:ok, Phoenix.HTML.raw(html)}
    end
  rescue
    error in ArgumentError -> {:error, Exception.message(error)}
  end

  # ---- formulários ---------------------------------------------------------------

  defp sample(%{id: :text_input}, a, _) do
    assigns = %{a: a}
    ~H|<.text_input name="demo" value="" placeholder="Digite algo…" {@a} />|
  end

  defp sample(%{id: :textarea}, a, _) do
    assigns = %{a: a}
    ~H|<.textarea name="demo" value="" placeholder="Escreva…" {@a} />|
  end

  defp sample(%{id: :password}, a, _) do
    assigns = %{a: a}
    ~H|<.password name="senha" {@a} />|
  end

  defp sample(%{id: :select}, a, _) do
    assigns = %{a: a}
    ~H|<.select
  name="demo"
  value="b"
  options={[{"Opção A", "a"}, {"Opção B", "b"}, {"Opção C", "c"}]}
  {@a}
/>|
  end

  defp sample(%{id: :combobox}, a, _) do
    assigns = %{a: a}
    ~H|<.combobox name="fruta" value="uva" options={fruits()} {@a} />|
  end

  defp sample(%{id: :multi_select}, a, _) do
    assigns = %{a: a}
    ~H|<.multi_select name="frutas" value={["maca", "uva"]} options={fruits()} {@a} />|
  end

  defp sample(%{id: :checkbox}, a, _) do
    assigns = %{a: a}
    ~H|<.checkbox name="demo" label="Aceito os termos" {@a} />|
  end

  defp sample(%{id: :switch}, a, _) do
    assigns = %{a: a}
    ~H|<.switch name="demo" label="Receber notificações" {@a} />|
  end

  defp sample(%{id: :radio_group}, a, _) do
    assigns = %{a: a}
    ~H|<.radio_group
  name="plano"
  value="pro"
  label="Plano"
  options={[{"Básico", "basico"}, {"Pro", "pro"}, {"Equipe", "equipe"}]}
  {@a}
/>|
  end

  defp sample(%{id: :slider}, a, _) do
    assigns = %{a: a}
    ~H|<.slider name="vol" value={40} show_value {@a} />|
  end

  defp sample(%{id: :rating}, a, _) do
    assigns = %{a: a}
    ~H|<.rating name="nota" value={3} {@a} />|
  end

  defp sample(%{id: :date_picker}, a, _) do
    # o id vira CSS inline: valida a pré-condição antes (o LiveComponent não pode ser pré-avaliado)
    FrappeUILive.Components.Anchor.valid_id!(a.id, "date_picker")
    assigns = %{a: a}
    {:live, ~H|<.date_picker name="data" value="2026-03-09" {@a} />|}
  end

  defp sample(%{id: :time_picker}, a, _) do
    assigns = %{a: a}
    ~H|<.time_picker name="hora" value="08:30" {@a} />|
  end

  defp sample(%{id: :duration}, a, _) do
    assigns = %{a: a}
    ~H|<.duration name="tempo" value={5400} {@a} />|
  end

  defp sample(%{id: :form_label}, a, _) do
    assigns = %{a: a}
    ~H|<.form_label for="demo" {@a}>Rótulo do campo</.form_label>|
  end

  defp sample(%{id: :form_control}, a, _) do
    assigns = %{a: a}
    ~H|<.form_control field={demo_field()} options={[{"Opção A", "a"}, {"Opção B", "b"}]} {@a} />|
  end

  defp sample(%{id: :file_uploader}, a, %{upload: upload}) do
    assigns = %{a: a, upload: upload}

    ~H"""
    <form id="upload-form" phx-change="validate-upload" phx-submit="noop">
      <.file_uploader upload={@upload} on_cancel="cancel-upload" {@a}>
        <:hint>PNG, JPG ou PDF — até 2 arquivos</:hint>
      </.file_uploader>
    </form>
    """
  end

  # ---- feedback ----------------------------------------------------------------

  defp sample(%{id: :alert}, a, _) do
    assigns = %{a: a}
    ~H|<.alert {@a}>Descrição do alerta: o que aconteceu e o que fazer.</.alert>|
  end

  defp sample(%{id: :error_message}, a, _) do
    assigns = %{a: a}
    ~H|<.error_message message={["Campo obrigatório", "Mínimo de 3 caracteres"]} {@a} />|
  end

  defp sample(%{id: :keyboard_shortcut}, a, _) do
    assigns = %{a: a}
    ~H|<.keyboard_shortcut keys={["Ctrl", "K"]} {@a} />|
  end

  defp sample(%{id: :item_list_row}, a, _) do
    assigns = %{a: a}
    ~H|<.item_list_row {@a}>
  <:icon><.icon name="file-text" /></:icon><:actions>
    <.button label="Abrir" size={:xs} />
  </:actions>
</.item_list_row>|
  end

  defp sample(%{id: :saved_indicator}, a, extras) do
    assigns = %{a: a, at: extras[:saved_at]}

    ~H"""
    <div class="flex items-center gap-3">
      <.button label="Salvar" variant={:solid} phx-click="saved" />
      <.saved_indicator at={@at} {@a} />
    </div>
    <p class="fui-text-sm text-ink-gray-5 mt-3">
      Cada clique devolve um valor novo; o <code>:key</code>
      remonta o elemento e reinicia a animação, sem timer.
    </p>
    """
  end

  defp sample(%{id: :toast_container}, _a, _) do
    assigns = %{}

    ~H"""
    <div class="flex flex-wrap gap-2">
      <.button label="Info" phx-click="toast" phx-value-kind="info" />
      <.button label="Sucesso" theme={:green} phx-click="toast" phx-value-kind="success" />
      <.button label="Aviso" phx-click="toast" phx-value-kind="warning" />
      <.button label="Erro" theme={:red} phx-click="toast" phx-value-kind="error" />
    </div>
    <p class="fui-text-sm text-ink-gray-5 mt-3">
      O toast sai do servidor por <code>FrappeUILive.Toast.put_toast/4</code>; o container fica no layout desta página.
    </p>
    """
  end

  # ---- overlays ----------------------------------------------------------------

  defp sample(%{id: :dialog}, a, _) do
    assigns = %{a: a}

    ~H"""
    <.button label="Abrir diálogo" variant={:solid} phx-click={show_dialog(@a.id)} />
    <.dialog {@a}>
      Este conteúdo é renderizado no servidor; o &lt;dialog&gt; nativo cuida de foco, Esc e backdrop.
      <:actions>
        <.button label="Cancelar" phx-click={hide_dialog(@a.id)} />
        <.button label="Confirmar" variant={:solid} phx-click={hide_dialog(@a.id)} />
      </:actions>
    </.dialog>
    """
  end

  defp sample(%{id: :bottom_sheet}, a, _) do
    assigns = %{a: a}

    ~H"""
    <.button label="Abrir folha inferior" variant={:solid} phx-click={show_dialog(@a.id)} />
    <.bottom_sheet {@a}>
      Folha ancorada embaixo, ideal para telas estreitas.
      <:actions><.button label="Fechar" phx-click={hide_dialog(@a.id)} /></:actions>
    </.bottom_sheet>
    """
  end

  defp sample(%{id: :settings_dialog}, a, _) do
    assigns = %{a: a}

    ~H"""
    <.button label="Abrir configurações" variant={:solid} phx-click={show_dialog(@a.id)} />
    <.settings_dialog {@a}>
      <:tab id="conta" label="Conta" icon="user" click={JS.push("pg_tab", value: %{tab: "conta"})} />
      <:tab id="avisos" label="Avisos" icon="bell" click={JS.push("pg_tab", value: %{tab: "avisos"})} />
      Seção <strong>{@a.active}</strong>: o servidor decide qual conteúdo mostrar.
    </.settings_dialog>
    """
  end

  defp sample(%{id: :keyboard_shortcuts_dialog}, a, _) do
    assigns = %{a: a}

    ~H"""
    <.button label="Ver atalhos" variant={:solid} phx-click={show_dialog(@a.id)} />
    <.keyboard_shortcuts_dialog
      shortcuts={[
        %{label: "Buscar", keys: ["Ctrl", "K"]},
        %{label: "Ajuda", keys: ["?"]},
        %{label: "Salvar", keys: ["Ctrl", "S"]}
      ]}
      {@a}
    />
    """
  end

  defp sample(%{id: :dropdown}, a, _) do
    assigns = %{a: a}

    ~H"""
    <.dropdown {@a}>
      <:item label="Editar" icon="pencil" click="demo" />
      <:item label="Abrir página" navigate="/" />
      <:item label="Excluir" icon="trash-2" theme={:red} click="demo" />
    </.dropdown>
    """
  end

  defp sample(%{id: :popover}, a, _) do
    assigns = %{a: a}

    ~H"""
    <.popover {@a}>
      <:trigger><.button label="Abrir popover" icon_right="chevron-down" /></:trigger>
      <p class="fui-text-base-medium text-ink-gray-9">Conteúdo livre</p>
      <p class="fui-text-sm text-ink-gray-6 mt-1">Fecha com Esc ou clicando fora (Popover API).</p>
    </.popover>
    """
  end

  defp sample(%{id: :context_menu}, a, _) do
    assigns = %{a: a}

    ~H"""
    <.context_menu
      {@a}
      class="border-outline-gray-3 text-ink-gray-5 rounded-5 border border-dashed p-8 text-center"
    >
      Clique com o botão direito aqui <:item label="Copiar" icon="copy" click="demo" />
      <:item label="Compartilhar" icon="share-2" click="demo" />
      <:item label="Apagar" icon="trash-2" theme={:red} click="demo" />
    </.context_menu>
    """
  end

  defp sample(%{id: :hover_card}, a, _) do
    assigns = %{a: a}

    ~H"""
    <div class="py-8">
      <.hover_card {@a}>
        <:trigger><.badge label="@ana" theme={:blue} /></:trigger>
        <div class="flex items-center gap-2">
          <.avatar label="Ana" /><div>
            <p class="fui-text-base-medium">Ana Souza</p><p class="fui-text-sm text-ink-gray-5">
              Administradora
            </p>
          </div>
        </div>
      </.hover_card>
    </div>
    """
  end

  defp sample(%{id: :tooltip}, a, _) do
    assigns = %{a: a}
    ~H|<div class="py-8 text-center">
  <.tooltip {@a}><.button label="Passe o mouse ou foque" /></.tooltip>
</div>|
  end

  # ---- navegação ---------------------------------------------------------------

  defp sample(%{id: :tabs}, a, _) do
    assigns = %{a: a}

    ~H"""
    <.tabs {@a}>
      <:tab id="geral" label="Geral" click={JS.push("pg_tab", value: %{tab: "geral"})} />
      <:tab id="itens" label="Itens" icon="plus" click={JS.push("pg_tab", value: %{tab: "itens"})} />
      <:tab id="config" label="Configurações" click={JS.push("pg_tab", value: %{tab: "config"})} />
      O painel da aba <strong>{@a.active}</strong>
      — a aba ativa é um assign do servidor.
    </.tabs>
    """
  end

  defp sample(%{id: :tab_buttons}, a, _) do
    assigns = %{a: a}

    ~H"""
    <.tab_buttons {@a}>
      <:button id="dia" label="Dia" click={JS.push("pg_tab", value: %{tab: "dia"})} />
      <:button id="semana" label="Semana" click={JS.push("pg_tab", value: %{tab: "semana"})} />
      <:button id="mes" label="Mês" icon="calendar" click={JS.push("pg_tab", value: %{tab: "mes"})} />
    </.tab_buttons>
    """
  end

  defp sample(%{id: :breadcrumbs}, _a, _) do
    assigns = %{}
    ~H|<.breadcrumbs>
  <:item label="Início" navigate="/" /><:item label="Pedidos" navigate="/" /><:item label="#42" />
</.breadcrumbs>|
  end

  defp sample(%{id: :page_header}, a, _) do
    assigns = %{a: a}

    ~H"""
    <.page_header {@a}>
      <:breadcrumbs>
        <.breadcrumbs><:item label="Início" navigate="/" /><:item label="Pedidos" /></.breadcrumbs>
      </:breadcrumbs>
      <:actions><.button label="Novo" variant={:solid} icon_left="plus" /></:actions>
    </.page_header>
    """
  end

  defp sample(%{id: :sidebar}, a, _) do
    assigns = %{a: a}

    ~H"""
    <div class="border-outline-gray-2 h-72 overflow-hidden rounded-5 border">
      <.sidebar {@a}>
        <:header><span class="fui-text-lg-semibold">Minha app</span></:header>
        <:item
          id="inicio"
          label="Início"
          icon="house"
          click={JS.push("pg_tab", value: %{tab: "inicio"})}
        />
        <:item
          id="pedidos"
          label="Pedidos"
          icon="file-text"
          click={JS.push("pg_tab", value: %{tab: "pedidos"})}
        />
        <:item
          id="config"
          label="Configurações"
          icon="settings"
          click={JS.push("pg_tab", value: %{tab: "config"})}
        />
        <:footer><span class="fui-text-sm text-ink-gray-5">v0.1</span></:footer>
      </.sidebar>
    </div>
    """
  end

  defp sample(%{id: :sidebar_rail}, a, _) do
    assigns = %{a: a}

    ~H"""
    <div class="border-outline-gray-2 h-72 w-12 overflow-hidden rounded-5 border">
      <.sidebar_rail {@a}>
        <:item
          id="inicio"
          label="Início"
          icon="house"
          click={JS.push("pg_tab", value: %{tab: "inicio"})}
        />
        <:item
          id="pedidos"
          label="Pedidos"
          icon="file-text"
          click={JS.push("pg_tab", value: %{tab: "pedidos"})}
        />
        <:item
          id="config"
          label="Configurações"
          icon="settings"
          click={JS.push("pg_tab", value: %{tab: "config"})}
        />
      </.sidebar_rail>
    </div>
    """
  end

  defp sample(%{id: :desktop_shell}, a, _) do
    assigns = %{a: a}

    ~H"""
    <div class="border-outline-gray-2 h-72 overflow-hidden rounded-5 border">
      <.desktop_shell class="h-72!" {@a}>
        <:sidebar>
          <.sidebar active="inicio">
            <:item id="inicio" label="Início" icon="house" click="demo" /><:item
              id="pedidos"
              label="Pedidos"
              icon="file-text"
              click="demo"
            />
          </.sidebar>
        </:sidebar>
        <.page_header title="Conteúdo principal" />
        <p class="p-5">A casca compõe sidebar + área rolável.</p>
      </.desktop_shell>
    </div>
    """
  end

  defp sample(%{id: :mobile_shell}, a, _) do
    assigns = %{a: a}

    ~H"""
    <div class="border-outline-gray-2 mx-auto h-80 w-72 overflow-hidden rounded-5 border">
      <.mobile_shell class="h-80!" {@a}>
        <:header><span class="fui-text-lg-semibold">Mobile</span></:header>
        <:nav
          id="inicio"
          label="Início"
          icon="house"
          click={JS.push("pg_tab", value: %{tab: "inicio"})}
        />
        <:nav
          id="buscar"
          label="Buscar"
          icon="search"
          click={JS.push("pg_tab", value: %{tab: "buscar"})}
        />
        <:nav
          id="perfil"
          label="Perfil"
          icon="user"
          click={JS.push("pg_tab", value: %{tab: "perfil"})}
        />
        <p class="p-4">Aba: <strong>{@a.active}</strong></p>
      </.mobile_shell>
    </div>
    """
  end

  defp sample(%{id: :scroll_area}, a, _) do
    assigns = %{a: a}

    ~H"""
    <.scroll_area {@a} class="border-outline-gray-2 max-h-32 rounded-5 border p-3">
      <p :for={n <- 1..20} class="fui-text-base text-ink-gray-7">Linha {n} da área rolável</p>
    </.scroll_area>
    """
  end

  # ---- dados -------------------------------------------------------------------

  defp sample(%{id: :list}, a, %{demo: demo}) do
    assigns = %{a: a, demo: demo}

    ~H"""
    <.list rows={@demo.rows} selected={@demo.selected} on_select="sel" on_drop="reorder" {@a}>
      <:col :let={r} label="Nome">{r.nome}</:col>
      <:col :let={r} label="Papel"><.badge label={r.papel} /></:col>
      <:action :let={r}>
        <.button label="Ver" size={:xs} phx-click="demo" phx-value-id={r.id} />
      </:action>
    </.list>
    <p class="fui-text-sm text-ink-gray-5 mt-2">
      Arraste as linhas; o servidor reordena. Selecionados: {Enum.join(@demo.selected, ", ")}
    </p>
    """
  end

  defp sample(%{id: :tree}, a, %{demo: demo}) do
    assigns = %{a: a, demo: demo, nodes: tree_nodes()}

    ~H"""
    <.tree
      nodes={@nodes}
      expanded={@demo.expanded}
      selected={@demo.tree_selected}
      on_toggle="tog"
      on_select="tsel"
      {@a}
    />
    """
  end

  defp sample(%{id: :sortable}, a, %{demo: demo}) do
    assigns = %{a: a, demo: demo}

    ~H"""
    <.sortable items={@demo.items} on_drop="reorder_items" class="space-y-1" {@a}>
      <:item :let={item}>
        <div class="border-outline-gray-2 bg-surface-base fui-text-base flex items-center gap-2 rounded-5 border px-3 py-2">
          <.icon name="grip-vertical" class="text-ink-gray-4 size-4" />{item.nome}
        </div>
      </:item>
    </.sortable>
    """
  end

  # ---- charts ------------------------------------------------------------------

  defp sample(%{id: :bar_chart}, a, _) do
    assigns = %{a: a}
    ~H|<.bar_chart categories={months()} series={series()} {@a} />|
  end

  defp sample(%{id: :line_chart}, a, _) do
    assigns = %{a: a}
    ~H|<.line_chart categories={months()} series={series()} {@a} />|
  end

  defp sample(%{id: :area_chart}, a, _) do
    assigns = %{a: a}
    ~H|<.area_chart categories={months()} series={series()} {@a} />|
  end

  defp sample(%{id: :donut_chart}, a, _) do
    assigns = %{a: a}
    ~H|<.donut_chart data={share()} {@a} />|
  end

  defp sample(%{id: :percentage_bar_chart}, a, _) do
    assigns = %{a: a}
    ~H|<.percentage_bar_chart data={share()} {@a} />|
  end

  defp sample(%{id: :funnel_chart}, a, _) do
    assigns = %{a: a}
    ~H|<.funnel_chart
  steps={[
    %{label: "Visitas", value: 1000},
    %{label: "Cadastros", value: 420},
    %{label: "Compras", value: 130}
  ]}
  {@a}
/>|
  end

  defp sample(%{id: :heatmap_chart}, a, _) do
    assigns = %{a: a}
    ~H|<.heatmap_chart
  rows={["Seg", "Ter", "Qua"]}
  cols={["8h", "12h", "16h", "20h"]}
  values={[[1, 4, 9, 3], [2, 8, 6, 2], [0, 3, 7, 5]]}
  {@a}
/>|
  end

  defp sample(%{id: :calendar_heatmap_chart}, a, _) do
    assigns = %{a: a}
    ~H|<.calendar_heatmap_chart data={activity()} {@a} />|
  end

  defp sample(%{id: :scatter_chart}, a, _) do
    assigns = %{a: a}
    ~H|<.scatter_chart
  series={[
    %{name: "Lote A", points: [{1, 3}, {2, 5}, {3, 4}, {4, 8}, {5, 7}]},
    %{name: "Lote B", points: [{1, 1}, {2, 2}, {3, 6}, {4, 3}, {5, 9}]}
  ]}
  {@a}
/>|
  end

  defp sample(%{id: :sankey_chart}, a, _) do
    assigns = %{a: a}
    ~H|<.sankey_chart
  links={[
    %{source: "Site", target: "Carrinho", value: 60},
    %{source: "App", target: "Carrinho", value: 40},
    %{source: "Carrinho", target: "Compra", value: 70},
    %{source: "Carrinho", target: "Abandono", value: 30}
  ]}
  {@a}
/>|
  end

  defp sample(%{id: :number_card}, a, _) do
    assigns = %{a: a}
    ~H|<.number_card value="R$ 48.230" delta={12.5} {@a} />|
  end

  defp sample(%{id: :chart_card}, a, _) do
    assigns = %{a: a}
    ~H|<.chart_card {@a} subtitle="Primeiro semestre">
  <:actions><.button label="Exportar" size={:xs} /></:actions><.bar_chart
    categories={months()}
    series={series()}
  />
</.chart_card>|
  end

  defp sample(%{id: :chart_legend}, a, _) do
    assigns = %{a: a}
    ~H|<.chart_legend
  items={[
    %{label: "Receita", color: "var(--surface-blue-6)"},
    %{label: "Custo", color: "var(--surface-green-6)"}
  ]}
  {@a}
/>|
  end

  defp sample(%{id: :chart_tooltip}, a, _) do
    assigns = %{a: a}
    ~H|<svg viewBox="0 0 200 60" class="w-full max-w-xs"><g class="group" tabindex="0">
  <circle cx="100" cy="40" r="6" style="fill: var(--surface-blue-6)" /><.chart_tooltip
    x={100.0}
    y={36.0}
    text="Mar · A: 30"
    {@a}
  />
</g></svg><p class="fui-text-sm text-ink-gray-5">Passe o mouse ou foque no ponto.</p>|
  end

  defp sample(%{id: :chart_frame}, a, _) do
    assigns = %{a: a}
    ~H|<.chart_frame {@a}>
  <div class="bg-surface-gray-2 fui-text-base text-ink-gray-6 flex h-24 items-center justify-center rounded-5">
    Gráfico aqui (estado :ready)
  </div>
</.chart_frame>|
  end

  # ---- editores ----------------------------------------------------------------

  defp sample(%{id: :editor}, a, _) do
    assigns = %{a: a}
    ~H|<.editor name="texto" value={markdown_sample()} {@a} />|
  end

  defp sample(%{id: :code_editor}, a, _) do
    assigns = %{a: a}
    ~H|<.code_editor name="codigo" value={code_sample()} {@a} />|
  end

  # Demais componentes: sem slots obrigatórios nem contexto.
  defp sample(%{module: module, fun: fun}, a, _),
    do: apply(module, fun, [Map.put(a, :__changed__, nil)])

  defp markdown_sample, do: "## Título

Texto com **negrito** e _itálico_.

- item um
- item dois"
  defp code_sample, do: "{
  \"nome\": \"frappe_ui_live\",
  \"versao\": \"0.1.0\"
}"

  defp fruits, do: @fruits
  defp months, do: @months

  defp series,
    do: [
      %{name: "Receita", data: [12, 19, 15, 25, 22, 30]},
      %{name: "Custo", data: [8, 11, 10, 14, 13, 17]}
    ]

  defp share,
    do: [%{label: "Web", value: 55}, %{label: "App", value: 30}, %{label: "Loja", value: 15}]

  defp activity do
    today = Date.utc_today()

    for offset <- 0..120,
        rem(offset * 7, 5) != 0,
        into: %{},
        do: {Date.add(today, -offset), rem(offset * 13, 9) + 1}
  end

  defp tree_nodes do
    [
      %{
        id: 1,
        label: "Projetos",
        icon: "folder",
        children: [
          %{id: 2, label: "Site", icon: "file-text"},
          %{
            id: 3,
            label: "App",
            icon: "folder",
            children: [%{id: 4, label: "iOS", icon: "file-text"}]
          }
        ]
      },
      %{id: 5, label: "Arquivos soltos", icon: "file"}
    ]
  end

  defp demo_field, do: to_form(%{"nome" => ""}, as: :demo)[:nome]
end
