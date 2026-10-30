defmodule FrappeUILive.Components.Anchor do
  @moduledoc """
  Posicionamento de flutuantes por CSS Anchor Positioning (sem JS).

  Funções puras compartilhadas por Dropdown, Popover e afins: o `id` entra em
  CSS inline, então tem pré-condição de formato (falha alto se inválido).
  """
  alias FrappeUILive.Contract

  @placements ~w(bottom top)a

  @doc "Placements aceitos."
  def placements, do: @placements

  @doc "Valida o `id` (vira parte de CSS inline) e o devolve."
  @spec valid_id!(String.t(), String.t()) :: String.t()
  def valid_id!(id, component) do
    Contract.ensure!(
      is_binary(id) and Regex.match?(~r/\A[A-Za-z][\w-]*\z/, id),
      "#{component} id inválido: #{inspect(id)}"
    )

    id
  end

  @doc "Estilo do gatilho: define o nome da âncora."
  @spec trigger_style(String.t()) :: String.t()
  def trigger_style(id), do: "anchor-name: #{name(id)}"

  @doc "Estilo do painel, ancorado ao gatilho e invertendo quando falta espaço."
  @spec panel_style(String.t(), atom()) :: String.t()
  def panel_style(id, placement \\ :bottom) do
    Contract.require!(placement, @placements, "anchor placement")
    area = if placement == :bottom, do: "bottom span-right", else: "top span-right"

    "position-anchor: #{name(id)}; position-area: #{area}; position-try-fallbacks: flip-block; inset: auto; margin: 4px 0;"
  end

  defp name(id), do: "--fui-#{id}"
end
