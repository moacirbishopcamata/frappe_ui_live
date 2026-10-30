defmodule FrappeUILive.Components.HoverCard do
  @moduledoc "Cartão que aparece em hover ou foco do gatilho, com pequeno atraso (CSS puro)."
  use Phoenix.Component

  attr :class, :any, default: nil, doc: "classes do cartão"
  attr :rest, :global
  slot :trigger, required: true
  slot :inner_block, required: true, doc: "conteúdo do cartão"

  def hover_card(assigns) do
    ~H"""
    <span class="group/hovercard relative inline-block" {@rest}>
      <span tabindex="0" class="inline-flex">{render_slot(@trigger)}</span>
      <span
        role="tooltip"
        class={[
          "bg-surface-elevation-1 border-outline-gray-1 shadow-elevation-lg rounded-5 invisible absolute top-full left-0 z-50 mt-1.5 w-64 border p-3 opacity-0 transition-opacity delay-200",
          "group-hover/hovercard:visible group-hover/hovercard:opacity-100 group-focus-within/hovercard:visible group-focus-within/hovercard:opacity-100",
          @class
        ]}
      >
        {render_slot(@inner_block)}
      </span>
    </span>
    """
  end
end
