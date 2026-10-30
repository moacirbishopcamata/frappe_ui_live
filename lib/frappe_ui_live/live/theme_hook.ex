defmodule FrappeUILive.Live.ThemeHook do
  @moduledoc """
  `on_mount` que copia o tema resolvido por `FrappeUILive.Plug.Theme` (guardado
  na sessão) para `socket.assigns.frappe_ui_theme`, mantendo o estado autoritativo
  no servidor também dentro do LiveView.

      live_session :default, on_mount: [FrappeUILive.Live.ThemeHook] do
        ...
      end
  """
  import Phoenix.Component, only: [assign: 3]

  @spec on_mount(atom(), map(), map(), Phoenix.LiveView.Socket.t()) ::
          {:cont, Phoenix.LiveView.Socket.t()}
  def on_mount(:default, _params, session, socket) do
    theme = session["frappe_ui_theme"]
    theme = if theme in FrappeUILive.Plug.Theme.themes(), do: theme, else: "light"
    {:cont, assign(socket, :frappe_ui_theme, theme)}
  end
end
