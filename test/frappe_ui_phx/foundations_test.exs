defmodule FrappeUIPhx.FoundationsTest do
  @moduledoc """
  Costura: os dados dos Fundamentos (`priv/foundations.json`) × o CSS gerado (`priv/static/frappe_ui.css`).
  Cada token documentado precisa existir no CSS, senão a página mostraria um token que não funciona.
  """
  use ExUnit.Case, async: true

  alias FrappeUIPhx.Foundations

  @css Path.expand("../../priv/static/frappe_ui.css", __DIR__)

  setup_all do
    %{css: File.read!(@css)}
  end

  test "seções dos fundamentos" do
    assert Enum.map(Foundations.sections(), & &1.id) ==
             ~w(colors typography radius shadows focus_ring chart_colors)a

    assert Foundations.section(:radius).title == "Radius"
    assert Foundations.section(:nada) == nil
    assert Enum.all?(Foundations.sections(), &(&1.summary != ""))
  end

  test "toda cor semântica documentada existe no CSS (variável e utilitário de tema)", %{css: css} do
    for category <- Foundations.color_categories(), token <- Foundations.colors()[category] do
      assert css =~ "  --#{category}-#{token.name}: ",
             "variável --#{category}-#{token.name} ausente"

      assert css =~ "  --color-#{category}-#{token.name}: var(--#{category}-#{token.name});"
      assert is_binary(token.light) and is_binary(token.dark)
    end
  end

  test "claro e escuro diferem em ao menos alguns tokens (o tema escuro é real)" do
    differing = for t <- Foundations.colors()["surface"], t.light != t.dark, do: t.name
    assert length(differing) > 10
  end

  test "rampas primitivas: famílias e tons", _ctx do
    assert "gray" in Map.keys(Foundations.ramps()) and "blue" in Map.keys(Foundations.ramps())

    assert Enum.map(Foundations.ramps()["gray"], & &1.shade) ==
             ~w(50 100 200 300 400 500 600 700 800 900 950)
  end

  test "raios e sombras existem como variáveis estáticas do tema", %{css: css} do
    for r <- Foundations.radius(),
        do: assert(css =~ "--radius-#{r.name}: #{r.value};", "radius #{r.name}")

    assert Enum.find(Foundations.radius(), &(&1.name == "4")).value == "8px"

    for s <- Foundations.shadows(), s.name != "none" do
      assert css =~ "--shadow-elevation-#{s.name}: ", "sombra #{s.name}"
    end

    assert css =~ "@theme static {"
  end

  test "anéis de foco: variável e utilitário", %{css: css} do
    names = Enum.map(Foundations.focus_rings(), & &1.name)
    assert names == ~w(default red green amber blue violet)

    for name <- names do
      assert css =~ "--focus-outline-#{name}: "

      assert css =~
               if(name == "default",
                 do: "@utility focus-ring {",
                 else: "@utility focus-ring-#{name} {"
               )
    end
  end

  test "escala tipográfica: tamanhos, peso e utilitário correspondente", %{css: css} do
    base = Enum.find(Foundations.type_scale(), &(&1.name == "base"))
    assert base.size == "14px"
    assert Foundations.font_family() =~ "Inter"

    assert Enum.map(Foundations.font_weights(), & &1.name) ==
             ~w(regular medium semibold bold black)

    for item <- Foundations.type_scale(), not item.paragraph do
      assert css =~ "@utility fui-text-#{item.name} {", "utilitário fui-text-#{item.name}"
    end

    assert Enum.any?(Foundations.type_scale(), & &1.paragraph)
  end

  test "cores de gráficos acompanham a paleta usada pelos gráficos e existem no tema", %{css: css} do
    colors = Foundations.chart_colors()
    assert length(colors) == FrappeUIPhx.Charts.Scale.palette_size()
    assert hd(colors) == %{index: 0, family: "blue", color: "var(--surface-blue-6)"}

    for %{family: family} <- colors do
      assert css =~ "--surface-#{family}-6: ", "token surface-#{family}-6 ausente"
    end
  end

  test "helpers de classe e variável" do
    assert Foundations.color_class("surface", "gray-2", :bg) == "bg-surface-gray-2"
    assert Foundations.color_class("ink", "gray-8", :text) == "text-ink-gray-8"
    assert Foundations.color_class("outline", "gray-2", :border) == "border-outline-gray-2"
    assert Foundations.color_var("surface", "base") == "var(--surface-base)"
  end
end
