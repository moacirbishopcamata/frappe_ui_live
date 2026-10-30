defmodule ShowcaseWeb.DemoStateTest do
  @moduledoc """
  Comportamentos dos componentes novos que dependem de estado no servidor.
  Cada teste muta por um evento e relê o DOM por outro caminho (não pelo retorno).
  """
  use ShowcaseWeb.ConnCase, async: true

  defp row_ids(view, table) do
    view
    |> element("#preview")
    |> render()
    |> LazyHTML.from_fragment()
    |> LazyHTML.query("#{table} tr[data-sortable-id]")
    |> LazyHTML.attribute("data-sortable-id")
  end

  describe "List (seleção e reordenação no servidor)" do
    test "selecionar alterna o item e ignora id forjado", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/list")
      assert view |> element("#preview tr#demo-list-2") |> render() =~ ~s(aria-selected="true")

      render_click(view, "sel", %{"id" => "1"})
      assert view |> element("#preview tr#demo-list-1") |> render() =~ ~s(aria-selected="true")
      render_click(view, "sel", %{"id" => "2"})
      assert view |> element("#preview tr#demo-list-2") |> render() =~ ~s(aria-selected="false")

      render_click(view, "sel", %{"id" => "999"})
      render_click(view, "sel", %{"id" => "abc"})
      assert Process.alive?(view.pid)
    end

    test "o drop reordena as linhas e o evento forjado não corrompe a ordem", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/list")
      assert row_ids(view, "#demo-list") == ["1", "2", "3"]

      render_click(view, "reorder", %{"id" => "3", "to" => "1", "position" => "before"})
      assert row_ids(view, "#demo-list") == ["3", "1", "2"]

      render_click(view, "reorder", %{"id" => "9", "to" => "1", "position" => "before"})
      assert row_ids(view, "#demo-list") == ["3", "1", "2"]
    end
  end

  describe "Tree e Sortable" do
    test "expandir revela filhos; selecionar marca o nó", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/tree")
      refute render(view) =~ "iOS"

      render_click(view, "tog", %{"id" => "3"})
      assert render(view) =~ "iOS"
      render_click(view, "tog", %{"id" => "3"})
      refute render(view) =~ "iOS"

      render_click(view, "tsel", %{"id" => "5"})
      assert view |> element("#preview") |> render() =~ ~s(aria-selected="true")
      render_click(view, "tog", %{"id" => "lixo"})
      assert Process.alive?(view.pid)
    end

    test "sortable reordena itens", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/sortable")
      render_click(view, "reorder_items", %{"id" => "1", "to" => "3", "position" => "after"})

      names =
        view
        |> element("#preview")
        |> render()
        |> LazyHTML.from_fragment()
        |> LazyHTML.query("[data-sortable-id]")
        |> LazyHTML.text()

      assert names =~ ~r/Segundo\s+Terceiro\s+Primeiro/
    end
  end

  describe "SavedIndicator" do
    test "só aparece depois de salvar e reaparece a cada sucesso", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/saved_indicator")
      refute view |> element("#preview") |> render() =~ "fui-saved"

      view |> element("#preview button", "Salvar") |> render_click()
      assert view |> element("#preview") |> render() =~ "fui-saved"

      view |> element("#preview button", "Salvar") |> render_click()
      assert view |> element("#preview") |> render() =~ "fui-saved"
    end
  end

  describe "FileUploader (upload real)" do
    test "envia um arquivo aceito e mostra o progresso concluído", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/file_uploader")

      upload =
        file_input(view, "#upload-form", :demo, [
          %{name: "foto.png", content: String.duplicate("x", 1000), type: "image/png"}
        ])

      assert render_upload(upload, "foto.png", 100) =~ "foto.png"
      assert view |> element("#preview") |> render() =~ ~s(aria-valuenow="100")
    end

    test "tipo não aceito e arquivo grande demais viram mensagens em português", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/file_uploader")

      bad =
        file_input(view, "#upload-form", :demo, [
          %{name: "virus.exe", content: "x", type: "application/x-msdownload"}
        ])

      assert {:error, _} = render_upload(bad, "virus.exe")
      assert render(view) =~ "Tipo de arquivo não aceito."

      {:ok, view, _} = live(conn, "/c/file_uploader")

      big =
        file_input(view, "#upload-form", :demo, [
          %{name: "grande.png", content: String.duplicate("x", 2_500_000), type: "image/png"}
        ])

      assert {:error, _} = render_upload(big, "grande.png")
      assert render(view) =~ "maior que o permitido"
    end

    test "cancelar remove o arquivo da lista", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/file_uploader")

      upload =
        file_input(view, "#upload-form", :demo, [
          %{name: "foto.png", content: "xx", type: "image/png"}
        ])

      render_upload(upload, "foto.png", 50)

      [ref] =
        view
        |> element("#preview")
        |> render()
        |> LazyHTML.from_fragment()
        |> LazyHTML.query("button[phx-value-ref]")
        |> LazyHTML.attribute("phx-value-ref")

      render_click(view, "cancel-upload", %{"ref" => ref})
      refute view |> element("#preview") |> render() =~ "foto.png"
    end
  end

  describe "DatePicker (LiveComponent dentro do playground)" do
    test "escolher um dia atualiza o valor do formulário e o texto do gatilho", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/date_picker")
      hidden = fn -> view |> element("#demo-date input[type=hidden]") |> render() end
      assert hidden.() =~ "2026-03-09"

      view |> element("#demo-date button[data-date='2026-03-20']") |> render_click()
      assert hidden.() =~ "2026-03-20"

      assert view |> element("#demo-date button[aria-haspopup=dialog]") |> render() =~
               "20/03/2026"
    end

    test "navegar de mês muda o rótulo; id inválido mostra o contrato violado", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/date_picker")
      assert view |> element("#demo-date [aria-live=polite]") |> render() =~ "Março 2026"
      view |> element("#demo-date button[aria-label='Próximo mês']") |> render_click()
      assert view |> element("#demo-date [aria-live=polite]") |> render() =~ "Abril 2026"

      view |> form("#playground-form", pg: %{id: "a b"}) |> render_change()
      assert render(view) =~ "Contrato violado"
      assert Process.alive?(view.pid)
    end
  end

  describe "estado ativo por assign (tabs, sidebar, abas inferiores)" do
    test "tab_buttons troca o ativo no servidor", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/tab_buttons")
      assert view |> element("#preview [aria-selected=true]") |> render() =~ "Dia"
      view |> element("#preview button", "Semana") |> render_click()
      assert view |> element("#preview [aria-selected=true]") |> render() =~ "Semana"
    end

    test "sidebar e settings_dialog respondem ao mesmo evento", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/sidebar")
      view |> element("#preview button", "Pedidos") |> render_click()
      assert view |> element("#preview [aria-current=page]") |> render() =~ "Pedidos"

      {:ok, view, _} = live(conn, "/c/settings_dialog")
      view |> element("#preview button", "Avisos") |> render_click()
      assert view |> element("#preview section") |> render() =~ "avisos"
    end
  end

  describe "eventos forjados" do
    test "evento desconhecido ou malformado é ignorado e o LiveView continua vivo", %{conn: conn} do
      {:ok, view, _} = live(conn, "/c/list")
      render_click(view, "evento_que_nao_existe", %{})
      render_click(view, "reorder", %{"id" => "1"})
      render_click(view, "sel", %{})
      assert Process.alive?(view.pid)
      assert has_element?(view, "#preview")
    end
  end
end
