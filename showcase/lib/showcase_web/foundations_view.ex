defmodule ShowcaseWeb.FoundationsView do
  @moduledoc """
  Páginas de Fundamentos (Colors, Typography, Radius, Shadows, Focus ring e Chart colors).

  Tudo vem de `FrappeUIPhx.Foundations` (gerado da mesma fonte do CSS) e é exibido
  pelas **variáveis CSS do tema** (`var(--surface-gray-2)`...): trocar claro/escuro
  muda as amostras na hora. Estilos de amostra usam `style` inline porque os nomes são
  dinâmicos (o Tailwind só enxerga classes escritas por inteiro no código).
  """
  use Phoenix.Component
  use FrappeUIPhx

  alias FrappeUIPhx.Foundations

  attr :id, :atom, required: true

  def section(%{id: :colors} = assigns), do: colors(assigns)
  def section(%{id: :typography} = assigns), do: typography(assigns)
  def section(%{id: :radius} = assigns), do: radius(assigns)
  def section(%{id: :shadows} = assigns), do: shadows(assigns)
  def section(%{id: :focus_ring} = assigns), do: focus_ring(assigns)
  def section(%{id: :chart_colors} = assigns), do: chart_colors(assigns)

  # ---- Colors ------------------------------------------------------------------

  defp colors(assigns) do
    assigns = assign(assigns, :categories, Foundations.color_categories())

    ~H"""
    <div class="space-y-10" id="foundation-colors">
      <p class="fui-text-p-base text-ink-gray-6 max-w-2xl">
        Três famílias semânticas: <code>surface</code>
        (fundos), <code>ink</code>
        (texto e ícones) e <code>outline</code>
        (bordas), cada uma com variante <code>alpha</code>
        quando existe. Cada token troca de valor com o
        tema, então a mesma classe serve no claro e no escuro, sem <code>dark:</code>.
      </p>

      <section :for={category <- @categories} id={"colors-#{category}"} data-category={category}>
        <h2 class="fui-text-lg-semibold text-ink-gray-9 mb-3">{category}</h2>
        <div :for={{family, tokens} <- families(Foundations.colors()[category])} class="mb-4">
          <p class="fui-text-sm-medium text-ink-gray-6 mb-1.5">{family}</p>
          <div class="grid grid-cols-2 gap-2 sm:grid-cols-3 lg:grid-cols-5 xl:grid-cols-6">
            <div
              :for={token <- tokens}
              data-token={"#{category}-#{token.name}"}
              class="border-outline-gray-2 overflow-hidden rounded-5 border"
            >
              <div class="h-12" style={"background: var(--#{category}-#{token.name})"}></div>
              <div class="p-2">
                <p class="fui-text-sm-medium text-ink-gray-9 truncate">{token.name}</p>
                <p class="fui-text-xs text-ink-gray-5 truncate" title={"bg-#{category}-#{token.name}"}>
                  bg-{category}-{token.name}
                </p>
                <p class="fui-text-2xs text-ink-gray-4 mt-1 truncate" title={"claro: #{token.light}"}>
                  ☀ {token.light}
                </p>
                <p class="fui-text-2xs text-ink-gray-4 truncate" title={"escuro: #{token.dark}"}>
                  ☾ {token.dark}
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section id="colors-ramps">
        <h2 class="fui-text-lg-semibold text-ink-gray-9 mb-1">Rampas primitivas</h2>
        <p class="fui-text-sm text-ink-gray-5 mb-3">
          Valores fixos (não mudam com o tema). Use só quando a cor não deve acompanhar o tema.
        </p>
        <div :for={{family, shades} <- Enum.sort(Foundations.ramps())} class="mb-3" data-ramp={family}>
          <p class="fui-text-sm-medium text-ink-gray-6 mb-1">{family}</p>
          <div class="flex overflow-hidden rounded-4">
            <div
              :for={shade <- shades}
              class="h-10 flex-1"
              style={"background: #{shade.value}"}
              title={"#{family}-#{shade.shade}: #{shade.value}"}
            >
            </div>
          </div>
        </div>
      </section>
    </div>
    """
  end

  @doc "Agrupa tokens pela família (`gray-2` → `gray`); os sem número ficam em \"base\". Mantém a ordem."
  @spec families([map()]) :: [{String.t(), [map()]}]
  def families(tokens) do
    key = fn token ->
      case Regex.run(~r/\A(.+)-\d+\z/, token.name) do
        [_, family] -> family
        nil -> "base"
      end
    end

    order = tokens |> Enum.map(key) |> Enum.uniq()
    grouped = Enum.group_by(tokens, key)
    for family <- order, do: {family, Map.fetch!(grouped, family)}
  end

  # ---- Typography ------------------------------------------------------------------

  defp typography(assigns) do
    assigns =
      assigns
      |> assign(:family, Foundations.font_family())
      |> assign(:weights, Foundations.font_weights())
      |> assign(:text_scale, Enum.reject(Foundations.type_scale(), & &1.paragraph))
      |> assign(:paragraph_scale, Enum.filter(Foundations.type_scale(), & &1.paragraph))

    ~H"""
    <div class="space-y-10" id="foundation-typography">
      <section>
        <h2 class="fui-text-lg-semibold text-ink-gray-9 mb-1">Fonte</h2>
        <p class="fui-text-p-base text-ink-gray-6 mb-3">
          Família <code>{@family}</code>. O host carrega a fonte (Inter); a biblioteca não a embute.
        </p>
        <div class="flex flex-wrap gap-6">
          <div
            :for={weight <- @weights}
            data-weight={weight.name}
            class="border-outline-gray-2 rounded-5 border px-5 py-3 text-center"
          >
            <p class="text-ink-gray-9 text-3xl" style={"font-weight: #{weight.value}"}>Aa</p>
            <p class="fui-text-sm text-ink-gray-6">{weight.name} · {weight.value}</p>
          </div>
        </div>
      </section>

      <.scale
        title="Texto"
        note="classes fui-text-{tamanho}, com variantes -medium, -semibold e -bold"
        items={@text_scale}
      />
      <.scale
        title="Parágrafo"
        note="classes fui-text-p-{tamanho}: entrelinha maior para leitura"
        items={@paragraph_scale}
      />
    </div>
    """
  end

  attr :title, :string, required: true
  attr :note, :string, required: true
  attr :items, :list, required: true

  defp scale(assigns) do
    ~H"""
    <section>
      <h2 class="fui-text-lg-semibold text-ink-gray-9">{@title}</h2>
      <p class="fui-text-sm text-ink-gray-5 mb-3">{@note}</p>
      <div class="border-outline-gray-2 divide-outline-gray-1 divide-y rounded-5 border">
        <div
          :for={item <- @items}
          data-type={item.name}
          class="grid grid-cols-[8rem_1fr] items-center gap-4 px-4 py-3"
        >
          <div>
            <p class="fui-text-sm-medium text-ink-gray-9">{item.name}</p>
            <p class="fui-text-2xs text-ink-gray-5">
              {item.size} / {item.lineHeight} / {item.letterSpacing}
            </p>
          </div>
          <p
            class="text-ink-gray-8 truncate"
            style={"font-size: #{item.size}; line-height: #{item.lineHeight}; letter-spacing: #{item.letterSpacing}; font-weight: #{item.weight}"}
          >
            O rato roeu a roupa do rei de Roma
          </p>
        </div>
      </div>
    </section>
    """
  end

  # ---- Radius ------------------------------------------------------------------

  defp radius(assigns) do
    assigns = assign(assigns, :items, Foundations.radius())

    ~H"""
    <div id="foundation-radius" class="space-y-4">
      <p class="fui-text-p-base text-ink-gray-6 max-w-2xl">
        Escala numérica: <code>rounded-4</code>
        = 8px. O <code>rounded-9</code>
        (100px) faz pílulas e <code>rounded-full</code>
        círculos.
      </p>
      <div class="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-6">
        <div :for={item <- @items} data-radius={item.name} class="text-center">
          <div
            class="bg-surface-gray-3 border-outline-gray-3 mx-auto size-20 border"
            style={"border-radius: var(--radius-#{item.name})"}
          >
          </div>
          <p class="fui-text-sm-medium text-ink-gray-9 mt-2">rounded-{item.name}</p>
          <p class="fui-text-xs text-ink-gray-5">{item.value}</p>
        </div>
      </div>
    </div>
    """
  end

  # ---- Shadows ------------------------------------------------------------------

  defp shadows(assigns) do
    assigns = assign(assigns, :items, Foundations.shadows())

    ~H"""
    <div id="foundation-shadows" class="space-y-4">
      <p class="fui-text-p-base text-ink-gray-6 max-w-2xl">
        Elevações em camadas (borda sutil + sombras suaves). Use <code>shadow-elevation-*</code>; o nome
        <code>shadow-*</code>
        do Tailwind não é alterado.
      </p>
      <div class="bg-surface-gray-1 grid grid-cols-2 gap-6 rounded-6 p-8 sm:grid-cols-3 lg:grid-cols-4">
        <div :for={item <- @items} data-shadow={item.name} class="text-center">
          <div
            class="bg-surface-base border-outline-gray-1 mx-auto h-20 w-28 rounded-5 border"
            style={
              if item.name == "none",
                do: "box-shadow: none",
                else: "box-shadow: var(--shadow-elevation-#{item.name})"
            }
          >
          </div>
          <p class="fui-text-sm-medium text-ink-gray-9 mt-3">shadow-elevation-{item.name}</p>
        </div>
      </div>
    </div>
    """
  end

  # ---- Focus ring ------------------------------------------------------------------

  defp focus_ring(assigns) do
    assigns = assign(assigns, :items, Foundations.focus_rings())

    ~H"""
    <div id="foundation-focus-ring" class="space-y-4">
      <p class="fui-text-p-base text-ink-gray-6 max-w-2xl">
        Anel de foco por cor. Navegue por <kbd>Tab</kbd> nos botões abaixo para ver o anel real
        (<code>focus-visible:focus-ring-blue</code>); a caixa ao lado mostra o valor estático.
      </p>
      <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <div
          :for={item <- @items}
          data-ring={item.name}
          class="border-outline-gray-2 flex items-center gap-4 rounded-5 border p-4"
        >
          <div
            class="bg-surface-base size-12 shrink-0 rounded-4"
            style={"outline: var(--focus-outline-#{item.name}); outline-offset: 0"}
          >
          </div>
          <div class="min-w-0">
            <button
              type="button"
              class={[
                "fui-text-base bg-surface-gray-2 rounded-4 px-3 py-1.5 focus:outline-none",
                ring_class(item.name)
              ]}
            >
              {item.name}
            </button>
            <p class="fui-text-xs text-ink-gray-5 mt-1 truncate">{item.value}</p>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc "Classe de foco literal por cor (precisa estar escrita por inteiro para o Tailwind gerá-la)."
  @spec ring_class(String.t()) :: String.t()
  def ring_class("default"), do: "focus-visible:focus-ring"
  def ring_class("red"), do: "focus-visible:focus-ring-red"
  def ring_class("green"), do: "focus-visible:focus-ring-green"
  def ring_class("amber"), do: "focus-visible:focus-ring-amber"
  def ring_class("blue"), do: "focus-visible:focus-ring-blue"
  def ring_class("violet"), do: "focus-visible:focus-ring-violet"

  # ---- Chart colors ------------------------------------------------------------------

  defp chart_colors(assigns) do
    assigns =
      assigns
      |> assign(:colors, Foundations.chart_colors())
      |> assign(:steps, [0.08, 0.25, 0.45, 0.7, 1.0])
      |> assign(
        :series,
        for(n <- 1..4, do: %{name: "Série #{n}", data: Enum.map(1..4, &(&1 * n + n))})
      )

    ~H"""
    <div id="foundation-chart-colors" class="space-y-8">
      <p class="fui-text-p-base text-ink-gray-6 max-w-2xl">
        As séries usam estas cores, nesta ordem, e repetem depois da última. São variáveis do tema
        (<code>var(--surface-{"{família}"}-6)</code>), então acompanham claro e escuro.
      </p>

      <section>
        <h2 class="fui-text-lg-semibold text-ink-gray-9 mb-3">Séries categóricas</h2>
        <div class="grid grid-cols-2 gap-3 sm:grid-cols-5">
          <div
            :for={color <- @colors}
            data-series={color.index}
            class="border-outline-gray-2 overflow-hidden rounded-5 border"
          >
            <div class="h-14" style={"background: #{color.color}"}></div>
            <div class="p-2">
              <p class="fui-text-sm-medium text-ink-gray-9">Série {color.index + 1}</p>
              <p class="fui-text-xs text-ink-gray-5">{color.family}</p>
            </div>
          </div>
        </div>
      </section>

      <section>
        <h2 class="fui-text-lg-semibold text-ink-gray-9 mb-1">Escala sequencial</h2>
        <p class="fui-text-sm text-ink-gray-5 mb-2">
          Intensidade por opacidade (mapas de calor): do valor mínimo ao máximo.
        </p>
        <div class="flex gap-1">
          <div
            :for={opacity <- @steps}
            class="h-10 flex-1 rounded-3"
            style={"background: var(--surface-blue-7); opacity: #{opacity}"}
            title={"opacidade #{opacity}"}
          >
          </div>
        </div>
      </section>

      <section>
        <h2 class="fui-text-lg-semibold text-ink-gray-9 mb-1">Positivo / negativo</h2>
        <p class="fui-text-sm text-ink-gray-5 mb-2">
          Variações usam verde e vermelho (<code>NumberCard</code>).
        </p>
        <div class="flex gap-3">
          <span class="fui-text-sm text-ink-green-5">+12,5%</span>
          <span class="fui-text-sm text-ink-red-5">-3%</span>
        </div>
      </section>

      <section>
        <h2 class="fui-text-lg-semibold text-ink-gray-9 mb-2">Em uso</h2>
        <.bar_chart categories={["T1", "T2", "T3", "T4"]} series={@series} />
      </section>
    </div>
    """
  end
end
