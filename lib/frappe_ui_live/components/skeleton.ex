defmodule FrappeUILive.Components.Skeleton do
  @moduledoc "Bloco animado para estados de carregamento; dimensione por `class` (ex.: `h-4 w-32`)."
  use Phoenix.Component

  attr :class, :any, default: "h-4 w-full"
  attr :rest, :global

  def skeleton(assigns) do
    ~H"""
    <div class={["bg-surface-gray-3 animate-pulse rounded-4", @class]} aria-hidden="true" {@rest}>
    </div>
    """
  end
end
