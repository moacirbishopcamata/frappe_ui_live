defmodule FrappeUIPhx.Components.KeyboardShortcutsDialog do
  @moduledoc "Diálogo com a lista de atalhos: `shortcuts={[%{label: \"Buscar\", keys: [\"Ctrl\", \"K\"]}]}`."
  use Phoenix.Component

  alias FrappeUIPhx.Texts

  alias FrappeUIPhx.Components.{Dialog, KeyboardShortcut}
  alias FrappeUIPhx.Contract

  attr :id, :string, required: true
  attr :open, :boolean, default: false
  attr :title, :string, default: nil
  attr :shortcuts, :list, required: true, doc: "lista de %{label: String, keys: [String]}"
  attr :on_close, :string, default: nil
  attr :rest, :global

  def keyboard_shortcuts_dialog(assigns) do
    assigns = assign(assigns, :title, assigns.title || Texts.t(:shortcuts))

    Contract.ensure!(
      Enum.all?(assigns.shortcuts, &(is_binary(&1[:label]) and is_list(&1[:keys]))),
      "keyboard_shortcuts_dialog: cada atalho precisa de label (texto) e keys (lista)"
    )

    ~H"""
    <Dialog.dialog id={@id} open={@open} title={@title} on_close={@on_close} size={:md} {@rest}>
      <ul class="divide-outline-gray-1 divide-y">
        <li :for={shortcut <- @shortcuts} class="flex items-center justify-between py-2">
          <span class="fui-text-base text-ink-gray-7">{shortcut.label}</span>
          <KeyboardShortcut.keyboard_shortcut keys={shortcut.keys} />
        </li>
      </ul>
    </Dialog.dialog>
    """
  end
end
