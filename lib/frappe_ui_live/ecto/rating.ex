if Code.ensure_loaded?(Ecto.ParameterizedType) do
  defmodule FrappeUILive.Ecto.Rating do
    @moduledoc """
    `Ecto.ParameterizedType` para avaliação em estrelas: inteiro de `0` a `max`
    (padrão 5). Aceita string vindo do formulário.

        field :nota, FrappeUILive.Ecto.Rating, max: 5
    """
    use Ecto.ParameterizedType

    @impl true
    def type(_params), do: :integer

    @impl true
    def init(opts) do
      max = Keyword.get(opts, :max, 5)

      FrappeUILive.Contract.ensure!(
        is_integer(max) and max > 0,
        "Rating: :max deve ser inteiro positivo"
      )

      %{max: max}
    end

    @impl true
    def cast(nil, _), do: {:ok, nil}
    def cast("", _), do: {:ok, nil}

    def cast(value, %{max: max}) when is_binary(value) do
      case Integer.parse(value) do
        {n, ""} -> cast(n, %{max: max})
        _ -> :error
      end
    end

    def cast(value, %{max: max}) when is_integer(value) and value in 0..max//1, do: {:ok, value}
    def cast(_, _), do: :error

    @impl true
    def load(value, _loader, _params), do: {:ok, value}

    @impl true
    def dump(value, _dumper, %{max: max}) when is_integer(value) and value in 0..max//1,
      do: {:ok, value}

    def dump(nil, _dumper, _params), do: {:ok, nil}
    def dump(_, _, _), do: :error
  end
end
