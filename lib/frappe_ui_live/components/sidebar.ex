defmodule FrappeUILive.Components.Sidebar do
  @moduledoc """
  Barra lateral de navegação. O item ativo (`active`) e o recolhimento
  (`collapsed`) são assigns do servidor; recolhida, só os ícones aparecem.
  """
  use Phoenix.Component

  alias FrappeUILive.Texts

  alias FrappeUILive.Components.NavItem

  attr :active, :string, default: nil, doc: "id do item ativo (precisa existir se informado)"
  attr :collapsed, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global
  slot :header
  slot :footer

  slot :item, required: true do
    attr :id, :string, required: true
    attr :label, :string, required: true
    attr :icon, :string
    attr :patch, :string
    attr :navigate, :string
    attr :href, :string
    attr :click, :any
  end

  def sidebar(assigns) do
    assigns =
      assign(
        assigns,
        :active,
        NavItem.known_active(assigns.active, Enum.map(assigns.item, & &1.id))
      )

    ~H"""
    <aside
      class={[
        "border-outline-gray-2 bg-surface-sidebar flex h-full shrink-0 flex-col border-r transition-[width]",
        @collapsed && "w-14",
        !@collapsed && "w-60",
        @class
      ]}
      {@rest}
    >
      <div :if={@header != []} class="px-3 py-3">{render_slot(@header)}</div>
      <nav aria-label={Texts.t(:main_nav)} class="flex-1 space-y-0.5 overflow-y-auto px-2">
        <NavItem.nav_item
          :for={item <- @item}
          item={item}
          active={item.id == @active}
          icon_only={@collapsed}
          class={[
            "fui-text-base rounded-4 px-2 py-1.5",
            item.id == @active && "bg-surface-gray-3 text-ink-gray-9",
            item.id != @active && "text-ink-gray-7 hover:bg-surface-gray-2"
          ]}
        />
      </nav>
      <div :if={@footer != []} class="border-outline-gray-2 border-t px-3 py-3">
        {render_slot(@footer)}
      </div>
    </aside>
    """
  end
end
