if Code.ensure_loaded?(Ecto.Type) do
  defmodule FrappeUIPhx.Ecto.Duration do
    @moduledoc """
    `Ecto.Type` para o campo Duration do Frappe UI: guarda **segundos** (inteiro
    não negativo) e aceita no `cast` o que um usuário digita:

        1h 30m   |   90m   |   45s   |   1:30   |   1:30:15   |   5400

        field :tempo, FrappeUIPhx.Ecto.Duration

    O parsing é o de `FrappeUIPhx.Duration`, o mesmo do componente `duration`.
    """
    use Ecto.Type

    alias FrappeUIPhx.Duration

    @impl true
    def type, do: :integer

    @impl true
    def cast(value), do: Duration.parse(value)

    @impl true
    def load(seconds) when is_integer(seconds), do: {:ok, seconds}
    def load(nil), do: {:ok, nil}
    def load(_), do: :error

    @impl true
    def dump(seconds) when is_integer(seconds) and seconds >= 0, do: {:ok, seconds}
    def dump(nil), do: {:ok, nil}
    def dump(_), do: :error

    @doc "Segundos como `\"1h 30m 15s\"`; veja `FrappeUIPhx.Duration.humanize/1`."
    @spec humanize(non_neg_integer() | nil) :: String.t()
    defdelegate humanize(seconds), to: Duration
  end
end
