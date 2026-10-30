defmodule FrappeUILive.Components.Checkbox do
  @moduledoc """
  Caixa de seleção com rótulo opcional. Emite o `hidden` com `"false"` como o
  `core_components` do Phoenix, para que o desmarcado chegue ao servidor.
  """
  use Phoenix.Component

  alias FrappeUILive.Components.Icon
  alias FrappeUILive.Field

  attr :field, Phoenix.HTML.FormField, default: nil
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :checked, :boolean, doc: "padrão: derivado de `value`"
  attr :label, :string, default: nil
  attr :errors, :list, default: []
  attr :disabled, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(form required)

  def checkbox(assigns) do
    assigns = Field.assign_field(assigns)

    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <label class={[
      "inline-flex items-center gap-2",
      @disabled && "cursor-not-allowed",
      !@disabled && "cursor-pointer",
      @class
    ]}>
      <input type="hidden" name={@name} value="false" disabled={@disabled} />
      <span class="relative mt-px inline-flex">
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          disabled={@disabled}
          aria-invalid={@errors != [] && "true"}
          class="peer border-outline-gray-4 bg-surface-base checked:border-surface-gray-10 checked:bg-surface-gray-10 hover:border-outline-gray-5 focus-visible:focus-ring size-4 appearance-none rounded-1 border transition disabled:cursor-not-allowed disabled:opacity-60"
          {@rest}
        />
        <Icon.icon
          name="check"
          class="text-ink-base pointer-events-none absolute inset-0 m-auto hidden size-3 peer-checked:block"
        />
      </span>
      <span :if={@label} class="fui-text-base text-ink-gray-8">{@label}</span>
    </label>
    """
  end
end
