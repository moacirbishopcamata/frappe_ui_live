defmodule FrappeUILive.Components.TextInput do
  @moduledoc """
  Campo de uma linha. Aceita `field={@form[:campo]}` (Phoenix/Ecto) ou
  `name`/`value` avulsos. Restrições (`required`, `maxlength`, `min`, `pattern`,
  `placeholder`...) vão direto ao `<input>`; o servidor continua sendo a
  barreira real (o `required` aqui espelha a regra do changeset).
  """
  use Phoenix.Component

  alias FrappeUILive.Components.InputStyle
  alias FrappeUILive.{Contract, Field}

  @types ~w(text email number password search tel url date time datetime-local month week color)

  attr :field, Phoenix.HTML.FormField, default: nil
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :type, :string, default: "text", values: @types
  attr :variant, :atom, default: :subtle, values: InputStyle.variants()
  attr :size, :atom, default: :sm, values: InputStyle.sizes()
  attr :errors, :list, default: []
  attr :disabled, :boolean, default: false
  attr :class, :any, default: nil

  attr :rest, :global,
    include:
      ~w(autocomplete autofocus form list max maxlength min minlength pattern placeholder readonly required step inputmode)

  def text_input(assigns) do
    Contract.require!(assigns.type, @types, "text_input type")
    Contract.require!(assigns.variant, InputStyle.variants(), "text_input variant")
    Contract.require!(assigns.size, InputStyle.sizes(), "text_input size")
    assigns = Field.assign_field(assigns)

    ~H"""
    <input
      type={@type}
      id={@id}
      name={@name}
      value={Phoenix.HTML.Form.normalize_value(@type, @value)}
      disabled={@disabled}
      aria-invalid={@errors != [] && "true"}
      class={
        InputStyle.classes(@variant, @size,
          invalid: @errors != [],
          disabled: @disabled,
          class: @class
        )
      }
      {@rest}
    />
    """
  end
end
