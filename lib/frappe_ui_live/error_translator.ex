defmodule FrappeUILive.ErrorTranslator do
  @moduledoc """
  Contrato de tradução de erros de changeset `{mensagem, opções}`.

  Implementação padrão: `FrappeUILive.ErrorTranslator.Default` (interpola `%{count}` etc.,
  sem depender de Ecto). Para Gettext:

      config :frappe_ui_live, error_translator: MyAppWeb.ErrorTranslator
  """

  @callback translate({String.t(), keyword() | map()}) :: String.t()

  @doc "Traduz o erro pela implementação configurada (validada)."
  @spec translate({String.t(), keyword() | map()}) :: String.t()
  def translate({_msg, _opts} = error) do
    FrappeUILive.Config.module!(:error_translator, __MODULE__.Default, :translate, 1).translate(
      error
    )
  end
end

defmodule FrappeUILive.ErrorTranslator.Default do
  @moduledoc """
  Tradutor padrão de erros de changeset: interpola `%{chave}` da mensagem com as opções
  do erro, sem depender de Gettext nem do próprio Ecto.
  """
  @behaviour FrappeUILive.ErrorTranslator

  @impl true
  def translate({msg, opts}) when is_binary(msg) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string_safe(value) end)
    end)
  end

  defp to_string_safe(value) when is_binary(value) or is_number(value) or is_atom(value),
    do: to_string(value)

  defp to_string_safe(value), do: inspect(value)
end
