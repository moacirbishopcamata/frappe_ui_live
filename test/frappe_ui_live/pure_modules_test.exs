defmodule FrappeUILive.PureModulesTest do
  use ExUnit.Case, async: true

  alias FrappeUILive.{Calendar, Duration, Markdown}
  alias FrappeUILive.Components.{Anchor, Sortable}

  describe "Duration" do
    test "parse aceita as formas digitadas e barra o resto" do
      assert Duration.parse("1h 30m") == {:ok, 5400}
      assert Duration.parse("1:30:15") == {:ok, 5415}
      assert Duration.parse(90) == {:ok, 90}
      assert Duration.parse("") == {:ok, nil}
      assert Duration.parse(nil) == {:ok, nil}
      assert Duration.parse("xyz") == :error
      assert Duration.parse(-1) == :error
      assert Duration.parse(1.5) == :error
    end

    test "display mostra segundos como texto e preserva o que o usuário digitou" do
      assert Duration.display(5400) == "1h 30m"
      assert Duration.display("1h30") == "1h30"
      assert Duration.display(nil) == ""
      assert Duration.display(-3) == ""
    end

    test "ida e volta: humanize -> parse" do
      for s <- [0, 1, 59, 60, 3661, 86_399],
          do: assert({:ok, ^s} = s |> Duration.humanize() |> Duration.parse())
    end
  end

  describe "Calendar" do
    test "weeks/1 devolve 6 semanas de 7 dias começando no domingo e cobrindo o mês" do
      weeks = Calendar.weeks(~D[2026-03-15])
      assert length(weeks) == 6 and Enum.all?(weeks, &(length(&1) == 7))
      assert Date.day_of_week(hd(hd(weeks)), :sunday) == 1
      days = List.flatten(weeks)
      assert ~D[2026-03-01] in days and ~D[2026-03-31] in days
      assert Enum.uniq(days) == days
    end

    test "shift_month cruza o ano e sempre volta o dia 1" do
      assert Calendar.shift_month(~D[2026-12-20], 1) == ~D[2027-01-01]
      assert Calendar.shift_month(~D[2026-01-31], -1) == ~D[2025-12-01]
    end

    test "rótulos, formatação e conversão" do
      assert Calendar.label(~D[2026-03-09]) == "Março 2026"
      assert Calendar.format(~D[2026-03-09]) == "09/03/2026"
      assert Calendar.to_date("2026-03-09") == ~D[2026-03-09]
      assert Calendar.to_date("lixo") == nil
      assert Calendar.to_date(nil) == nil
      assert Calendar.to_date(~D[2026-03-09]) == ~D[2026-03-09]
      assert length(Calendar.weekdays()) == 7 and length(Calendar.months()) == 12
    end

    test "within?/3 com limites opcionais e inclusivos" do
      assert Calendar.within?(~D[2026-03-09], nil, nil)
      assert Calendar.within?(~D[2026-03-09], ~D[2026-03-09], ~D[2026-03-09])
      refute Calendar.within?(~D[2026-03-08], ~D[2026-03-09], nil)
      refute Calendar.within?(~D[2026-03-10], nil, ~D[2026-03-09])
    end
  end

  describe "Markdown (segurança)" do
    test "escapa HTML antes de qualquer marcação" do
      html = Markdown.to_html("<script>alert(1)</script> **ok**")
      refute html =~ "<script>"
      assert html =~ "&lt;script&gt;"
      assert html =~ "<strong>ok</strong>"
    end

    test "link javascript: e data: não viram âncora; http, mailto e relativo viram" do
      refute Markdown.to_html("[x](javascript:alert(1))") =~ "<a "
      refute Markdown.to_html("[x](data:text/html;base64,AAA)") =~ "<a "
      refute Markdown.to_html("[x](//evil.com)") =~ "<a "

      assert Markdown.to_html("[x](https://a.b/c)") =~
               ~s(<a href="https://a.b/c" rel="noopener noreferrer">x</a>)

      assert Markdown.to_html("[x](mailto:a@b.c)") =~ "<a "
      assert Markdown.to_html("[x](/rota)") =~ "<a "
    end

    test "atributo malicioso não escapa do href" do
      refute Markdown.to_html(~s{[x](https://a.b/"onmouseover="alert(1))}) =~
               ~s(onmouseover="alert)
    end

    test "blocos: título, listas, parágrafos e quebra de linha" do
      assert Markdown.to_html("## Olá") == "<h2>Olá</h2>"
      assert Markdown.to_html("- a\n- b") == "<ul><li>a</li><li>b</li></ul>"
      assert Markdown.to_html("1. a\n2. b") == "<ol><li>a</li><li>b</li></ol>"
      assert Markdown.to_html("um\n\ndois") == "<p>um</p><p>dois</p>"
      assert Markdown.to_html("a\nb") == "<p>a<br>b</p>"
      assert Markdown.to_html("`x` e _y_") == "<p><code>x</code> e <em>y</em></p>"
    end

    test "nil e vazio" do
      assert Markdown.to_html(nil) == ""
      assert Markdown.to_html("") == ""
    end
  end

  describe "Sortable.move/5" do
    @items [%{id: 1}, %{id: 2}, %{id: 3}, %{id: 4}]
    defp ids(items), do: Enum.map(items, & &1.id)

    test "move antes e depois do destino (ids como texto, vindos do DOM)" do
      assert ids(Sortable.move(@items, & &1.id, "4", "1", "before")) == [4, 1, 2, 3]
      assert ids(Sortable.move(@items, & &1.id, "1", "3", "after")) == [2, 3, 1, 4]
      assert ids(Sortable.move(@items, & &1.id, 2, 4, :after)) == [1, 3, 4, 2]
    end

    test "evento forjado não corrompe a ordem" do
      assert Sortable.move(@items, & &1.id, "9", "1", "before") == @items
      assert Sortable.move(@items, & &1.id, "1", "9", "before") == @items
      assert Sortable.move(@items, & &1.id, "1", "1", "after") == @items
    end

    test "preserva todos os itens (permutação)" do
      for id <- 1..4, to <- 1..4, pos <- ["before", "after"] do
        assert @items |> Sortable.move(& &1.id, id, to, pos) |> ids() |> Enum.sort() == [
                 1,
                 2,
                 3,
                 4
               ]
      end
    end
  end

  describe "Anchor" do
    test "valid_id! aceita identificadores seguros e barra CSS injetado" do
      assert Anchor.valid_id!("menu-1", "x") == "menu-1"
      assert_raise ArgumentError, ~r/x id inválido/, fn -> Anchor.valid_id!("a; b", "x") end
      assert_raise ArgumentError, fn -> Anchor.valid_id!(List.first([]), "x") end
    end

    test "estilos de âncora e placement" do
      assert Anchor.trigger_style("m") == "anchor-name: --fui-m"
      assert Anchor.panel_style("m", :top) =~ "position-area: top span-right"
      assert Anchor.panel_style("m") =~ "bottom span-right"
      assert_raise ArgumentError, ~r/anchor placement/, fn -> Anchor.panel_style("m", :meio) end
      assert Anchor.placements() == [:bottom, :top]
    end
  end
end
