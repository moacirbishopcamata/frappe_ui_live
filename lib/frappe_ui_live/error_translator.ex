defmodule FrappeUILive.ErrorTranslator do
  @moduledoc """
  Contrato de tradução de erros de changeset `{mensagem, opções}`.

  Implementação padrão: `FrappeUILive.Ecto.Errors` (interpola `%{count}` etc.).
  Para Gettext:

      config :frappe_ui_live, error_translator: MyAppWeb.ErrorTranslator
  """

  @callback translate({String.t(), keyword() | map()}) :: String.t()

  @spec translate({String.t(), keyword() | map()}) :: String.t()
  def translate({_msg, _opts} = error), do: translator().translate(error)

  defp translator,
    do: Application.get_env(:frappe_ui_live, :error_translator, FrappeUILive.Ecto.Errors)
end
