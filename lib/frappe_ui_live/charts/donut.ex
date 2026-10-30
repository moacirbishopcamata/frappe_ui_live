defmodule FrappeUILive.Charts.Donut do
  @moduledoc "Gráfico de rosca (SVG no servidor). `data` é `[%{label, value}]`; valores ≤ 0 são ignorados."
  use Phoenix.Component

  alias FrappeUILive.Charts.{Frame, Legend, Scale}

  @size 200
  @outer 90
  @inner 58

  attr :data, :list, required: true
  attr :center_label, :string, default: nil, doc: "texto no centro (padrão: total)"
  attr :legend, :boolean, default: true
  attr :loading, :boolean, default: false
  attr :error, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  def donut_chart(assigns) do
    slices = slices(assigns.data)
    state = Frame.state(assigns.loading, assigns.error, slices == [])
    total = slices |> Enum.map(& &1.value) |> Enum.sum()

    assigns =
      assigns
      |> assign(:state, state)
      |> assign(:slices, slices)
      |> assign(:total, total)
      |> assign(:legend_items, Enum.map(slices, &%{label: &1.label, color: &1.color}))

    ~H"""
    <div class={@class} {@rest}>
      <Frame.chart_frame state={@state} error={@error} height={200}>
        <svg
          viewBox="0 0 200 200"
          class="mx-auto w-full max-w-60"
          role="img"
          aria-label="Gráfico de rosca"
        >
          <path
            :for={slice <- @slices}
            d={slice.path}
            fill-rule="evenodd"
            style={"fill: #{slice.color}"}
            class="hover:opacity-80"
            data-slice
          >
            <title>{slice.label}: {slice.value} ({slice.percent}%)</title>
          </path>
          <text
            x="100"
            y="98"
            text-anchor="middle"
            font-size="22"
            font-weight="600"
            style="fill: var(--ink-gray-9)"
          >
            {@center_label || @total}
          </text>
          <text
            :if={!@center_label}
            x="100"
            y="116"
            text-anchor="middle"
            font-size="11"
            style="fill: var(--ink-gray-5)"
          >
            total
          </text>
        </svg>
        <Legend.chart_legend :if={@legend} items={@legend_items} class="mt-2 justify-center" />
      </Frame.chart_frame>
    </div>
    """
  end

  @doc "Fatias (função pura) com `path`, cor e percentual; ignora valores não positivos."
  @spec slices([map()]) :: [map()]
  def slices(data) do
    data = Enum.filter(data, &(is_number(&1.value) and &1.value > 0))
    total = data |> Enum.map(& &1.value) |> Enum.sum()

    {slices, _} =
      data
      |> Enum.with_index()
      |> Enum.map_reduce(0.0, fn {item, index}, start ->
        sweep = item.value / total * 2 * :math.pi()

        slice = %{
          label: item.label,
          value: item.value,
          percent: Float.round(item.value / total * 100, 1),
          color: Scale.color(index),
          path: arc(start, start + sweep)
        }

        {slice, start + sweep}
      end)

    slices
  end

  # Anel de `a0` a `a1` (radianos, 0 = topo). Fatia de 360° vira dois semicírculos.
  defp arc(a0, a1) do
    if a1 - a0 >= 2 * :math.pi() - 1.0e-6,
      do: "#{ring(0, :math.pi())} #{ring(:math.pi(), 2 * :math.pi())}",
      else: ring(a0, a1)
  end

  defp ring(a0, a1) do
    large = if a1 - a0 > :math.pi(), do: 1, else: 0
    {ox0, oy0} = point(@outer, a0)
    {ox1, oy1} = point(@outer, a1)
    {ix1, iy1} = point(@inner, a1)
    {ix0, iy0} = point(@inner, a0)

    "M#{Scale.n(ox0)},#{Scale.n(oy0)} A#{@outer},#{@outer} 0 #{large} 1 #{Scale.n(ox1)},#{Scale.n(oy1)} " <>
      "L#{Scale.n(ix1)},#{Scale.n(iy1)} A#{@inner},#{@inner} 0 #{large} 0 #{Scale.n(ix0)},#{Scale.n(iy0)} Z"
  end

  defp point(radius, angle),
    do: {@size / 2 + radius * :math.sin(angle), @size / 2 - radius * :math.cos(angle)}
end
