defmodule FrappeUIPhx.Charts.NumberCard do
  @moduledoc "Cartão de indicador: rótulo, valor grande e variação percentual opcional (verde sobe, vermelho cai)."
  use Phoenix.Component

  alias FrappeUIPhx.Texts

  alias FrappeUIPhx.Charts.Frame
  alias FrappeUIPhx.Components.{Icon, Skeleton}

  attr :label, :string, required: true
  attr :value, :any, required: true
  attr :delta, :float, default: nil, doc: "variação percentual (ex.: 12.5 ou -3.0)"
  attr :delta_label, :string, default: nil
  attr :loading, :boolean, default: false
  attr :error, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  def number_card(assigns) do
    assigns = assign(assigns, :delta_label, assigns.delta_label || Texts.t(:vs_previous))
    assigns = assign(assigns, :state, Frame.state(assigns.loading, assigns.error, false))

    ~H"""
    <div class={["border-outline-gray-2 bg-surface-base rounded-6 border p-4", @class]} {@rest}>
      <p class="fui-text-sm text-ink-gray-5">{@label}</p>
      <Skeleton.skeleton :if={@state == :loading} class="mt-2 h-8 w-24" />
      <p :if={@state == :error} class="fui-text-sm text-ink-red-7 mt-2">{@error}</p>
      <div :if={@state == :ready}>
        <p class="text-ink-gray-9 mt-1 text-2xl font-semibold" data-value>{@value}</p>
        <p
          :if={@delta}
          class={["fui-text-sm mt-1 inline-flex items-center gap-1", delta_class(@delta)]}
          data-delta
        >
          <Icon.icon name={if @delta >= 0, do: "trending-up", else: "trending-down"} class="size-4" />
          {format_delta(@delta)}
          <span class="text-ink-gray-5">{@delta_label}</span>
        </p>
      </div>
    </div>
    """
  end

  @doc "`12.5` → `\"+12,5%\"`, `-3.0` → `\"-3%\"`."
  @spec format_delta(number()) :: String.t()
  def format_delta(delta) do
    sign = if delta > 0, do: "+", else: ""
    rounded = Float.round(delta * 1.0, 1)

    text =
      if rounded == Float.round(rounded, 0),
        do: Integer.to_string(trunc(rounded)),
        else: String.replace(to_string(rounded), ".", ",")

    "#{sign}#{text}%"
  end

  defp delta_class(delta) when delta > 0, do: "text-ink-green-5"
  defp delta_class(delta) when delta < 0, do: "text-ink-red-5"
  defp delta_class(_), do: "text-ink-gray-5"
end
