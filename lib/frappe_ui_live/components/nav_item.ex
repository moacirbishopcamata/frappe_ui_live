defmodule FrappeUILive.Components.NavItem do
  @moduledoc """
  Item de navegação com ícone e rótulo (Tabs, TabButtons, Sidebar, SidebarRail,
  SettingsDialog, MobileShell). Navega por `patch`/`navigate`/`href` ou dispara `click`
  (evento ou `%JS{}`) — a decisão "link ou botão" é de `FrappeUILive.Components.Action`.
  O estado ativo é decidido por quem chama (assign do servidor).

  Vocabulário **único** dos slots de item (todos os componentes de navegação o aceitam):
  `id`, `label`, `icon`, `patch`, `navigate`, `href`, `click`.
  """
  use Phoenix.Component

  alias FrappeUILive.Components.{Action, Icon}

  @doc """
  Item ativo seguro: devolve `active` se for um dos `ids`, senão `nil` (nenhum ativo).

  `active` costuma vir da URL (`?tab=...`); valor desconhecido é entrada de usuário e
  não pode derrubar a página.
  """
  @spec known_active(String.t() | nil, [String.t()]) :: String.t() | nil
  def known_active(active, ids), do: if(active in ids, do: active)

  attr :item, :map, required: true, doc: "id, label, icon, patch, navigate, href, click"
  attr :active, :boolean, default: false
  attr :class, :any, default: nil
  attr :icon_only, :boolean, default: false, doc: "esconde o rótulo (continua acessível)"
  attr :stacked, :boolean, default: false, doc: "ícone acima do rótulo"
  attr :role, :string, default: nil
  attr :rest, :global, doc: "ex.: aria-controls"

  def nav_item(assigns) do
    assigns =
      assigns
      |> assign(:icon, Map.get(assigns.item, :icon))
      |> assign(:aria_current, if(assigns.active, do: "page"))
      |> assign(:aria_selected, assigns.role == "tab" && to_string(assigns.active))
      |> assign(:title, assigns.icon_only && assigns.item.label)

    ~H"""
    <Action.action
      item={@item}
      role={@role}
      aria-current={@aria_current}
      aria-selected={@aria_selected}
      title={@title}
      class={[classes(@stacked), @class]}
      {@rest}
    >
      <.inner item={@item} icon={@icon} icon_only={@icon_only} />
    </Action.action>
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
