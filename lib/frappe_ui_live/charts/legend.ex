defmodule FrappeUILive.Charts.Legend do
  @moduledoc "Legenda: marcador colorido + nome. `items` é `[%{label, color}]` ou vem das séries."
  use Phoenix.Component

  alias FrappeUILive.Charts.Scale

  attr :items, :list, required: true, doc: "[%{label: String, color: String}]"
  attr :class, :any, default: nil

  def chart_legend(assigns) do
    ~H"""
    <ul
      :if={@items != []}
      class={["fui-text-sm text-ink-gray-6 flex flex-wrap gap-x-4 gap-y-1", @class]}
    >
      <li :for={item <- @items} class="flex items-center gap-1.5">
        <span class="size-2.5 rounded-full" style={"background: #{item.color}"}></span>{item.label}
      </li>
    </ul>
    """
  end

  @doc "Itens de legenda a partir de nomes, usando a paleta do tema na ordem."
  @spec from_names([String.t()]) :: [map()]
  def from_names(names) do
    names
    |> Enum.with_index()
    |> Enum.map(fn {name, i} -> %{label: name, color: Scale.color(i)} end)
  end
end
