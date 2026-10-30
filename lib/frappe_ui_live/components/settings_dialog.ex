defmodule FrappeUILive.Components.SettingsDialog do
  @moduledoc """
  Diálogo de configurações: navegação lateral por seções (`:tab`) e o conteúdo
  da seção ativa. A seção ativa (`active`) é um assign do servidor.
  """
  use Phoenix.Component

  alias FrappeUILive.Texts

  alias FrappeUILive.Components.{Dialog, NavItem}

  attr :id, :string, required: true
  attr :open, :boolean, default: false
  attr :title, :string, default: nil
  attr :active, :string, required: true, doc: "id da seção ativa"
  attr :on_close, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true, doc: "conteúdo da seção ativa"

  slot :tab, required: true do
    attr :id, :string, required: true
    attr :label, :string, required: true
    attr :icon, :string
    attr :patch, :string
    attr :navigate, :string
    attr :href, :string
    attr :click, :any
  end

  def settings_dialog(assigns) do
    assigns = assign(assigns, :title, assigns.title || Texts.t(:settings))

    assigns =
      assign(
        assigns,
        :active,
        NavItem.known_active(assigns.active, Enum.map(assigns.tab, & &1.id))
      )

    ~H"""
    <Dialog.dialog id={@id} open={@open} title={@title} on_close={@on_close} size={:"2xl"} {@rest}>
      <div class="flex min-h-64 gap-6">
        <nav aria-label={@title} class="w-44 shrink-0 space-y-0.5">
          <NavItem.nav_item
            :for={item <- @tab}
            item={item}
            active={item.id == @active}
            class={[
              "fui-text-base w-full rounded-4 px-2 py-1.5 text-left",
              item.id == @active && "bg-surface-gray-3 text-ink-gray-9",
              item.id != @active && "text-ink-gray-7 hover:bg-surface-gray-2"
            ]}
          />
        </nav>
        <section class="min-w-0 flex-1">{render_slot(@inner_block)}</section>
      </div>
    </Dialog.dialog>
    """
  end
end
