defmodule FrappeUIPhx.Charts.ChartCard do
  @moduledoc "Cartão que enquadra um gráfico: título, subtítulo, ações e o gráfico no corpo."
  use Phoenix.Component

  attr :title, :string, required: true
  attr :subtitle, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global
  slot :actions
  slot :inner_block, required: true

  def chart_card(assigns) do
    ~H"""
    <section class={["border-outline-gray-2 bg-surface-base rounded-6 border p-4", @class]} {@rest}>
      <header class="mb-3 flex items-start justify-between gap-3">
        <div class="min-w-0">
          <h3 class="fui-text-lg-semibold text-ink-gray-9 truncate">{@title}</h3>
          <p :if={@subtitle} class="fui-text-sm text-ink-gray-5">{@subtitle}</p>
        </div>
        <div :if={@actions != []} class="flex shrink-0 items-center gap-1">
          {render_slot(@actions)}
        </div>
      </header>
      {render_slot(@inner_block)}
    </section>
    """
  end
end
