defmodule FrappeUILive.Icons.Lucide do
  @moduledoc """
  Um componente LiveView por ícone Lucide (atalhos de `FrappeUILive.Icons.Svg`).

      alias FrappeUILive.Icons.Lucide

      <Lucide.plus />
      <Lucide.circle_alert size={16} color="red" stroke_width={1.5} title="Erro" />

  O nome da função é o nome do ícone com `-` trocado por `_` (e prefixo `i_` quando
  começa com dígito, ex.: `"1-circle"` -> `<Lucide.i_1_circle />`); veja `FrappeUILive.Icons.function_name/1`.
  Para escolher o ícone por dado (string), use `<.icon name="..." />`, que também
  aceita nomes antigos (aliases) e `-filled`.
  """
  use Phoenix.Component

  alias FrappeUILive.Icons
  alias FrappeUILive.Icons.Svg

  for name <- Icons.names() do
    fun = Icons.function_name(name)

    attr :size, :any, default: 24
    attr :color, :string, default: "currentColor"
    attr :stroke_width, :any, default: 2
    attr :absolute_stroke_width, :boolean, default: false
    attr :title, :string, default: nil
    attr :class, :any, default: nil
    attr :rest, :global

    @doc "Ícone Lucide `#{name}`."
    def unquote(fun)(assigns), do: Svg.svg(Map.put(assigns, :name, unquote(name)))
  end
end
