defmodule FrappeUIPhx.PlugTest do
  use ExUnit.Case, async: true
  import Plug.Conn
  import Plug.Test

  alias FrappeUIPhx.Live.ThemeHook
  alias FrappeUIPhx.Plug.{Static, Theme}

  defp run(conn, opts \\ []) do
    conn
    |> Plug.Test.init_test_session(%{})
    |> Theme.call(Theme.init(opts))
  end

  defp new_conn(path \\ "/"), do: conn(:get, path)

  describe "Plug.Theme" do
    test "padrão: light, gravado na sessão" do
      conn = run(new_conn())
      assert conn.assigns.frappe_ui_theme == "light"
      assert get_session(conn, "frappe_ui_theme") == "light"
    end

    test "?theme=dark persiste em sessão e cookie, e a próxima requisição lê da sessão" do
      first = run(new_conn("/?theme=dark"))
      assert first.assigns.frappe_ui_theme == "dark"
      assert first.resp_cookies["frappe_ui_theme"].value == "dark"

      # releitura por caminho independente: nova conn só com a sessão gravada
      second =
        new_conn()
        |> Plug.Test.init_test_session(%{
          "frappe_ui_theme" => get_session(first, "frappe_ui_theme")
        })
        |> Theme.call(Theme.init([]))

      assert second.assigns.frappe_ui_theme == "dark"
    end

    test "cookie vale quando não há sessão; valores inválidos são ignorados" do
      conn = new_conn() |> put_req_cookie("frappe_ui_theme", "dark") |> run()
      assert conn.assigns.frappe_ui_theme == "dark"

      invalid =
        new_conn("/?theme=neon") |> put_req_cookie("frappe_ui_theme", "tema-estranho") |> run()

      assert invalid.assigns.frappe_ui_theme == "light"
      refute Map.has_key?(invalid.resp_cookies, "frappe_ui_theme")
    end

    test "default configurável e validado no init" do
      assert run(new_conn(), default: "dark").assigns.frappe_ui_theme == "dark"
      assert_raise ArgumentError, ~r/default/, fn -> Theme.init(default: "neon") end
      assert Theme.themes() == ~w(light dark)
    end
  end

  describe "Live.ThemeHook" do
    test "copia o tema da sessão para os assigns e cai em light se inválido" do
      socket = %Phoenix.LiveView.Socket{}

      assert {:cont, s} =
               ThemeHook.on_mount(:default, %{}, %{"frappe_ui_theme" => "dark"}, socket)

      assert s.assigns.frappe_ui_theme == "dark"
      assert {:cont, s} = ThemeHook.on_mount(:default, %{}, %{"frappe_ui_theme" => "xx"}, socket)
      assert s.assigns.frappe_ui_theme == "light"
      assert {:cont, s} = ThemeHook.on_mount(:default, %{}, %{}, socket)
      assert s.assigns.frappe_ui_theme == "light"
    end
  end

  describe "Plug.Static" do
    test "serve o CSS de tokens da dependência e nada além dele" do
      opts = Static.init([])
      css = new_conn("/frappe_ui/frappe_ui.css") |> Static.call(opts)
      assert css.status == 200
      assert css.resp_body =~ "--surface-base"
      assert css.halted

      other = new_conn("/frappe_ui/outro.txt") |> Static.call(opts)
      refute other.halted
    end
  end
end
