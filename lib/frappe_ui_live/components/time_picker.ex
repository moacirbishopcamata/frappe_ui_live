defmodule FrappeUILive.Components.TimePicker do
  @moduledoc "Seletor de horário (`<input type=time>` nativo, com o teclado/relógio do dispositivo); `step` em segundos."
  use Phoenix.Component

  alias FrappeUILive.Components.{InputStyle, TextInput}
  alias FrappeUILive.{Contract, Field}

  attr :field, Phoenix.HTML.FormField, default: nil
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :step, :integer, default: 60, doc: "segundos; 60 = minutos, 1 = com segundos"
  attr :variant, :atom, default: :subtle, values: InputStyle.variants()
  attr :size, :atom, default: :sm, values: InputStyle.sizes()
  attr :errors, :list, default: []
  attr :disabled, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(autofocus form min max required)

  def time_picker(assigns) do
    Contract.ensure!(assigns.step > 0, "time_picker: step deve ser positivo")
    assigns = Field.assign_field(assigns)

    ~H"""
    <TextInput.text_input
      id={@id}
      name={@name}
      value={@value}
      type="time"
      step={@step}
      variant={@variant}
      size={@size}
      errors={@errors}
      disabled={@disabled}
      class={@class}
      {@rest}
    />
    """
  end
end
