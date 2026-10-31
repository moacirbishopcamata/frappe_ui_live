defmodule ShowcaseWeb.IconsView do
  @moduledoc """
  Página de Ícones: grade de todos os ícones Lucide com busca por nome/tag, controles
  ao vivo das propriedades (`size`, `color`, `stroke_width`, `absolute_stroke_width`)
  e detalhe do ícone (tags, aliases e trecho de uso).

  O estado (`init/0`, `cast/2`) é puro e vive no servidor (assigns do `CatalogLive`);
  entrada do formulário é convertida e limitada aqui, nunca confiada.
  """
  use Phoenix.Component
  use FrappeUIPhx

  alias FrappeUIPhx.Icons

  @page 120
  @colors ~w(currentColor red blue green orange purple)
  @size {8, 96}
  @stroke {0.25, 4}

  @type state :: %{
          q: String.t(),
          size: number(),
          color: String.t(),
          stroke_width: number(),
          absolute: boolean(),
          limit: pos_integer(),
          selected: String.t() | nil
        }

  @doc "Estado inicial: padrões do Lucide (24, currentColor, traço 2)."
  @spec init() :: state()
  def init do
    %{
      q: "",
      size: 24,
      color: "currentColor",
      stroke_width: 2,
      absolute: false,
      limit: @page,
      selected: nil
    }
  end

  @doc "Lista de cores aceitas no controle."
  def colors, do: @colors

  @doc "Aplica o formulário (strings) ao estado, descartando o que sai dos limites."
  @spec cast(state(), map()) :: state()
  def cast(state, params) when is_map(params) do
    q = params |> Map.get("q", state.q) |> to_string() |> String.slice(0, 60)

    %{
      state
      | q: q,
        size: number(params["size"], @size, state.size),
        color: pick(params["color"], @colors, state.color),
        stroke_width: number(params["stroke_width"], @stroke, state.stroke_width),
        absolute: params["absolute"] in ["true", "on"],
        limit: if(q == state.q, do: state.limit, else: @page)
    }
  end

  @doc "Mostra mais um lote de ícones."
  @spec more(state()) :: state()
  def more(state), do: %{state | limit: state.limit + @page}

  @doc "Seleciona um ícone pelo nome; nome desconhecido ou vazio limpa a seleção."
  @spec select(state(), String.t()) :: state()
  def select(state, name) do
    case Icons.get(name) do
      %{name: canonical} -> %{state | selected: canonical}
      nil -> %{state | selected: nil}
    end
  end

  defp pick(value, allowed, default), do: if(value in allowed, do: value, else: default)

  defp number(value, {min, max}, default) when is_binary(value) do
    case Float.parse(value) do
      {n, ""} when n >= min and n <= max -> if n == trunc(n), do: trunc(n), else: n
      _ -> default
    end
  end

  defp number(_value, _range, default), do: default

  attr :icons, :map, required: true, doc: "estado de `init/0`"

  def page(assigns) do
    found = Icons.search(assigns.icons.q)

    assigns =
      assigns
      |> assign(:found, found)
      |> assign(:shown, Enum.take(found, assigns.icons.limit))
      |> assign(:total, length(Icons.names()))
      |> assign(:selected, assigns.icons.selected && Icons.get(assigns.icons.selected))
      |> assign(:form, to_form(form_params(assigns.icons), as: :icons))

    ~H"""
    <.page_header
      title="Ícones"
      subtitle={"#{@total} ícones Lucide #{Icons.version()}, cada um como componente LiveView. Busque por nome ou tag e ajuste as propriedades."}
    />
    <div class="space-y-5 p-5" id="icons-page">
      <.form for={@form} id="icons-form" phx-change="icons" phx-submit="icons" class="space-y-3">
        <div class="grid gap-3 sm:grid-cols-2 xl:grid-cols-5">
          <.form_control
            field={@form[:q]}
            label="Buscar"
            type="text"
            placeholder="ex.: seta, trash, user"
            maxlength="60"
            phx-debounce="200"
            class="xl:col-span-2"
          />
          <.form_control field={@form[:size]} label="size" type="number" min="8" max="96" step="1" />
          <.form_control
            field={@form[:stroke_width]}
            label="stroke_width"
            type="number"
            min="0.25"
            max="4"
            step="0.25"
          />
          <.form_control
            field={@form[:color]}
            label="color"
            type="select"
            options={Enum.map(colors(), &{&1, &1})}
          />
        </div>
        <.form_control field={@form[:absolute]} label="absolute_stroke_width" type="checkbox" />
      </.form>

      <p id="icons-count" class="fui-text-sm text-ink-gray-5">
        {length(@found)} de {@total} ícones
      </p>

      <p :if={@found == []} id="icons-empty" class="fui-text-base text-ink-gray-6">
        Nenhum ícone para “{@icons.q}”.
      </p>

      <div class="grid gap-6 lg:grid-cols-[minmax(0,1fr)_18rem]">
        <div>
          <ul id="icons-grid" class="grid grid-cols-[repeat(auto-fill,minmax(7rem,1fr))] gap-2">
            <li :for={icon <- @shown} id={"icon-#{icon.name}"}>
              <button
                type="button"
                phx-click="icon_select"
                phx-value-name={icon.name}
                aria-pressed={to_string(@icons.selected == icon.name)}
                title={icon.name}
                class={[
                  "rounded-5 border-outline-gray-2 hover:bg-surface-gray-1 flex h-24 w-full flex-col items-center justify-center gap-2 border p-2",
                  @icons.selected == icon.name && "bg-surface-gray-2"
                ]}
              >
                <.icon
                  name={icon.name}
                  size={@icons.size}
                  color={@icons.color}
                  stroke_width={@icons.stroke_width}
                  absolute_stroke_width={@icons.absolute}
                />
                <span class="fui-text-xs text-ink-gray-6 w-full truncate">{icon.name}</span>
              </button>
            </li>
          </ul>
          <.button
            :if={length(@found) > @icons.limit}
            id="icons-more"
            class="mt-4"
            label={"Mostrar mais (#{length(@found) - @icons.limit} restantes)"}
            phx-click="icons_more"
          />
        </div>

        <aside id="icon-detail" class="border-outline-gray-2 rounded-6 h-fit space-y-3 border p-4">
          <p :if={!@selected} class="fui-text-sm text-ink-gray-5">
            Escolha um ícone para ver tags, aliases e como usar.
          </p>
          <.detail :if={@selected} icon={@selected} state={@icons} />
        </aside>
      </div>
    </div>
    """
  end

  attr :icon, :map, required: true
  attr :state, :map, required: true

  defp detail(assigns) do
    assigns = assign(assigns, :props, props(assigns.state))

    ~H"""
    <div class="flex items-center gap-3">
      <.icon
        name={@icon.name}
        size={32}
        color={@state.color}
        stroke_width={@state.stroke_width}
        absolute_stroke_width={@state.absolute}
      />
      <p class="fui-text-base-medium text-ink-gray-9">{@icon.name}</p>
    </div>
    <div :if={@icon.tags != []}>
      <p class="fui-text-xs-medium text-ink-gray-5 mb-1 uppercase">Tags</p>
      <div id="icon-tags" class="flex flex-wrap gap-1">
        <.badge :for={tag <- @icon.tags} label={tag} />
      </div>
    </div>
    <div :if={@icon.aliases != []}>
      <p class="fui-text-xs-medium text-ink-gray-5 mb-1 uppercase">Aliases</p>
      <p id="icon-aliases" class="fui-text-sm text-ink-gray-7">{Enum.join(@icon.aliases, ", ")}</p>
    </div>
    <div>
      <p class="fui-text-xs-medium text-ink-gray-5 mb-1 uppercase">Uso</p>
      <pre
        id="icon-snippet"
        class="bg-surface-gray-2 text-ink-gray-8 rounded-5 fui-text-sm overflow-x-auto p-2"
      ><code>{snippet(@icon.name, @props)}</code></pre>
    </div>
    """
  end

  # Só as propriedades que diferem do padrão do Lucide entram no trecho.
  defp props(state) do
    [
      state.size != 24 && "size={#{state.size}}",
      state.color != "currentColor" && ~s(color="#{state.color}"),
      state.stroke_width != 2 && "stroke_width={#{state.stroke_width}}",
      state.absolute && "absolute_stroke_width"
    ]
    |> Enum.filter(& &1)
  end

  @doc false
  def snippet(name, props) do
    props = Enum.map_join(props, "", &(" " <> &1))
    ~s(<Lucide.#{Icons.function_name(name)}#{props} />\n<.icon name="#{name}"#{props} />)
  end

  defp form_params(state) do
    %{
      "q" => state.q,
      "size" => state.size,
      "stroke_width" => state.stroke_width,
      "color" => state.color,
      "absolute" => state.absolute
    }
  end
end
