defmodule FrappeUILive.Components.Tabs do
  @moduledoc """
  Abas cujo item ativo é decidido por um assign (`active`), nunca por estado do
  cliente. Cada `:tab` navega (`patch`/`navigate`) ou dispara evento (`click`).
  O conteúdo do painel ativo vai no `inner_block`.
  """
  use Phoenix.Component

  alias FrappeUILive.Components.Icon
  alias FrappeUILive.Components.NavItem

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
          <.tab_item tab={tab} active={tab.id == @active} panel_id={"#{@id}-panel"} />
        <% end %>
      </div>
      <div :if={@inner_block != []} id={"#{@id}-panel"} role="tabpanel" class="pt-4">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  attr :tab, :map, required: true
  attr :active, :boolean, required: true
  attr :panel_id, :string, required: true

  defp tab_item(assigns) do
    tab = assigns.tab

    assigns =
      assigns
      |> assign(:nav, Map.take(tab, [:patch, :navigate]))
      |> assign(:link?, Map.has_key?(tab, :patch) or Map.has_key?(tab, :navigate))
      |> assign(:click, Map.get(tab, :click))
      |> assign(:icon, Map.get(tab, :icon))
      |> assign(:classes, [
        "fui-text-base -mb-px inline-flex items-center gap-1.5 border-b-2 px-3 py-2 transition-colors focus-visible:focus-ring",
        assigns.active && "border-surface-gray-10 text-ink-gray-9",
        !assigns.active && "text-ink-gray-5 hover:text-ink-gray-8 border-transparent"
      ])

    ~H"""
    <.link
      :if={@link?}
      role="tab"
      aria-selected={to_string(@active)}
      aria-controls={@panel_id}
      class={@classes}
      {@nav}
    >
      <Icon.icon :if={@icon} name={@icon} class="size-4" />{@tab.label}
    </.link>
    <button
      :if={!@link?}
      type="button"
      role="tab"
      aria-selected={to_string(@active)}
      aria-controls={@panel_id}
      phx-click={@click}
      class={@classes}
    >
      <Icon.icon :if={@icon} name={@icon} class="size-4" />{@tab.label}
    </button>
    """
  end
end
