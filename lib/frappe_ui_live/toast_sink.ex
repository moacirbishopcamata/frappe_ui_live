defmodule FrappeUILive.ToastSink do
  @moduledoc """
  Contrato de como um toast chega ao cliente. A implementação padrão
  (`FrappeUILive.ToastSink.PushEvent`) usa `push_event/3`; troque via config:

      config :frappe_ui_live, toast_sink: MyApp.ToastSink
  """

  @type payload :: %{kind: String.t(), message: String.t(), timeout: pos_integer()}

  @callback deliver(socket :: Phoenix.LiveView.Socket.t(), payload()) ::
              Phoenix.LiveView.Socket.t()

  @doc false
  def sink, do: Application.get_env(:frappe_ui_live, :toast_sink, __MODULE__.PushEvent)
end

defmodule FrappeUILive.ToastSink.PushEvent do
  @moduledoc "Entrega o toast ao hook `.Toast` pelo evento `frappe-ui:toast`."
  @behaviour FrappeUILive.ToastSink

  @impl true
  def deliver(socket, payload),
    do: Phoenix.LiveView.push_event(socket, "frappe-ui:toast", payload)
end
