defmodule FrappeUILive.Charts.Tooltip do
  @moduledoc """
  Dica de um ponto de dado, desenhada em SVG: aparece quando o pai tem a classe
  `group` e está em hover/foco (CSS puro). Complementa o `<title>` nativo.
  """
  use Phoenix.Component

  alias FrappeUILive.Charts.Scale

  attr :x, :float, required: true, doc: "centro horizontal"
  attr :y, :float, required: true, doc: "base da dica (acima do ponto)"
  attr :text, :string, required: true

  def chart_tooltip(assigns) do
    width = String.length(assigns.text) * 6.4 + 14

    assigns =
      assign(assigns,
        width: width,
        left: Scale.n(assigns.x - width / 2),
        top: Scale.n(assigns.y - 24)
      )

    ~H"""
    <g
      class="pointer-events-none invisible group-hover:visible group-focus:visible"
      aria-hidden="true"
    >
      <rect
        x={@left}
        y={@top}
        width={Scale.n(@width)}
        height="20"
        rx="4"
        style="fill: var(--surface-gray-10)"
      />
      <text
        x={Scale.n(@x)}
        y={Scale.n(@y - 10)}
        text-anchor="middle"
        font-size="11"
        style="fill: var(--ink-base)"
      >
        {@text}
      </text>
    </g>
    """
  end
end
