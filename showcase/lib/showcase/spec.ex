defmodule Showcase.Spec do
  @moduledoc """
  Especificação *derivada* de cada componente (parte do mostruário, não do pacote Hex), lida das declarações reais
  (`attr`/`slot` via `__components__/0` e `@moduledoc`), de modo que a
  documentação nunca diverge do código.

  Alimenta o mostruário: tabela de especificação, formulário do playground e a
  conversão (cast) do que o formulário envia para atributos tipados.
  """

  alias FrappeUIPhx.Components, as: Catalog

  @editable_types ~w(atom string boolean integer)a
  @hidden ~w(rest)a

  @type attribute :: %{
          name: atom(),
          type: term(),
          required: boolean(),
          default: term(),
          values: [term()] | nil,
          doc: String.t() | nil,
          editable: boolean()
        }

  @type t :: %{
          id: atom(),
          title: String.t(),
          category: atom(),
          module: module(),
          fun: atom(),
          doc: String.t(),
          attrs: [attribute()],
          slots: [map()]
        }

  @doc "Especificação de todas as entradas do catálogo."
  @spec all() :: [t()]
  def all, do: Enum.map(Catalog.catalog(), &build/1)

  @doc "Especificação do componente `id` ou `nil`."
  @spec get(atom()) :: t() | nil
  def get(id) do
    case Catalog.get(id) do
      nil -> nil
      entry -> build(entry)
    end
  end

  @doc "Atributos que o playground permite editar num formulário."
  @spec editable(t()) :: [attribute()]
  def editable(%{attrs: attrs}), do: Enum.filter(attrs, & &1.editable)

  @doc "Valores iniciais do formulário: o `default` declarado de cada atributo editável."
  @spec defaults(t()) :: %{atom() => term()}
  def defaults(spec), do: spec |> editable() |> Map.new(&{&1.name, &1.default})

  @doc """
  Converte os `params` de um formulário (strings) em atributos tipados.

  Valor inválido nunca levanta: cai no `default` do atributo (a entrada vem de
  um formulário, então é fluxo normal, não violação de contrato).
  """
  @spec cast(t(), map()) :: %{atom() => term()}
  def cast(spec, params) when is_map(params) do
    spec
    |> editable()
    |> Map.new(fn attr ->
      {attr.name, cast_value(attr, Map.get(params, Atom.to_string(attr.name)))}
    end)
  end

  # ---- construção ----------------------------------------------------------

  defp build(%{module: module, fun: fun} = entry) do
    component = Map.fetch!(module.__components__(), fun)

    %{
      id: entry.id,
      title: entry.title,
      category: entry.category,
      module: module,
      fun: fun,
      doc: moduledoc(module),
      attrs: for(a <- component.attrs, a.name not in @hidden, do: attribute(a)),
      slots: Enum.map(component.slots, &slot/1)
    }
  end

  defp attribute(a) do
    opts = a.opts
    values = Keyword.get(opts, :values)

    %{
      name: a.name,
      type: a.type,
      required: a.required,
      default: Keyword.get(opts, :default),
      values: values,
      doc: a[:doc] || Keyword.get(opts, :doc),
      editable: a.type in @editable_types and is_nil(Map.get(a, :slot))
    }
  end

  defp slot(s) do
    %{
      name: s.name,
      required: s.required,
      doc: s[:doc],
      attrs:
        for(a <- s.attrs, do: %{name: a.name, type: a.type, required: a.required, doc: a[:doc]})
    }
  end

  defp moduledoc(module) do
    case Code.fetch_docs(module) do
      {:docs_v1, _, _, _, %{"en" => doc}, _, _} -> doc
      _ -> ""
    end
  end

  # ---- cast ----------------------------------------------------------------

  defp cast_value(%{type: :boolean}, value), do: value in ["true", "on", true]

  defp cast_value(%{type: :integer, default: default}, value) when is_binary(value) do
    case Integer.parse(value) do
      {n, ""} -> n
      _ -> default
    end
  end

  defp cast_value(%{type: :atom, values: values, default: default}, value)
       when is_binary(value) do
    Enum.find(values || [], default, &(Atom.to_string(&1) == value))
  end

  defp cast_value(%{type: :string, required: required}, value) when is_binary(value) do
    if value == "" and not required, do: nil, else: value
  end

  defp cast_value(%{default: default}, _), do: default
end
