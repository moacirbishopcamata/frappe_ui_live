defmodule FrappeUIPhx.ToastSink do
  @moduledoc """
  Contrato de como um toast chega ao cliente. A implementação padrão
  (`FrappeUIPhx.ToastSink.PushEvent`) usa `push_event/3`; troque via config:

      config :frappe_ui_phx, toast_sink: MyApp.ToastSink
  """

  @typedoc "Payload entregue ao cliente (`kind` já como texto)."
  @type payload :: %{kind: String.t(), message: String.t(), timeout: pos_integer()}

  @callback deliver(socket :: Phoenix.LiveView.Socket.t(), payload()) ::
              Phoenix.LiveView.Socket.t()

  @doc "Entrega o toast pela implementação configurada (validada)."
  @spec deliver(Phoenix.LiveView.Socket.t(), payload()) :: Phoenix.LiveView.Socket.t()
  def deliver(socket, payload) do
    FrappeUIPhx.Config.module!(:toast_sink, __MODULE__.PushEvent, :deliver, 2).deliver(
      socket,
      payload
    )
  end
end

defmodule FrappeUIPhx.ToastSink.PushEvent do
  @moduledoc "Entrega o toast ao hook `.Toast` pelo evento `frappe-ui:toast`."
  @behaviour FrappeUIPhx.ToastSink

  @impl true
  def deliver(socket, payload),
    do: Phoenix.LiveView.push_event(socket, "frappe-ui:toast", payload)
end
