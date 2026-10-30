defmodule FrappeUILive.Components.Dropdown do
  @moduledoc """
  Menu suspenso sem JavaScript: Popover API (light-dismiss e Esc nativos) +
  CSS Anchor Positioning (inverte para cima quando falta espaço).

  Cada `:item` pode disparar um evento (`click`) ou navegar (`navigate`,
  `patch`, `href`); o menu fecha ao escolher.
  """
  use Phoenix.Component

  alias FrappeUILive.Components.{Button, Icon}
  alias FrappeUILive.Contract

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
    Contract.ensure!(Regex.match?(~r/\A[A-Za-z][\w-]*\z/, assigns.id), "dropdown id inválido: #{inspect(assigns.id)}")
    anchor = "--fui-#{assigns.id}"

    assigns =
      assigns
      |> assign(:anchor, anchor)
      |> assign(
        :menu_style,
        "position-anchor: #{anchor}; position-area: bottom span-right; position-try-fallbacks: flip-block; inset: auto; margin: 4px 0;"
      )

    ~H"""
    <div class={["inline-block", @class]} {@rest}>
      <button
        type="button"
        popovertarget={@id}
        style={"anchor-name: #{@anchor}"}
        aria-haspopup="menu"
        class={@trigger == [] && trigger_classes()}
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
        class="bg-surface-elevation-1 rounded-5 border-outline-gray-1 shadow-elevation-md min-w-40 border p-1"
      >
        <%= for item <- @item do %>
          <.menu_item item={item} popover_id={@id} />
        <% end %>
      </div>
    </div>
    """
  end

  defp trigger_classes do
    Button.classes(%{theme: :gray, variant: :subtle, size: :sm})
  end

  attr :item, :map, required: true
  attr :popover_id, :string, required: true

  defp menu_item(assigns) do
    item = assigns.item
    theme = Map.get(item, :theme, :gray)
    link? = Enum.any?([:navigate, :patch, :href], &Map.has_key?(item, &1))

    assigns =
      assigns
      |> assign(:link?, link?)
      |> assign(:click, Map.get(item, :click))
      |> assign(:icon, Map.get(item, :icon))
      |> assign(:nav, Map.take(item, [:navigate, :patch, :href]))
      |> assign(:classes, item_classes(theme))

    ~H"""
    <.link :if={@link?} role="menuitem" class={@classes} {@nav}>
      <Icon.icon :if={@icon} name={@icon} class="size-4" />{@item.label}
    </.link>
    <button
      :if={!@link?}
      type="button"
      role="menuitem"
      popovertarget={@popover_id}
      popovertargetaction="hide"
      phx-click={@click}
      class={@classes}
    >
      <Icon.icon :if={@icon} name={@icon} class="size-4" />{@item.label}
    </button>
    """
  end

  @doc false
  def item_classes(:red),
    do: "fui-text-base text-ink-red-3 hover:bg-surface-red-2 flex w-full items-center gap-2 rounded-4 px-2 py-1.5 text-left"

  def item_classes(_gray),
    do: "fui-text-base text-ink-gray-7 hover:bg-surface-gray-2 flex w-full items-center gap-2 rounded-4 px-2 py-1.5 text-left"
end
