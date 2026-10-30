defmodule FrappeUILive.Charts.Proportion do
  @moduledoc "Gráficos de proporção: barra percentual empilhada e funil."
  use Phoenix.Component

  alias FrappeUILive.Charts.{Frame, Legend, Scale}

  attr :data, :list, required: true, doc: "[%{label, value}]"
  attr :legend, :boolean, default: true
  attr :loading, :boolean, default: false
  attr :error, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  def percentage_bar_chart(assigns) do
    parts = parts(assigns.data)
    state = Frame.state(assigns.loading, assigns.error, parts == [])

    assigns =
      assigns
      |> assign(:state, state)
      |> assign(:parts, parts)
      |> assign(:legend_items, Enum.map(parts, &%{label: &1.label, color: &1.color}))

    ~H"""
    <div class={@class} {@rest}>
      <Frame.chart_frame state={@state} error={@error} height={24}>
        <div
          class="flex h-3 w-full overflow-hidden rounded-full"
          role="img"
          aria-label="Barra percentual"
        >
          <div
            :for={part <- @parts}
            data-part
            title={"#{part.label}: #{part.value} (#{part.percent}%)"}
            class="h-full first:rounded-l-full last:rounded-r-full hover:opacity-80"
            style={"width: #{part.percent}%; background: #{part.color}"}
          >
          </div>
        </div>
        <Legend.chart_legend :if={@legend} items={@legend_items} class="mt-2" />
      </Frame.chart_frame>
    </div>
    """
  end

  @doc "Partes com percentual (função pura); valores não positivos são ignorados."
  @spec parts([map()]) :: [map()]
  def parts(data) do
    data = Enum.filter(data, &(is_number(&1.value) and &1.value > 0))
    total = data |> Enum.map(& &1.value) |> Enum.sum()

    for {item, i} <- Enum.with_index(data) do
      %{
        label: item.label,
        value: item.value,
        percent: Float.round(item.value / total * 100, 1),
        color: Scale.color(i)
      }
    end
  end

  attr :steps, :list, required: true, doc: "[%{label, value}] em ordem de etapa"
  attr :height, :integer, default: 260
  attr :loading, :boolean, default: false
  attr :error, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  def funnel_chart(assigns) do
    state = Frame.state(assigns.loading, assigns.error, assigns.steps == [])
    shapes = funnel(assigns.steps, assigns.height)

    assigns = assigns |> assign(:state, state) |> assign(:shapes, shapes)

    ~H"""
    <div class={@class} {@rest}>
      <Frame.chart_frame state={@state} error={@error} height={@height}>
        <svg viewBox={"0 0 600 #{@height}"} class="w-full" role="img" aria-label="Gráfico de funil">
          <g :for={shape <- @shapes} data-step>
            <polygon points={shape.points} style={"fill: #{shape.color}"} class="hover:opacity-80">
              <title>{shape.label}: {shape.value} ({shape.percent}% da etapa inicial)</title>
            </polygon>
            <text
              x="300"
              y={Scale.n(shape.center_y + 4)}
              text-anchor="middle"
              font-size="12"
              style="fill: var(--ink-base)"
            >
              {shape.label} · {shape.value}
            </text>
          </g>
        </svg>
      </Frame.chart_frame>
    </div>
    """
  end

  @doc "Trapézios do funil (função pura): largura proporcional ao valor, centrados."
  @spec funnel([map()], pos_integer()) :: [map()]
  def funnel([], _height), do: []

  def funnel(steps, height) do
    max = steps |> Enum.map(& &1.value) |> Enum.max() |> max(1)
    count = length(steps)
    gap = 4
    band = (height - gap * (count - 1)) / count

    steps
    |> Enum.with_index()
    |> Enum.map(fn {step, i} ->
      next = Enum.at(steps, i + 1)
      top_w = step.value / max * 560
      bottom_w = if(next, do: next.value, else: step.value) / max * 560
      y0 = i * (band + gap)
      y1 = y0 + band

      %{
        label: step.label,
        value: step.value,
        percent: Float.round(step.value / max * 100, 1),
        color: Scale.color(i),
        center_y: y0 + band / 2,
        points:
          "#{Scale.n(300 - top_w / 2)},#{Scale.n(y0)} #{Scale.n(300 + top_w / 2)},#{Scale.n(y0)} " <>
            "#{Scale.n(300 + bottom_w / 2)},#{Scale.n(y1)} #{Scale.n(300 - bottom_w / 2)},#{Scale.n(y1)}"
      }
    end)
  end
end
