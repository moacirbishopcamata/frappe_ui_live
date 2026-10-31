defmodule FrappeUIPhx.ToastTest do
  use ExUnit.Case, async: true

  alias FrappeUIPhx.Toast
  alias Phoenix.LiveView.Socket

  defmodule MemorySink do
    @behaviour FrappeUIPhx.ToastSink
    @impl true
    def deliver(socket, payload), do: Phoenix.Component.assign(socket, :entregue, payload)
  end

  defp socket, do: %Socket{}

  test "put_toast/4 empurra o evento frappe-ui:toast com tipo, mensagem e timeout" do
    out = Toast.put_toast(socket(), :success, "Salvo!", timeout: 1_500)

    assert [["frappe-ui:toast", %{kind: "success", message: "Salvo!", timeout: 1_500}]] =
             out.private.live_temp[:push_events]
  end

  test "timeout padrão é 4s" do
    out = Toast.put_toast(socket(), :info, "oi")
    assert [["frappe-ui:toast", %{timeout: 4_000}]] = out.private.live_temp[:push_events]
  end

  test "o destino é substituível por configuração (ToastSink)" do
    Application.put_env(:frappe_ui_phx, :toast_sink, MemorySink)
    on_exit(fn -> Application.delete_env(:frappe_ui_phx, :toast_sink) end)

    out = Toast.put_toast(socket(), :error, "ruim")
    assert out.assigns.entregue == %{kind: "error", message: "ruim", timeout: 4_000}
  end

  test "contrato: tipo, mensagem e timeout inválidos falham alto" do
    assert_raise ArgumentError, ~r/toast kind/, fn -> Toast.put_toast(socket(), :neon, "x") end
    assert_raise ArgumentError, ~r/mensagem vazia/, fn -> Toast.put_toast(socket(), :info, "") end

    assert_raise ArgumentError, ~r/timeout/, fn ->
      Toast.put_toast(socket(), :info, "x", timeout: 0)
    end
  end

  test "kinds/0 lista os tipos aceitos" do
    assert Toast.kinds() == ~w(info success warning error)a
  end
end
