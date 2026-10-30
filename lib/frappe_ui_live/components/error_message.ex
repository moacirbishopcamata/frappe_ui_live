defmodule FrappeUILive.Components.ErrorMessage do
  @moduledoc "Mensagem(ns) de erro. Aceita uma string, uma lista de strings ou `nil` (não renderiza nada)."
  use Phoenix.Component

  attr :message, :any, default: nil, doc: "String ou lista de strings"
  attr :id, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  def error_message(assigns) do
    assigns = assign(assigns, :lines, lines(assigns.message))

    ~H"""
    <p
      :if={@lines != []}
      id={@id}
      role="alert"
      class={["fui-text-sm text-ink-red-7 whitespace-pre-line", @class]}
      {@rest}
    >
      {Enum.join(@lines, "\n")}
    </p>
    """
  end

  @doc "Normaliza a mensagem em lista de linhas não vazias."
  @spec lines(nil | String.t() | [String.t()]) :: [String.t()]
  def lines(nil), do: []
  def lines(message) when is_binary(message), do: lines([message])

  def lines(messages) when is_list(messages),
    do: messages |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == ""))
end
