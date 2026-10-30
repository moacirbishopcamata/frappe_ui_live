defmodule FrappeUILive.Components.DiceBearAvatar do
  @moduledoc """
  Avatar gerado pelo [DiceBear](https://www.dicebear.com/) a partir de uma `seed`:
  a mesma `style` + `seed` + `options` dá sempre o mesmo desenho. Mesmos tamanhos e
  formas do `FrappeUILive.Components.Avatar`, de quem herda o visual (composição).

      <.dice_bear_avatar seed={@user.public_id} style="thumbs" size={:xl} />
      <.dice_bear_avatar seed={@user.public_id} options={%{backgroundColor: ["b6e3f4"], flip: true}} />

  A imagem é buscada da API do DiceBear (`FrappeUILive.DiceBear`): **a `seed` vai na
  URL**. Não passe e-mail nem nome; use `FrappeUILive.DiceBear.seed/1` e, se preciso,
  hospede a API (`config :frappe_ui_live, dice_bear_base_url: ...`). A imagem é
  carregada sob demanda e sem enviar o `Referer`. Se a página usa CSP, libere o
  host da API em `img-src`.
  """
  use Phoenix.Component

  alias FrappeUILive.Components.Avatar
  alias FrappeUILive.DiceBear

  attr :seed, :string, required: true, doc: "identificador estável e não pessoal do avatar"

  attr :style, :string,
    default: "thumbs",
    values: DiceBear.styles(),
    doc: "estilo da coleção DiceBear 9.x"

  attr :label, :string,
    default: nil,
    doc: "nome acessível (alt) e dica; sem ele a imagem é decorativa"

  attr :size, :atom, default: :md, values: ~w(xs sm md lg xl 2xl 3xl)a
  attr :shape, :atom, default: :circle, values: ~w(circle square)a

  attr :options, :map,
    default: %{},
    doc: "parâmetros da API (backgroundColor, radius, flip, scale...); listas viram a,b"

  attr :base_url, :string, default: nil, doc: "servidor DiceBear (padrão: config ou API pública)"
  attr :class, :any, default: nil
  attr :rest, :global

  def dice_bear_avatar(assigns) do
    config = if assigns.base_url, do: [base_url: assigns.base_url], else: []

    assigns =
      assign(assigns, :url, DiceBear.url(assigns.style, assigns.seed, assigns.options, config))

    ~H"""
    <Avatar.avatar
      image={@url}
      label={@label}
      size={@size}
      shape={@shape}
      class={@class}
      data-dice-bear-style={@style}
      {@rest}
    />
    """
  end
end
