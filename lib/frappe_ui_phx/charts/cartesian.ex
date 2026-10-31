defmodule FrappeUIPhx.Charts.Cartesian do
  @moduledoc """
  Geometria compartilhada pelos gráficos de eixos (barras, linhas, áreas):
  área de plotagem, escala Y, posições X por categoria e grade. Funções puras.
  """
  alias FrappeUIPhx.Charts.Scale
  alias FrappeUIPhx.Contract

  @width 600
  @margin %{top: 12, right: 12, bottom: 28, left: 44}

  @doc "Largura do `viewBox`."
  def width, do: @width

  @doc """
  Valida e calcula o layout para `categories` e `series` (`[%{name, data}]`).

  Pré-condição: toda série tem um valor por categoria e só números.
  """
  @spec layout([String.t()], [map()], pos_integer()) :: map()
  def layout(categories, series, height) do
    Contract.ensure!(
      Enum.all?(series, fn s ->
        length(s.data) == length(categories) and Enum.all?(s.data, &is_number/1)
      end),
      "gráfico: cada série deve ter exatamente um número por categoria"
    )

    values = Enum.flat_map(series, & &1.data)
    max = Scale.nice_max(Enum.max(values, fn -> 0 end))

    plot = %{
      left: @margin.left,
      right: @width - @margin.right,
      top: @margin.top,
      bottom: height - @margin.bottom
    }

    %{
      width: @width,
      height: height,
      plot: plot,
      max: max,
      ticks: for(t <- Scale.ticks(max), do: %{value: t, y: y(t, max, plot)}),
      count: length(categories)
    }
  end

  @doc "Coordenada Y de `value`."
  def y(value, max, plot), do: Scale.linear(value, {0, max}, {plot.bottom, plot.top})

  @doc "Início e largura da faixa horizontal da categoria `index`."
  @spec band(non_neg_integer(), pos_integer(), map()) :: {float(), float()}
  def band(index, count, plot) do
    w = (plot.right - plot.left) / count
    {plot.left + index * w, w}
  end

  @doc "Centro horizontal da categoria `index`."
  def center(index, count, plot) do
    {x, w} = band(index, count, plot)
    x + w / 2
  end
end
