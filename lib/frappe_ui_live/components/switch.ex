defmodule FrappeUILive.Components.Switch do
  @moduledoc "Interruptor. É um checkbox nativo (`peer`), então funciona em formulários sem JS."
  use Phoenix.Component

  alias FrappeUILive.Contract
  alias FrappeUILive.Field

  @sizes ~w(sm md)a

  attr :field, Phoenix.HTML.FormField, default: nil
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :checked, :boolean
  attr :label, :string, default: nil
  attr :size, :atom, default: :sm, values: @sizes
  attr :errors, :list, default: []
  attr :disabled, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(form)

  def switch(assigns) do
    Contract.require!(assigns.size, @sizes, "switch size")
    assigns = Field.assign_field(assigns)

    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <label class={["inline-flex items-center gap-2.5", @disabled && "cursor-not-allowed", !@disabled && "cursor-pointer", @class]}>
      <input type="hidden" name={@name} value="false" disabled={@disabled} />
      <input
        type="checkbox"
        role="switch"
        id={@id}
        name={@name}
        value="true"
        checked={@checked}
        disabled={@disabled}
        class="peer sr-only"
        {@rest}
      />
      <span class={[
        "bg-surface-gray-4 peer-checked:bg-surface-gray-10 peer-focus-visible:focus-ring relative inline-flex shrink-0 items-center rounded-full transition-colors duration-100 peer-disabled:opacity-60",
        @size == :sm && "h-4 w-[26px] [&>span]:size-3 peer-checked:[&>span]:translate-x-[10px]",
        @size == :md && "h-5 w-8 [&>span]:size-3.5 peer-checked:[&>span]:translate-x-3"
      ]}>
        <span class="bg-surface-base pointer-events-none ml-0.5 inline-block rounded-full shadow-elevation-sm transition-transform duration-100">
        </span>
      </span>
      <span :if={@label} class="fui-text-base text-ink-gray-8">{@label}</span>
    </label>
    """
  end
end
