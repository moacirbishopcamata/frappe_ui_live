defmodule FrappeUIPhx.TokensSeamTest do
  @moduledoc """
  Teste de costura: tokens do Frappe UI (fonte) -> CSS gerado.

  Os valores esperados são lidos **direto da fonte vendorizada, por Node**, num
  caminho independente do gerador; o CSS é lido do arquivo em `priv/`. Se o
  gerador perder, truncar ou trocar um token, este teste quebra.
  """
  use ExUnit.Case, async: true

  @moduletag :node
  @css Path.expand("../../priv/static/frappe_ui.css", __DIR__)
  @dump Path.expand("../support/dump_tokens.mjs", __DIR__)

  setup_all do
    {json, 0} = System.cmd("node", [@dump])
    %{tokens: Jason.decode!(json), css: File.read!(@css)}
  end

  defp block(css, selector) do
    [_, body] = Regex.run(~r/#{Regex.escape(selector)} \{\n(.*?)\n\}/s, css)
    for [_, k, v] <- Regex.scan(~r/^  (--[\w-]+): (.*);$/m, body), into: %{}, do: {k, v}
  end

  test "todo token semântico claro do Frappe UI está em :root com o mesmo valor", %{
    tokens: t,
    css: css
  } do
    root = block(css, ":root")
    assert map_size(t["light"]) > 300
    for {name, value} <- t["light"], do: assert(root[name] == value, "token #{name} divergente")
  end

  test "todo token semântico escuro está em [data-theme=dark] com o mesmo valor", %{
    tokens: t,
    css: css
  } do
    dark = block(css, ~s([data-theme="dark"]))
    assert map_size(t["dark"]) > 300
    for {name, value} <- t["dark"], do: assert(dark[name] == value, "token #{name} divergente")
  end

  test "todo token semântico vira cor do tema Tailwind apontando para a variável", %{
    tokens: t,
    css: css
  } do
    for name <- Map.keys(t["light"]) do
      utility = String.replace_prefix(name, "--", "--color-")
      assert css =~ "  #{utility}: var(#{name});", "falta #{utility}"
    end
  end

  test "radius e focus ring existem", %{css: css} do
    assert css =~ "--radius-4: 8px;"
    assert css =~ "@utility focus-ring-blue"
    assert css =~ ~s|@custom-variant dark (&:where([data-theme="dark"], [data-theme="dark"] *));|
  end

  test "proveniência registra versão e hash do CSS gerado", %{css: css} do
    prov =
      @css
      |> Path.dirname()
      |> Path.join("../tokens.provenance.json")
      |> File.read!()
      |> Jason.decode!()

    assert prov["version"] == "1.1.0"
    assert prov["cssSha256"] == :crypto.hash(:sha256, css) |> Base.encode16(case: :lower)
  end
end
