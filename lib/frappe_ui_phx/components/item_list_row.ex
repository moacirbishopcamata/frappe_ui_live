defmodule FrappeUIPhx.Components.ItemListRow do
  @moduledoc "Linha de lista com ícone, título, subtítulo e ações; navegável por `navigate`/`patch`/`href`."
  use Phoenix.Component

  attr :title, :string, required: true
  attr :subtitle, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(navigate patch href)
  slot :icon
  slot :actions

  def item_list_row(assigns) do
    assigns =
      assign(
        assigns,
        :link?,
        Enum.any?(~w(navigate patch href)a, &Map.has_key?(assigns.rest, &1))
      )

    ~H"""
    <div class={["border-outline-gray-1 flex items-center gap-3 border-b px-3 py-2", @class]}>
      <div :if={@icon != []} class="text-ink-gray-5 shrink-0">{render_slot(@icon)}</div>
      <div class="min-w-0 flex-1">
        <.link :if={@link?} class="fui-text-base-medium text-ink-gray-9 hover:underline" {@rest}>
          {@title}
        </.link>
        <p :if={!@link?} class="fui-text-base-medium text-ink-gray-9 truncate">{@title}</p>
        <p :if={@subtitle} class="fui-text-sm text-ink-gray-5 truncate">{@subtitle}</p>
      </div>
      <div :if={@actions != []} class="flex shrink-0 items-center gap-1">{render_slot(@actions)}</div>
    </div>
    """
  end
end
