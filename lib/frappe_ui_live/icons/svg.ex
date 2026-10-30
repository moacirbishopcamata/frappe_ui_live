defmodule FrappeUILive.Icons.Svg do
  @moduledoc """
  Renderiza um ícone do catálogo como `<svg>` inline, com as propriedades do Lucide.

  É a única implementação de renderização: o componente genérico `<.icon>` e os
  atalhos `FrappeUILive.Icons.Lucide` apenas chamam `svg/1`.

  Pré-condições (violação é bug de quem chama, `ArgumentError`): `name` existe no
  catálogo; `size` e `stroke_width` são números positivos.
  """
  use Phoenix.Component

  alias FrappeUILive.{Contract, Icons}

  attr :name, :string, required: true, doc: ~s(nome Lucide, alias ou "-filled", ex.: "plus")
  attr :size, :any, default: 24, doc: "largura e altura em pixels (número positivo)"
  attr :color, :string, default: "currentColor", doc: "cor do traço (qualquer cor CSS)"
  attr :stroke_width, :any, default: 2, doc: "espessura do traço (número positivo)"

  attr :absolute_stroke_width, :boolean,
    default: false,
    doc: "mantém a espessura visual do traço igual em qualquer tamanho"

  attr :title, :string, default: nil, doc: "nome acessível; sem ele o ícone é decorativo"
  attr :class, :any, default: nil
  attr :rest, :global

  @spec svg(map()) :: Phoenix.LiveView.Rendered.t()
  def svg(assigns) do
    {canonical, filled?} = resolve!(assigns.name)
    positive!(assigns.size, "Icon size")
    positive!(assigns.stroke_width, "Icon stroke_width")

    assigns =
      assign(assigns,
        canonical: canonical,
        fill: if(filled?, do: "currentColor", else: "none"),
        width: stroke_width(assigns),
        children: Phoenix.HTML.raw(Icons.children(canonical))
      )

    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={@size}
      height={@size}
      viewBox="0 0 24 24"
      fill={@fill}
      stroke={@color}
      stroke-width={@width}
      stroke-linecap="round"
      stroke-linejoin="round"
      class={["lucide lucide-#{@canonical}", @class]}
      role={@title && "img"}
      aria-hidden={is_nil(@title) && "true"}
      {@rest}
    ><title :if={@title}>{@title}</title>{@children}</svg>
    """
  end

  defp stroke_width(%{absolute_stroke_width: true, stroke_width: sw, size: size}),
    do: Float.round(sw * 24 / size, 3)

  defp stroke_width(%{stroke_width: sw}), do: sw

  defp resolve!(name) do
    case Icons.resolve(name) do
      {:ok, canonical, filled?} ->
        {canonical, filled?}

      :error ->
        raise ArgumentError,
              "Icon name: #{inspect(name)} não existe no catálogo Lucide #{Icons.version()}; " <>
                "parecidos: #{Enum.join(Icons.suggestions(name), ", ")}"
    end
  end

  defp positive!(value, label) do
    Contract.ensure!(
      is_number(value) and value > 0,
      "#{label}: valor #{inspect(value)} fora do contrato; esperado um número positivo"
    )
  end
end
