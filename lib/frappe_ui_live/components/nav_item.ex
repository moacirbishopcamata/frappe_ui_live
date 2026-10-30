defmodule FrappeUILive.Components.NavItem do
  @moduledoc """
  Item de navegação com ícone e rótulo (Sidebar, SidebarRail, TabButtons,
  MobileShell). Navega por `patch`/`navigate`/`href` ou dispara `click`. O
  estado ativo é decidido por quem chama (assign do servidor).
  """
  use Phoenix.Component

  alias FrappeUILive.Components.Icon

  attr :item, :map, required: true, doc: "id, label, icon, patch, navigate, href, click"
  attr :active, :boolean, default: false
  attr :class, :any, default: nil
  attr :icon_only, :boolean, default: false, doc: "esconde o rótulo (continua acessível)"
  attr :stacked, :boolean, default: false, doc: "ícone acima do rótulo"
  attr :role, :string, default: nil

  def nav_item(assigns) do
    item = assigns.item
    nav = Map.take(item, [:patch, :navigate, :href])

    assigns =
      assigns
      |> assign(:nav, nav)
      |> assign(:link?, nav != %{})
      |> assign(:click, Map.get(item, :click))
      |> assign(:icon, Map.get(item, :icon))
      |> assign(:aria_current, if(assigns.active, do: "page"))

    ~H"""
    <.link
      :if={@link?}
      role={@role}
      aria-current={@aria_current}
      aria-selected={@role == "tab" && to_string(@active)}
      title={@icon_only && @item.label}
      class={[classes(@stacked), @class]}
      {@nav}
    >
      <.inner item={@item} icon={@icon} icon_only={@icon_only} />
    </.link>
    <button
      :if={!@link?}
      type="button"
      role={@role}
      aria-current={@aria_current}
      aria-selected={@role == "tab" && to_string(@active)}
      title={@icon_only && @item.label}
      phx-click={@click}
      class={[classes(@stacked), @class]}
    >
      <.inner item={@item} icon={@icon} icon_only={@icon_only} />
    </button>
    """
  end

  defp classes(stacked?) do
    [
      "focus-visible:focus-ring flex items-center transition-colors",
      if(stacked?, do: "flex-col gap-0.5", else: "gap-2")
    ]
  end

  attr :item, :map, required: true
  attr :icon, :string, default: nil
  attr :icon_only, :boolean, required: true

  defp inner(assigns) do
    ~H"""
    <Icon.icon :if={@icon} name={@icon} class="size-4 shrink-0" />
    <span class={[@icon_only && "sr-only", !@icon_only && "truncate"]}>{@item.label}</span>
    """
  end
end
