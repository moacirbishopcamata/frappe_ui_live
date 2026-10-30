defmodule FrappeUILive.Plug.Theme do
  @moduledoc """
  Resolve o tema (`"light"` ou `"dark"`) e o expõe em `conn.assigns.frappe_ui_theme`
  para o layout raiz: `<html data-theme={@frappe_ui_theme}>`.

  Ordem de resolução: parâmetro `?theme=` (persistido em sessão e cookie) →
  sessão → cookie → `default` (`"light"`). Valores inválidos são ignorados.

      plug :fetch_session
      plug FrappeUILive.Plug.Theme
  """
  @behaviour Plug

  import Plug.Conn

  @themes ~w(light dark)
  @session_key "frappe_ui_theme"
  @cookie_key "frappe_ui_theme"
  @max_age 60 * 60 * 24 * 365

  @doc "Temas aceitos."
  def themes, do: @themes

  @impl true
  def init(opts) do
    default = Keyword.get(opts, :default, "light")
    FrappeUILive.Contract.require!(default, @themes, "Plug.Theme default")
    %{default: default}
  end

  @impl true
  def call(conn, %{default: default}) do
    conn = conn |> fetch_cookies() |> fetch_query_params()

    case conn.params["theme"] do
      theme when theme in @themes ->
        conn
        |> put_session(@session_key, theme)
        |> put_resp_cookie(@cookie_key, theme, max_age: @max_age, same_site: "Lax")
        |> assign(:frappe_ui_theme, theme)

      _ ->
        theme = pick([get_session(conn, @session_key), conn.req_cookies[@cookie_key]], default)

        # só grava a sessão quando muda (evita Set-Cookie em toda requisição)
        conn
        |> maybe_put_session(theme)
        |> assign(:frappe_ui_theme, theme)
    end
  end

  defp maybe_put_session(conn, theme) do
    if get_session(conn, @session_key) == theme,
      do: conn,
      else: put_session(conn, @session_key, theme)
  end

  @doc "Chave da sessão onde o tema é guardado (compartilhada com `FrappeUILive.Live.ThemeHook`)."
  def session_key, do: @session_key

  defp pick(candidates, default), do: Enum.find(candidates, default, &(&1 in @themes))
end
