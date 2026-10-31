defmodule ShowcaseWeb.CatalogLiveTest do
  use ShowcaseWeb.ConnCase, async: true

  alias FrappeUIPhx.Components, as: Catalog
  alias FrappeUIPhx.Icons

  describe "índice" do
    test "lista todos os componentes do catálogo, agrupados por categoria", %{conn: conn} do
      {:ok, view, html} = live(conn, "/")

      for entry <- Catalog.catalog() do
        assert has_element?(view, "#card-#{entry.id}"), "sem card para #{entry.id}"
        assert has_element?(view, "#nav-#{entry.id}"), "sem item de navegação para #{entry.id}"
      end

      for {_id, title} <- Catalog.categories(), do: assert(html =~ title)
    end

    test "navega pelo menu para o componente (patch, sem recarregar)", %{conn: conn} do
      {:ok, view, _} = live(conn, "/")
      view |> element("#nav-button") |> render_click()
      assert_patch(view, "/c/button")
      assert has_element?(view, "#playground-form")
    end

    test "id desconhecido volta ao índice com aviso", %{conn: conn} do
      assert {:error, {:live_redirect, %{to: "/", flash: flash}}} = live(conn, "/c/nao_existe")
      assert flash["error"] =~ "desconhecido"
    end
  end

  describe "todos os componentes" do
    test "cada um monta, mostra prévia válida e tem as duas abas", %{conn: conn} do
      for entry <- Catalog.catalog() do
        {:ok, view, html} = live(conn, "/c/#{entry.id}")
        assert has_element?(view, "#preview"), "#{entry.id}: sem prévia"
        refute html =~ "Contrato violado", "#{entry.id}: estado inicial viola o contrato"
        assert has_element?(view, "#snippet")

        view |> element(~s(a[role=tab]), "Especificação") |> render_click()
        assert has_element?(view, "#attrs-table"), "#{entry.id}: sem tabela de especificação"
        assert has_element?(view, "#moduledoc")
      end
    end

    test "costura ícones: todo ícone renderizado existe no catálogo Lucide", %{conn: conn} do
      used =
        for entry <- Catalog.catalog(),
            {:ok, _view, html} = live(conn, "/c/#{entry.id}"),
            [name] <-
              Regex.scan(~r/class="lucide lucide-([a-z0-9-]+)/, html, capture: :all_but_first),
            uniq: true,
            do: name

      assert used != []
      missing = Enum.reject(used, &Icons.get/1)
      assert missing == [], "ícones fora do catálogo: #{inspect(missing)}"
    end

    test "ícones padrão de cada tema do Alert existem no catálogo" do
      for name <-
            ~w(info circle-check triangle-alert circle-alert chevron-down chevron-right check x) do
        assert Icons.get(name), name
      end
    end
  end

  describe "playground" do
    test "mudar o formulário muda a prévia e o trecho de uso (releitura por outro caminho)", %{
      conn: conn
    } do
      {:ok, view, _html} = live(conn, "/c/button")
      before = view |> element("#preview") |> render()
      assert before =~ "bg-surface-gray-2"
      refute before =~ "bg-surface-gray-10"

      view |> form("#playground-form", pg: %{variant: "solid"}) |> render_change()

      # outra leitura: o HTML completo e os elementos do DOM, não o retorno do evento
      assert view |> element("#preview") |> render() =~ "bg-surface-gray-10"
      assert view |> element("#snippet") |> render() =~ "variant={:solid}"
    end

    test "booleano e inteiro são convertidos", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/progress")
      view |> form("#playground-form", pg: %{value: "75"}) |> render_change()
      assert view |> element("#preview") |> render() =~ "width: 75%"
    end

    test "entrada inválida cai no padrão em vez de quebrar", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/progress")
      view |> form("#playground-form", pg: %{value: "abc"}) |> render_change()
      assert Process.alive?(view.pid)
      assert has_element?(view, "#preview")
    end

    test "violação de contrato é exibida e o LiveView continua vivo", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/dialog")
      view |> form("#playground-form", pg: %{id: "1 ruim"}) |> render_change()

      assert render(view) =~ "Contrato violado"
      assert render(view) =~ "dialog id inválido"
      assert Process.alive?(view.pid)

      view |> form("#playground-form", pg: %{id: "bom-id"}) |> render_change()
      refute render(view) =~ "Contrato violado"
    end

    test "reiniciar restaura os valores iniciais", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/button")
      view |> form("#playground-form", pg: %{variant: "solid"}) |> render_change()
      view |> element("#playground-reset") |> render_click()
      refute view |> element("#preview") |> render() =~ "bg-surface-gray-10"
    end

    test "trocar de aba mantém os valores do playground", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/button")
      view |> form("#playground-form", pg: %{variant: "solid"}) |> render_change()
      view |> element(~s(a[role=tab]), "Especificação") |> render_click()
      view |> element(~s(a[role=tab]), "Playground") |> render_click()
      assert view |> element("#preview") |> render() =~ "bg-surface-gray-10"
    end
  end

  describe "especificação" do
    test "lista os atributos e slots reais, com valores permitidos", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/button?tab=spec")
      assert has_element?(view, ~s(tr[data-attr=variant]))

      assert view |> element(~s(tr[data-attr=variant])) |> render() =~
               ":solid | :subtle | :outline | :ghost"

      assert has_element?(view, ~s(tr[data-attr=loading]))
      assert has_element?(view, ~s(li[data-slot=inner_block]))
    end

    test "atributo obrigatório aparece como tal", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/alert?tab=spec")
      assert view |> element(~s(tr[data-attr=title])) |> render() =~ "sim"
    end
  end

  describe "comportamentos de servidor" do
    test "toast sai do servidor como push_event", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/toast_container")
      view |> element(~s(button[phx-value-kind=success])) |> render_click()
      assert_push_event(view, "frappe-ui:toast", %{kind: "success", message: msg})
      assert msg =~ "success"
    end

    test "tipo de toast desconhecido é ignorado", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/toast_container")
      render_click(view, "toast", %{"kind" => "neon"})
      assert Process.alive?(view.pid)
    end

    test "aba ativa do componente Tabs é estado do servidor", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/tabs")
      assert view |> element("#preview") |> render() =~ "<strong>geral</strong>"
      render_click(view, "pg_tab", %{"tab" => "itens"})
      assert view |> element("#preview") |> render() =~ "<strong>itens</strong>"
    end

    test "item de menu dispara evento no servidor", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/dropdown")
      render_click(view, "demo", %{})
      assert_push_event(view, "frappe-ui:toast", %{kind: "info"})
    end
  end

  describe "tema (Plug + ThemeHook)" do
    test "?theme=dark vira data-theme e persiste na sessão para a próxima visita", %{conn: conn} do
      conn = get(conn, "/?theme=dark")
      assert html_response(conn, 200) =~ ~s(data-theme="dark")

      again = conn |> recycle() |> get("/")
      assert html_response(again, 200) =~ ~s(data-theme="dark")

      {:ok, view, _} = conn |> recycle() |> live("/")
      assert render(view) =~ "Tema claro"
    end

    test "padrão é claro e o botão oferece o escuro", %{conn: conn} do
      {:ok, view, html} = live(conn, "/")
      assert html =~ ~s(data-theme="light")
      assert view |> element("#theme-toggle") |> render() =~ "theme=dark"
    end
  end

  describe "assets do mostruário" do
    @describetag :assets
    test "app.js e app.css servidos pelo endpoint contêm hooks colocated e tokens", %{conn: conn} do
      js = conn |> get("/assets/js/app.js") |> response(200)
      assert js =~ "fui:dialog-open"
      assert js =~ "frappe-ui:toast"

      css = conn |> get("/assets/css/app.css") |> response(200)
      assert css =~ "--surface-base"
      refute css =~ "lucide-plus"
    end
  end
end
