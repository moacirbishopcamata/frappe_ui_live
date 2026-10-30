defmodule FrappeUILive.DiceBear do
  @moduledoc """
  URL da [API HTTP do DiceBear](https://www.dicebear.com/integrations/http-api/)
  (avatares gerados a partir de uma *seed*).

  Funções puras; o componente é `FrappeUILive.Components.DiceBearAvatar`. A API
  devolve o mesmo avatar para a mesma `style` + `seed` + opções, então o servidor
  só monta a URL — nada é gerado nem guardado aqui. Não há biblioteca oficial para
  Elixir; as opções são esta API (URL em `<img>`) ou a mesma API hospedada por você.

  ## Privacidade

  A `seed` vai na URL para quem hospeda a API. Não use e-mail, CPF ou nome completo;
  use `seed/1` (id opaco).

  ## Uso comercial, limites e licenças

  A API pública (`https://api.dicebear.com/10.x`) é gratuita **para uso não
  comercial**, sem garantia de disponibilidade e com limite por segundo (SVG 50,
  raster 10; excedido: HTTP 429). Em produção/comercial, hospede a sua
  ([guia](https://www.dicebear.com/recipes/self-host-the-http-api/), imagem Docker
  `dicebear/api`) e configure:

      config :frappe_ui_live, dice_bear_base_url: "https://avatars.meuapp.com/10.x"

  Cada estilo tem a licença do seu criador (CC BY 4.0 exige atribuição, CC0, MIT...);
  confira em <https://www.dicebear.com/licenses/> antes de publicar.

  ## Opções

  `opts` vira a query string. Comuns: `flip` (`none|horizontal|vertical|both`),
  `rotate`, `scale`, `borderRadius` (0 a 50), `size`, `translateX`/`translateY`,
  `backgroundColor` (lista de hex), `backgroundColorFill`; cada estilo tem as suas
  (`hairVariant`, ...). `idRandomization`, `fontFamily`, `fontWeight` e `title` só
  funcionam em instância própria. Raster (`png`, `jpg`, `webp`, `avif`) vai até 256 px
  na API pública.
  """

  alias FrappeUILive.Contract

  @default_base "https://api.dicebear.com/10.x"

  # Estilos oficiais conhecidos (10.x). A lista autoritativa é `GET <base_url>` (JSON `styles`).
  @styles ~w(blobs disco glass glyphs icons identicon initial-face initials loops patchwork
             rings shape-grid shapes slice squircles stack stripes triangles waves weave
             adventurer adventurer-neutral avataaars avataaars-neutral big-ears big-ears-neutral
             big-smile bottts bottts-neutral cameo clay critters croodles croodles-neutral cutouts
             dylan fun-emoji gaze line-face lorelei lorelei-neutral marbles micah miniavs moods
             notionists notionists-neutral open-peeps personas pixel-art pixel-art-neutral
             pixelbot shadows sprouts thumbs toon-head voxel-art voxel-bot
             constellation landscape planets)

  @formats ~w(svg png jpg webp avif)
  @key ~r/\A[a-zA-Z][a-zA-Z0-9]*\z/
  @style_name ~r/\A[a-z][a-z0-9]*(-[a-z0-9]+)*\z/

  @doc "Estilos oficiais conhecidos (DiceBear 10.x), para documentação e seletores."
  @spec styles() :: [String.t()]
  def styles, do: @styles

  @doc "Formatos de imagem aceitos (`json` devolve metadados, não imagem)."
  @spec formats() :: [String.t()]
  def formats, do: @formats

  @doc "URL base configurada (`:dice_bear_base_url`) ou a API pública do DiceBear."
  @spec base_url() :: String.t()
  def base_url do
    url = Application.get_env(:frappe_ui_live, :dice_bear_base_url, @default_base)
    ensure_base!(url, "dice_bear_base_url")
    String.trim_trailing(url, "/")
  end

  @doc """
  URL do avatar. `opts` são os parâmetros da API (listas viram `a,b`); `config`
  aceita `format:` (`svg` padrão) e `base_url:` (troca o servidor).

  O estilo só precisa ter um nome bem formado (`thumbs`, `pixel-art`): a lista muda
  entre versões e em instâncias próprias, então um estilo novo não é recusado aqui
  (se não existir, o servidor responde 404).

      iex> FrappeUILive.DiceBear.url("thumbs", "ana", %{backgroundColor: ["b6e3f4"], flip: "horizontal"})
      "https://api.dicebear.com/10.x/thumbs/svg?backgroundColor=b6e3f4&flip=horizontal&seed=ana"
  """
  @spec url(String.t(), String.t(), map() | keyword(), keyword()) :: String.t()
  def url(style, seed, opts \\ %{}, config \\ []) do
    Contract.ensure!(
      is_binary(style) and style =~ @style_name,
      "dice_bear style: #{inspect(style)} fora do contrato; esperado um nome como \"thumbs\" ou \"pixel-art\""
    )

    Contract.ensure!(
      is_binary(seed) and seed != "",
      "dice_bear seed: esperado texto não vazio, recebeu #{inspect(seed)}"
    )

    format = Contract.require!(Keyword.get(config, :format, "svg"), @formats, "dice_bear format")
    base = Keyword.get_lazy(config, :base_url, &base_url/0)
    ensure_base!(base, "dice_bear base_url")

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

  defp ensure_base!(url, label) do
    Contract.ensure!(
      is_binary(url) and valid_base?(url),
      "#{label}: #{inspect(url)} deve ser http(s):// ou começar com /"
    )
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
