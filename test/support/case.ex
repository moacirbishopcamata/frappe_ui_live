defmodule FrappeUIPhx.Case do
  @moduledoc "Base dos testes de componente: HEEx, renderização para string e parsing de HTML."
  use ExUnit.CaseTemplate

  using do
    quote do
      import Phoenix.Component
      import Phoenix.LiveViewTest, only: [rendered_to_string: 1]
      import FrappeUIPhx.Case
    end
  end

  @doc "Primeiro elemento que casa o seletor, como `LazyHTML`."
  def query(html, selector), do: html |> LazyHTML.from_fragment() |> LazyHTML.query(selector)

  @doc "Valor do atributo no primeiro elemento do seletor (ou `nil`)."
  def html_attr(html, selector, name) do
    case html |> query(selector) |> LazyHTML.attribute(name) do
      [value | _] -> value
      [] -> nil
    end
  end

  @doc "Existe pelo menos um elemento para o seletor?"
  def has?(html, selector), do: Enum.count(query(html, selector)) > 0

  @doc "Texto do primeiro elemento, sem espaços nas pontas."
  def text(html, selector), do: html |> query(selector) |> LazyHTML.text() |> String.trim()

  @doc "`Phoenix.HTML.FormField` com `value`, `errors` e se foi usado (params presentes)."
  def form_field(name \\ :nome, value \\ nil, errors \\ [], used? \\ true) do
    params = if used?, do: %{Atom.to_string(name) => value || ""}, else: %{}
    form = Phoenix.Component.to_form(params, as: :f, errors: Enum.map(errors, &{name, &1}))
    form[name]
  end
end
