if Code.ensure_loaded?(Ecto.Enum) do
  defmodule FrappeUILive.Ecto.Options do
    @moduledoc """
    Opções de `Select`/`Combobox` a partir de um campo `Ecto.Enum`, para que a
    lista da tela e o domínio nunca divirjam:

        <.select field={@form[:status]} options={FrappeUILive.Ecto.Options.from_enum(Pedido, :status)} />
    """

    @doc "`[{rótulo, valor}]` para o campo `Ecto.Enum` `field` do `schema`."
    @spec from_enum(module(), atom()) :: [{String.t(), String.t()}]
    def from_enum(schema, field) when is_atom(schema) and is_atom(field) do
      FrappeUILive.Contract.ensure!(
        function_exported?(schema, :__schema__, 2) and
          match?({:parameterized, {Ecto.Enum, _}}, schema.__schema__(:type, field)),
        "#{inspect(schema)}.#{field} não é um Ecto.Enum"
      )

      schema
      |> Ecto.Enum.values(field)
      |> Enum.map(&{humanize(&1), Atom.to_string(&1)})
    end

    @doc "`:em_andamento` vira `\"Em andamento\"`."
    @spec humanize(atom() | String.t()) :: String.t()
    def humanize(value) do
      value |> to_string() |> String.replace("_", " ") |> String.capitalize()
    end
  end
end
