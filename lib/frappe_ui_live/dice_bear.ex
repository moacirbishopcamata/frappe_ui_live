defmodule FrappeUILive.DiceBear do
  @moduledoc """
  URL da [API do DiceBear](https://www.dicebear.com/) (avatares gerados a partir de uma *seed*).

  Funções puras; o componente é `FrappeUILive.Components.DiceBearAvatar`. A API
  devolve o mesmo avatar para a mesma `style` + `seed` + opções, então o servidor
  só monta a URL — nada é gerado nem guardado aqui.

  **Privacidade**: a `seed` vai na URL para quem hospeda a API. Não use e-mail, CPF
  ou nome completo; use `seed/1` (id opaco) e, para não depender de terceiros,
  hospede a API do DiceBear e configure:

      config :frappe_ui_live, dice_bear_base_url: "https://avatars.meuapp.com/9.x"

  Padrão: `https://api.dicebear.com/9.x`. Estilos: coleção oficial 9.x (`styles/0`).
  """

  alias FrappeUILive.Contract

  @default_base "https://api.dicebear.com/9.x"

  @styles ~w(adventurer adventurer-neutral avataaars avataaars-neutral big-ears big-ears-neutral
             big-smile bottts bottts-neutral croodles croodles-neutral dylan fun-emoji glass icons
             identicon initials lorelei lorelei-neutral micah miniavs notionists notionists-neutral
             open-peeps personas pixel-art pixel-art-neutral rings shapes thumbs)

  @formats ~w(svg png jpg webp avif)
  @key ~r/\A[a-zA-Z][a-zA-Z0-9]*\z/

  @doc "Estilos oficiais da coleção DiceBear 9.x."
  @spec styles() :: [String.t()]
  def styles, do: @styles

  @doc "Formatos de imagem aceitos pela API."
  @spec formats() :: [String.t()]
  def formats, do: @formats

  @doc "URL base configurada (`:dice_bear_base_url`) ou a API pública do DiceBear."
  @spec base_url() :: String.t()
  def base_url do
    url = Application.get_env(:frappe_ui_live, :dice_bear_base_url, @default_base)

    Contract.ensure!(
      valid_base?(url),
      "dice_bear_base_url: #{inspect(url)} deve ser http(s):// ou começar com /"
    )

    String.trim_trailing(url, "/")
  end

  @doc """
  URL do avatar. `opts` são os parâmetros da API (`backgroundColor`, `radius`, `flip`,
  `scale`, ...; listas viram `a,b`); `format` escolhe a imagem (`svg` padrão) e
  `base_url` troca o servidor.

      iex> FrappeUILive.DiceBear.url("thumbs", "ana", %{backgroundColor: ["b6e3f4"], flip: true})
      "https://api.dicebear.com/9.x/thumbs/svg?backgroundColor=b6e3f4&flip=true&seed=ana"
  """
  @spec url(String.t(), String.t(), map() | keyword(), keyword()) :: String.t()
  def url(style, seed, opts \\ %{}, config \\ []) do
    Contract.require!(style, @styles, "dice_bear style")

    Contract.ensure!(
      is_binary(seed) and seed != "",
      "dice_bear seed: esperado texto não vazio, recebeu #{inspect(seed)}"
    )

    format = Contract.require!(Keyword.get(config, :format, "svg"), @formats, "dice_bear format")
    base = Keyword.get_lazy(config, :base_url, &base_url/0)

    Contract.ensure!(
      valid_base?(base),
      "dice_bear base_url: #{inspect(base)} deve ser http(s):// ou começar com /"
    )

    query =
      opts
      |> Enum.map(fn {key, value} -> {option_key!(key), option_value!(key, value)} end)
      |> Map.new()
      |> Map.put("seed", seed)
      |> Enum.sort()
      |> URI.encode_query()

    "#{String.trim_trailing(base, "/")}/#{style}/#{format}?#{query}"
  end

  @doc """
  *Seed* opaca e estável para um identificador (id, e-mail...): 16 hex do SHA-256.
  Evita colocar dados pessoais na URL.
  """
  @spec seed(term()) :: String.t()
  def seed(identifier) do
    :crypto.hash(:sha256, to_string(identifier))
    |> Base.encode16(case: :lower)
    |> binary_part(0, 16)
  end

  defp valid_base?("/" <> _), do: true
  defp valid_base?("http://" <> _), do: true
  defp valid_base?("https://" <> _), do: true
  defp valid_base?(_), do: false

  defp option_key!(key) do
    key = to_string(key)

    Contract.ensure!(
      key =~ @key,
      "dice_bear option #{inspect(key)}: nome inválido (esperado letras e números, ex.: backgroundColor)"
    )

    key
  end

  defp option_value!(_key, value) when is_binary(value) or is_number(value) or is_boolean(value),
    do: to_string(value)

  defp option_value!(key, [_ | _] = values) do
    Contract.ensure!(
      Enum.all?(values, &(is_binary(&1) or is_number(&1) or is_boolean(&1))),
      "dice_bear option #{inspect(key)}: lista só aceita texto, número ou booleano"
    )

    Enum.map_join(values, ",", &to_string/1)
  end

  defp option_value!(key, value),
    do:
      raise(
        ArgumentError,
        "dice_bear option #{inspect(key)}: valor #{inspect(value)} não suportado"
      )
end
