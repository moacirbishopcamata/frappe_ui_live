defmodule FrappeUIPhx.Components.RadioGroup do
  @moduledoc "Grupo de opções exclusivas (`<input type=radio>` nativos); `options` como em `Select`."
  use Phoenix.Component

  alias FrappeUIPhx.{Contract, Field}

  @orientations ~w(vertical horizontal)a

  attr :field, Phoenix.HTML.FormField, default: nil
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :options, :list, required: true, doc: "strings ou {rótulo, valor}"
  attr :label, :string, default: nil
  attr :orientation, :atom, default: :vertical, values: @orientations
  attr :errors, :list, default: []
  attr :disabled, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(form required)

  def radio_group(assigns) do
    Contract.require!(assigns.orientation, @orientations, "radio_group orientation")
    assigns = Field.assign_field(assigns)
    current = to_string(assigns.value)

    assigns =
      assign(assigns, :choices, for(opt <- assigns.options, do: choice(opt, current)))

    ~H"""
    <fieldset class={@class} aria-invalid={@errors != [] && "true"}>
      <legend :if={@label} class="fui-text-sm text-ink-gray-6 mb-1.5">{@label}</legend>
      <div class={[
        "flex gap-2",
        @orientation == :vertical && "flex-col",
        @orientation == :horizontal && "flex-row flex-wrap gap-4"
      ]}>
        <label
          :for={{label, value, checked} <- @choices}
          :key={value}
          class="inline-flex cursor-pointer items-center gap-2"
        >
          <input
            type="radio"
            name={@name}
            value={value}
            checked={checked}
            disabled={@disabled}
            class="border-outline-gray-4 bg-surface-base checked:border-surface-gray-10 hover:border-outline-gray-5 focus-visible:focus-ring size-4 appearance-none rounded-full border checked:border-[5px]"
            {@rest}
          />
          <span class="fui-text-base text-ink-gray-8">{label}</span>
        </label>
      </div>
    </fieldset>
    """
  end

  @doc "Normaliza uma opção em `{rótulo, valor, marcada?}`."
  @spec choice(String.t() | {term(), term()}, String.t()) :: {String.t(), String.t(), boolean()}
  def choice({label, value}, current),
    do: {to_string(label), to_string(value), to_string(value) == current}

  def choice(value, current), do: choice({value, value}, current)
end
