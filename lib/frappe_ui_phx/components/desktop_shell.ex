defmodule FrappeUIPhx.Components.DesktopShell do
  @moduledoc "Casca de página para desktop: `:sidebar` à esquerda e o conteúdo rolável à direita."
  use Phoenix.Component

  attr :class, :any, default: nil
  attr :rest, :global
  slot :sidebar
  slot :inner_block, required: true

  def desktop_shell(assigns) do
    ~H"""
    <div class={["bg-surface-base text-ink-gray-8 flex h-dvh w-full", @class]} {@rest}>
      {render_slot(@sidebar)}
      <main class="min-w-0 flex-1 overflow-auto">{render_slot(@inner_block)}</main>
    </div>
    """
  end
end
