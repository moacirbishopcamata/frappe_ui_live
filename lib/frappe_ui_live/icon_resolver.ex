defmodule FrappeUILive.IconResolver do
  @moduledoc """
  Contrato de como um nome de ícone vira classe CSS.

  A implementação padrão (`FrappeUILive.IconResolver.Lucide`) usa classes de
  máscara `lucide-<nome>`, como o Frappe UI. Troque via config:

      config :frappe_ui_live, icon_resolver: MyApp.Icons

  Os componentes chamam `resolve/1`; a implementação configurada fornece `class/1`.
  """

  @callback class(name :: String.t()) :: String.t()

  @doc "Classe CSS do ícone `name`, pela implementação configurada (validada)."
  @spec resolve(String.t()) :: String.t()
  def resolve(name) when is_binary(name) do
    FrappeUILive.Config.module!(:icon_resolver, __MODULE__.Lucide, :class, 1).class(name)
  end
end

defmodule FrappeUILive.IconResolver.Lucide do
  @moduledoc "Resolvedor padrão: `\"plus\"` vira `\"lucide-plus\"`; nomes já prefixados passam direto."
  @behaviour FrappeUILive.IconResolver

  @impl true
  def class("lucide-" <> _ = name), do: name
  def class(name), do: "lucide-" <> name
end
