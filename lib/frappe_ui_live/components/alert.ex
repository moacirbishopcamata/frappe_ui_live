defmodule FrappeUILive.Components.Alert do
  @moduledoc "Alerta com título, descrição e ação opcional. Temas `gray | blue | green | amber | red`."
  use Phoenix.Component

  alias FrappeUILive.Components.Icon
  alias FrappeUILive.Contract

  @themes ~w(gray blue green amber red)a

  @icons %{
    gray: "info",
    blue: "info",
    green: "circle-check",
    amber: "triangle-alert",
    red: "circle-alert"
  }

  @icon_colors %{
    gray: "text-ink-gray-7",
    blue: "text-ink-blue-5",
    green: "text-ink-green-5",
    amber: "text-ink-amber-5",
    red: "text-ink-red-5"
  }

  attr :theme, :atom, default: :gray, values: @themes
  attr :title, :string, required: true
  attr :icon, :string, default: nil, doc: "sobrescreve o ícone do tema"
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, doc: "descrição"
  slot :actions

  def alert(assigns) do
    Contract.require!(assigns.theme, @themes, "alert theme")

    assigns =
      assigns
      |> assign(:icon_name, assigns.icon || @icons[assigns.theme])
      |> assign(:icon_color, @icon_colors[assigns.theme])

    ~H"""
    <div role="alert" class={["rounded-6 bg-surface-gray-1 flex items-start gap-2 px-3.5 py-2.5", @class]} {@rest}>
      <Icon.icon name={@icon_name} class={["mt-0.5 size-4 shrink-0", @icon_color]} />
      <div class="min-w-0 flex-1">
        <p class="fui-text-base-medium text-ink-gray-8">{@title}</p>
        <div :if={@inner_block != []} class="fui-text-p-base text-ink-gray-6 mt-1">
          {render_slot(@inner_block)}
        </div>
      </div>
      <div :if={@actions != []} class="ml-1.5 flex shrink-0 items-center gap-1">
        {render_slot(@actions)}
      </div>
    </div>
    """
  end
end
