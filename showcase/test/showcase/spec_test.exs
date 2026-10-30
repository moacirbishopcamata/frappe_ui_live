defmodule Showcase.SpecTest do
  use ExUnit.Case, async: true

  alias Showcase.Spec

  test "all/0 cobre todo o catálogo, com documentação do módulo" do
    specs = Spec.all()
    assert length(specs) == length(FrappeUILive.Components.catalog())
    assert Enum.all?(specs, &(&1.doc != ""))
  end

  test "reflete os atributos reais do Button (valores, defaults, obrigatoriedade)" do
    spec = Spec.get(:button)
    variant = Enum.find(spec.attrs, &(&1.name == :variant))

    assert variant.values == ~w(solid subtle outline ghost)a
    assert variant.default == :subtle
    assert variant.editable
    refute Enum.any?(spec.attrs, &(&1.name == :rest))
    assert Enum.any?(spec.slots, &(&1.name == :inner_block))
  end

  test "atributo obrigatório e slot com atributos (Alert, Dropdown)" do
    assert Enum.find(Spec.get(:alert).attrs, &(&1.name == :title)).required
    item = Enum.find(Spec.get(:dropdown).slots, &(&1.name == :item))
    assert item.required
    assert Enum.any?(item.attrs, &(&1.name == :label and &1.required))
  end

  test "só tipos simples são editáveis; struct de FormField não" do
    spec = Spec.get(:text_input)
    refute Enum.find(spec.attrs, &(&1.name == :field)).editable
    assert Enum.find(spec.attrs, &(&1.name == :type)).editable
  end

  test "get/1 devolve nil para id desconhecido" do
    assert Spec.get(:nao_existe) == nil
  end

  test "defaults/1 e cast/2 ida e volta" do
    spec = Spec.get(:button)
    assert %{theme: :gray, variant: :subtle, size: :sm, loading: false} = Spec.defaults(spec)

    cast =
      Spec.cast(spec, %{
        "theme" => "red",
        "variant" => "solid",
        "loading" => "true",
        "label" => "Ok"
      })

    assert %{theme: :red, variant: :solid, loading: true, label: "Ok", size: :sm} = cast
  end

  test "cast/2 com entrada inválida cai no default, sem levantar" do
    spec = Spec.get(:button)
    cast = Spec.cast(spec, %{"theme" => "neon", "size" => "", "label" => ""})
    assert cast.theme == :gray
    assert cast.size == :sm
    assert cast.label == nil
  end

  test "cast/2 de inteiro e de string obrigatória" do
    progress = Spec.get(:progress)
    assert Spec.cast(progress, %{"value" => "55"}).value == 55
    assert Spec.cast(progress, %{"value" => "abc"}).value == nil
    assert Spec.cast(progress, %{}).value == nil

    alert = Spec.get(:alert)
    assert Spec.cast(alert, %{"title" => ""}).title == ""
  end

  test "ausência de parâmetro de checkbox significa false" do
    assert Spec.cast(Spec.get(:button), %{}).disabled == false
  end
end
