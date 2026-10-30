defmodule FrappeUILive.Plug.Static do
  @moduledoc """
  Serve `frappe_ui.css` (tokens) e `frappe_ui_icons.css` da própria dependência em `/frappe_ui/`,
  para quem prefere `<link>` a `@import` no `app.css`.

      plug FrappeUILive.Plug.Static
  """
  @behaviour Plug

  @impl true
  def init(opts) do
    Plug.Static.init(
      at: Keyword.get(opts, :at, "/frappe_ui"),
      from: {:frappe_ui_live, "priv/static"},
      only: ~w(frappe_ui.css frappe_ui_icons.css),
      gzip: false
    )
  end

  @impl true
  def call(conn, static_opts), do: Plug.Static.call(conn, static_opts)
end
