defmodule FrappeUIPhx.Components.ScrollArea do
  @moduledoc "Região rolável com barras finas e discretas (CSS nativo); focável para rolagem por teclado."
  use Phoenix.Component

  alias FrappeUIPhx.Contract

  @orientations ~w(vertical horizontal both)a

  attr :orientation, :atom, default: :vertical, values: @orientations
  attr :class, :any, default: nil, doc: "defina a altura/largura máxima aqui, ex.: max-h-64"
  attr :rest, :global
  slot :inner_block, required: true

  def scroll_area(assigns) do
    Contract.require!(assigns.orientation, @orientations, "scroll_area orientation")

    ~H"""
    <div
      tabindex="0"
      class={[
        "focus-visible:focus-ring [scrollbar-color:var(--outline-gray-3)_transparent] [scrollbar-width:thin]",
        @orientation == :vertical && "overflow-x-hidden overflow-y-auto",
        @orientation == :horizontal && "overflow-x-auto overflow-y-hidden",
        @orientation == :both && "overflow-auto",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
