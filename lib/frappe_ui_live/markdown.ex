defmodule FrappeUILive.Markdown do
  @moduledoc """
  Subconjunto **seguro** de Markdown usado pelo Editor: `## título`, listas
  (`- ` e `1. `), parágrafos, `**negrito**`, `_itálico_`, `` `código` `` e
  `[texto](https://url)`.

  Todo texto é escapado *antes* de qualquer marcação, e só links `http(s)`,
  `mailto:` ou relativos (`/...`) viram `<a>`: nada de HTML vindo do usuário
  chega ao DOM. É por isso que o Editor guarda Markdown, não HTML.
  """

  @doc "Markdown → HTML seguro (string)."
  @spec to_html(String.t() | nil) :: String.t()
  def to_html(nil), do: ""
  def to_html(""), do: ""

  def to_html(markdown) when is_binary(markdown) do
    markdown
    |> String.replace(~r/\r\n?/, "\n")
    |> String.split(~r/\n{2,}/, trim: true)
    |> Enum.map_join("", &block/1)
  end

  defp block(chunk) do
    lines = String.split(chunk, "\n", trim: true)

    cond do
      match?("## " <> _, chunk) ->
        "<h2>#{inline(String.replace_prefix(chunk, "## ", ""))}</h2>"

      Enum.all?(lines, &String.starts_with?(&1, "- ")) ->
        list("ul", lines, "- ")

      Enum.all?(lines, &Regex.match?(~r/\A\d+\. /, &1)) ->
        list("ol", Enum.map(lines, &Regex.replace(~r/\A\d+\. /, &1, "")), "")

      true ->
        "<p>#{lines |> Enum.map(&inline/1) |> Enum.join("<br>")}</p>"
    end
  end

  defp list(tag, lines, prefix) do
    items = Enum.map_join(lines, "", &"<li>#{inline(String.replace_prefix(&1, prefix, ""))}</li>")
    "<#{tag}>#{items}</#{tag}>"
  end

  defp inline(text) do
    text
    |> escape()
    |> then(&Regex.replace(~r/`([^`]+)`/, &1, "<code>\\1</code>"))
    |> then(&Regex.replace(~r/\*\*([^*]+)\*\*/, &1, "<strong>\\1</strong>"))
    |> then(&Regex.replace(~r/(?<![\w])_([^_]+)_(?![\w])/, &1, "<em>\\1</em>"))
    |> then(
      &Regex.replace(~r/\[([^\]]+)\]\(([^)\s]+)\)/, &1, fn whole, label, url ->
        link(whole, label, url)
      end)
    )
  end

  defp link(whole, label, url) do
    if safe_url?(url),
      do: ~s(<a href="#{url}" rel="noopener noreferrer">#{label}</a>),
      else: whole
  end

  @doc "A URL é segura para `href`? (`http(s)://`, `mailto:` ou caminho relativo `/…`)"
  @spec safe_url?(String.t()) :: boolean()
  def safe_url?(url) do
    Regex.match?(~r{\A(https?://|mailto:|/(?!/))}i, url) and
      not String.contains?(url, ["\"", "<", ">"])
  end

  defp escape(text), do: text |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string()
end
