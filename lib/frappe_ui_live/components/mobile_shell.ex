defmodule FrappeUILive.Components.MobileShell do
  @moduledoc "Casca para telas estreitas: cabeçalho, conteúdo rolável e navegação inferior (`:nav`)."
  use Phoenix.Component

  alias FrappeUILive.Components.NavItem
  alias FrappeUILive.Contract

  attr :active, :string, default: nil, doc: "id da aba inferior ativa"
  attr :class, :any, default: nil
  attr :rest, :global
  slot :header
  slot :inner_block, required: true

  slot :nav do
    attr :id, :string, required: true
    attr :label, :string, required: true
    attr :icon, :string
    attr :patch, :string
    attr :navigate, :string
    attr :href, :string
    attr :click, :any
  end

  def mobile_shell(assigns) do
    if assigns.active,
      do: Contract.require!(assigns.active, Enum.map(assigns.nav, & &1.id), "mobile_shell active")

    ~H"""
    <div class={["bg-surface-base text-ink-gray-8 flex h-dvh w-full flex-col", @class]} {@rest}>
      <header :if={@header != []} class="border-outline-gray-2 border-b px-4 py-2">
        {render_slot(@header)}
      </header>
      <main class="min-h-0 flex-1 overflow-auto">{render_slot(@inner_block)}</main>
      <nav
        :if={@nav != []}
        aria-label="Principal"
        class="border-outline-gray-2 bg-surface-base flex border-t pb-[env(safe-area-inset-bottom)]"
      >
        <NavItem.nav_item
          :for={item <- @nav}
          item={item}
          stacked
          active={item.id == @active}
          class={[
            "fui-text-xs flex-1 py-2",
            item.id == @active && "text-ink-gray-9",
            item.id != @active && "text-ink-gray-5"
          ]}
        />
      </nav>
    </div>
    """
  end
end
