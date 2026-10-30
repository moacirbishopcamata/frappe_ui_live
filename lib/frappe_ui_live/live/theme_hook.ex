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

  @doc """
  `on_mount: [FrappeUILive.Live.ThemeHook]` ou, para outro tema padrão (o mesmo `default:`
  do `FrappeUILive.Plug.Theme`), `on_mount: [{FrappeUILive.Live.ThemeHook, default: "dark"}]`.
  """
  @spec on_mount(:default | keyword(), map(), map(), Phoenix.LiveView.Socket.t()) ::
          {:cont, Phoenix.LiveView.Socket.t()}
  def on_mount(opts, _params, session, socket) do
    default = opts |> options() |> Keyword.get(:default, "light")
    FrappeUILive.Contract.require!(default, FrappeUILive.Plug.Theme.themes(), "ThemeHook default")

    theme = session[FrappeUILive.Plug.Theme.session_key()]
    theme = if theme in FrappeUILive.Plug.Theme.themes(), do: theme, else: default
    {:cont, assign(socket, :frappe_ui_theme, theme)}
  end

  defp options(:default), do: []
  defp options(opts) when is_list(opts), do: opts
end
