defmodule FrappeUIPhx.Charts.Line do
  @moduledoc "Gráficos de linha e de área (SVG no servidor), com pontos, dicas e estados."
  use Phoenix.Component

  alias FrappeUIPhx.Texts

  alias FrappeUIPhx.Charts.{Axes, Cartesian, Frame, Legend, Scale, Tooltip}

  attr :categories, :list, required: true
  attr :series, :list, required: true, doc: "[%{name: String, data: [number]}]"
  attr :height, :integer, default: 240
  attr :legend, :boolean, default: true
  attr :loading, :boolean, default: false
  attr :error, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  def line_chart(assigns), do: render_chart(assigns, false)

  attr :categories, :list, required: true
  attr :series, :list, required: true, doc: "[%{name: String, data: [number]}]"
  attr :height, :integer, default: 240
  attr :legend, :boolean, default: true
  attr :loading, :boolean, default: false
  attr :error, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  def area_chart(assigns), do: render_chart(assigns, true)

  defp render_chart(assigns, area?) do
    empty? = assigns.categories == [] or assigns.series == []
    state = Frame.state(assigns.loading, assigns.error, empty?)

    layout =
      if state == :ready, do: Cartesian.layout(assigns.categories, assigns.series, assigns.height)

    assigns =
      assigns
      |> assign(:state, state)
      |> assign(:layout, layout)
      |> assign(:area?, area?)
      |> assign(
        :lines,
        if(layout, do: lines(assigns.categories, assigns.series, layout), else: [])
      )
      |> assign(:legend_items, Legend.from_names(Enum.map(assigns.series, & &1.name)))

    ~H"""
    <div class={@class} {@rest}>
      <Frame.chart_frame state={@state} error={@error} height={@height}>
        <svg
          viewBox={"0 0 #{Cartesian.width()} #{@height}"}
          class="w-full"
          role="img"
          aria-label={if @area?, do: Texts.t(:chart_area), else: Texts.t(:chart_line)}
        >
          <Axes.axes layout={@layout} categories={@categories} />
          <g :for={line <- @lines} data-series={line.name}>
            <path :if={@area?} d={line.area} style={"fill: #{line.color}"} fill-opacity="0.15" />
            <path
              d={line.path}
              fill="none"
              stroke-width="2"
              stroke-linejoin="round"
              style={"stroke: #{line.color}"}
            />
            <g :for={point <- line.points} class="group" tabindex="0" data-point>
              <circle
                cx={Scale.n(point.x)}
                cy={Scale.n(point.y)}
                r="3.5"
                style={"fill: #{line.color}"}
                class="group-hover:r-5"
              >
                <title>{point.title}</title>
              </circle>
              <Tooltip.chart_tooltip x={point.x} y={point.y - 6} text={point.title} />
            </g>
          </g>
        </svg>
        <Legend.chart_legend :if={@legend and length(@series) > 1} items={@legend_items} class="mt-2" />
      </Frame.chart_frame>
    </div>
    """
  end

  @doc "Geometria das séries (função pura): path da linha, path da área e pontos."
  @spec lines([String.t()], [map()], map()) :: [map()]
  def lines(categories, series, layout) do
    for {serie, si} <- Enum.with_index(series) do
      points =
        for {category, ci} <- Enum.with_index(categories) do
          value = Enum.at(serie.data, ci)

          %{
            x: Cartesian.center(ci, layout.count, layout.plot),
            y: Cartesian.y(value, layout.max, layout.plot),
            title: "#{category} · #{serie.name}: #{value}"
          }
        end

      path =
        points
        |> Enum.with_index()
        |> Enum.map_join(" ", fn {p, i} ->
          "#{if i == 0, do: "M", else: "L"}#{Scale.n(p.x)},#{Scale.n(p.y)}"
        end)

      first = hd(points)
      last = List.last(points)
      base = Scale.n(layout.plot.bottom)

      %{
        name: serie.name,
        color: Scale.color(si),
        points: points,
        path: path,
        area: "#{path} L#{Scale.n(last.x)},#{base} L#{Scale.n(first.x)},#{base} Z"
      }
    end
  end
end
