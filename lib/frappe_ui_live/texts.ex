defmodule FrappeUILive.Texts do
  @moduledoc """
  Textos fixos da biblioteca (rótulos de acessibilidade, mensagens auxiliares), em
  português por padrão, **sobrescrevíveis sem copiar componentes**.

  Ordem de resolução de `t/2`:

    1. `config :frappe_ui_live, :translator, MeuApp.Translator` — módulo com o
       behaviour `FrappeUILive.Translator` (ex.: delega ao Gettext);
    2. `config :frappe_ui_live, :texts, %{close: "Close"}` — sobrescritas pontuais;
    3. o texto padrão em português.

  Interpolação: `%{nome}` é trocado pelo valor em `bindings`. Chave desconhecida é bug
  do chamador e levanta `KeyError`.
  """

  @defaults %{
    close: "Fechar",
    loading: "Carregando",
    loading_text: "Carregando…",
    toggle_password: "Mostrar ou ocultar a senha",
    rating: "Avaliação",
    rating_item: "%{n} de %{max}",
    editor_placeholder: "Escreva aqui…",
    formatting: "Formatação",
    bold: "Negrito",
    italic: "Itálico",
    heading: "Título",
    list: "Lista",
    ordered_list: "Lista numerada",
    code: "Código",
    link: "Link",
    link_prompt: "Endereço do link (https://…)",
    select_date: "Selecione a data",
    prev_month: "Mês anterior",
    next_month: "Próximo mês",
    today: "Hoje",
    clear: "Limpar",
    saved: "Salvo",
    select: "Selecione…",
    search: "Buscar…",
    no_results: "Nenhum resultado",
    breadcrumbs: "Trilha de navegação",
    collapse: "Recolher",
    expand: "Expandir",
    go_back_to: "Voltar para %{label}",
    command_placeholder: "Buscar comandos…",
    command_empty: "Nenhum comando encontrado.",
    command_palette: "Paleta de comandos",
    empty_list: "Nada por aqui.",
    actions: "Ações",
    reorder: "Reordenar",
    select_row: "Selecionar linha",
    main_nav: "Principal",
    theme: "Tema",
    theme_light: "Claro",
    theme_dark: "Escuro",
    settings: "Configurações",
    shortcuts: "Atalhos de teclado",
    chart_empty: "Sem dados para exibir.",
    chart_error_title: "Não foi possível carregar o gráfico",
    vs_previous: "vs. período anterior",
    chart_bar: "Gráfico de barras",
    chart_line: "Gráfico de linhas",
    chart_area: "Gráfico de área",
    chart_donut: "Gráfico de rosca",
    chart_percentage: "Barra percentual",
    chart_funnel: "Gráfico de funil",
    chart_heatmap: "Mapa de calor",
    chart_calendar: "Calendário de atividade",
    chart_scatter: "Gráfico de dispersão",
    chart_sankey: "Diagrama de Sankey",
    upload_label: "Arraste arquivos ou clique para enviar",
    upload_cancel: "Cancelar %{name}",
    upload_too_large: "Arquivo maior que o permitido.",
    upload_not_accepted: "Tipo de arquivo não aceito.",
    upload_too_many_files: "Há arquivos demais selecionados.",
    upload_failure: "Falha no envio. Tente novamente.",
    upload_error: "Erro no envio (%{reason})."
  }

  @doc "Chaves conhecidas."
  @spec keys() :: [atom()]
  def keys, do: Map.keys(@defaults)

  @doc "Texto padrão (português) de `key`."
  @spec default(atom()) :: String.t()
  def default(key), do: Map.fetch!(@defaults, key)

  @doc "Texto de `key` conforme a configuração, com `%{nome}` interpolado de `bindings`."
  @spec t(atom(), keyword()) :: String.t()
  def t(key, bindings \\ []) when is_atom(key) do
    default = default(key)

    text =
      case Application.get_env(:frappe_ui_live, :translator) do
        nil ->
          override(key, default)

        _module ->
          FrappeUILive.Config.module!(:translator, nil, :translate, 3).translate(
            key,
            override(key, default),
            bindings
          )
      end

    interpolate(text, bindings)
  end

  defp override(key, default) do
    :frappe_ui_live |> Application.get_env(:texts, %{}) |> Map.get(key, default)
  end

  defp interpolate(text, bindings) do
    Enum.reduce(bindings, text, fn {name, value}, acc ->
      String.replace(acc, "%{#{name}}", to_string(value))
    end)
  end
end

defmodule FrappeUILive.Translator do
  @moduledoc """
  Contrato para traduzir os textos fixos da biblioteca.

      defmodule MeuApp.Translator do
        @behaviour FrappeUILive.Translator
        @impl true
        def translate(key, default, _bindings), do: Gettext.dgettext(MeuApp.Gettext, "frappe_ui", default)
      end

      config :frappe_ui_live, translator: MeuApp.Translator

  `default` já considera `config :frappe_ui_live, :texts`. O resultado ainda passa pela
  interpolação de `%{nome}`.
  """

  @callback translate(key :: atom(), default :: String.t(), bindings :: keyword()) :: String.t()
end
