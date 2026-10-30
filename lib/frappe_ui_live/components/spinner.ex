defmodule FrappeUILive.Components.Spinner do
  @moduledoc "Indicador de carregamento; herda a cor do texto."
  use Phoenix.Component

  attr :class, :any, default: "size-4"
  attr :rest, :global

  def spinner(assigns) do
    ~H"""
    <svg
      class={["animate-spin", @class]}
      viewBox="0 0 24 24"
      fill="none"
      role="status"
      aria-label="Carregando"
      {@rest}
    >
      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
    </svg>
    """
  end
end
