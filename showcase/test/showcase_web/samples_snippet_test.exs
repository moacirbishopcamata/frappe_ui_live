defmodule ShowcaseWeb.SamplesSnippetTest do
  use ExUnit.Case, async: true

  alias Showcase.Spec
  alias ShowcaseWeb.{CatalogLive, Samples, Snippet}

  describe "Snippet.build/2" do
    test "sem diferenças dos padrões vira tag vazia" do
      spec = Spec.get(:badge)
      assert Snippet.build(spec, Spec.defaults(spec)) == "<.badge />"
    end

    test "inclui só o que difere do padrão, com a sintaxe de cada tipo" do
      spec = Spec.get(:button)

      attrs =
        Spec.defaults(spec)
        |> Map.merge(%{variant: :solid, label: "Ok", loading: true, disabled: false})

      snippet = Snippet.build(spec, attrs)
      assert snippet =~ "<.button"
      assert snippet =~ "variant={:solid}"
      assert snippet =~ ~s(label="Ok")
      assert snippet =~ "\n  loading\n"
      refute snippet =~ "disabled"
      refute snippet =~ "theme"
    end

    test "inteiros usam chaves" do
      spec = Spec.get(:progress)
      assert Snippet.build(spec, %{value: 40, size: :md}) =~ "value={40}"
    end
  end

  describe "Samples" do
    test "initial/1 fornece amostras e {} para o resto" do
      assert Samples.initial(:button) == %{label: "Salvar"}
      assert Samples.initial(:divider) == %{}
    end

    test "caminho genérico aplica os defaults dos atributos (apply direto)" do
      spec = Spec.get(:badge)
      attrs = Spec.defaults(spec) |> Map.merge(Samples.initial(:badge))
      assert {:ok, html} = Samples.render(spec, attrs)
      assert Phoenix.HTML.safe_to_string(html) =~ "Novo"
    end

    test "valor fora do contrato vira {:error, mensagem}, sem levantar" do
      spec = Spec.get(:badge)
      attrs = Spec.defaults(spec) |> Map.merge(%{theme: :neon, label: "x"})
      assert {:error, message} = Samples.render(spec, attrs)
      assert message =~ "badge theme"
    end
  end

  test "summary/1 pega o primeiro parágrafo" do
    assert CatalogLive.summary("Primeiro.\n\nSegundo.") == "Primeiro."
    assert CatalogLive.summary("") == ""
  end

  describe "cobertura de amostras" do
    test "ids genéricos existem no catálogo" do
      ids = FrappeUILive.Components.catalog() |> Enum.map(& &1.id)
      assert Samples.generic_ids() -- ids == []
    end

    test "componente sem amostra falha alto (não cai num caminho genérico)" do
      spec = %{id: :componente_novo, module: FrappeUILive.Components.Badge, fun: :badge}
      assert_raise FunctionClauseError, fn -> Samples.render(spec, %{}, %{}) end
    end

    test "todo id do catálogo renderiza com os valores iniciais (genérico ou com amostra própria)" do
      upload =
        Phoenix.LiveView.allow_upload(%Phoenix.LiveView.Socket{}, :demo, accept: ~w(.png)).assigns.uploads.demo

      extras = %{upload: upload, saved_at: nil, demo: Samples.demo_state(), theme: "light"}

      for entry <- FrappeUILive.Components.catalog() do
        spec = Spec.get(entry.id)
        attrs = spec |> Spec.defaults() |> Map.merge(Samples.initial(entry.id))
        assert {tag, _} = Samples.render(spec, attrs, extras)
        assert tag in [:ok, :live], "#{entry.id}: #{inspect(tag)}"
      end
    end
  end
end
