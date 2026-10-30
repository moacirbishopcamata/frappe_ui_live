defmodule ShowcaseWeb.FoundationsTest do
  @moduledoc "Páginas de Fundamentos e comportamentos dos componentes experimentais no mostruário."
  use ShowcaseWeb.ConnCase, async: true

  alias FrappeUILive.Foundations
  alias ShowcaseWeb.FoundationsView

  describe "navegação" do
    test "o índice e o menu listam todos os fundamentos", %{conn: conn} do
      {:ok, view, _} = live(conn, "/")

      for section <- Foundations.sections() do
        assert has_element?(view, "#card-foundation-#{section.id}"), "sem card para #{section.id}"
        assert has_element?(view, "#nav-foundation-#{section.id}"), "sem menu para #{section.id}"
      end
    end

    test "navegar pelo menu abre a página (patch) e marca o item", %{conn: conn} do
      {:ok, view, _} = live(conn, "/")
      view |> element("#nav-foundation-radius") |> render_click()
      assert_patch(view, "/f/radius")
      assert has_element?(view, "#foundation-radius")
      assert view |> element("#nav-foundation-radius") |> render() =~ ~s(aria-current="page")
    end

    test "fundamento desconhecido volta ao índice com aviso", %{conn: conn} do
      assert {:error, {:live_redirect, %{to: "/", flash: flash}}} = live(conn, "/f/nao_existe")
      assert flash["error"] =~ "desconhecido"
    end

    test "componentes continuam abrindo depois de visitar um fundamento", %{conn: conn} do
      {:ok, view, _} = live(conn, "/f/colors")
      view |> element("#nav-button") |> render_click()
      assert has_element?(view, "#playground-form")
      refute has_element?(view, "#foundation-colors")
    end
  end

  describe "Colors" do
    test "mostra cada token semântico (nome, classe, valor claro e escuro)", %{conn: conn} do
      {:ok, view, _} = live(conn, "/f/colors")

      for category <- Foundations.color_categories(), token <- Foundations.colors()[category] do
        assert has_element?(view, ~s([data-token="#{category}-#{token.name}"])),
               "falta #{category}-#{token.name}"
      end

      html = view |> element(~s([data-token="surface-gray-2"])) |> render()
      assert html =~ "var(--surface-gray-2)"
      assert html =~ "bg-surface-gray-2"
      assert html =~ "☀" and html =~ "☾"
    end

    test "rampas primitivas por família", %{conn: conn} do
      {:ok, view, _} = live(conn, "/f/colors")

      for family <- Map.keys(Foundations.ramps()),
          do: assert(has_element?(view, ~s([data-ramp="#{family}"])))
    end

    test "families/1 agrupa pelo nome e mantém a ordem" do
      tokens = [
        %{name: "base"},
        %{name: "gray-1"},
        %{name: "gray-2"},
        %{name: "sidebar"},
        %{name: "red-1"}
      ]

      assert [{"base", [_, _]}, {"gray", [_, _]}, {"red", [_]}] = FoundationsView.families(tokens)
    end
  end

  describe "Typography" do
    test "fonte, pesos e toda a escala", %{conn: conn} do
      {:ok, view, _} = live(conn, "/f/typography")
      assert render(view) =~ Foundations.font_family()

      for weight <- Foundations.font_weights(),
          do: assert(has_element?(view, ~s([data-weight="#{weight.name}"])))

      for item <- Foundations.type_scale(),
          do: assert(has_element?(view, ~s([data-type="#{item.name}"])), item.name)

      assert view |> element(~s([data-type="base"])) |> render() =~ "font-size: 14px"
    end
  end

  describe "Radius, Shadows e Focus ring" do
    test "radius: uma amostra por token, com a variável do tema", %{conn: conn} do
      {:ok, view, _} = live(conn, "/f/radius")

      for item <- Foundations.radius() do
        assert view |> element(~s([data-radius="#{item.name}"])) |> render() =~
                 "var(--radius-#{item.name})"
      end
    end

    test "shadows: uma amostra por elevação", %{conn: conn} do
      {:ok, view, _} = live(conn, "/f/shadows")

      for item <- Foundations.shadows(), item.name != "none" do
        assert view |> element(~s([data-shadow="#{item.name}"])) |> render() =~
                 "var(--shadow-elevation-#{item.name})"
      end

      assert view |> element(~s([data-shadow="none"])) |> render() =~ "box-shadow: none"
    end

    test "focus ring: variável estática e botão com a classe de foco literal", %{conn: conn} do
      {:ok, view, _} = live(conn, "/f/focus_ring")

      for item <- Foundations.focus_rings() do
        html = view |> element(~s([data-ring="#{item.name}"])) |> render()
        assert html =~ "var(--focus-outline-#{item.name})"
        assert html =~ FoundationsView.ring_class(item.name)
      end
    end
  end

  describe "Chart colors" do
    test "paleta de séries na ordem de uso e gráfico de exemplo", %{conn: conn} do
      {:ok, view, _} = live(conn, "/f/chart_colors")

      for color <- Foundations.chart_colors() do
        assert view |> element(~s([data-series="#{color.index}"])) |> render() =~ color.color
      end

      assert has_element?(view, "#foundation-chart-colors [data-bar]")
    end
  end

  describe "tema" do
    test "as páginas acompanham o tema escuro (variáveis do tema, sem cores fixas)", %{conn: conn} do
      conn = get(conn, "/f/colors?theme=dark")
      html = html_response(conn, 200)
      assert html =~ ~s(data-theme="dark")
      assert html =~ "var(--surface-gray-2)"
    end
  end

  describe "experimentais" do
    test "calendar: navegar, voltar a hoje e escolher um dia (estado no servidor)", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/calendar")
      label = fn -> view |> element("#demo-calendar [aria-live=polite]") |> render() end
      first = label.()

      render_click(view, "cal_next", %{})
      refute label.() == first
      render_click(view, "cal_today", %{})
      assert label.() == first

      view |> element("#demo-calendar [data-day] button", "15") |> render_click()
      assert view |> element("#demo-calendar [aria-selected=true]") |> render() =~ "15"
      render_click(view, "cal_select", %{"date" => "lixo"})
      assert Process.alive?(view.pid)
    end

    test "calendar mostra eventos do mês exibido", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/calendar")
      html = view |> element("#demo-calendar") |> render()
      assert html =~ "Reunião" and html =~ "Entrega"
      assert html =~ "+1"
    end

    test "list_view: recolher e expandir um grupo; grupo forjado é ignorado", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/list_view")

      assert view |> element("#preview tbody[data-group=Admin] button") |> render() =~
               ~s(aria-expanded="true")

      render_click(view, "lv_toggle", %{"group" => "Admin"})

      assert view |> element("#preview tbody[data-group=Admin] button") |> render() =~
               ~s(aria-expanded="false")

      assert view |> element("#preview tbody[data-group=Admin]") |> render() =~ "hidden"

      render_click(view, "lv_toggle", %{"group" => "Admin"})

      assert view |> element("#preview tbody[data-group=Admin] button") |> render() =~
               ~s(aria-expanded="true")

      render_click(view, "lv_toggle", %{"group" => "Forjado"})
      assert Process.alive?(view.pid)
    end

    test "stepper: o servidor avança e volta, com limites", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/stepper")
      assert view |> element("#preview [aria-current=step]") |> render() =~ "Pagamento"

      render_click(view, "step_go", %{"step" => "2"})
      assert view |> element("#preview [aria-current=step]") |> render() =~ "Revisão"
      render_click(view, "step_go", %{"step" => "0"})
      assert view |> element("#preview [aria-current=step]") |> render() =~ "Conta"

      render_click(view, "step_go", %{"step" => "99"})
      render_click(view, "step_go", %{"step" => "x"})
      assert view |> element("#preview [aria-current=step]") |> render() =~ "Conta"
    end

    test "theme_switcher reflete o tema atual da sessão", %{conn: conn} do
      conn = get(conn, "/c/theme_switcher?theme=dark")
      {:ok, view, _} = live(recycle(conn), "/c/theme_switcher")

      assert view |> element("#preview a[href='?theme=dark']") |> render() =~
               ~s(aria-pressed="true")
    end

    test "accordion e command_palette renderizam sua estrutura", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/accordion")
      assert has_element?(view, "#preview details[name=demo-accordion]")
      assert has_element?(view, "#preview details[open]")

      {:ok, view, _} = live(conn, "/c/command_palette")
      assert has_element?(view, "#preview dialog#demo-palette")
      assert has_element?(view, "#preview [data-command-item]")
    end
  end

  describe "home: todos os componentes, no mesmo estilo, com prévia ao vivo" do
    alias FrappeUILive.Components, as: Catalog

    test "cada componente do catálogo tem cartão com prévia renderizada", %{conn: conn} do
      {:ok, view, _} = live(conn, "/")

      for entry <- Catalog.catalog() do
        assert has_element?(view, "#card-#{entry.id}"), "sem cartão para #{entry.id}"
        preview = view |> element("#preview-#{entry.id}") |> render()
        refute preview =~ "sem prévia", "prévia indisponível para #{entry.id}"
        assert preview =~ ~r/<\w+/, "prévia vazia para #{entry.id}"
      end
    end

    test "o cartão é navegável pelo título (stretched link) e a prévia é inerte", %{conn: conn} do
      {:ok, view, html} = live(conn, "/")
      assert html =~ ~s(id="preview-button")
      assert view |> element("#preview-button") |> render() =~ "inert"
      assert view |> element("#preview-button") |> render() =~ "pointer-events-none"

      view |> element("#card-badge a", "Badge") |> render_click()
      assert_patch(view, "/c/badge")
    end

    test "HTML válido: nenhum link dentro de link e ids únicos na página inteira", %{conn: conn} do
      {:ok, view, _} = live(conn, "/")
      doc = LazyHTML.from_fragment(render(view))

      assert Enum.count(LazyHTML.query(doc, "a a")) == 0, "<a> aninhado"

      ids = doc |> LazyHTML.query("[id]") |> LazyHTML.attribute("id")
      duplicated = ids -- Enum.uniq(ids)
      assert duplicated == [], "ids duplicados: #{inspect(Enum.uniq(duplicated))}"
    end

    test "resumo com as contagens e a lista de blocos internos", %{conn: conn} do
      {:ok, view, html} = live(conn, "/")
      assert html =~ "#{length(Catalog.catalog())} componentes"
      assert html =~ "#{length(Foundations.sections())} fundamentos"
      assert html =~ "#{length(Catalog.internal())} blocos internos"

      for {_module, fun} <- Catalog.internal() do
        assert has_element?(view, ~s(#index-internal [data-internal="#{fun}"])),
               "falta bloco #{fun}"
      end

      for {category, _title} <- Catalog.categories(),
          do: assert(has_element?(view, "#index-#{category}"))
    end
  end
end
