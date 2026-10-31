defmodule FrappeUIPhx.DiceBear do
  @moduledoc """
  URL da [API HTTP do DiceBear](https://www.dicebear.com/integrations/http-api/)
  (avatares gerados a partir de uma *seed*).

  Funções puras; o componente é `FrappeUIPhx.Components.DiceBearAvatar`. A API
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

      config :frappe_ui_phx, dice_bear_base_url: "https://avatars.meuapp.com/10.x"

  Cada estilo tem a licença do seu criador (CC BY 4.0 exige atribuição, CC0, MIT...);
  confira em <https://www.dicebear.com/licenses/> antes de publicar.

  ## Determinismo

  A `seed` passa por um hash (FNV-1a) que inicia um gerador pseudoaleatório
  (Mulberry32): a mesma `style` + `seed` + opções dá sempre o mesmo avatar. Não é
  criptográfico: serve para avatar estável, nunca para derivar segredo.

  ## Opções

  `opts` vira a query string. Comuns: `flip` (`none|horizontal|vertical|both`),
  `rotate`, `scale`, `borderRadius` (0 a 50), `size`, `translateX`/`translateY`,
  `backgroundColor` (lista de hex), `backgroundColorFill`; cada estilo tem as suas
  (`hairVariant`, ...). `idRandomization`, `fontFamily`, `fontWeight` e `title` só
  funcionam em instância própria. Raster (`png`, `jpg`, `webp`, `avif`) vai até 256 px
  na API pública. `options/1` converte e valida as opções do núcleo em `snake_case`
  (`border_radius: 50`) para os parâmetros da API.

  ## Receita "avatar placeholder"

  Para quem ainda não enviou foto, gere o avatar de uma seed estável (id do usuário,
  `seed/1`) ou, no estilo `initials`, das iniciais do nome (`initials/1`). O componente
  `DiceBearAvatar` já faz a troca no servidor (`image` presente = foto real).
  """

  alias FrappeUIPhx.Contract

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

  # Só funcionam em instância própria (a API pública os exclui).
  @self_host_only ~w(idRandomization fontFamily fontWeight title)
  @public_host "api.dicebear.com"

  @flips ~w(none horizontal vertical both)
  @fills ~w(solid linear radial)
  @hex ~r/\A(?:[0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})\z/

  # opção em snake_case -> {parâmetro da API, validador}
  @typed %{
    flip: {"flip", {:enum, @flips}},
    rotate: {"rotate", {:range, -360, 360}},
    scale: {"scale", {:range, 0, 10}},
    border_radius: {"borderRadius", {:range, 0, 50}},
    translate_x: {"translateX", {:range, -1000, 1000}},
    translate_y: {"translateY", {:range, -1000, 1000}},
    background_color: {"backgroundColor", :colors},
    background_color_fill: {"backgroundColorFill", {:enum, @fills}},
    background_color_angle: {"backgroundColorAngle", {:range, -360, 360}},
    tags: {"tags", :tags}
  }
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
    url = Application.get_env(:frappe_ui_phx, :dice_bear_base_url, @default_base)
    ensure_base!(url, "dice_bear_base_url")
    String.trim_trailing(url, "/")
  end

  @doc """
  URL do avatar. `opts` são os parâmetros da API (listas viram `a,b`); `config`
  aceita `format:` (`svg` padrão) e `base_url:` (troca o servidor).

  O estilo só precisa ter um nome bem formado (`thumbs`, `pixel-art`): a lista muda
  entre versões e em instâncias próprias, então um estilo novo não é recusado aqui
  (se não existir, o servidor responde 404).

      iex> FrappeUIPhx.DiceBear.url("thumbs", "ana", %{backgroundColor: ["b6e3f4"], flip: "horizontal"})
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

    guard_public_host!(base, opts)

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
  Opções do núcleo em `snake_case` -> parâmetros da API, validadas nos intervalos da
  documentação (`flip`, `rotate` -360..360, `scale` 0..10, `border_radius` 0..50,
  `translate_x`/`translate_y` -1000..1000, `background_color` (hex, com ou sem `#`; texto
  ou lista), `background_color_fill`, `background_color_angle`, `tags`). Chave
  desconhecida ou valor fora do contrato falha alto.

      iex> FrappeUIPhx.DiceBear.options(border_radius: 50, background_color: ["#b6e3f4"])
      %{"backgroundColor" => ["b6e3f4"], "borderRadius" => 50}
  """
  @spec options(keyword() | map()) :: %{String.t() => term()}
  def options(typed) do
    Map.new(typed, fn {key, value} ->
      case Map.fetch(@typed, key) do
        {:ok, {param, check}} ->
          {param, check!(key, check, value)}

        :error ->
          raise ArgumentError,
                "dice_bear option #{inspect(key)}: desconhecida; esperado uma de #{inspect(Map.keys(@typed))}"
      end
    end)
  end

  @doc """
  Iniciais de um nome (até duas letras maiúsculas): `"Ana Souza"` -> `"AS"`,
  `"ana"` -> `"A"`, sem letras -> `nil`. Para `style="initials"` na receita de placeholder.
  """
  @spec initials(term()) :: String.t() | nil
  def initials(name) when is_binary(name) do
    letters =
      name
      |> String.split(~r/[^\p{L}\p{N}]+/u, trim: true)
      |> Enum.map(&String.first/1)

    case letters do
      [] -> nil
      [one] -> String.upcase(one)
      [first | rest] -> String.upcase(first <> List.last(rest))
    end
  end

  def initials(_name), do: nil

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

  defp guard_public_host!(base, opts) do
    host = base |> URI.parse() |> Map.get(:host)

    if host == @public_host do
      bad = opts |> Map.keys() |> Enum.map(&to_string/1) |> Enum.filter(&(&1 in @self_host_only))

      Contract.ensure!(
        bad == [],
        "dice_bear option #{Enum.join(bad, ", ")}: não funciona na API pública (#{@public_host}); só em instância própria (dice_bear_base_url)"
      )
    end
  end

  defp check!(key, {:enum, values}, value) do
    Contract.require!(to_string(value), values, "dice_bear #{key}")
  end

  defp check!(key, {:range, min, max}, value) do
    Contract.ensure!(
      is_number(value) and value >= min and value <= max,
      "dice_bear #{key}: valor #{inspect(value)} fora do contrato; esperado número de #{min} a #{max}"
    )

    value
  end

  defp check!(key, :colors, value) do
    colors = value |> List.wrap() |> Enum.map(&hex!(key, &1))
    Contract.ensure!(colors != [], "dice_bear #{key}: esperado ao menos uma cor")
    colors
  end

  defp check!(key, :tags, value) do
    tags = List.wrap(value)

    Contract.ensure!(
      tags != [] and Enum.all?(tags, &(is_binary(&1) and &1 =~ ~r/\A!?[A-Za-z0-9:_-]+\z/)),
      "dice_bear #{key}: esperado texto como \"animation\" ou \"hairLength:long\" (\"!\" exclui)"
    )

    tags
  end

  defp hex!(key, color) do
    hex = if is_binary(color), do: String.trim_leading(color, "#"), else: nil

    Contract.ensure!(
      is_binary(hex) and hex =~ @hex,
      "dice_bear #{key}: cor #{inspect(color)} fora do contrato; esperado hex (#RGB, #RRGGBB ou #RRGGBBAA)"
    )

    hex
  end

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
