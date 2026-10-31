defmodule ShowcaseWeb.IconsPageTest do
  use ShowcaseWeb.ConnCase, async: true

  alias FrappeUIPhx.Icons
  alias ShowcaseWeb.IconsView

  defp change(view, params) do
    view |> form("#icons-form", icons: params) |> render_change()
  end

  describe "página /icones" do
    test "abre com o primeiro lote e a contagem total", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/icones")
      total = length(Icons.names())

      assert has_element?(view, "#icons-count", "#{total} de #{total} ícones")
      assert has_element?(view, "#icons-grid li svg.lucide")
      assert has_element?(view, "#icons-more")
      assert has_element?(view, "#nav-icons[aria-current=page]")
    end

    test "busca por nome mostra só os que casam; sem resultado informa", %{conn: conn} do
      {:ok, view, _} = live(conn, "/icones")

      change(view, %{q: "trash"})
      assert has_element?(view, "#icon-trash")
      refute has_element?(view, "#icon-plus")

      change(view, %{q: "zzzzzz-nada"})
      assert has_element?(view, "#icons-empty", "zzzzzz-nada")
      refute has_element?(view, "#icons-grid li")
    end

    test "busca por tag encontra ícone cujo nome não contém o termo", %{conn: conn} do
      {:ok, view, _} = live(conn, "/icones")
      icon = Icons.get("trash")
      tag = Enum.find(icon.tags, &(&1 =~ ~r/^[a-z]{5,}$/ and not String.contains?(icon.name, &1)))

      change(view, %{q: tag})
      assert has_element?(view, "#icon-trash")
    end

    test "propriedades ao vivo chegam a todos os ícones visíveis", %{conn: conn} do
      {:ok, view, _} = live(conn, "/icones")
      change(view, %{size: "40", stroke_width: "1", color: "red"})

      assert has_element?(view, ~s(#icons-grid svg[width="40"][stroke="red"][stroke-width="1"]))
      refute has_element?(view, ~s(#icons-grid svg[width="24"]))
      refute has_element?(view, ~s(#icons-grid svg[stroke="currentColor"]))

      change(view, %{size: "48", stroke_width: "2", absolute: "true"})
      assert has_element?(view, ~s(#icons-grid svg[width="48"][stroke-width="1.0"]))
    end

    test "valores fora dos limites ou cores desconhecidas são ignorados", %{conn: conn} do
      {:ok, view, _} = live(conn, "/icones")

      render_hook(view, "icons", %{
        "icons" => %{"size" => "9999", "color" => "url(x)", "stroke_width" => "-3"}
      })

      assert has_element?(
               view,
               ~s(#icons-grid svg[width="24"][stroke="currentColor"][stroke-width="2"])
             )
    end

    test "escolher um ícone mostra nome, tags, aliases e o trecho de uso", %{conn: conn} do
      {:ok, view, _} = live(conn, "/icones")
      change(view, %{q: "circle-alert"})
      view |> element("#icon-circle-alert button") |> render_click()

      assert has_element?(view, "#icon-detail", "circle-alert")
      assert has_element?(view, "#icon-tags")
      assert has_element?(view, "#icon-aliases", "alert-circle")
      assert render(view) =~ "&lt;Lucide.circle_alert /&gt;"

      change(view, %{size: "16", color: "blue"})
      html = render(view)
      assert html =~ "size={16}" and html =~ ~s(color=&quot;blue&quot;)
    end

    test "'mostrar mais' amplia o lote", %{conn: conn} do
      {:ok, view, _} = live(conn, "/icones")
      before = view |> render() |> String.split(~s(id="icon-)) |> length()
      view |> element("#icons-more") |> render_click()
      assert view |> render() |> String.split(~s(id="icon-)) |> length() > before
    end

    test "evento forjado não derruba a página", %{conn: conn} do
      {:ok, view, _} = live(conn, "/icones")
      render_hook(view, "icon_select", %{"name" => "../../etc/passwd"})
      render_hook(view, "icon_select", %{"name" => 42})
      render_hook(view, "icons", %{"nada" => 1})
      assert has_element?(view, "#icons-grid")
      assert has_element?(view, "#icon-detail", "Escolha um ícone")
    end
  end

  describe "navegação" do
    test "a home tem o cartão de ícones que leva à página", %{conn: conn} do
      {:ok, view, _} = live(conn, "/")
      assert has_element?(view, "#card-icons", "Todos os ícones Lucide")
      view |> element("#card-icons") |> render_click()
      assert_patch(view, "/icones")
    end
  end

  describe "IconsView (estado puro)" do
    test "cast limita size e stroke_width, aceita só cores da lista" do
      s =
        IconsView.cast(IconsView.init(), %{"size" => "7", "stroke_width" => "5", "color" => "red"})

      assert s.size == 24 and s.stroke_width == 2 and s.color == "red"

      assert IconsView.cast(s, %{"size" => "16.5", "stroke_width" => "0.5"})
             |> Map.take([:size, :stroke_width]) ==
               %{size: 16.5, stroke_width: 0.5}
    end

    test "buscar de novo volta ao primeiro lote" do
      s = IconsView.init() |> IconsView.more()
      assert s.limit > IconsView.init().limit
      assert IconsView.cast(s, %{"q" => "plus"}).limit == IconsView.init().limit
    end

    test "select resolve alias para o nome atual e limpa com nome desconhecido" do
      s = IconsView.select(IconsView.init(), "alert-circle")
      assert s.selected == "circle-alert"
      assert IconsView.select(s, "nao-existe").selected == nil
    end
  end
end
