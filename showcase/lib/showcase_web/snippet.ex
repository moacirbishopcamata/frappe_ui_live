defmodule ShowcaseWeb.Snippet do
  @moduledoc """
  Gera o trecho HEEx de uso a partir da especificação e dos valores atuais do
  playground. Só inclui o que difere do `default` declarado (função pura).
  """

  alias Showcase.Spec

  @spec build(Spec.t(), map()) :: String.t()
  def build(spec, attrs) do
    parts =
      for attr <- Spec.editable(spec),
          value = Map.get(attrs, attr.name),
          value != attr.default,
          value != nil,
          value != false,
          do: render_attr(attr.name, value)

    tag = "." <> Atom.to_string(spec.fun)

    case parts do
      [] -> "<#{tag} />"
      _ -> "<#{tag}\n" <> Enum.map_join(parts, "\n", &("  " <> &1)) <> "\n/>"
    end
  end

  defp render_attr(name, true), do: Atom.to_string(name)
  defp render_attr(name, value) when is_binary(value), do: ~s(#{name}="#{value}")
  defp render_attr(name, value) when is_atom(value), do: "#{name}={#{inspect(value)}}"
  defp render_attr(name, value) when is_integer(value), do: "#{name}={#{value}}"
end
