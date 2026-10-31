defmodule FrappeUIPhx.Components.Slider do
  @moduledoc "Controle deslizante (`<input type=range>`); `min <= value <= max` é pré-condição."
  use Phoenix.Component

  alias FrappeUIPhx.{Contract, Field}

  attr :field, Phoenix.HTML.FormField, default: nil
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :min, :integer, default: 0
  attr :max, :integer, default: 100
  attr :step, :integer, default: 1
  attr :show_value, :boolean, default: false
  attr :errors, :list, default: []
  attr :disabled, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(form)

  def slider(assigns) do
    Contract.ensure!(assigns.min < assigns.max, "slider: min deve ser menor que max")
    Contract.ensure!(assigns.step > 0, "slider: step deve ser positivo")
    assigns = Field.assign_field(assigns)

    ~H"""
    <div class={["flex items-center gap-3", @class]}>
      <input
        type="range"
        id={@id}
        name={@name}
        min={@min}
        max={@max}
        step={@step}
        value={@value || @min}
        disabled={@disabled}
        aria-invalid={@errors != [] && "true"}
        class="accent-surface-gray-10 h-1 w-full cursor-pointer disabled:cursor-not-allowed disabled:opacity-60"
        {@rest}
      />
      <output :if={@show_value} for={@id} class="fui-text-base text-ink-gray-7 w-10 text-right">
        {@value || @min}
      </output>
    </div>
    """
  end
end
