defmodule FrappeUIPhx.Components.Password do
  @moduledoc """
  Campo de senha com botão de mostrar/ocultar. A alternância é só visual
  (`JS.toggle_attribute` no `type`); o valor **nunca** é reenviado ao HTML.
  """
  use Phoenix.Component

  alias FrappeUIPhx.Texts

  alias FrappeUIPhx.Components.{Icon, InputStyle, TextInput}
  alias FrappeUIPhx.Field
  alias Phoenix.LiveView.JS

  attr :field, Phoenix.HTML.FormField, default: nil
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :variant, :atom, default: :subtle, values: InputStyle.variants()
  attr :size, :atom, default: :sm, values: InputStyle.sizes()
  attr :errors, :list, default: []
  attr :disabled, :boolean, default: false
  attr :class, :any, default: nil

  attr :rest, :global,
    include: ~w(autocomplete autofocus form maxlength minlength placeholder required)

  def password(assigns) do
    assigns = Field.assign_field(assigns)
    Field.require_id!(assigns, "password")

    ~H"""
    <div class="relative w-full">
      <TextInput.text_input
        id={@id}
        name={@name}
        value={nil}
        type="password"
        variant={@variant}
        size={@size}
        errors={@errors}
        disabled={@disabled}
        class={["pr-8", @class]}
        {@rest}
      />
      <button
        type="button"
        aria-label={Texts.t(:toggle_password)}
        disabled={@disabled}
        phx-click={JS.toggle_attribute({"type", "password", "text"}, to: "##{@id}")}
        class="text-ink-gray-5 hover:text-ink-gray-8 absolute top-1/2 right-1.5 -translate-y-1/2"
      >
        <Icon.icon name="eye" class="size-4" />
      </button>
    </div>
    """
  end
end
