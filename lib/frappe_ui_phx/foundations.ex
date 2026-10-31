defmodule FrappeUIPhx.Foundations do
  @moduledoc """
  Fundamentos visuais do Frappe UI (cores, tipografia, raios, sombras, anel de
  foco e cores de gráficos) como **dados**, lidos de `priv/foundations.json`, que
  `mix tokens.sync` gera da mesma fonte dos tokens do CSS. Alimenta as páginas de
  Fundamentos do mostruário e serve de referência em código (ex.: listar tokens).
  """

  alias FrappeUIPhx.Charts.Scale

  @json Path.expand("../../priv/foundations.json", __DIR__)
  @external_resource @json
  @raw @json |> File.read!() |> Jason.decode!()

  # Registros viram mapas com chaves átomo (arquivo confiável, gerado por nós em tempo de compilação).
  @records fn list ->
    Enum.map(list, fn m -> Map.new(m, fn {k, v} -> {String.to_atom(k), v} end) end)
  end

  @data %{
    colors: Map.new(@raw["colors"], fn {k, v} -> {k, @records.(v)} end),
    ramps: Map.new(@raw["ramps"], fn {k, v} -> {k, @records.(v)} end),
    radius: @records.(@raw["radius"]),
    shadows: @records.(@raw["shadows"]),
    focus_rings: @records.(@raw["focusRing"]),
    family: @raw["typography"]["family"],
    weights: @records.(@raw["typography"]["weights"]),
    scale: @records.(@raw["typography"]["scale"])
  }

  @sections [
    %{
      id: :colors,
      title: "Colors",
      summary: "Tokens semânticos surface, ink e outline (claro e escuro) e as rampas primitivas."
    },
    %{
      id: :typography,
      title: "Typography",
      summary: "Fonte Inter, pesos e a escala de tamanhos com entrelinha e espaçamento."
    },
    %{
      id: :radius,
      title: "Radius",
      summary: "Escala numérica de arredondamento (`rounded-4` = 8px)."
    },
    %{id: :shadows, title: "Shadows", summary: "Elevações de sombra (`shadow-elevation-*`)."},
    %{
      id: :focus_ring,
      title: "Focus ring",
      summary: "Anel de foco por cor (`focus-ring`, `focus-ring-blue`...)."
    },
    %{
      id: :chart_colors,
      title: "Chart colors",
      summary: "Paleta de séries dos gráficos, na ordem em que é usada."
    }
  ]

  @doc "Seções dos Fundamentos: `[%{id, title, summary}]`."
  def sections, do: @sections

  @doc "Seção por `id` ou `nil`."
  def section(id) when is_atom(id), do: Enum.find(@sections, &(&1.id == id))

  @doc "Tokens semânticos por categoria: `%{\"surface\" => [%{name, light, dark}]}`."
  @spec colors() :: %{String.t() => [map()]}
  def colors, do: @data.colors

  @doc "Categorias semânticas na ordem de exibição."
  def color_categories, do: ~w(surface surface-alpha ink outline outline-alpha)

  @doc "Rampas primitivas por família: `%{\"gray\" => [%{shade, value}]}`."
  def ramps, do: @data.ramps

  @doc "Escala de raios: `[%{name, value}]`."
  def radius, do: @data.radius

  @doc "Sombras de elevação: `[%{name, value}]` (sem `DEFAULT`)."
  def shadows, do: @data.shadows

  @doc "Anéis de foco: `[%{name, value}]` (valor da `outline` em tema claro)."
  def focus_rings, do: @data.focus_rings

  @doc "Família de fonte do texto."
  def font_family, do: @data.family

  @doc "Pesos: `[%{name, value}]`."
  def font_weights, do: @data.weights

  @doc "Escala tipográfica: `[%{name, size, lineHeight, letterSpacing, weight, paragraph}]`."
  def type_scale, do: @data.scale

  @doc "Cores das séries dos gráficos, na ordem de uso: `[%{index, family, color}]`."
  @spec chart_colors() :: [%{index: non_neg_integer(), family: String.t(), color: String.t()}]
  def chart_colors do
    for {family, index} <- Enum.with_index(Scale.palette()) do
      %{index: index, family: family, color: Scale.color(index)}
    end
  end

  @doc "Classe do token de cor para uso em HTML (`\"surface\"`, `\"gray-2\"` → `bg-surface-gray-2`)."
  @spec color_class(String.t(), String.t(), :bg | :text | :border) :: String.t()
  def color_class(category, name, :bg), do: "bg-#{category}-#{name}"
  def color_class(category, name, :text), do: "text-#{category}-#{name}"
  def color_class(category, name, :border), do: "border-#{category}-#{name}"

  @doc "Variável CSS do token semântico."
  @spec color_var(String.t(), String.t()) :: String.t()
  def color_var(category, name), do: "var(--#{category}-#{name})"
end
