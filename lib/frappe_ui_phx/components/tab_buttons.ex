defmodule FrappeUIPhx.Components.TabButtons do
  @moduledoc "Abas em formato de botões segmentados; a ativa é um assign do servidor (`active`)."
  use Phoenix.Component

  alias FrappeUIPhx.Components.NavItem

  attr :active, :string, required: true, doc: "id do botão ativo"
  attr :class, :any, default: nil
  attr :rest, :global

  slot :button, required: true do
    attr :id, :string, required: true
    attr :label, :string, required: true
    attr :icon, :string
    attr :patch, :string
    attr :navigate, :string
    attr :href, :string
    attr :click, :any
  end

  def tab_buttons(assigns) do
    assigns =
      assign(
        assigns,
        :active,
        NavItem.known_active(assigns.active, Enum.map(assigns.button, & &1.id))
      )

    ~H"""
    <div
      role="tablist"
      class={["bg-surface-gray-2 inline-flex gap-0.5 rounded-5 p-0.5", @class]}
      {@rest}
    >
      <NavItem.nav_item
        :for={item <- @button}
        item={item}
        role="tab"
        active={item.id == @active}
        class={[
          "fui-text-base rounded-4 px-2.5 py-1",
          item.id == @active && "bg-surface-base text-ink-gray-9 shadow-elevation-sm",
          item.id != @active && "text-ink-gray-6 hover:text-ink-gray-8"
        ]}
      />
    </div>
    """
  end
end
