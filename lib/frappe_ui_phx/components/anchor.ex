defmodule FrappeUIPhx.Components.Anchor do
  @moduledoc """
  Posicionamento de flutuantes por CSS Anchor Positioning (sem JS).

  Funções puras compartilhadas por Dropdown, Popover e afins: o `id` entra em
  CSS inline, então tem pré-condição de formato (falha alto se inválido).
  """
  alias FrappeUIPhx.Contract

  @placements ~w(bottom top)a

  @doc "Placements aceitos."
  def placements, do: @placements

  @doc "Valida o `id` (vira parte de CSS inline) e o devolve."
  @spec valid_id!(term(), String.t()) :: String.t()
  def valid_id!(id, component) do
    # Pré-condição do chamador (id vira seletor/CSS): valor inválido é bug, não entrada de usuário.
    if is_binary(id) and Regex.match?(~r/\A[A-Za-z][\w-]*\z/, id) do
      id
    else
      raise ArgumentError, "#{component} id inválido: #{inspect(id)}"
    end
  end

  @doc """
  Casca visual comum dos painéis flutuantes (Dropdown, Popover, ContextMenu, DatePicker,
  OptionList): fundo elevado, borda, raio e sombra. Cada componente soma só o que é seu
  (largura, espaçamento).
  """
  @spec panel_classes() :: String.t()
  def panel_classes,
    do: "bg-surface-elevation-1 rounded-5 border-outline-gray-1 shadow-elevation-md border"

  @doc "Estilo do gatilho: define o nome da âncora."
  @spec trigger_style(term()) :: String.t()
  def trigger_style(id), do: "anchor-name: #{name(valid_id!(id, "anchor"))}"

  @doc "Estilo do painel, ancorado ao gatilho e invertendo quando falta espaço."
  @spec panel_style(term(), atom()) :: String.t()
  def panel_style(id, placement \\ :bottom) do
    Contract.require!(placement, @placements, "anchor placement")
    valid_id!(id, "anchor")
    area = if placement == :bottom, do: "bottom span-right", else: "top span-right"

    "position-anchor: #{name(id)}; position-area: #{area}; position-try-fallbacks: flip-block; inset: auto; margin: 4px 0;"
  end

  defp name(id), do: "--fui-#{id}"
end
