if Code.ensure_loaded?(Ecto.Type) do
  defmodule FrappeUILive.Ecto.StringList do
    @moduledoc """
    `Ecto.Type` para listas de textos (tags, MultiSelect): persiste como
    `{:array, :string}` e aceita no `cast` uma lista ou uma string separada por
    vírgula. Descarta vazios e repetidos, preservando a ordem.

        field :tags, FrappeUILive.Ecto.StringList
    """
    use Ecto.Type

    @impl true
    def type, do: {:array, :string}

    @impl true
    def cast(nil), do: {:ok, []}
    def cast(text) when is_binary(text), do: text |> String.split(",") |> cast()

    def cast(list) when is_list(list) do
      if Enum.all?(list, &is_binary/1) do
        {:ok, list |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == "")) |> Enum.uniq()}
      else
        :error
      end
    end

    def cast(_), do: :error

    @impl true
    def load(list) when is_list(list), do: {:ok, list}
    def load(nil), do: {:ok, []}
    def load(_), do: :error

    @impl true
    def dump(list) when is_list(list), do: {:ok, list}
    def dump(_), do: :error
  end
end
