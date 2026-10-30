defmodule FrappeUILive.Components.Button do
  @moduledoc """
  Botão do Frappe UI: variantes `solid | subtle | outline | ghost`, temas
  `gray | blue | green | red`, tamanhos `xs | sm | md | lg`.

  Vira `<.link>` quando recebe `href`, `navigate` ou `patch` (e não está
  inerte); caso contrário é um `<button>`. Com `loading`, mostra o spinner e
  fica inerte, mas mantém o visual normal (igual ao original).
  """
  use Phoenix.Component

  alias FrappeUILive.Components.{Icon, Spinner}
  alias FrappeUILive.Contract

  @themes ~w(gray blue green red)a
  @variants ~w(solid subtle outline ghost)a
  @sizes ~w(xs sm md lg)a
  @link_attrs ~w(href navigate patch)a

  @variant_classes %{
    {:gray, :solid} =>
      "text-ink-base bg-surface-gray-10 hover:bg-surface-gray-9 active:bg-surface-gray-8",
    {:blue, :solid} =>
      "text-ink-base bg-surface-blue-6 hover:bg-surface-blue-7 active:bg-surface-blue-8",
    {:green, :solid} =>
      "text-ink-base bg-surface-green-7 hover:bg-surface-green-8 active:bg-surface-green-9",
    {:red, :solid} =>
      "text-ink-base dark:text-ink-red-9 bg-surface-red-7 hover:bg-surface-red-8 active:bg-surface-red-9",
    {:gray, :subtle} =>
      "text-ink-gray-8 bg-surface-gray-2 hover:bg-surface-gray-3 active:bg-surface-gray-4",
    {:blue, :subtle} =>
      "text-ink-blue-5 bg-surface-blue-2 hover:bg-surface-blue-3 active:bg-surface-blue-4",
    {:green, :subtle} =>
      "text-ink-green-8 bg-surface-green-2 hover:bg-surface-green-3 active:bg-surface-green-4",
    {:red, :subtle} =>
      "text-ink-red-7 bg-surface-red-2 hover:bg-surface-red-3 active:bg-surface-red-4",
    {:gray, :outline} =>
      "text-ink-gray-8 bg-surface-base border border-outline-gray-2 hover:border-outline-gray-3 active:border-outline-gray-3 active:bg-surface-gray-4",
    {:blue, :outline} =>
      "text-ink-blue-5 bg-surface-base border border-outline-blue-1 hover:border-outline-blue-4 active:border-outline-blue-4 active:bg-surface-blue-4",
    {:green, :outline} =>
      "text-ink-green-8 bg-surface-base border border-outline-green-3 hover:border-outline-green-5 active:border-outline-green-5 active:bg-surface-green-4",
    {:red, :outline} =>
      "text-ink-red-7 bg-surface-base border border-outline-red-1 hover:border-outline-red-3 active:border-outline-red-3 active:bg-surface-red-3",
    {:gray, :ghost} => "text-ink-gray-8 bg-transparent hover:bg-surface-gray-3 active:bg-surface-gray-4",
    {:blue, :ghost} => "text-ink-blue-5 bg-transparent hover:bg-surface-blue-3 active:bg-surface-blue-4",
    {:green, :ghost} =>
      "text-ink-green-8 bg-transparent hover:bg-surface-green-3 active:bg-surface-green-4",
    {:red, :ghost} => "text-ink-red-7 bg-transparent hover:bg-surface-red-3 active:bg-surface-red-4"
  }

  @disabled_classes %{
    {:gray, :solid} => "bg-surface-gray-2 text-ink-gray-4",
    {:gray, :subtle} => "bg-surface-gray-2 text-ink-gray-4",
    {:gray, :outline} => "bg-surface-gray-2 text-ink-gray-4 border border-outline-gray-2",
    {:gray, :ghost} => "text-ink-gray-4",
    {:blue, :solid} => "bg-surface-blue-4 text-ink-base",
    {:blue, :subtle} => "bg-surface-blue-2 text-ink-blue-link",
    {:blue, :outline} => "bg-surface-blue-2 text-ink-blue-link border border-outline-blue-1",
    {:blue, :ghost} => "text-ink-blue-link",
    {:green, :solid} => "bg-surface-green-2 text-ink-green-4",
    {:green, :subtle} => "bg-surface-green-2 text-ink-green-4",
    {:green, :outline} => "bg-surface-green-2 text-ink-green-4 border border-outline-green-3",
    {:green, :ghost} => "text-ink-green-4",
    {:red, :solid} => "bg-surface-red-2 text-ink-red-4",
    {:red, :subtle} => "bg-surface-red-2 text-ink-red-4",
    {:red, :outline} => "bg-surface-red-2 text-ink-red-4 border border-outline-red-1",
    {:red, :ghost} => "text-ink-red-4"
  }

  @focus_classes %{
    gray: nil,
    blue: "focus-visible:focus-ring-blue",
    green: "focus-visible:focus-ring-green",
    red: "focus-visible:focus-ring-red"
  }

  @icon_only_sizes %{
    xs: "h-6 w-6 rounded-3",
    sm: "h-7 w-7 rounded-4",
    md: "h-8 w-8 rounded-4",
    lg: "h-10 w-10 rounded-5"
  }

  @text_sizes %{
    xs: "h-6 fui-text-xs px-1.5 rounded-3",
    sm: "h-7 fui-text-base px-2 rounded-4",
    md: "h-8 fui-text-base-medium px-2.5 rounded-4",
    lg: "h-10 fui-text-lg-medium px-3 rounded-5"
  }

  @icon_sizes %{xs: "size-3.5", sm: "size-4", md: "size-4.5", lg: "size-5"}

  attr :theme, :atom, default: :gray, values: @themes
  attr :variant, :atom, default: :subtle, values: @variants
  attr :size, :atom, default: :sm, values: @sizes
  attr :label, :string, default: nil
  attr :icon, :string, default: nil, doc: "botão só com ícone (nome Lucide)"
  attr :icon_left, :string, default: nil
  attr :icon_right, :string, default: nil
  attr :loading, :boolean, default: false
  attr :loading_text, :string, default: nil
  attr :disabled, :boolean, default: false
  attr :type, :string, default: "button"
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(href navigate patch method download name value form)
  slot :inner_block

  def button(assigns) do
    Contract.require!(assigns.theme, @themes, "button theme")
    Contract.require!(assigns.variant, @variants, "button variant")
    Contract.require!(assigns.size, @sizes, "button size")

    inert? = assigns.disabled or assigns.loading
    link? = not inert? and Enum.any?(@link_attrs, &Map.has_key?(assigns.rest, &1))

    assigns =
      assigns
      |> assign(:classes, classes(assigns))
      |> assign(:inert?, inert?)
      |> assign(:link?, link?)
      |> assign(:icon_class, @icon_sizes[assigns.size])

    ~H"""
    <.link :if={@link?} class={@classes} {@rest}>
      <.content {content_attrs(assigns)}>{render_slot(@inner_block)}</.content>
    </.link>
    <button :if={not @link?} type={@type} disabled={@inert?} class={@classes} {@rest}>
      <.content {content_attrs(assigns)}>{render_slot(@inner_block)}</.content>
    </button>
    """
  end

  @doc """
  Classes do botão para a combinação de atributos. Função pura, testável sem renderizar.
  """
  @spec classes(map()) :: [String.t() | nil]
  def classes(%{theme: theme, variant: variant, size: size} = attrs) do
    icon_only? = Map.get(attrs, :icon) != nil
    key = {theme, variant}

    [
      "inline-flex items-center justify-center gap-2 transition-colors shrink-0",
      if(Map.get(attrs, :disabled, false), do: @disabled_classes[key], else: @variant_classes[key]),
      if(Map.get(attrs, :loading, false) and not Map.get(attrs, :disabled, false),
        do: "pointer-events-none"
      ),
      @focus_classes[theme],
      if(icon_only?, do: @icon_only_sizes[size], else: @text_sizes[size]),
      Map.get(attrs, :class)
    ]
  end

  defp content_attrs(assigns) do
    Map.take(assigns, [:loading, :loading_text, :icon, :icon_left, :icon_right, :label, :icon_class])
  end

  attr :loading, :boolean, required: true
  attr :loading_text, :string, default: nil
  attr :icon, :string, default: nil
  attr :icon_left, :string, default: nil
  attr :icon_right, :string, default: nil
  attr :label, :string, default: nil
  attr :icon_class, :string, required: true
  slot :inner_block

  defp content(assigns) do
    ~H"""
    <Spinner.spinner :if={@loading} class={@icon_class} />
    <Icon.icon :if={@icon_left && !@loading} name={@icon_left} class={@icon_class} />
    <Icon.icon :if={@icon && !@loading} name={@icon} class={@icon_class} />
    <span :if={!@icon} class="truncate leading-[1.35]">
      <%= cond do %>
        <% @loading and @loading_text -> %>
          {@loading_text}
        <% @inner_block != [] -> %>
          {render_slot(@inner_block)}
        <% true -> %>
          {@label}
      <% end %>
    </span>
    <Icon.icon :if={@icon_right} name={@icon_right} class={@icon_class} />
    """
  end
end
