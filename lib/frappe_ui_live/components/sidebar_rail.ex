defmodule FrappeUILive.Components.SidebarRail do
  @moduledoc "Trilho estreito só com ícones (rótulo acessível e `title`); ativo por assign."
  use Phoenix.Component

  alias FrappeUILive.Components.NavItem
  alias FrappeUILive.Contract

  attr :active, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global
  slot :header
  slot :footer

  slot :item, required: true do
    attr :id, :string, required: true
    attr :label, :string, required: true
    attr :icon, :string, required: true
    attr :patch, :string
    attr :navigate, :string
    attr :href, :string
    attr :click, :any
  end

  def sidebar_rail(assigns) do
    if assigns.active,
      do:
        Contract.require!(assigns.active, Enum.map(assigns.item, & &1.id), "sidebar_rail active")

    ~H"""
    <aside
      class={[
        "border-outline-gray-2 bg-surface-sidebar flex h-full w-12 shrink-0 flex-col items-center border-r py-2",
        @class
      ]}
      {@rest}
    >
      <div :if={@header != []} class="mb-2">{render_slot(@header)}</div>
      <nav aria-label="Principal" class="flex flex-1 flex-col items-center gap-1">
        <NavItem.nav_item
          :for={item <- @item}
          item={item}
          active={item.id == @active}
          icon_only
          class={[
            "size-8 justify-center rounded-4",
            item.id == @active && "bg-surface-gray-3 text-ink-gray-9",
            item.id != @active && "text-ink-gray-6 hover:bg-surface-gray-2"
          ]}
        />
      </nav>
      <div :if={@footer != []}>{render_slot(@footer)}</div>
    </aside>
    """
  end
end
