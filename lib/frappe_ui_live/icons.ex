defmodule FrappeUILive.Icons do
  @moduledoc """
  Catálogo de ícones Lucide: nomes, tags, aliases (nomes antigos) e busca.

  Os dados vêm de `priv/icons.json`, gerado por `mix icons.sync` a partir do
  `lucide-static` fixado, e são lidos em tempo de compilação. O desenho de cada
  ícone é renderizado por `FrappeUILive.Icons.Svg` (componente `<.icon>`) ou pelos
  atalhos `FrappeUILive.Icons.Lucide` (`<Lucide.plus />`).

  Um nome terminado em `-filled` (ex.: `"star-filled"`) é o mesmo ícone com
  preenchimento; um prefixo `lucide-` é aceito e ignorado.
  """

  @path Path.join([__DIR__, "..", "..", "priv", "icons.json"]) |> Path.expand()
  @external_resource @path

  @data @path |> File.read!() |> Jason.decode!()
  @version @data["version"]

  @icons Map.new(@data["icons"], fn {name, i} ->
           {name, %{name: name, tags: i["tags"], aliases: i["aliases"]}}
         end)
  @names @icons |> Map.keys() |> Enum.sort()

  # nome atual ou alias -> nome atual
  @lookup Enum.reduce(@icons, %{}, fn {name, %{aliases: aliases}}, acc ->
            Enum.reduce(aliases, Map.put(acc, name, name), &Map.put(&2, &1, name))
          end)

  # Filhos do <svg> já em HTML (escapado), um por ícone atual.
  @children Map.new(@data["icons"], fn {name, i} ->
              html =
                Enum.map_join(i["nodes"], fn [tag, attrs] ->
                  attrs =
                    attrs
                    |> Enum.sort()
                    |> Phoenix.HTML.attributes_escape()
                    |> Phoenix.HTML.safe_to_string()

                  "<#{tag}#{attrs}/>"
                end)

              {name, html}
            end)

  @type icon :: %{name: String.t(), tags: [String.t()], aliases: [String.t()]}

  @doc "Versão do Lucide de onde o catálogo foi gerado."
  @spec version() :: String.t()
  def version, do: @version

  @doc "Nomes atuais de todos os ícones, em ordem alfabética."
  @spec names() :: [String.t()]
  def names, do: @names

  @doc "Metadados de um ícone por nome atual, alias ou `-filled`; `nil` se não existir."
  @spec get(String.t()) :: icon() | nil
  def get(name) when is_binary(name) do
    case resolve(name) do
      {:ok, canonical, _filled?} -> Map.fetch!(@icons, canonical)
      :error -> nil
    end
  end

  @doc """
  Resolve um nome para `{:ok, nome_atual, preenchido?}` ou `:error`.
  """
  @spec resolve(String.t()) :: {:ok, String.t(), boolean()} | :error
  def resolve("lucide-" <> name), do: resolve(name)

  def resolve(name) when is_binary(name) do
    with :error <- Map.fetch(@lookup, name),
         true <- String.ends_with?(name, "-filled"),
         {:ok, canonical} <- Map.fetch(@lookup, String.replace_suffix(name, "-filled", "")) do
      {:ok, canonical, true}
    else
      {:ok, canonical} -> {:ok, canonical, false}
      _ -> :error
    end
  end

  @doc """
  Busca por nome, alias ou tag (sem diferenciar caixa nem acentos). Ordem: nome
  exato, prefixo do nome, nome contém, alias, tag. Termo vazio devolve todos.
  """
  @spec search(String.t()) :: [icon()]
  def search(term) when is_binary(term) do
    case normalize(term) do
      "" ->
        Enum.map(@names, &Map.fetch!(@icons, &1))

      q ->
        @names
        |> Enum.map(&Map.fetch!(@icons, &1))
        |> Enum.flat_map(fn icon ->
          case rank(icon, q) do
            nil -> []
            rank -> [{rank, icon}]
          end
        end)
        |> Enum.sort_by(fn {rank, icon} -> {rank, icon.name} end)
        |> Enum.map(&elem(&1, 1))
    end
  end

  defp rank(%{name: name, aliases: aliases, tags: tags}, q) do
    cond do
      name == q -> 0
      String.starts_with?(name, q) -> 1
      String.contains?(name, q) -> 2
      Enum.any?(aliases, &String.contains?(&1, q)) -> 3
      Enum.any?(tags, &String.contains?(normalize(&1), q)) -> 4
      true -> nil
    end
  end

  defp normalize(text) do
    text
    |> String.trim()
    |> String.downcase()
    |> String.normalize(:nfd)
    |> String.replace(~r/\p{Mn}/u, "")
  end

  @doc "Até `limit` nomes parecidos com `name` (para mensagens de erro)."
  @spec suggestions(String.t(), pos_integer()) :: [String.t()]
  def suggestions(name, limit \\ 3) when is_binary(name) do
    @names
    |> Enum.map(&{String.jaro_distance(&1, name), &1})
    |> Enum.sort_by(&elem(&1, 0), :desc)
    |> Enum.take(limit)
    |> Enum.map(&elem(&1, 1))
  end

  @doc """
  Nome da função de `FrappeUILive.Icons.Lucide` para o ícone `name`:
  `"circle-alert"` -> `:circle_alert`; nome que começa com dígito ganha o prefixo `i_`.
  """
  @spec function_name(String.t()) :: atom()
  def function_name(name) when is_binary(name) do
    snake = String.replace(name, "-", "_")
    if snake =~ ~r/^\d/, do: String.to_atom("i_" <> snake), else: String.to_atom(snake)
  end

  @doc false
  @spec children(String.t()) :: String.t()
  def children(canonical), do: Map.fetch!(@children, canonical)
end
