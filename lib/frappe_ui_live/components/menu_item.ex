defmodule FrappeUILive.Components.MenuItem do
  @moduledoc """
  Item de menu (Dropdown, ContextMenu): navega (`navigate`/`patch`/`href`) ou
  dispara evento (`click`) e fecha o popover pai. Tema `:gray` ou `:red`.
  """
  use Phoenix.Component

  alias FrappeUILive.Components.{Action, Icon}

  attr :item, :map,
    required: true,
    doc: "mapa do slot: label, icon, click, navigate, patch, href, theme"

  attr :popover_id, :string, required: true
  attr :rest, :global

  def menu_item(assigns) do
    assigns =
      assigns
      |> assign(:icon, Map.get(assigns.item, :icon))
      |> assign(:classes, classes(Map.get(assigns.item, :theme, :gray)))

    ~H"""
    <Action.action item={@item} role="menuitem" popover_id={@popover_id} class={@classes} {@rest}>
      <Icon.icon :if={@icon} name={@icon} class="size-4" />{@item.label}
    </Action.action>
    """
  end

  @doc "Classes do item para o tema."
  @spec classes(atom()) :: String.t()
  def classes(:red),
    do:
      "fui-text-base text-ink-red-3 hover:bg-surface-red-2 flex w-full items-center gap-2 rounded-4 px-2 py-1.5 text-left"

  def classes(_gray),
    do:
      "fui-text-base text-ink-gray-7 hover:bg-surface-gray-2 flex w-full items-center gap-2 rounded-4 px-2 py-1.5 text-left"
end
