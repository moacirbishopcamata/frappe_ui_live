defmodule FrappeUILive.Components.FormLabel do
  @moduledoc "Rótulo de campo; `required` acrescenta o asterisco e deve espelhar o `required` do controle."
  use Phoenix.Component

  attr :for, :string, default: nil
  attr :required, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def form_label(assigns) do
    ~H"""
    <label for={@for} class={["fui-text-sm text-ink-gray-6 block leading-[1.35]", @class]} {@rest}>
      {render_slot(@inner_block)}<span :if={@required} class="text-ink-red-5" aria-hidden="true"> *</span>
    </label>
    """
  end
end
