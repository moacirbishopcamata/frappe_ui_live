defmodule FrappeUILive.Components.Badge do
  @moduledoc "Selo de status: temas `gray | blue | green | amber | red | violet`, variantes `solid | subtle | outline | ghost`."
  use Phoenix.Component

  alias FrappeUILive.Contract

  @themes ~w(gray blue green amber red violet)a
  @variants ~w(solid subtle outline ghost)a
  @sizes ~w(sm md lg)a

  @sizes_classes %{
    sm: "h-4 px-1.5 fui-text-xs",
    md: "h-5 px-1.5 fui-text-xs",
    lg: "h-6 px-2 text-[13px] tracking-[0.02em]"
  }

  attr :theme, :atom, default: :gray, values: @themes
  attr :variant, :atom, default: :subtle, values: @variants
  attr :size, :atom, default: :md, values: @sizes
  attr :label, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block

  def badge(assigns) do
    Contract.require!(assigns.theme, @themes, "badge theme")
    Contract.require!(assigns.variant, @variants, "badge variant")
    Contract.require!(assigns.size, @sizes, "badge size")
    assigns = assign(assigns, :classes, classes(assigns))

    ~H"""
    <span class={@classes} {@rest}>
      <%= if @inner_block != [] do %>
        {render_slot(@inner_block)}
      <% else %>
        {@label}
      <% end %>
    </span>
    """
  end

  @doc "Classes do selo para a combinação de atributos (função pura)."
  @spec classes(map()) :: list()
  def classes(%{theme: theme, variant: variant, size: size} = attrs) do
    [
      "inline-flex select-none items-center gap-1 overflow-clip rounded-full leading-[1.35] whitespace-nowrap",
      color_classes(theme, variant),
      @sizes_classes[size],
      Map.get(attrs, :class)
    ]
  end

  defp color_classes(:gray, :solid), do: "text-ink-base bg-surface-gray-10"
  defp color_classes(:gray, :subtle), do: "text-ink-gray-6 bg-surface-gray-2"
  defp color_classes(:gray, :outline), do: "text-ink-gray-6 border border-outline-gray-2"
  defp color_classes(:gray, :ghost), do: "text-ink-gray-6"
  defp color_classes(:blue, v), do: colored("blue", v)
  defp color_classes(:green, v), do: colored("green", v)
  defp color_classes(:amber, v), do: colored("amber", v)
  defp color_classes(:red, v), do: colored("red", v)
  defp color_classes(:violet, v), do: colored("violet", v)

  # Classes completas por cor: o Tailwind só gera o que enxerga literalmente.
  defp colored("blue", :solid), do: "text-white bg-surface-blue-7"
  defp colored("blue", :subtle), do: "text-ink-blue-7 bg-surface-blue-2"
  defp colored("blue", :outline), do: "text-ink-blue-7 border border-outline-blue-3"
  defp colored("blue", :ghost), do: "text-ink-blue-7"
  defp colored("green", :solid), do: "text-white bg-surface-green-7"
  defp colored("green", :subtle), do: "text-ink-green-7 bg-surface-green-2"
  defp colored("green", :outline), do: "text-ink-green-7 border border-outline-green-3"
  defp colored("green", :ghost), do: "text-ink-green-7"
  defp colored("amber", :solid), do: "text-white bg-surface-amber-7"
  defp colored("amber", :subtle), do: "text-ink-amber-7 bg-surface-amber-2"
  defp colored("amber", :outline), do: "text-ink-amber-7 border border-outline-amber-3"
  defp colored("amber", :ghost), do: "text-ink-amber-7"
  defp colored("red", :solid), do: "text-white bg-surface-red-7"
  defp colored("red", :subtle), do: "text-ink-red-7 bg-surface-red-2"
  defp colored("red", :outline), do: "text-ink-red-7 border border-outline-red-3"
  defp colored("red", :ghost), do: "text-ink-red-7"
  defp colored("violet", :solid), do: "text-white bg-surface-violet-7"
  defp colored("violet", :subtle), do: "text-ink-violet-7 bg-surface-violet-2"
  defp colored("violet", :outline), do: "text-ink-violet-7 border border-outline-violet-3"
  defp colored("violet", :ghost), do: "text-ink-violet-7"
end
