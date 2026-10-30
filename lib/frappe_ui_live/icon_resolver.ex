defmodule FrappeUILive.IconResolver do
  @moduledoc """
  Contrato de como um nome de ícone vira classe CSS.

  A implementação padrão (`FrappeUILive.IconResolver.Lucide`) usa classes de
  máscara `lucide-<nome>`, como o Frappe UI. Troque via config:

      config :frappe_ui_live, icon_resolver: MyApp.Icons
  """

  @callback class(name :: String.t()) :: String.t()

  @doc "Classe CSS do ícone `name`, pela implementação configurada."
  @spec class(String.t()) :: String.t()
  def class(name) when is_binary(name) do
    resolver().class(name)
  end

  defp resolver, do: Application.get_env(:frappe_ui_live, :icon_resolver, __MODULE__.Lucide)
end

defmodule FrappeUILive.IconResolver.Lucide do
  @moduledoc "Resolvedor padrão: `\"plus\"` vira `\"lucide-plus\"`; nomes já prefixados passam direto."
  @behaviour FrappeUILive.IconResolver

  @impl true
  def class("lucide-" <> _ = name), do: name
  def class(name), do: "lucide-" <> name
end
