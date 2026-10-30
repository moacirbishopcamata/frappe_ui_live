defmodule FrappeUILive.Components.Tooltip do
  @moduledoc "Dica visual sem JavaScript: aparece em hover e em foco do conteúdo envolvido."
  use Phoenix.Component

  alias FrappeUILive.Contract

  @placements ~w(top bottom left right)a

  @placement_classes %{
    top: "bottom-full left-1/2 mb-1.5 -translate-x-1/2",
    bottom: "top-full left-1/2 mt-1.5 -translate-x-1/2",
    left: "right-full top-1/2 mr-1.5 -translate-y-1/2",
    right: "left-full top-1/2 ml-1.5 -translate-y-1/2"
  }

  attr :text, :string, required: true
  attr :placement, :atom, default: :top, values: @placements
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def tooltip(assigns) do
    Contract.require!(assigns.placement, @placements, "tooltip placement")
    assigns = assign(assigns, :placement_class, @placement_classes[assigns.placement])

    ~H"""
    <span class={["group/tooltip relative inline-flex", @class]} {@rest}>
      {render_slot(@inner_block)}
      <span
        role="tooltip"
        class={[
          "bg-surface-gray-10 text-ink-base fui-text-xs pointer-events-none invisible absolute z-50 rounded-4 px-2 py-1 whitespace-nowrap opacity-0 shadow-elevation-md transition-opacity",
          "group-hover/tooltip:visible group-hover/tooltip:opacity-100 group-focus-within/tooltip:visible group-focus-within/tooltip:opacity-100",
          @placement_class
        ]}
      >
        {@text}
      </span>
    </span>
    """
  end
end
