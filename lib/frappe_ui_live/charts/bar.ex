defmodule FrappeUILive.Charts.Bar do
  @moduledoc "Gráfico de barras agrupadas (SVG no servidor, cores do tema, estados loading/empty/error)."
  use Phoenix.Component

  alias FrappeUILive.Texts

  alias FrappeUILive.Charts.{Axes, Cartesian, Frame, Legend, Scale, Tooltip}

  attr :categories, :list, required: true
  attr :series, :list, required: true, doc: "[%{name: String, data: [number]}]"
  attr :height, :integer, default: 240
  attr :legend, :boolean, default: true
  attr :loading, :boolean, default: false
  attr :error, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  def bar_chart(assigns) do
    empty? = assigns.categories == [] or assigns.series == []
    state = Frame.state(assigns.loading, assigns.error, empty?)

    layout =
      if state == :ready, do: Cartesian.layout(assigns.categories, assigns.series, assigns.height)

    assigns =
      assigns
      |> assign(:state, state)
      |> assign(:layout, layout)
      |> assign(:bars, if(layout, do: bars(assigns.categories, assigns.series, layout), else: []))
      |> assign(:legend_items, Legend.from_names(Enum.map(assigns.series, & &1.name)))

    ~H"""
    <div class={@class} {@rest}>
      <Frame.chart_frame state={@state} error={@error} height={@height}>
        <svg
          viewBox={"0 0 #{Cartesian.width()} #{@height}"}
          class="w-full"
          role="img"
          aria-label={Texts.t(:chart_bar)}
        >
          <Axes.axes layout={@layout} categories={@categories} />
          <g :for={bar <- @bars} class="group" data-bar tabindex="0">
            <rect
              x={Scale.n(bar.x)}
              y={Scale.n(bar.y)}
              width={Scale.n(bar.w)}
              height={Scale.n(bar.h)}
              rx="2"
              style={"fill: #{bar.color}"}
              class="group-hover:opacity-80"
            >
              <title>{bar.title}</title>
            </rect>
            <Tooltip.chart_tooltip x={bar.x + bar.w / 2} y={bar.y} text={bar.title} />
          </g>
        </svg>
        <Legend.chart_legend :if={@legend and length(@series) > 1} items={@legend_items} class="mt-2" />
      </Frame.chart_frame>
    </div>
    """
  end

  @doc "Retângulos de barras (função pura): `%{x, y, w, h, color, title}` por série e categoria."
  @spec bars([String.t()], [map()], map()) :: [map()]
  def bars(categories, series, layout) do
    count = length(series)

    for {category, ci} <- Enum.with_index(categories),
        {serie, si} <- Enum.with_index(series) do
      {x0, band} = Cartesian.band(ci, layout.count, layout.plot)
      group = band * 0.7
      w = group / count
      value = Enum.at(serie.data, ci)
      y = Cartesian.y(value, layout.max, layout.plot)

      %{
        x: x0 + (band - group) / 2 + si * w + 1,
        y: y,
        w: max(w - 2, 1),
        h: layout.plot.bottom - y,
        color: Scale.color(si),
        title: "#{category} · #{serie.name}: #{value}"
      }
    end
  end
end
