defmodule FrappeUILive.Components.Select do
  @moduledoc """
  Seleção nativa. `options` aceita lista de strings, `{rótulo, valor}` ou
  keyword; `prompt` adiciona uma primeira opção vazia.
  """
  use Phoenix.Component

  alias FrappeUILive.Components.{Icon, InputStyle}
  alias FrappeUILive.{Contract, Field}

  attr :field, Phoenix.HTML.FormField, default: nil
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :options, :list, required: true
  attr :prompt, :string, default: nil
  attr :multiple, :boolean, default: false
  attr :variant, :atom, default: :subtle, values: InputStyle.variants()
  attr :size, :atom, default: :sm, values: InputStyle.sizes()
  attr :errors, :list, default: []
  attr :disabled, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(autofocus form required)

  def select(assigns) do
    Contract.require!(assigns.variant, InputStyle.variants(), "select variant")
    Contract.require!(assigns.size, InputStyle.sizes(), "select size")
    assigns = Field.assign_field(assigns)

    ~H"""
    <div class="relative w-full">
      <select
        id={@id}
        name={@name}
        multiple={@multiple}
        disabled={@disabled}
        aria-invalid={@errors != [] && "true"}
        class={[
          InputStyle.classes(@variant, @size,
            invalid: @errors != [],
            disabled: @disabled,
            class: @class
          ),
          "appearance-none pr-7"
        ]}
        {@rest}
      >
        <option :if={@prompt} value="">{@prompt}</option>
        {Phoenix.HTML.Form.options_for_select(@options, @value)}
      </select>
      <Icon.icon
        :if={!@multiple}
        name="chevron-down"
        class="text-ink-gray-5 pointer-events-none absolute top-1/2 right-2 size-4 -translate-y-1/2"
      />
    </div>
    """
  end
end
