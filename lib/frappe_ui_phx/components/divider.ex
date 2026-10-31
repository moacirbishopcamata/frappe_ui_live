defmodule FrappeUIPhx.Components.Divider do
  @moduledoc "Linha divisória horizontal ou vertical."
  use Phoenix.Component

  alias FrappeUIPhx.Contract

  @orientations ~w(horizontal vertical)a

  attr :orientation, :atom, default: :horizontal, values: @orientations
  attr :class, :any, default: nil
  attr :rest, :global

  def divider(assigns) do
    Contract.require!(assigns.orientation, @orientations, "divider orientation")

    ~H"""
    <hr
      aria-orientation={@orientation}
      class={[
        "border-outline-gray-2 border-0",
        @orientation == :horizontal && "w-full border-t-[1px]",
        @orientation == :vertical && "h-full self-stretch border-l-[1px]",
        @class
      ]}
      {@rest}
    />
    """
  end
end
