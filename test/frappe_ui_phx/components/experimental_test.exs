defmodule FrappeUIPhx.Components.ExperimentalTest do
  use FrappeUIPhx.Case, async: true

  alias FrappeUIPhx.Components.{
    Accordion,
    Calendar,
    CommandPalette,
    Dialog,
    ListView,
    Stepper,
    ThemeSwitcher
  }

  describe "Accordion" do
    test "seções exclusivas por padrão (details com o mesmo name) e item aberto pelo servidor" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Accordion.accordion id="faq">
          <:item id="a" title="Primeira" open>Corpo A</:item>
          <:item id="b" title="Segunda">Corpo B</:item>
        </Accordion.accordion>
        """)

      assert Enum.count(query(html, "details[name=faq]")) == 2
      assert has?(html, "details#faq-a[open]")
      refute has?(html, "details#faq-b[open]")
      assert text(html, "#faq-a summary") == "Primeira"
      assert html =~ "Corpo B"
    end

    test "multiple remove o agrupamento exclusivo" do
      assigns = %{}
      html = rendered_to_string(~H|<Accordion.accordion id="m" multiple>
  <:item id="a" title="A">x</:item>
</Accordion.accordion>|)
      refute has?(html, "details[name]")
    end

    test "contratos: id válido e itens únicos" do
      assigns = %{}

      assert_raise ArgumentError, ~r/accordion id/, fn ->
        rendered_to_string(~H|<Accordion.accordion id="a b">
  <:item id="a" title="A">x</:item>
</Accordion.accordion>|)
      end

      assert_raise ArgumentError, ~r/únicos/, fn ->
        rendered_to_string(~H|<Accordion.accordion id="ok">
  <:item id="a" title="A">x</:item><:item id="a" title="B">y</:item>
</Accordion.accordion>|)
      end
    end
  end

  describe "Calendar" do
    @events [
      %{date: ~D[2026-03-09], title: "Reunião", theme: :green},
      %{date: "2026-03-09", title: "Almoço"},
      %{date: ~D[2026-03-09], title: "Revisão", theme: :neon},
      %{date: "lixo", title: "Inválido"}
    ]

    test "events_by_day agrupa e descarta datas inválidas" do
      by_day = Calendar.events_by_day(@events)
      assert length(by_day[~D[2026-03-09]]) == 3
      assert map_size(by_day) == 1
    end

    test "mês, 42 dias, eventos limitados e mais contador" do
      assigns = %{events: @events}

      html =
        rendered_to_string(~H"""
        <Calendar.calendar
          id="agenda"
          month="2026-03-20"
          today="2026-03-15"
          selected="2026-03-09"
          events={@events}
          on_select="escolher"
          on_prev="ant"
          on_next="prox"
          on_today="hoje"
        />
        """)

      assert text(html, "[aria-live=polite]") == "Março 2026"
      assert Enum.count(query(html, "[data-day]")) == 42
      assert html_attr(html, "[data-day='2026-03-09']", "aria-selected") == "true"
      assert Enum.count(query(html, "[data-day='2026-03-09'] [data-event]")) == 2
      assert text(html, "[data-day='2026-03-09'] [data-more]") == "+1"
      assert html_attr(html, "[data-day='2026-03-15'] button", "class") =~ "border-outline-gray-4"
      assert html_attr(html, "[data-day='2026-03-09'] button", "phx-click") == "escolher"
      assert html_attr(html, "[data-day='2026-03-09'] button", "phx-value-date") == "2026-03-09"
      assert html_attr(html, "button[aria-label='Próximo mês']", "phx-click") == "prox"
      assert html_attr(html, "button[aria-label='Mês anterior']", "phx-click") == "ant"
      assert has?(html, "button[phx-click=hoje]")
    end

    test "mês padrão é o de hoje e sem eventos não há selos" do
      assigns = %{}
      html = rendered_to_string(~H|<Calendar.calendar id="c" today="2026-07-04" />|)
      assert text(html, "[aria-live=polite]") == "Julho 2026"
      refute has?(html, "[data-event]")
      refute has?(html, "button[phx-click=hoje]")
    end
  end

  describe "CommandPalette" do
    test "group_items preserva a ordem do primeiro aparecimento e search_text normaliza" do
      items = [
        %{label: "A", group: "Ir"},
        %{label: "B"},
        %{label: "C", group: "Ir"},
        %{label: "D", group: "Ação"}
      ]

      assert [
               {"Ir", [%{label: "A"}, %{label: "C"}]},
               {nil, [%{label: "B"}]},
               {"Ação", [%{label: "D"}]}
             ] = CommandPalette.group_items(items)

      assert CommandPalette.search_text(%{label: "Novo Pedido", group: "Criar", keywords: "Add"}) ==
               "novo pedido criar add"

      assert CommandPalette.search_text(%{label: "X"}) == "x"
    end

    test "renderiza dialog nativo com o hook do Dialog e o hook da paleta" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <CommandPalette.command_palette id="cmd">
          <:item
            label="Novo pedido"
            group="Criar"
            icon="plus"
            click="novo"
            shortcut={["N"]}
            keywords="adicionar"
          />
          <:item label="Ir para início" group="Ir" navigate="/" />
          <:item label="Sair" click="sair" />
        </CommandPalette.command_palette>
        """)

      assert html_attr(html, "dialog#cmd", "phx-hook") == Dialog.hook_name()
      assert html_attr(html, "#cmd-palette", "phx-hook") =~ "CommandPalette"
      assert html_attr(html, "#cmd-palette", "data-dialog") == "cmd"
      assert html_attr(html, "#cmd-palette", "data-shortcut") == "true"
      assert Enum.count(query(html, "[data-command-item]")) == 3
      assert Enum.count(query(html, "[data-command-group]")) == 3

      assert html_attr(html, "[data-command-item]", "data-search") ==
               "novo pedido criar adicionar"

      assert html_attr(html, "a[href='/']", "href") == "/"
      assert html =~ "Criar" and html =~ "lucide-plus"
      assert has?(html, "kbd")
    end

    test "o clique fecha a paleta antes de empurrar o evento" do
      assigns = %{}
      html = rendered_to_string(~H|<CommandPalette.command_palette id="cmd">
  <:item label="Sair" click="sair" />
</CommandPalette.command_palette>|)
      click = html_attr(html, "button[phx-click]", "phx-click")
      assert click =~ "fui:dialog-close"
      assert click =~ "sair"
    end

    test "shortcut desligado e contrato de id" do
      assigns = %{}
      html = rendered_to_string(~H|<CommandPalette.command_palette id="cmd" shortcut={false}>
  <:item label="x" click="x" />
</CommandPalette.command_palette>|)
      assert html_attr(html, "#cmd-palette", "data-shortcut") == "false"

      assert_raise ArgumentError, ~r/command_palette id/, fn ->
        rendered_to_string(~H|<CommandPalette.command_palette id="a b">
  <:item label="x" click="x" />
</CommandPalette.command_palette>|)
      end
    end
  end

  describe "ListView" do
    @rows [
      %{id: 1, nome: "Ana", time: "A"},
      %{id: 2, nome: "Bia", time: "B"},
      %{id: 3, nome: "Caio", time: "A"}
    ]

    test "groups/2 preserva a ordem e cobre vazio e sem agrupamento" do
      assert [{"A", [%{id: 1}, %{id: 3}]}, {"B", [%{id: 2}]}] = ListView.groups(@rows, & &1.time)
      assert ListView.groups(@rows, nil) == [{nil, @rows}]
      assert ListView.groups([], & &1.time) == []
    end

    test "grupos com contagem, recolhidos ocultos e evento de alternar" do
      assigns = %{rows: @rows}

      html =
        rendered_to_string(~H"""
        <ListView.list_view
          id="lv"
          rows={@rows}
          group_by={& &1.time}
          collapsed={["B"]}
          on_toggle="alternar"
        >
          <:col :let={r} label="Nome">{r.nome}</:col>
        </ListView.list_view>
        """)

      assert Enum.count(query(html, "tbody[data-group]")) == 2
      assert text(html, "tbody[data-group=A] button") =~ "(2)"
      assert html_attr(html, "tbody[data-group=A] button", "phx-value-group") == "A"
      assert html_attr(html, "tbody[data-group=A] button", "phx-click") == "alternar"
      assert html_attr(html, "tbody[data-group=A] button", "aria-expanded") == "true"
      assert html_attr(html, "tbody[data-group=B] button", "aria-expanded") == "false"
      assert has?(html, "tbody[data-group=B] tr[hidden]")
      refute has?(html, "tbody[data-group=A] tr[hidden]")
    end

    test "sem group_by não há cabeçalho de grupo; vazio mostra o texto" do
      assigns = %{rows: @rows}
      html = rendered_to_string(~H|<ListView.list_view id="lv" rows={@rows}>
  <:col :let={r} label="Nome">{r.nome}</:col>
</ListView.list_view>|)
      refute has?(html, "button[aria-expanded]")
      assert Enum.count(query(html, "tbody tr")) == 3

      empty = rendered_to_string(~H|<ListView.list_view id="lv" rows={[]} empty_text="Vazio">
  <:col label="N">x</:col>
</ListView.list_view>|)
      assert empty =~ "Vazio"
    end
  end

  describe "Stepper" do
    test "state/2" do
      assert {Stepper.state(0, 1), Stepper.state(1, 1), Stepper.state(2, 1)} ==
               {:done, :current, :upcoming}
    end

    test "estados derivados do assign, aria-current e botões só nas etapas concluídas" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Stepper.stepper current={1} on_go="ir">
          <:step label="Conta" description="Dados básicos" />
          <:step label="Pagamento" />
          <:step label="Revisão" />
        </Stepper.stepper>
        """)

      assert html_attr(html, "[data-step='0']", "data-state") == "done"
      assert html_attr(html, "[data-step='1']", "aria-current") == "step"
      assert html_attr(html, "[data-step='2']", "data-state") == "upcoming"
      assert Enum.count(query(html, "button[phx-click=ir]")) == 1
      assert html_attr(html, "button[phx-click=ir]", "phx-value-step") == "0"
      assert html =~ "Dados básicos"
      assert html =~ "lucide-check"
    end

    test "tudo concluído e orientação vertical" do
      assigns = %{}
      html = rendered_to_string(~H|<Stepper.stepper current={2} orientation={:vertical}>
  <:step label="A" /><:step label="B" />
</Stepper.stepper>|)
      assert Enum.count(query(html, "[data-state=done]")) == 2
      assert html_attr(html, "ol", "class") =~ "flex-col"
      refute has?(html, "[aria-current=step]")
    end

    test "contratos: current fora de 0..n e orientação" do
      assigns = %{}

      assert_raise ArgumentError, ~r/current deve estar entre 0 e 2/, fn ->
        rendered_to_string(
          ~H|<Stepper.stepper current={3}><:step label="A" /><:step label="B" /></Stepper.stepper>|
        )
      end

      assert_raise ArgumentError, ~r/stepper orientation/, fn ->
        rendered_to_string(
          ~H|<Stepper.stepper current={0} orientation={:diagonal}><:step label="A" /></Stepper.stepper>|
        )
      end
    end
  end

  describe "ThemeSwitcher" do
    test "links ?theme=, opção atual marcada" do
      assigns = %{}
      html = rendered_to_string(~H|<ThemeSwitcher.theme_switcher current="dark" />|)
      assert html_attr(html, "a[href='?theme=light']", "aria-pressed") == "false"
      assert html_attr(html, "a[href='?theme=dark']", "aria-pressed") == "true"
      assert html =~ "lucide-sun" and html =~ "lucide-moon"
      assert ThemeSwitcher.href("tema", "dark") == "?tema=dark"
    end

    test "tema desconhecido viola o contrato" do
      assigns = %{}

      assert_raise ArgumentError, ~r/theme_switcher current/, fn ->
        rendered_to_string(~H|<ThemeSwitcher.theme_switcher current="sepia" />|)
      end
    end
  end
end
