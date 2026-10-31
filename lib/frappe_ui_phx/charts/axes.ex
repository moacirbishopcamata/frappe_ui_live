defmodule FrappeUIPhx.Charts.Axes do
  @moduledoc "Grade horizontal, rótulos do eixo Y e rótulos de categorias (SVG)."
  use Phoenix.Component

  alias FrappeUIPhx.Charts.{Cartesian, Scale}

  @max_labels 12

  attr :layout, :map, required: true
  attr :categories, :list, required: true

  def axes(assigns) do
    step = max(1, ceil(length(assigns.categories) / @max_labels))

    labels =
      assigns.categories
      |> Enum.with_index()
      |> Enum.filter(fn {_c, i} -> rem(i, step) == 0 end)

    assigns = assign(assigns, :labels, labels)

    ~H"""
    <g aria-hidden="true" font-size="11">
      <g :for={tick <- @layout.ticks}>
        <line
          x1={Scale.n(@layout.plot.left)}
          x2={Scale.n(@layout.plot.right)}
          y1={Scale.n(tick.y)}
          y2={Scale.n(tick.y)}
          style="stroke: var(--outline-gray-2)"
          stroke-dasharray={tick.value != 0 && "3 3"}
        />
        <text
          x={Scale.n(@layout.plot.left - 6)}
          y={Scale.n(tick.y + 4)}
          text-anchor="end"
          style="fill: var(--ink-gray-5)"
        >
          {Scale.short(tick.value)}
        </text>
      </g>
      <text
        :for={{category, index} <- @labels}
        x={Scale.n(Cartesian.center(index, @layout.count, @layout.plot))}
        y={Scale.n(@layout.plot.bottom + 16)}
        text-anchor="middle"
        style="fill: var(--ink-gray-5)"
      >
        {category}
      </text>
    </g>
    """
  end
end
