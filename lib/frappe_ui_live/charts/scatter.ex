defmodule FrappeUILive.Charts.Scatter do
  @moduledoc "Gráfico de dispersão: séries de pontos `{x, y}` em eixos numéricos."
  use Phoenix.Component

  alias FrappeUILive.Charts.{Frame, Legend, Scale, Tooltip}
  alias FrappeUILive.Contract

  @width 600
  @plot %{left: 44, right: 588, top: 12}

  attr :series, :list, required: true, doc: "[%{name: String, points: [{x, y}]}]"
  attr :height, :integer, default: 260
  attr :legend, :boolean, default: true
  attr :loading, :boolean, default: false
  attr :error, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  def scatter_chart(assigns) do
    Contract.ensure!(
      Enum.all?(assigns.series, fn s ->
        Enum.all?(s.points, &match?({x, y} when is_number(x) and is_number(y), &1))
      end),
      "scatter_chart: pontos devem ser tuplas {x, y} numéricas"
    )

    empty? = Enum.all?(assigns.series, &(&1.points == []))
    state = Frame.state(assigns.loading, assigns.error, empty?)
    geometry = geometry(assigns.series, assigns.height)

    assigns =
      assigns
      |> assign(state: state, geometry: geometry, width: @width)
      |> assign(:legend_items, Legend.from_names(Enum.map(assigns.series, & &1.name)))

    ~H"""
    <div class={@class} {@rest}>
      <Frame.chart_frame state={@state} error={@error} height={@height}>
        <svg
          viewBox={"0 0 #{@width} #{@height}"}
          class="w-full"
          role="img"
          aria-label="Gráfico de dispersão"
        >
          <g aria-hidden="true" font-size="11">
            <g :for={tick <- @geometry.y_ticks}>
              <line
                x1={@geometry.left}
                x2={@geometry.right}
                y1={Scale.n(tick.pos)}
                y2={Scale.n(tick.pos)}
                style="stroke: var(--outline-gray-2)"
              />
              <text
                x={@geometry.left - 6}
                y={Scale.n(tick.pos + 4)}
                text-anchor="end"
                style="fill: var(--ink-gray-5)"
              >
                {Scale.short(tick.value)}
              </text>
            </g>
            <text
              :for={tick <- @geometry.x_ticks}
              x={Scale.n(tick.pos)}
              y={@geometry.bottom + 16}
              text-anchor="middle"
              style="fill: var(--ink-gray-5)"
            >
              {Scale.short(tick.value)}
            </text>
          </g>
          <g :for={serie <- @geometry.series} data-series={serie.name}>
            <g :for={point <- serie.points} class="group" tabindex="0" data-point>
              <circle
                cx={Scale.n(point.x)}
                cy={Scale.n(point.y)}
                r="4.5"
                fill-opacity="0.75"
                style={"fill: #{serie.color}"}
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

  @doc "Escalas e pontos em coordenadas SVG (função pura)."
  @spec geometry([map()], pos_integer()) :: map()
  def geometry(series, height) do
    points = Enum.flat_map(series, & &1.points)
    bottom = height - 28
    {xs, ys} = {Enum.map(points, &elem(&1, 0)), Enum.map(points, &elem(&1, 1))}
    {x_min, x_max} = bounds(xs)
    y_max = Scale.nice_max(Enum.max(ys, fn -> 0 end))

    x_pos = &Scale.linear(&1, {x_min, x_max}, {@plot.left + 8, @plot.right - 8})
    y_pos = &Scale.linear(&1, {0, y_max}, {bottom, @plot.top})

    %{
      left: @plot.left,
      right: @plot.right,
      bottom: bottom,
      y_ticks: for(v <- Scale.ticks(y_max), do: %{value: v, pos: y_pos.(v)}),
      x_ticks:
        for(i <- 0..4, v = x_min + (x_max - x_min) * i / 4, do: %{value: v, pos: x_pos.(v)}),
      series:
        for {serie, si} <- Enum.with_index(series) do
          %{
            name: serie.name,
            color: Scale.color(si),
            points:
              for(
                {x, y} <- serie.points,
                do: %{x: x_pos.(x), y: y_pos.(y), title: "#{serie.name}: (#{x}, #{y})"}
              )
          }
        end
    }
  end

  defp bounds([]), do: {0, 1}
  defp bounds(xs), do: {Enum.min(xs), Enum.max(xs)}
end
