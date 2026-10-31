defmodule FrappeUIPhx.Live.ThemeHook do
  @moduledoc """
  `on_mount` que copia o tema resolvido por `FrappeUIPhx.Plug.Theme` (guardado
  na sessão) para `socket.assigns.frappe_ui_theme`, mantendo o estado autoritativo
  no servidor também dentro do LiveView.

      live_session :default, on_mount: [FrappeUIPhx.Live.ThemeHook] do
        ...
      end
  """
  import Phoenix.Component, only: [assign: 3]

  @doc """
  `on_mount: [FrappeUIPhx.Live.ThemeHook]` ou, para outro tema padrão (o mesmo `default:`
  do `FrappeUIPhx.Plug.Theme`), `on_mount: [{FrappeUIPhx.Live.ThemeHook, default: "dark"}]`.
  """
  @spec on_mount(:default | keyword(), map(), map(), Phoenix.LiveView.Socket.t()) ::
          {:cont, Phoenix.LiveView.Socket.t()}
  def on_mount(opts, _params, session, socket) do
    default = opts |> options() |> Keyword.get(:default, "light")
    FrappeUIPhx.Contract.require!(default, FrappeUIPhx.Plug.Theme.themes(), "ThemeHook default")

    theme = session[FrappeUIPhx.Plug.Theme.session_key()]
    theme = if theme in FrappeUIPhx.Plug.Theme.themes(), do: theme, else: default
    {:cont, assign(socket, :frappe_ui_theme, theme)}
  end

  defp options(:default), do: []
  defp options(opts) when is_list(opts), do: opts
end
