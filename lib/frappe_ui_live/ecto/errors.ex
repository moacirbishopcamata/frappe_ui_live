defmodule FrappeUILive.Ecto.Errors do
  @moduledoc """
  Tradutor padrão de erros de changeset: interpola `%{chave}` da mensagem com
  as opções do erro, sem depender de Gettext nem do próprio Ecto.
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
