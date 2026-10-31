defmodule FrappeUIPhx.Components.Tabs do
  @moduledoc """
  Abas cujo item ativo é decidido por um assign (`active`), nunca por estado do
  cliente. Cada `:tab` navega (`patch`/`navigate`) ou dispara evento (`click`).
  O conteúdo do painel ativo vai no `inner_block`.
  """
  use Phoenix.Component

  alias FrappeUIPhx.Components.NavItem

  attr :id, :string, required: true
  attr :active, :string, required: true, doc: "id da aba ativa"
  attr :class, :any, default: nil
  attr :rest, :global

  slot :tab, required: true do
    attr :id, :string, required: true
    attr :label, :string, required: true
    attr :icon, :string
    attr :patch, :string
    attr :navigate, :string
    attr :href, :string
    attr :click, :any
  end

  slot :inner_block, doc: "painel da aba ativa"

  def tabs(assigns) do
    ids = Enum.map(assigns.tab, & &1.id)
    assigns = assign(assigns, :active, NavItem.known_active(assigns.active, ids))

    ~H"""
    <div class={@class} {@rest}>
      <div role="tablist" class="border-outline-gray-2 flex gap-1 border-b">
        <%= for tab <- @tab do %>
          <NavItem.nav_item
            item={tab}
            role="tab"
            active={tab.id == @active}
            aria-controls={"#{@id}-panel"}
            class={[
              "fui-text-base -mb-px inline-flex items-center gap-1.5 border-b-2 px-3 py-2",
              tab.id == @active && "border-surface-gray-10 text-ink-gray-9",
              tab.id != @active && "text-ink-gray-5 hover:text-ink-gray-8 border-transparent"
            ]}
          />
        <% end %>
      </div>
      <div :if={@inner_block != []} id={"#{@id}-panel"} role="tabpanel" class="pt-4">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end
end
