defmodule FrappeUIPhx.Components.Duration do
  @moduledoc """
  Campo de duração: mostra `1h 30m` quando o valor são segundos e aceita o que
  `FrappeUIPhx.Duration` entende. Combine com `FrappeUIPhx.Ecto.Duration` no schema.
  """
  use Phoenix.Component

  alias FrappeUIPhx.Components.{InputStyle, TextInput}
  alias FrappeUIPhx.{Duration, Field}

  attr :field, Phoenix.HTML.FormField, default: nil
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :variant, :atom, default: :subtle, values: InputStyle.variants()
  attr :size, :atom, default: :sm, values: InputStyle.sizes()
  attr :errors, :list, default: []
  attr :disabled, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(autofocus form placeholder required)

  def duration(assigns) do
    assigns = Field.assign_field(assigns)

    ~H"""
    <TextInput.text_input
      id={@id}
      name={@name}
      value={Duration.display(@value)}
      variant={@variant}
      size={@size}
      errors={@errors}
      disabled={@disabled}
      class={@class}
      inputmode="text"
      autocomplete="off"
      placeholder="1h 30m"
      {@rest}
    />
    """
  end
end
