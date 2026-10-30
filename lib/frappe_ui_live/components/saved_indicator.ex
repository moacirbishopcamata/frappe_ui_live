defmodule FrappeUILive.Components.SavedIndicator do
  @moduledoc """
  Confirmação visual transitória ("Salvo") sem `useEffect`/timer: o servidor
  devolve um valor que muda a cada sucesso (`at`, ex. um timestamp) e o `:key`
  remonta o elemento, reiniciando a animação CSS que termina em opacidade 0.
  """
  use Phoenix.Component

  alias FrappeUILive.Texts

  alias FrappeUILive.Components.Icon

  attr :at, :any, default: nil, doc: "muda a cada sucesso; `nil` não mostra nada"
  attr :label, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  def saved_indicator(assigns) do
    assigns = assign(assigns, :label, assigns.label || Texts.t(:saved))

    ~H"""
    <span aria-live="polite" class={["inline-flex h-5 items-center", @class]} {@rest}>
      <span
        :for={stamp <- List.wrap(@at)}
        :key={stamp}
        class="fui-saved text-ink-green-5 fui-text-sm inline-flex items-center gap-1"
      >
        <Icon.icon name="check" class="size-3.5" />{@label}
      </span>
    </span>
    """
  end
end
