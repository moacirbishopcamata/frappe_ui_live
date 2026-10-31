defmodule FrappeUIPhx.IconsTest do
  @moduledoc """
  Costura do catálogo de ícones: lucide-static (fonte) -> `priv/icons.json` ->
  `Icons` / `Icons.Lucide` / `<.icon>`. Os valores esperados vêm dos arquivos do
  `lucide-static` lidos aqui, por um caminho independente do gerador.
  """
  use FrappeUIPhx.Case, async: true

  alias FrappeUIPhx.Components.Icon
  alias FrappeUIPhx.Icons
  alias FrappeUIPhx.Icons.Lucide

  @root Path.expand("../..", __DIR__)
  @lucide Path.join(@root, "node_modules/lucide-static")
  @json Path.join(@root, "priv/icons.json")

  defp render(name, attrs \\ []) do
    assigns = %{name: name, attrs: attrs}
    rendered_to_string(~H|<Icon.icon name={@name} {@attrs} />|)
  end

  describe "catálogo x lucide-static (costura)" do
    @describetag :node

    test "todo ícone de icon-nodes.json e tags.json está no catálogo, com as mesmas tags" do
      nodes = @lucide |> Path.join("icon-nodes.json") |> File.read!() |> Jason.decode!()
      tags = @lucide |> Path.join("tags.json") |> File.read!() |> Jason.decode!()

      assert Icons.names() == nodes |> Map.keys() |> Enum.sort()
      assert Map.keys(tags) -- Icons.names() == []
      for {name, expected} <- tags, do: assert(Icons.get(name).tags == expected, name)
    end

    test "todo arquivo SVG do lucide-static resolve para um ícone (atual ou alias)" do
      svgs =
        @lucide
        |> Path.join("icons/*.svg")
        |> Path.wildcard()
        |> Enum.map(&Path.basename(&1, ".svg"))

      assert length(svgs) > 2000
      assert Enum.reject(svgs, &Icons.get/1) == []
    end

    test "a versão do catálogo confere com o lucide-static instalado" do
      pkg = @lucide |> Path.join("package.json") |> File.read!() |> Jason.decode!()
      assert Icons.version() == pkg["version"]
      assert @json |> File.read!() |> Jason.decode!() |> Map.fetch!("version") == pkg["version"]
    end

    test "mix icons.sync é determinístico: regenerar não muda o arquivo" do
      before = File.read!(@json)

      {_, 0} =
        System.cmd("node", [Path.join(@root, "scripts/sync_icons.mjs")], stderr_to_stdout: true)

      assert File.read!(@json) == before
    end
  end

  describe "componente por ícone" do
    test "todo ícone do catálogo tem função em Icons.Lucide, e só eles" do
      expected = Icons.names() |> Enum.map(&Icons.function_name/1) |> Enum.sort()

      actual =
        for {fun, 1} <- Lucide.__info__(:functions), fun != :__components__, do: fun

      assert Enum.sort(actual) -- expected == []
      assert expected -- actual == []
    end

    test "nomes que começam com dígito ganham prefixo e não colidem" do
      assert Icons.function_name("1-circle") == :i_1_circle
      assert Icons.function_name("circle-alert") == :circle_alert
      names = Enum.map(Icons.names(), &Icons.function_name/1)
      assert length(names) == length(Enum.uniq(names))
    end

    test "o atalho desenha o mesmo SVG que o componente genérico" do
      assigns = %{}
      shortcut = rendered_to_string(~H|<Lucide.circle_alert size={16} />|)
      assert shortcut == render("circle-alert", size: 16)
    end
  end

  describe "propriedades" do
    test "padrões: 24, currentColor, traço 2, decorativo" do
      html = render("plus")
      assert html_attr(html, "svg", "width") == "24"
      assert html_attr(html, "svg", "height") == "24"
      assert html_attr(html, "svg", "stroke") == "currentColor"
      assert html_attr(html, "svg", "stroke-width") == "2"
      assert html_attr(html, "svg", "fill") == "none"
      assert html_attr(html, "svg", "aria-hidden") == "true"
      assert has?(html, "svg.lucide.lucide-plus path")
    end

    test "size, color e stroke_width" do
      html = render("plus", size: 16, color: "red", stroke_width: 1.5)
      assert html_attr(html, "svg", "width") == "16"
      assert html_attr(html, "svg", "height") == "16"
      assert html_attr(html, "svg", "stroke") == "red"
      assert html_attr(html, "svg", "stroke-width") == "1.5"
    end

    test "absolute_stroke_width mantém a espessura visual (traço × 24 / tamanho)" do
      html = render("plus", size: 48, stroke_width: 2, absolute_stroke_width: true)
      assert html_attr(html, "svg", "stroke-width") == "1.0"
      html = render("plus", size: 12, stroke_width: 2, absolute_stroke_width: true)
      assert html_attr(html, "svg", "stroke-width") == "4.0"
    end

    test "class e atributos globais passam adiante" do
      html = render("plus", class: "size-4 text-red-500", "data-x": "1")
      assert html_attr(html, "svg", "class") =~ "lucide-plus size-4 text-red-500"
      assert html_attr(html, "svg", "data-x") == "1"
    end

    test "valores fora do contrato falham alto" do
      for {key, value} <- [size: 0, size: -1, size: "16", stroke_width: 0, stroke_width: nil] do
        assert_raise ArgumentError, ~r/fora do contrato/, fn -> render("plus", [{key, value}]) end
      end
    end

    test "-filled preenche o ícone" do
      html = render("star-filled")
      assert html_attr(html, "svg", "fill") == "currentColor"
      assert has?(html, "svg.lucide-star")
    end
  end

  describe "acessibilidade" do
    test "com title expõe role=img e <title>, sem aria-hidden" do
      html = render("plus", title: "Adicionar")
      assert html_attr(html, "svg", "role") == "img"
      assert html_attr(html, "svg", "aria-hidden") == nil
      assert text(html, "svg title") == "Adicionar"
    end

    test "sem title é decorativo" do
      html = render("plus")
      assert html_attr(html, "svg", "role") == nil
      refute has?(html, "svg title")
    end
  end

  describe "nomes" do
    test "alias (nome antigo) desenha o ícone atual" do
      assert render("alert-circle") =~ "lucide-circle-alert"
      assert Icons.get("alert-circle").name == "circle-alert"
    end

    test "prefixo lucide- é aceito" do
      assert render("lucide-x") =~ "lucide-x"
    end

    test "nome inexistente falha citando o nome e sugerindo parecidos" do
      error = assert_raise ArgumentError, fn -> render("circle-alertt") end
      assert error.message =~ ~s("circle-alertt")
      assert error.message =~ "circle-alert"
    end

    test "Icons.get/1 devolve nil para nome inexistente" do
      assert Icons.get("nao-existe-mesmo") == nil
    end
  end

  describe "busca" do
    test "por nome, com o nome exato primeiro" do
      assert [%{name: "plus"} | _] = Icons.search("plus")
    end

    test "por tag, mesmo sem o termo no nome" do
      tag_only =
        Enum.find(Icons.search(""), fn i ->
          Enum.any?(
            i.tags,
            &(String.length(&1) > 4 and not String.contains?(i.name, &1) and &1 =~ ~r/^[a-z]+$/)
          )
        end)

      tag =
        Enum.find(
          tag_only.tags,
          &(not String.contains?(tag_only.name, &1) and &1 =~ ~r/^[a-z]{5,}$/)
        )

      assert tag_only.name in Enum.map(Icons.search(tag), & &1.name)
    end

    test "sem caixa nem acento; vazio devolve todos; sem resultado devolve []" do
      assert Icons.search("PLUS") == Icons.search("plus")
      assert Icons.search("pluś") == Icons.search("plus")
      assert length(Icons.search("  ")) == length(Icons.names())
      assert Icons.search("zzzzzz-nada") == []
    end
  end

  describe "IconResolver" do
    test "o padrão deixa o nome passar e componentes aceitam ícones fora dos 82 originais" do
      assert FrappeUIPhx.IconResolver.resolve("anchor") == "anchor"
      assigns = %{}

      html =
        rendered_to_string(~H|<FrappeUIPhx.Components.Button.button icon="anchor" label="Ir" />|)

      assert has?(html, "button svg.lucide-anchor")
    end
  end
end
