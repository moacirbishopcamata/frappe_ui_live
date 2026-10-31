defmodule FrappeUIPhx.Contract do
  @moduledoc """
  Design by Contract para os componentes.

  Uma violação de contrato é um bug de quem chama, não fluxo de negócio: por
  isso falha alto (`ArgumentError`), em vez de renderizar algo errado em
  silêncio. Entrada de usuário (valores de formulário) nunca passa por aqui;
  ela vira `errors` do `Phoenix.HTML.FormField`.

    * `require!/3` — pré-condição: o valor pertence ao domínio permitido.
    * `ensure!/2` — pós-condição / invariante: algo que o código garantiu.
  """

  @doc "Pré-condição: `value` deve estar em `allowed`. Devolve `value`."
  @spec require!(term(), Enumerable.t(), atom() | String.t()) :: term()
  def require!(value, allowed, name) do
    if value in allowed do
      value
    else
      raise ArgumentError,
            "#{name}: valor #{inspect(value)} fora do contrato; esperado um de #{inspect(allowed)}"
    end
  end

  @doc "Pós-condição ou invariante: levanta `ArgumentError` com `message` se `condition` for falsa."
  @spec ensure!(term(), String.t()) :: :ok
  def ensure!(condition, message) when is_binary(message) do
    if condition, do: :ok, else: raise(ArgumentError, message)
  end
end
