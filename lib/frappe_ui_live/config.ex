defmodule FrappeUILive.Config do
  @moduledoc """
  Resolve e **valida** o módulo configurado para um ponto de extensão
  (`IconResolver`, `ToastSink`, `ErrorTranslator`, `Translator`). Um módulo inexistente
  ou sem o callback falha na primeira chamada com mensagem clara, em vez de um
  `UndefinedFunctionError` no meio da renderização.
  """

  @doc "Módulo de `config :frappe_ui_live, key`, ou `default`, garantindo `callback/arity`."
  @spec module!(atom(), module(), atom(), arity()) :: module()
  def module!(key, default, callback, arity) do
    module = Application.get_env(:frappe_ui_live, key, default)
    Code.ensure_loaded(module)

    unless function_exported?(module, callback, arity) do
      raise ArgumentError,
            "config :frappe_ui_live, #{key}: #{inspect(module)} não implementa #{callback}/#{arity}"
    end

    module
  end
end
