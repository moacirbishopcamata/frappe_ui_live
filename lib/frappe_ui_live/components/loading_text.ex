defmodule FrappeUILive.Components.LoadingText do
  @moduledoc "Texto de carregamento com spinner."
  use Phoenix.Component

  alias FrappeUILive.Components.Spinner

  attr :text, :string, default: "Carregando…"
  attr :class, :any, default: nil
  attr :rest, :global

  def loading_text(assigns) do
    ~H"""
    <span class={["fui-text-base text-ink-gray-5 inline-flex items-center gap-2", @class]} {@rest}>
      <Spinner.spinner class="size-4" />{@text}
    </span>
    """
  end
end
