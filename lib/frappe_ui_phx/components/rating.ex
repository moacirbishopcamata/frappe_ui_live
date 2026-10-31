defmodule FrappeUIPhx.Components.Rating do
  @moduledoc """
  Avaliação em estrelas (`1..max`). Cada estrela é um `<input type=radio>`, então
  funciona em formulários e `phx-change`; o preenchimento vem do valor no servidor.
  Combine com `FrappeUIPhx.Ecto.Rating` no schema.
  """
  use Phoenix.Component

  alias FrappeUIPhx.Texts

  alias FrappeUIPhx.Components.Icon
  alias FrappeUIPhx.{Contract, Field}

  attr :field, Phoenix.HTML.FormField, default: nil
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :max, :integer, default: 5
  attr :readonly, :boolean, default: false
  attr :errors, :list, default: []
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(form)

  def rating(assigns) do
    Contract.ensure!(assigns.max in 1..20, "rating: max deve estar entre 1 e 20")
    assigns = Field.assign_field(assigns)
    assigns = assign(assigns, :current, current(assigns.value, assigns.max))

    ~H"""
    <div
      role="radiogroup"
      aria-label={Texts.t(:rating)}
      class={["inline-flex items-center gap-0.5", @class]}
    >
      <label :for={n <- 1..@max} :key={n} class={[!@readonly && "cursor-pointer"]}>
        <input
          type="radio"
          name={@name}
          value={n}
          checked={n == @current}
          disabled={@readonly}
          class="peer sr-only"
          aria-label={Texts.t(:rating_item, n: n, max: @max)}
          {@rest}
        />
        <Icon.icon
          name={if n <= @current, do: "star-filled", else: "star"}
          class={[
            "peer-focus-visible:focus-ring size-5 rounded-1",
            n <= @current && "text-ink-amber-3",
            n > @current && "text-ink-gray-3"
          ]}
        />
      </label>
    </div>
    """
  end

  @doc "Valor (string ou inteiro) normalizado para `0..max`; inválido vira 0."
  @spec current(term(), pos_integer()) :: non_neg_integer()
  def current(value, max) when is_integer(value) and value in 0..max//1, do: value

  def current(value, max) when is_binary(value) do
    case Integer.parse(value) do
      {n, ""} -> current(n, max)
      _ -> 0
    end
  end

  def current(_, _), do: 0
end
