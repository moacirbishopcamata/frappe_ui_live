defmodule FrappeUILive.Components.ContextMenu do
  @moduledoc """
  Menu de contexto (botão direito) sobre uma região. O hook colocated só
  posiciona e abre o `popover` no cursor; o que cada item faz é decidido pelo
  servidor (`click`) ou por navegação.
  """
  use Phoenix.Component

  alias FrappeUILive.Components.{Anchor, MenuItem}

  attr :id, :string, required: true
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true, doc: "região que responde ao botão direito"

  slot :item, required: true do
    attr :label, :string, required: true
    attr :icon, :string
    attr :click, :any
    attr :navigate, :string
    attr :patch, :string
    attr :href, :string
    attr :theme, :atom
  end

  def context_menu(assigns) do
    Anchor.valid_id!(assigns.id, "context_menu")
    assigns = assign(assigns, :menu_id, "#{assigns.id}-menu")

    ~H"""
    <div id={@id} phx-hook=".ContextMenu" data-menu={@menu_id} class={@class} {@rest}>
      {render_slot(@inner_block)}
    </div>
    <div
      id={@menu_id}
      popover
      role="menu"
      class="bg-surface-elevation-1 rounded-5 border-outline-gray-1 shadow-elevation-md m-0 min-w-40 border p-1"
      style="inset: auto;"
    >
      <%= for item <- @item do %>
        <MenuItem.menu_item item={item} popover_id={@menu_id} />
      <% end %>
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".ContextMenu">
      export default {
        mounted() {
          this.el.addEventListener("contextmenu", (event) => {
            const menu = document.getElementById(this.el.dataset.menu)
            if (!menu) return
            event.preventDefault()
            menu.showPopover()
            // fica dentro da janela: abre à esquerda/acima se não couber
            const x = Math.min(event.clientX, window.innerWidth - menu.offsetWidth - 4)
            const y = Math.min(event.clientY, window.innerHeight - menu.offsetHeight - 4)
            menu.style.left = Math.max(4, x) + "px"
            menu.style.top = Math.max(4, y) + "px"
          })
        }
      }
    </script>
    """
  end
end
