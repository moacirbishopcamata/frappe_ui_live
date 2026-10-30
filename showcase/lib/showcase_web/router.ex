defmodule ShowcaseWeb.Router do
  use Phoenix.Router, helpers: false
  import Phoenix.LiveView.Router
  import Plug.Conn
  import Phoenix.Controller

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ShowcaseWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    # Integração da biblioteca: resolve o tema (?theme=dark) e o guarda em sessão/cookie.
    plug FrappeUILive.Plug.Theme
  end

  scope "/", ShowcaseWeb do
    pipe_through :browser

    live_session :default, on_mount: [FrappeUILive.Live.ThemeHook] do
      live "/", CatalogLive, :index
      live "/c/:id", CatalogLive, :show
      live "/f/:id", CatalogLive, :foundation
      live "/icones", CatalogLive, :icons
    end
  end
end
