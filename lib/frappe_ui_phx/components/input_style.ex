defmodule FrappeUIPhx.Components.InputStyle do
  @moduledoc """
  Classes compartilhadas por TextInput, Textarea e Select (função pura).

  Existe separado dos componentes para que as três variantes visuais tenham um
  único dono (S do SOLID) e possam ser testadas sem renderizar.
  """

  @variants ~w(subtle outline ghost)a
  @sizes ~w(xs sm md lg)a

  @size_classes %{
    xs: "fui-text-xs rounded-3 h-6",
    sm: "fui-text-base rounded-4 h-7",
    md: "fui-text-base rounded-4 h-8",
    lg: "fui-text-lg rounded-5 h-10"
  }

  @variant_classes %{
    subtle:
      "border border-surface-gray-2 bg-surface-gray-2 placeholder:text-ink-gray-4 hover:border-outline-elevation-2 hover:bg-surface-gray-3 focus:bg-surface-base focus:border-outline-gray-4 focus:shadow-elevation-sm focus:outline-none",
    outline:
      "border border-outline-gray-2 bg-surface-base placeholder:text-ink-gray-4 hover:border-outline-gray-3 hover:shadow-elevation-sm focus:bg-surface-base focus:border-outline-gray-4 focus:shadow-elevation-sm focus:outline-none",
    ghost: "border-0 bg-transparent focus:outline-none focus-visible:outline-none"
  }

  def variants, do: @variants
  def sizes, do: @sizes

  @doc "Classes do controle para variante, tamanho e estados."
  @spec classes(atom(), atom(), keyword()) :: list()
  def classes(variant, size, opts \\ []) do
    invalid? = Keyword.get(opts, :invalid, false)
    disabled? = Keyword.get(opts, :disabled, false)

    [
      "leading-[1.35] transition-colors w-full px-2 py-1.5 dark:[color-scheme:dark]",
      @size_classes[size],
      @variant_classes[variant],
      if(disabled?, do: "text-ink-gray-5 cursor-not-allowed", else: "text-ink-gray-8"),
      invalid? && "border-outline-red-3 hover:border-outline-red-3 focus:border-outline-red-4",
      Keyword.get(opts, :class)
    ]
  end
end
