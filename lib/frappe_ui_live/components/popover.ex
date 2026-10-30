defmodule FrappeUILive.Components.Popover do
  @moduledoc "Painel flutuante com conteúdo livre: Popover API + CSS Anchor Positioning (sem JS)."
  use Phoenix.Component

  alias FrappeUILive.Components.Anchor

  attr :id, :string, required: true
  attr :placement, :atom, default: :bottom, values: [:bottom, :top]
  attr :class, :any, default: nil, doc: "classes do painel"
  attr :rest, :global
  slot :trigger, required: true
  slot :inner_block, required: true, doc: "conteúdo do painel"

  def popover(assigns) do
    Anchor.valid_id!(assigns.id, "popover")

    assigns =
      assigns
      |> assign(:anchor_style, Anchor.trigger_style(assigns.id))
      |> assign(:panel_style, Anchor.panel_style(assigns.id, assigns.placement))

    ~H"""
    <div class="inline-block" {@rest}>
      <button
        type="button"
        popovertarget={@id}
        style={@anchor_style}
        aria-haspopup="dialog"
        class="inline-flex"
      >
        {render_slot(@trigger)}
      </button>
      <div
        id={@id}
        popover
        style={@panel_style}
        class={[
          Anchor.panel_classes(),
          "p-3",
          @class
        ]}
      >
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end
end
