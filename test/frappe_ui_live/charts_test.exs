defmodule FrappeUILive.ChartsTest do
  use FrappeUILive.Case, async: true

  alias FrappeUILive.Charts.{
    Bar,
    Cartesian,
    ChartCard,
    Donut,
    Frame,
    Legend,
    Line,
    Matrix,
    NumberCard,
    Proportion,
    Sankey,
    Scale,
    Scatter,
    Tooltip
  }

  @cats ["Jan", "Fev", "Mar"]
  @series [%{name: "A", data: [10, 20, 30]}, %{name: "B", data: [5, 15, 25]}]

  describe "Scale (puro)" do
    test "nice_max arredonda para 1, 2, 5 × 10ⁿ" do
      assert Scale.nice_max(0) == 1
      assert Scale.nice_max(0.4) == 1
      assert Scale.nice_max(7) == 10
      assert Scale.nice_max(130) == 200
      assert Scale.nice_max(450) == 500
      assert Scale.nice_max(1000) == 1000
      for v <- [1.5, 3, 99, 1234, 98_765], do: assert(Scale.nice_max(v) >= v)
    end

    test "ticks, linear e formatação" do
      assert Scale.ticks(100) == [0.0, 25.0, 50.0, 75.0, 100.0]
      assert Scale.linear(5, {0, 10}, {100, 0}) == 50.0
      assert Scale.linear(5, {3, 3}, {7, 9}) == 7.0
      assert Scale.n(3) == "3"
      assert Scale.n(3.14159) == "3.14"
      assert Scale.n(2.0) == "2"
      assert Scale.short(950) == "950"
      assert Scale.short(1200) == "1,2 mil"
      assert Scale.short(3_000_000) == "3 mi"
    end

    test "cores vêm do tema e repetem depois de esgotar a paleta" do
      assert Scale.color(0) == "var(--surface-blue-6)"
      assert Scale.color(Scale.palette_size()) == Scale.color(0)
    end
  end

  describe "Cartesian.layout/3 (contrato)" do
    test "calcula grade e escalas" do
      layout = Cartesian.layout(@cats, @series, 240)
      assert layout.max == 50 and layout.count == 3
      assert length(layout.ticks) == 5
      assert Cartesian.y(0, layout.max, layout.plot) == layout.plot.bottom
    end

    test "série com tamanho diferente das categorias viola a pré-condição" do
      assert_raise ArgumentError, ~r/um número por categoria/, fn ->
        Cartesian.layout(@cats, [%{name: "x", data: [1, 2]}], 240)
      end

      assert_raise ArgumentError, fn ->
        Cartesian.layout(@cats, [%{name: "x", data: [1, "a", 3]}], 240)
      end
    end
  end

  describe "BarChart" do
    test "uma barra por série e categoria, com título e legenda" do
      assigns = %{c: @cats, s: @series}
      html = rendered_to_string(~H|<Bar.bar_chart categories={@c} series={@s} />|)
      assert Enum.count(query(html, "[data-bar]")) == 6
      assert html =~ "Jan · A: 10"
      assert html =~ "var(--surface-blue-6)" and html =~ "var(--surface-green-6)"
      assert has?(html, "ul")
    end

    test "alturas são proporcionais aos valores" do
      layout = Cartesian.layout(@cats, @series, 240)
      [first | _] = bars = Bar.bars(@cats, @series, layout)
      tallest = Enum.max_by(bars, & &1.h)
      assert tallest.title =~ "Mar · A: 30"
      assert first.h < tallest.h
      assert Enum.all?(bars, &(&1.h >= 0 and &1.w > 0))
    end

    test "uma série só não mostra legenda" do
      assigns = %{c: @cats, s: [hd(@series)]}
      refute has?(rendered_to_string(~H|<Bar.bar_chart categories={@c} series={@s} />|), "ul")
    end

    test "estados: vazio, carregando e erro são distintos" do
      assigns = %{c: @cats, s: @series}
      empty = rendered_to_string(~H|<Bar.bar_chart categories={[]} series={[]} />|)
      assert has?(empty, "[data-chart-state=empty]")
      refute has?(empty, "svg")

      assert has?(
               rendered_to_string(~H|<Bar.bar_chart categories={@c} series={@s} loading />|),
               "[data-chart-state=loading]"
             )

      error = rendered_to_string(~H|<Bar.bar_chart categories={@c} series={@s} error="falhou" />|)
      assert error =~ "falhou" and error =~ "Não foi possível"
      refute has?(error, "svg")
    end
  end

  describe "Line e Area" do
    test "linha tem path por série; área acrescenta o preenchimento fechado" do
      layout = Cartesian.layout(@cats, @series, 240)
      [a, b] = Line.lines(@cats, @series, layout)
      assert a.path =~ ~r/\AM[\d.]+,[\d.]+ L/
      assert a.area =~ "Z" and b.points |> length() == 3

      assigns = %{c: @cats, s: @series}
      line = rendered_to_string(~H|<Line.line_chart categories={@c} series={@s} />|)
      area = rendered_to_string(~H|<Line.area_chart categories={@c} series={@s} />|)
      assert Enum.count(query(line, "[data-point]")) == 6
      assert Enum.count(query(line, "path[fill-opacity]")) == 0
      assert Enum.count(query(area, "path[fill-opacity]")) == 2
    end

    test "estado vazio" do
      assigns = %{}

      assert has?(
               rendered_to_string(~H|<Line.line_chart categories={[]} series={[]} />|),
               "[data-chart-state=empty]"
             )
    end
  end

  describe "Donut" do
    test "fatias somam 100% e ignoram valores não positivos" do
      slices =
        Donut.slices([
          %{label: "a", value: 1},
          %{label: "b", value: 3},
          %{label: "z", value: 0},
          %{label: "n", value: -2}
        ])

      assert Enum.map(slices, & &1.label) == ["a", "b"]
      assert Enum.sum(Enum.map(slices, & &1.percent)) == 100.0
    end

    test "fatia única de 100% vira anel completo (dois arcos)" do
      [slice] = Donut.slices([%{label: "tudo", value: 5}])
      assert length(String.split(slice.path, "M", trim: true)) == 2
      assert slice.percent == 100.0
    end

    test "renderiza fatias, total no centro e legenda" do
      assigns = %{d: [%{label: "a", value: 2}, %{label: "b", value: 2}]}
      html = rendered_to_string(~H|<Donut.donut_chart data={@d} />|)
      assert Enum.count(query(html, "[data-slice]")) == 2
      assert html =~ ">4<" or html =~ "4\n"
      assert has?(html, "ul")
    end

    test "vazio e center_label" do
      assigns = %{}

      assert has?(
               rendered_to_string(~H|<Donut.donut_chart data={[]} />|),
               "[data-chart-state=empty]"
             )

      assigns = %{d: [%{label: "a", value: 1}]}
      assert rendered_to_string(~H|<Donut.donut_chart data={@d} center_label="R$ 9" />|) =~ "R$ 9"
    end
  end

  describe "Proporção" do
    test "percentage_bar: larguras percentuais somam 100" do
      parts = Proportion.parts([%{label: "a", value: 1}, %{label: "b", value: 3}])
      assert Enum.map(parts, & &1.percent) == [25.0, 75.0]
      assigns = %{d: [%{label: "a", value: 1}, %{label: "b", value: 3}]}
      html = rendered_to_string(~H|<Proportion.percentage_bar_chart data={@d} />|)
      assert Enum.count(query(html, "[data-part]")) == 2
      assert html =~ "width: 75.0%"
    end

    test "funil: largura proporcional e decrescente" do
      [a, b] =
        Proportion.funnel([%{label: "Visitas", value: 100}, %{label: "Compras", value: 25}], 200)

      assert a.percent == 100.0 and b.percent == 25.0
      assert a.points != b.points
      assert Proportion.funnel([], 200) == []

      assigns = %{s: [%{label: "Visitas", value: 100}, %{label: "Compras", value: 25}]}
      html = rendered_to_string(~H|<Proportion.funnel_chart steps={@s} />|)
      assert Enum.count(query(html, "[data-step]")) == 2
    end

    test "vazios" do
      assigns = %{}

      assert has?(
               rendered_to_string(~H|<Proportion.percentage_bar_chart data={[]} />|),
               "[data-chart-state=empty]"
             )

      assert has?(
               rendered_to_string(~H|<Proportion.funnel_chart steps={[]} />|),
               "[data-chart-state=empty]"
             )
    end
  end

  describe "Matrix" do
    test "heatmap: opacidade proporcional ao máximo e contrato da matriz" do
      cells = Matrix.cells(["r1", "r2"], ["c1", "c2"], [[0, 5], [10, 5]])
      assert length(cells) == 4
      assert Enum.find(cells, &(&1.value == 10)).opacity == 1.0
      assert Enum.find(cells, &(&1.value == 0)).opacity == 0.08

      assigns = %{}

      assert_raise ArgumentError, ~r/matriz 2×2/, fn ->
        rendered_to_string(
          ~H|<Matrix.heatmap_chart rows={["a", "b"]} cols={["x", "y"]} values={[[1, 2]]} />|
        )
      end

      html =
        rendered_to_string(
          ~H|<Matrix.heatmap_chart rows={["a", "b"]} cols={["x", "y"]} values={[[1, 2], [3, 4]]} />|
        )

      assert Enum.count(query(html, "[data-cell]")) == 4
    end

    test "calendário: não passa do último dia e destaca valores" do
      data = %{~D[2026-03-09] => 4, ~D[2026-03-10] => 8}
      days = Matrix.calendar_days(data, ~D[2026-03-12], 2)
      assert List.last(days).iso == "2026-03-12"
      assert Enum.find(days, &(&1.iso == "2026-03-10")).opacity == 1.0
      assert Enum.find(days, &(&1.iso == "2026-03-11")).opacity == 0.08
      assert Enum.all?(days, &(&1.weekday in 0..6))

      assigns = %{d: data}

      html =
        rendered_to_string(
          ~H|<Matrix.calendar_heatmap_chart data={@d} end_date="2026-03-12" weeks={2} />|
        )

      assert has?(html, "[data-day='2026-03-10']")

      assert_raise ArgumentError, ~r/weeks/, fn ->
        rendered_to_string(~H|<Matrix.calendar_heatmap_chart data={@d} weeks={99} />|)
      end

      assert has?(
               rendered_to_string(~H|<Matrix.calendar_heatmap_chart data={%{}} />|),
               "[data-chart-state=empty]"
             )
    end
  end

  describe "Scatter" do
    test "geometria dentro da área e contrato dos pontos" do
      geo = Scatter.geometry([%{name: "s", points: [{1, 2}, {5, 8}]}], 260)
      [serie] = geo.series

      assert Enum.all?(
               serie.points,
               &(&1.x >= geo.left and &1.x <= geo.right and &1.y <= geo.bottom)
             )

      assigns = %{s: [%{name: "s", points: [{1, 2}, {5, 8}]}]}

      assert Enum.count(
               query(
                 rendered_to_string(~H|<Scatter.scatter_chart series={@s} />|),
                 "[data-point]"
               )
             ) == 2

      assigns = %{bad: [%{name: "s", points: [{1, "x"}]}]}

      assert_raise ArgumentError, ~r/tuplas/, fn ->
        rendered_to_string(~H|<Scatter.scatter_chart series={@bad} />|)
      end

      assigns = %{}

      assert has?(
               rendered_to_string(
                 ~H|<Scatter.scatter_chart series={[%{name: "s", points: []}]} />|
               ),
               "[data-chart-state=empty]"
             )
    end
  end

  describe "Sankey" do
    @links [
      %{source: "A", target: "C", value: 5},
      %{source: "B", target: "C", value: 3},
      %{source: "C", target: "D", value: 8}
    ]

    test "colunas pela profundidade e fluxo conservado" do
      %{nodes: nodes, links: links} = Sankey.layout(@links, 280)
      by_id = Map.new(nodes, &{&1.id, &1})
      assert {by_id["A"].column, by_id["C"].column, by_id["D"].column} == {0, 1, 2}
      assert by_id["C"].value == 8
      assert length(links) == 3
      assert Enum.all?(nodes, &(&1.h > 0 and &1.y >= 0))
      assert_in_delta Enum.find(links, &(&1.source == "C")).width, by_id["C"].h, 0.001
    end

    test "ciclo falha alto" do
      assert_raise ArgumentError, ~r/ciclo/, fn ->
        Sankey.layout(
          [%{source: "A", target: "B", value: 1}, %{source: "B", target: "A", value: 1}],
          200
        )
      end
    end

    test "renderiza e trata vazio" do
      assigns = %{l: @links}
      html = rendered_to_string(~H|<Sankey.sankey_chart links={@l} />|)
      assert Enum.count(query(html, "[data-link]")) == 3
      assert Enum.count(query(html, "[data-node]")) == 4

      assert has?(
               rendered_to_string(~H|<Sankey.sankey_chart links={[]} />|),
               "[data-chart-state=empty]"
             )
    end
  end

  describe "Cartões, legenda, tooltip e estados" do
    test "NumberCard: delta positivo, negativo e estados" do
      assigns = %{}

      up =
        rendered_to_string(
          ~H|<NumberCard.number_card label="Receita" value="R$ 10" delta={12.5} />|
        )

      assert text(up, "[data-value]") == "R$ 10"
      assert text(up, "[data-delta]") =~ "+12,5%"
      assert html_attr(up, "[data-delta]", "class") =~ "text-ink-green-5"

      assert html_attr(
               rendered_to_string(
                 ~H|<NumberCard.number_card label="x" value="1" delta={-3.0} />|
               ),
               "[data-delta]",
               "class"
             ) =~ "text-ink-red-5"

      refute has?(
               rendered_to_string(~H|<NumberCard.number_card label="x" value="1" />|),
               "[data-delta]"
             )

      assert rendered_to_string(~H|<NumberCard.number_card label="x" value="1" loading />|) =~
               "animate-pulse"

      assert rendered_to_string(~H|<NumberCard.number_card label="x" value="1" error="boom" />|) =~
               "boom"

      assert NumberCard.format_delta(0.0) == "0%"
      assert NumberCard.format_delta(-3.04) == "-3%"
    end

    test "ChartCard e Legend" do
      assigns = %{}
      html = rendered_to_string(~H|<ChartCard.chart_card title="Vendas" subtitle="2026">
  <:actions>X</:actions>corpo
</ChartCard.chart_card>|)
      assert text(html, "h3") == "Vendas" and html =~ "2026" and html =~ "corpo" and html =~ "X"
      assigns = %{i: Legend.from_names(["a", "b"])}

      assert Enum.count(query(rendered_to_string(~H|<Legend.chart_legend items={@i} />|), "li")) ==
               2

      assert refute_has(rendered_to_string(~H|<Legend.chart_legend items={[]} />|), "ul")
    end

    test "Tooltip posiciona a dica acima do ponto" do
      assigns = %{}

      html =
        rendered_to_string(
          ~H|<svg><Tooltip.chart_tooltip x={100.0} y={50.0} text="Mar: 30" /></svg>|
        )

      assert html =~ "Mar: 30" and html =~ "group-hover:visible"
    end

    test "Frame.state/3 dá precedência: erro > carregando > vazio > pronto" do
      assert Frame.state(true, "x", true) == :error
      assert Frame.state(true, nil, true) == :loading
      assert Frame.state(false, "", true) == :empty
      assert Frame.state(false, nil, false) == :ready
    end
  end

  defp refute_has(html, selector), do: not has?(html, selector)
end
