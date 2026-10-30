defmodule FrappeUILive.IconResolver do
  @moduledoc """
  Contrato de como o nome de ícone usado no projeto vira um nome do catálogo Lucide
  (`FrappeUILive.Icons`). Serve para apelidos do projeto (`"salvar"` -> `"save"`):

      config :frappe_ui_live, icon_resolver: MyApp.Icons

  Os componentes chamam `resolve/1`; a implementação configurada fornece `name/1`.
  A implementação padrão (`FrappeUILive.IconResolver.Lucide`) devolve o nome como veio;
  nomes antigos (aliases) e `-filled` já são entendidos pelo catálogo.
  """

  @callback name(name :: String.t()) :: String.t()

  @doc "Nome do catálogo para `name`, pela implementação configurada (validada)."
  @spec resolve(String.t()) :: String.t()
  def resolve(name) when is_binary(name) do
    FrappeUILive.Config.module!(:icon_resolver, __MODULE__.Lucide, :name, 1).name(name)
  end
end

defmodule FrappeUILive.IconResolver.Lucide do
  @moduledoc "Resolvedor padrão: o nome já é do catálogo Lucide e passa direto."
  @behaviour FrappeUILive.IconResolver

  @impl true
  def name(name), do: name
end
