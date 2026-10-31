defmodule FrappeUIPhx.Components.Icon do
  @moduledoc """
  Ícone Lucide por nome, renderizado como `<svg>` inline (veja `FrappeUIPhx.Icons`).

  O nome passa por `FrappeUIPhx.IconResolver` (apelidos do projeto) e depois pelo
  catálogo, que aceita nomes antigos (aliases) e `-filled`. Para um ícone fixo no
  template, prefira `FrappeUIPhx.Icons.Lucide` (`<Lucide.plus />`).
  """
  use Phoenix.Component

  attr :name, :string, required: true, doc: ~s(nome Lucide, ex.: "plus")
  attr :size, :any, default: 24, doc: "largura e altura em pixels (número positivo)"
  attr :color, :string, default: "currentColor", doc: "cor do traço (qualquer cor CSS)"
  attr :stroke_width, :any, default: 2, doc: "espessura do traço (número positivo)"

  attr :absolute_stroke_width, :boolean,
    default: false,
    doc: "mantém a espessura visual do traço igual em qualquer tamanho"

  attr :title, :string, default: nil, doc: "nome acessível; sem ele o ícone é decorativo"
  attr :class, :any, default: nil
  attr :rest, :global

  def icon(assigns) do
    assigns = assign(assigns, :name, FrappeUIPhx.IconResolver.resolve(assigns.name))

    ~H"""
    <FrappeUIPhx.Icons.Svg.svg
      name={@name}
      size={@size}
      color={@color}
      stroke_width={@stroke_width}
      absolute_stroke_width={@absolute_stroke_width}
      title={@title}
      class={@class}
      {@rest}
    />
    """
  end
end
