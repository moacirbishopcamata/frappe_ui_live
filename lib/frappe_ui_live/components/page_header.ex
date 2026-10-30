defmodule FrappeUILive.Components.PageHeader do
  @moduledoc "Cabeçalho de página: breadcrumbs opcionais, título e ações."
  use Phoenix.Component

  attr :title, :string, required: true
  attr :subtitle, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global
  slot :breadcrumbs
  slot :actions

  def page_header(assigns) do
    ~H"""
    <header class={["border-outline-gray-2 flex flex-col gap-2 border-b px-5 py-3", @class]} {@rest}>
      <div :if={@breadcrumbs != []}>{render_slot(@breadcrumbs)}</div>
      <div class="flex items-center justify-between gap-3">
        <div class="min-w-0">
          <h1 class="fui-text-xl-semibold text-ink-gray-9 truncate">{@title}</h1>
          <p :if={@subtitle} class="fui-text-p-base text-ink-gray-5">{@subtitle}</p>
        </div>
        <div :if={@actions != []} class="flex shrink-0 items-center gap-2">{render_slot(@actions)}</div>
      </div>
    </header>
    """
  end
end
