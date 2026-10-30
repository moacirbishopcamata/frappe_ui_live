defmodule FrappeUILive.Components.Avatar do
  @moduledoc "Avatar com imagem ou iniciais do `label`. Formas `circle | square`."
  use Phoenix.Component

  alias FrappeUILive.Contract

  @sizes ~w(xs sm md lg xl 2xl 3xl)a
  @shapes ~w(circle square)a

  @size_classes %{
    xs: "size-4 fui-text-2xs",
    sm: "size-5 fui-text-2xs",
    md: "size-6 fui-text-xs",
    lg: "size-7 fui-text-sm",
    xl: "size-8 fui-text-base",
    "2xl": "size-10 fui-text-lg",
    "3xl": "size-12 fui-text-xl"
  }

  attr :label, :string, default: nil
  attr :image, :string, default: nil
  attr :size, :atom, default: :md, values: @sizes
  attr :shape, :atom, default: :circle, values: @shapes
  attr :class, :any, default: nil
  attr :rest, :global

  def avatar(assigns) do
    Contract.require!(assigns.size, @sizes, "avatar size")
    Contract.require!(assigns.shape, @shapes, "avatar shape")

    assigns =
      assigns
      |> assign(:initial, initial(assigns.label))
      |> assign(:size_class, @size_classes[assigns.size])

    ~H"""
    <span
      class={[
        "bg-surface-gray-2 text-ink-gray-5 inline-flex shrink-0 items-center justify-center overflow-hidden font-medium select-none",
        @shape == :circle && "rounded-full",
        @shape == :square && "rounded-4",
        @size_class,
        @class
      ]}
      title={@label}
      {@rest}
    >
      <img
        :if={@image}
        src={@image}
        alt={@label || ""}
        loading="lazy"
        decoding="async"
        referrerpolicy="no-referrer"
        class="size-full object-cover"
      />
      <span :if={!@image}>{@initial}</span>
    </span>
    """
  end

  @doc "Primeira letra maiúscula do rótulo, ou `\"\"` quando ausente."
  @spec initial(String.t() | nil) :: String.t()
  def initial(nil), do: ""

  def initial(label) when is_binary(label),
    do: label |> String.trim() |> String.first() |> Kernel.||("") |> String.upcase()
end
