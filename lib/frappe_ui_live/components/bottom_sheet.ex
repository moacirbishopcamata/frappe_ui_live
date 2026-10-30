defmodule FrappeUILive.Components.BottomSheet do
  @moduledoc "Folha inferior (mobile): um `Dialog` com `placement: :bottom`; abre/fecha com `show_dialog/1` e `hide_dialog/1`."
  use Phoenix.Component

  alias FrappeUILive.Components.Dialog

  attr :id, :string, required: true
  attr :open, :boolean, default: false
  attr :title, :string, default: nil
  attr :on_close, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true
  slot :actions

  def bottom_sheet(assigns) do
    ~H"""
    <Dialog.dialog
      id={@id}
      open={@open}
      title={@title}
      on_close={@on_close}
      placement={:bottom}
      class={@class}
      {@rest}
    >
      {render_slot(@inner_block)}
      <:actions :if={@actions != []}>{render_slot(@actions)}</:actions>
    </Dialog.dialog>
    """
  end
end
