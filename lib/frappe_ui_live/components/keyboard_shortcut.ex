defmodule FrappeUILive.Components.KeyboardShortcut do
  @moduledoc "Atalho de teclado: uma `<kbd>` por tecla (`keys={[\"Ctrl\", \"K\"]}`)."
  use Phoenix.Component

  attr :keys, :list, required: true, doc: "lista de teclas, ex.: [\"Ctrl\", \"K\"]"
  attr :class, :any, default: nil
  attr :rest, :global

  def keyboard_shortcut(assigns) do
    ~H"""
    <span class={["inline-flex items-center gap-1", @class]} {@rest}>
      <kbd
        :for={key <- @keys}
        class="bg-surface-gray-2 text-ink-gray-6 border-outline-gray-2 fui-text-xs inline-flex h-5 min-w-5 items-center justify-center rounded-3 border px-1 font-sans"
      >
        {key}
      </kbd>
    </span>
    """
  end
end
