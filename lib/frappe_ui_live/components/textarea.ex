defmodule FrappeUILive.Components.Textarea do
  @moduledoc "Campo de várias linhas; mesmo contrato de `FrappeUILive.Components.TextInput`."
  use Phoenix.Component

  alias FrappeUILive.Components.InputStyle
  alias FrappeUILive.{Contract, Field}

  attr :field, Phoenix.HTML.FormField, default: nil
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :variant, :atom, default: :subtle, values: InputStyle.variants()
  attr :size, :atom, default: :sm, values: InputStyle.sizes()
  attr :rows, :integer, default: 3
  attr :errors, :list, default: []
  attr :disabled, :boolean, default: false
  attr :class, :any, default: nil

  attr :rest, :global,
    include: ~w(autofocus cols form maxlength minlength placeholder readonly required)

  def textarea(assigns) do
    Contract.require!(assigns.variant, InputStyle.variants(), "textarea variant")
    Contract.require!(assigns.size, InputStyle.sizes(), "textarea size")
    assigns = Field.assign_field(assigns)

    ~H"""
    <textarea
      id={@id}
      name={@name}
      rows={@rows}
      disabled={@disabled}
      aria-invalid={@errors != [] && "true"}
      class={[
        InputStyle.classes(@variant, @size,
          invalid: @errors != [],
          disabled: @disabled,
          class: @class
        ),
        "h-auto min-h-7"
      ]}
      {@rest}
    >{Phoenix.HTML.Form.normalize_value("textarea", @value)}</textarea>
    """
  end
end
