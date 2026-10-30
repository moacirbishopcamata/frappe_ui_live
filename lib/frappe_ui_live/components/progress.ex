defmodule FrappeUILive.Components.Progress do
  @moduledoc "Barra de progresso (`value` de 0 a 100) com rótulo e valor opcionais."
  use Phoenix.Component

  alias FrappeUILive.Contract

  @sizes ~w(sm md lg xl)a
  @size_classes %{sm: "h-[2px]", md: "h-1", lg: "h-2", xl: "h-3"}

  attr :value, :integer, required: true, doc: "0..100"
  attr :size, :atom, default: :md, values: @sizes
  attr :label, :string, default: nil
  attr :show_value, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global

  def progress(assigns) do
    Contract.require!(assigns.size, @sizes, "progress size")

    Contract.ensure!(
      is_integer(assigns.value) and assigns.value in 0..100,
      "progress value: #{inspect(assigns.value)} fora de 0..100"
    )

    assigns = assign(assigns, :bar_class, @size_classes[assigns.size])

    ~H"""
    <div class={["w-full space-y-[10px]", @class]} {@rest}>
      <div :if={@label || @show_value} class="flex items-center justify-between">
        <span :if={@label} class="fui-text-base-medium text-ink-gray-8">{@label}</span>
        <span :if={@show_value} class="fui-text-base-medium text-ink-gray-4">{@value}%</span>
      </div>
      <div
        role="progressbar"
        aria-valuemin="0"
        aria-valuemax="100"
        aria-valuenow={@value}
        class={["bg-surface-gray-2 transform-gpu overflow-hidden rounded-7", @bar_class]}
      >
        <div
          class="bg-surface-gray-10 h-full transition-[width] duration-[660ms] ease-[cubic-bezier(0.65,0,0.35,1)] motion-reduce:transition-none"
          style={"width: #{@value}%"}
        >
        </div>
      </div>
    </div>
    """
  end
end
