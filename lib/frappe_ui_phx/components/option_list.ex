defmodule FrappeUIPhx.Components.OptionList do
  @moduledoc """
  Base de Combobox e MultiSelect: gatilho + painel (Popover API) com busca e
  opções que são `<input type=radio|checkbox>` **nativos** — então a seleção já é
  valor de formulário e dispara o `phx-change` sem nenhum JS de negócio.

  O hook colocated só filtra a lista pelo que foi digitado (estado de UI efêmero)
  e fecha o painel na escolha única. Com `on_search`, a busca vira evento para o
  servidor (lista grande/remota) e o filtro local é desligado.
  """
  use Phoenix.Component

  alias FrappeUIPhx.Texts

  alias FrappeUIPhx.Components.{Anchor, Badge, Icon, InputStyle}

  @max_badges 3

  attr :id, :string, required: true
  attr :name, :string, required: true
  attr :options, :list, required: true, doc: "strings ou {rótulo, valor}"
  attr :selected, :list, default: [], doc: "valores selecionados (strings)"
  attr :multiple, :boolean, default: false
  attr :placeholder, :string, default: nil
  attr :search_placeholder, :string, default: nil
  attr :empty_text, :string, default: nil
  attr :on_search, :string, default: nil
  attr :errors, :list, default: []
  attr :disabled, :boolean, default: false
  attr :form, :string, default: nil
  attr :required, :boolean, default: false, doc: "só vale na escolha única"
  attr :class, :any, default: nil
  attr :rest, :global

  def option_list(assigns) do
    assigns = assign(assigns, :empty_text, assigns.empty_text || Texts.t(:no_results))
    assigns = assign(assigns, :search_placeholder, assigns.search_placeholder || Texts.t(:search))
    assigns = assign(assigns, :placeholder, assigns.placeholder || Texts.t(:select))
    Anchor.valid_id!(assigns.id, "option_list")
    choices = Enum.map(assigns.options, &normalize/1)
    selected = Enum.map(assigns.selected, &to_string/1)

    assigns =
      assigns
      |> assign(:choices, choices)
      |> assign(:selected, selected)
      |> assign(:chosen, for({label, value} <- choices, value in selected, do: label))
      |> assign(:panel, "#{assigns.id}-panel")
      |> assign(:input_type, if(assigns.multiple, do: "checkbox", else: "radio"))
      |> assign(:max_badges, @max_badges)

    ~H"""
    <div
      id={@id}
      phx-hook=".OptionFilter"
      data-multiple={to_string(@multiple)}
      data-remote={to_string(@on_search != nil)}
      class={["relative w-full", @class]}
      {@rest}
    >
      <input :if={@multiple} type="hidden" name={@name} value="" form={@form} />
      <button
        type="button"
        popovertarget={@panel}
        style={Anchor.trigger_style(@id)}
        disabled={@disabled}
        aria-haspopup="listbox"
        aria-invalid={@errors != [] && "true"}
        class={[
          "bg-surface-gray-2 hover:bg-surface-gray-3 fui-text-base flex min-h-7 w-full items-center justify-between gap-2 rounded-4 border border-transparent px-2 py-1 text-left transition-colors disabled:cursor-not-allowed disabled:opacity-60",
          @errors != [] && "border-outline-red-3"
        ]}
      >
        <span class="flex min-w-0 flex-1 flex-wrap items-center gap-1">
          <span :if={@chosen == []} class="text-ink-gray-4 truncate">{@placeholder}</span>
          <span :if={@chosen != [] and !@multiple} class="text-ink-gray-8 truncate">{hd(@chosen)}</span>
          <Badge.badge
            :for={label <- Enum.take(@chosen, @max_badges)}
            :if={@multiple}
            label={label}
            size={:sm}
          />
          <Badge.badge
            :if={@multiple and length(@chosen) > @max_badges}
            label={"+#{length(@chosen) - @max_badges}"}
            size={:sm}
          />
        </span>
        <Icon.icon name="chevrons-up-down" class="text-ink-gray-5 size-4 shrink-0" />
      </button>

      <div
        id={@panel}
        popover
        style={Anchor.panel_style(@id)}
        class={[Anchor.panel_classes(), "w-64 border p-1.5"]}
      >
        <input
          type="search"
          data-option-search
          placeholder={@search_placeholder}
          autocomplete="off"
          phx-keyup={@on_search}
          phx-debounce={@on_search && "250"}
          class={InputStyle.classes(:subtle, :sm)}
        />
        <ul
          role="listbox"
          aria-multiselectable={to_string(@multiple)}
          class="mt-1 max-h-56 overflow-auto"
        >
          <li
            :for={{label, value} <- @choices}
            :key={value}
            data-option-label={String.downcase(label)}
          >
            <label class="hover:bg-surface-gray-2 fui-text-base flex cursor-pointer items-center gap-2 rounded-4 px-2 py-1.5">
              <input
                type={@input_type}
                name={@name}
                form={@form}
                required={@required and !@multiple}
                value={value}
                checked={value in @selected}
                class="peer sr-only"
              />
              <span class="size-4 shrink-0">
                <Icon.icon name="check" class="text-ink-gray-9 hidden size-4 peer-checked:block" />
              </span>
              <span class="text-ink-gray-8 truncate">{label}</span>
            </label>
          </li>
        </ul>
        <p
          data-option-empty
          hidden={@choices != []}
          class="fui-text-sm text-ink-gray-5 px-2 py-3 text-center"
        >
          {@empty_text}
        </p>
      </div>
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".OptionFilter">
      export default {
        mounted() {
          this.search = this.el.querySelector("[data-option-search]")
          this.panel = this.el.querySelector("[popover]")

          this.search.addEventListener("input", () => this.filter())
          this.panel.addEventListener("toggle", (event) => {
            if (event.newState === "open") this.search.focus()
          })
          this.el.addEventListener("change", (event) => {
            // escolha única: fecha o painel; múltipla: continua aberto
            if (this.el.dataset.multiple !== "true" && event.target.matches("input[type=radio]")) {
              this.panel.hidePopover()
            }
          })
        },
        updated() {
          this.filter()
        },
        filter() {
          if (this.el.dataset.remote === "true") return // o servidor filtra
          const query = this.search.value.trim().toLowerCase()
          let visible = 0
          this.el.querySelectorAll("[data-option-label]").forEach((item) => {
            const show = item.dataset.optionLabel.includes(query)
            item.hidden = !show
            if (show) visible += 1
          })
          this.el.querySelector("[data-option-empty]").hidden = visible > 0
        }
      }
    </script>
    """
  end

  @doc "Normaliza uma opção em `{rótulo, valor}` (ambos texto)."
  @spec normalize(String.t() | {term(), term()}) :: {String.t(), String.t()}
  def normalize({label, value}), do: {to_string(label), to_string(value)}
  def normalize(value), do: normalize({value, value})
end
