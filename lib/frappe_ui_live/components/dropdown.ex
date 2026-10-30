defmodule FrappeUILive.Components.Dropdown do
  @moduledoc """
  Menu suspenso sem JavaScript: Popover API (light-dismiss e Esc nativos) +
  CSS Anchor Positioning (inverte para cima quando falta espaço).

  Cada `:item` pode disparar um evento (`click`) ou navegar (`navigate`,
  `patch`, `href`); o menu fecha ao escolher.
  """
  use Phoenix.Component

  alias FrappeUILive.Components.{Anchor, Button, Icon, MenuItem}

  attr :id, :string, required: true
  attr :label, :string, default: nil, doc: "texto do botão padrão (ignorado se houver `:trigger`)"
  attr :icon, :string, default: nil, doc: "ícone do botão padrão"
  attr :class, :any, default: nil
  attr :rest, :global
  slot :trigger, doc: "conteúdo do gatilho personalizado"

  slot :item, required: true do
    attr :label, :string, required: true
    attr :icon, :string
    attr :click, :any, doc: "evento do servidor ou comando JS"
    attr :navigate, :string
    attr :patch, :string
    attr :href, :string
    attr :theme, :atom, doc: ":gray (padrão) ou :red"
  end

  def dropdown(assigns) do
    Anchor.valid_id!(assigns.id, "dropdown")

    assigns =
      assigns
      |> assign(:anchor_style, Anchor.trigger_style(assigns.id))
      |> assign(:menu_style, Anchor.panel_style(assigns.id))
      |> assign(:trigger_class, Button.classes(%{theme: :gray, variant: :subtle, size: :sm}))

    ~H"""
    <div class={["inline-block", @class]} {@rest}>
      <button
        type="button"
        popovertarget={@id}
        style={@anchor_style}
        aria-haspopup="menu"
        class={@trigger == [] && @trigger_class}
      >
        <%= if @trigger != [] do %>
          {render_slot(@trigger)}
        <% else %>
          <Icon.icon :if={@icon} name={@icon} class="size-4" />
          <span :if={@label}>{@label}</span>
          <Icon.icon name="chevron-down" class="size-4" />
        <% end %>
      </button>
      <div
        id={@id}
        popover
        role="menu"
        style={@menu_style}
        class={[Anchor.panel_classes(), "min-w-40 border p-1"]}
      >
        <%= for item <- @item do %>
          <MenuItem.menu_item item={item} popover_id={@id} />
        <% end %>
      </div>
    </div>
    """
  end
end
