defmodule FrappeUILive.Charts.Scale do
  @moduledoc """
  Matemática pura dos gráficos: escalas lineares, "números bonitos" para eixos,
  paleta de cores do tema e formatação numérica estável para SVG.
  """

  @palette ~w(blue green amber violet red teal pink cyan orange purple)

  @doc "Cor (variável CSS do tema, então acompanha claro/escuro) da série `index`."
  @spec color(non_neg_integer()) :: String.t()
  def color(index), do: "var(--surface-#{Enum.at(@palette, rem(index, length(@palette)))}-6)"

  @doc "Quantidade de cores distintas antes de repetir."
  def palette_size, do: length(@palette)

  @doc "Menor número \"bonito\" (1, 2, 5 × 10ⁿ) que é ≥ `max`; mínimo 1."
  @spec nice_max(number()) :: number()
  def nice_max(max) when max <= 1, do: 1

  def nice_max(max) do
    exp = :math.floor(:math.log10(max))
    base = :math.pow(10, exp)
    fraction = max / base

    nice =
      cond do
        fraction <= 1 -> 1
        fraction <= 2 -> 2
        fraction <= 5 -> 5
        true -> 10
      end

    result = nice * base
    if result == trunc(result), do: trunc(result), else: result
  end

  @doc "Valores de grade de 0 a `nice_max` em `count` intervalos."
  @spec ticks(number(), pos_integer()) :: [number()]
  def ticks(nice_max, count \\ 4), do: for(i <- 0..count, do: nice_max * i / count)

  @doc "Mapeia `value` do intervalo `{d0, d1}` para `{r0, r1}` (domínio degenerado vira o início)."
  @spec linear(number(), {number(), number()}, {number(), number()}) :: float()
  def linear(_value, {d0, d1}, {r0, _r1}) when d0 == d1, do: r0 * 1.0
  def linear(value, {d0, d1}, {r0, r1}), do: r0 + (value - d0) / (d1 - d0) * (r1 - r0)

  @doc "Número para atributo SVG: até 2 casas, sem notação científica."
  @spec n(number()) :: String.t()
  def n(value) when is_integer(value), do: Integer.to_string(value)

  def n(value) when is_float(value) do
    value
    |> Float.round(2)
    |> :erlang.float_to_binary(decimals: 2)
    |> String.trim_trailing("0")
    |> String.trim_trailing(".")
  end

  @doc "Rótulo curto de eixo: 1200 → \"1,2 mil\", 2500000 → \"2,5 mi\"."
  @spec short(number()) :: String.t()
  def short(value) when abs(value) >= 1_000_000, do: scaled(value / 1_000_000, "mi")
  def short(value) when abs(value) >= 1_000, do: scaled(value / 1_000, "mil")
  def short(value), do: value |> round_n() |> to_string()

  defp scaled(v, suffix),
    do: (v |> round_n() |> to_string() |> String.replace(".", ",")) <> " " <> suffix

  defp round_n(v) when is_integer(v), do: v
  defp round_n(v), do: if(v == Float.round(v, 0), do: trunc(v), else: Float.round(v, 1))
end
