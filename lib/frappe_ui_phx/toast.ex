defmodule FrappeUIPhx.Toast do
  @moduledoc """
  API de servidor para toasts (substitui `toast()` do Frappe UI).

      def handle_event("salvar", params, socket) do
        {:noreply, FrappeUIPhx.Toast.put_toast(socket, :success, "Salvo!")}
      end

  Requer `<.toast_container />` no layout (id padrão `"frappe-ui-toasts"`; passe `id=` para mudar).
  Este módulo é o lado do servidor; o container visual é `FrappeUIPhx.Components.Toast`.
  """
  alias FrappeUIPhx.{Contract, ToastSink}

  @kinds ~w(info success warning error)a
  @default_timeout 4_000

  @doc "Tipos de toast aceitos."
  def kinds, do: @kinds

  @doc """
  Envia um toast ao cliente.

  `kind`: `:info | :success | :warning | :error`. Opções: `:timeout` em ms (padrão `4000`).
  Violações (tipo desconhecido, mensagem vazia, timeout não positivo) levantam `ArgumentError`.
  """
  @spec put_toast(Phoenix.LiveView.Socket.t(), atom(), String.t(), keyword()) ::
          Phoenix.LiveView.Socket.t()
  def put_toast(socket, kind, message, opts \\ []) do
    Contract.require!(kind, @kinds, "toast kind")
    Contract.ensure!(is_binary(message) and message != "", "toast: mensagem vazia")
    timeout = Keyword.get(opts, :timeout, @default_timeout)

    Contract.ensure!(
      is_integer(timeout) and timeout > 0,
      "toast: timeout deve ser inteiro positivo"
    )

    ToastSink.deliver(socket, %{
      kind: Atom.to_string(kind),
      message: message,
      timeout: timeout
    })
  end
end
