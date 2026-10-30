defmodule ShowcaseWeb.Samples do
  @moduledoc """
  Como cada componente é exibido no playground: valores iniciais de amostra,
  conteúdo de slots e composições que precisam de contexto (diálogo com botão
  de abrir, menu com itens, abas...).

  `render/2` devolve o HTML já avaliado: uma violação de contrato (por exemplo
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
    dropdown: %{id: "demo-dropdown", label: "Ações"},
    tabs: %{id: "demo-tabs", active: "geral"},
    form_control: %{label: "Nome"},
    page_header: %{title: "Pedidos", subtitle: "Todos os pedidos"}
  }

  @doc "Valores de amostra para atributos obrigatórios/ilustrativos do componente."
  @spec initial(atom()) :: map()
  def initial(id), do: Map.get(@initial, id, %{})

  @doc "HTML do componente com os atributos atuais, ou o erro de contrato."
  @spec render(map(), map()) :: {:ok, Phoenix.HTML.safe()} | {:error, String.t()}
  def render(spec, attrs) do
    html = spec |> sample(attrs) |> Phoenix.HTML.Safe.to_iodata() |> IO.iodata_to_binary()
    {:ok, Phoenix.HTML.raw(html)}
  rescue
    error in ArgumentError -> {:error, Exception.message(error)}
  end

  # ---- composições com contexto ---------------------------------------------

  defp sample(%{id: :dialog}, a) do
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

  defp sample(%{id: :dropdown}, a) do
    assigns = %{a: a}

    ~H"""
    <.dropdown {@a}>
      <:item label="Editar" icon="plus" click="demo" />
      <:item label="Abrir página" navigate="/" />
      <:item label="Excluir" theme={:red} click="demo" />
    </.dropdown>
    """
  end

  defp sample(%{id: :tabs}, a) do
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

  defp sample(%{id: :breadcrumbs}, _a) do
    assigns = %{}

    ~H"""
    <.breadcrumbs>
      <:item label="Início" navigate="/" />
      <:item label="Pedidos" navigate="/" />
      <:item label="#42" />
    </.breadcrumbs>
    """
  end

  defp sample(%{id: :page_header}, a) do
    assigns = %{a: a}

    ~H"""
    <.page_header {@a}>
      <:breadcrumbs>
        <.breadcrumbs>
          <:item label="Início" navigate="/" />
          <:item label="Pedidos" />
        </.breadcrumbs>
      </:breadcrumbs>
      <:actions><.button label="Novo" variant={:solid} icon_left="plus" /></:actions>
    </.page_header>
    """
  end

  defp sample(%{id: :tooltip}, a) do
    assigns = %{a: a}

    ~H"""
    <div class="py-8 text-center">
      <.tooltip {@a}><.button label="Passe o mouse ou foque" /></.tooltip>
    </div>
    """
  end

  defp sample(%{id: :toast_container}, _a) do
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

  # ---- controles com valores de amostra ---------------------------------------

  defp sample(%{id: :text_input}, a) do
    assigns = %{a: a}
    ~H|<.text_input name="demo" value="" placeholder="Digite algo…" {@a} />|
  end

  defp sample(%{id: :textarea}, a) do
    assigns = %{a: a}
    ~H|<.textarea name="demo" value="" placeholder="Escreva…" {@a} />|
  end

  defp sample(%{id: :select}, a) do
    assigns = %{a: a}
    ~H|<.select
  name="demo"
  value="b"
  options={[{"Opção A", "a"}, {"Opção B", "b"}, {"Opção C", "c"}]}
  {@a}
/>|
  end

  defp sample(%{id: :checkbox}, a) do
    assigns = %{a: a}
    ~H|<.checkbox name="demo" label="Aceito os termos" {@a} />|
  end

  defp sample(%{id: :switch}, a) do
    assigns = %{a: a}
    ~H|<.switch name="demo" label="Receber notificações" {@a} />|
  end

  defp sample(%{id: :form_control}, a) do
    assigns = %{a: a, field: demo_field()}
    ~H|<.form_control field={@field} options={[{"Opção A", "a"}, {"Opção B", "b"}]} {@a} />|
  end

  defp sample(%{id: :form_label}, a) do
    assigns = %{a: a}
    ~H|<.form_label for="demo" {@a}>Rótulo do campo</.form_label>|
  end

  defp sample(%{id: :error_message}, a) do
    assigns = %{a: a}
    ~H|<.error_message message={["Campo obrigatório", "Mínimo de 3 caracteres"]} {@a} />|
  end

  defp sample(%{id: :alert}, a) do
    assigns = %{a: a}
    ~H|<.alert {@a}>Descrição do alerta: o que aconteceu e o que fazer.</.alert>|
  end

  # Demais componentes: sem slots obrigatórios nem contexto.
  defp sample(%{module: module, fun: fun}, a) do
    apply(module, fun, [Map.put(a, :__changed__, nil)])
  end

  defp demo_field, do: to_form(%{"nome" => ""}, as: :demo)[:nome]
end
