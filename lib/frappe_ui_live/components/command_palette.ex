defmodule FrappeUILive.Components.CommandPalette do
  @moduledoc """
  Paleta de comandos (Ctrl/⌘ + K): busca, grupos e navegação por teclado. Abre
  como o `Dialog` (mesmo hook nativo: foco preso, Esc, backdrop) e o hook próprio só
  filtra a lista, move a seleção com ↑/↓ e aciona o item com Enter. O que cada
  item *faz* é decidido pelo servidor (`click`) ou por navegação.

  Experimental.
  """
  use Phoenix.Component

  alias FrappeUILive.Components.{Anchor, Dialog, Icon, KeyboardShortcut}
  alias Phoenix.LiveView.JS

  attr :id, :string, required: true
  attr :placeholder, :string, default: "Buscar comandos…"
  attr :empty_text, :string, default: "Nenhum comando encontrado."
  attr :shortcut, :boolean, default: true, doc: "liga Ctrl/⌘ + K para abrir"
  attr :class, :any, default: nil

  slot :item, required: true do
    attr :label, :string, required: true
    attr :group, :string
    attr :icon, :string
    attr :keywords, :string
    attr :shortcut, :list
    attr :click, :any
    attr :navigate, :string
    attr :patch, :string
    attr :href, :string
  end

  def command_palette(assigns) do
    Anchor.valid_id!(assigns.id, "command_palette")

    assigns =
      assigns
      |> assign(:groups, group_items(assigns.item))
      |> assign(:close, JS.dispatch("fui:dialog-close", to: "##{assigns.id}"))

    ~H"""
    <dialog
      id={@id}
      phx-hook={Dialog.hook_name()}
      phx-mounted={JS.ignore_attributes(["open"])}
      data-open="false"
      data-backdrop-close="true"
      aria-label="Paleta de comandos"
      class={[
        "bg-surface-elevation-1 shadow-elevation-xl rounded-6 mx-auto mt-[12vh] w-full max-w-lg p-0 backdrop:bg-black/50",
        @class
      ]}
    >
      <div
        id={"#{@id}-palette"}
        phx-hook=".CommandPalette"
        data-dialog={@id}
        data-shortcut={to_string(@shortcut)}
      >
        <div class="border-outline-gray-2 flex items-center gap-2 border-b px-3">
          <Icon.icon name="search" class="text-ink-gray-5 size-4 shrink-0" />
          <input
            type="search"
            data-command-input
            placeholder={@placeholder}
            autocomplete="off"
            aria-label={@placeholder}
            class="fui-text-base text-ink-gray-8 h-11 w-full bg-transparent focus:outline-none"
          />
        </div>

        <ul role="listbox" class="max-h-80 overflow-auto p-1.5">
          <%= for {group, items} <- @groups do %>
            <li role="presentation" data-command-group class="mb-1">
              <p :if={group} class="fui-text-xs-medium text-ink-gray-5 px-2 py-1 uppercase">
                {group}
              </p>
              <ul role="presentation">
                <li
                  :for={item <- items}
                  role="option"
                  aria-selected="false"
                  data-command-item
                  data-search={search_text(item)}
                >
                  <.link
                    :if={nav?(item)}
                    class={item_class()}
                    phx-click={@close}
                    {Map.take(item, [:navigate, :patch, :href])}
                  >
                    <.row item={item} />
                  </.link>
                  <button
                    :if={!nav?(item)}
                    type="button"
                    phx-click={action(item, @close)}
                    class={item_class()}
                  >
                    <.row item={item} />
                  </button>
                </li>
              </ul>
            </li>
          <% end %>
        </ul>
        <p data-command-empty hidden class="fui-text-sm text-ink-gray-5 px-3 py-6 text-center">
          {@empty_text}
        </p>
      </div>
    </dialog>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".CommandPalette">
      export default {
        mounted() {
          this.dialog = document.getElementById(this.el.dataset.dialog)
          this.input = this.el.querySelector("[data-command-input]")
          this.input.addEventListener("input", () => this.filter())
          this.input.addEventListener("keydown", (event) => this.keys(event))

          // atalho global Ctrl/⌘ + K
          this.onKey = (event) => {
            if (this.el.dataset.shortcut !== "true") return
            if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === "k") {
              event.preventDefault()
              this.dialog.dispatchEvent(new Event("fui:dialog-open"))
              this.input.focus()
              this.input.select()
            }
          }
          window.addEventListener("keydown", this.onKey)
          this.dialog.addEventListener("close", () => { this.input.value = ""; this.filter() })
          this.filter()
        },
        destroyed() {
          window.removeEventListener("keydown", this.onKey)
        },
        items() {
          return Array.from(this.el.querySelectorAll("[data-command-item]")).filter((item) => !item.hidden)
        },
        filter() {
          const query = this.input.value.trim().toLowerCase()
          let visible = 0
          this.el.querySelectorAll("[data-command-item]").forEach((item) => {
            const show = item.dataset.search.includes(query)
            item.hidden = !show
            if (show) visible += 1
          })
          this.el.querySelectorAll("[data-command-group]").forEach((group) => {
            group.hidden = !group.querySelector("[data-command-item]:not([hidden])")
          })
          this.el.querySelector("[data-command-empty]").hidden = visible > 0
          this.select(0)
        },
        select(index) {
          const items = this.items()
          this.active = items.length ? (index + items.length) % items.length : 0
          this.el.querySelectorAll("[data-command-item]").forEach((item) => item.setAttribute("aria-selected", "false"))
          const current = items[this.active]
          if (current) {
            current.setAttribute("aria-selected", "true")
            current.scrollIntoView({block: "nearest"})
          }
        },
        keys(event) {
          if (event.key === "ArrowDown") { event.preventDefault(); this.select(this.active + 1) }
          else if (event.key === "ArrowUp") { event.preventDefault(); this.select(this.active - 1) }
          else if (event.key === "Enter") {
            event.preventDefault()
            const current = this.items()[this.active]
            if (current) current.querySelector("a, button").click()
          }
        }
      }
    </script>
    """
  end

  attr :item, :map, required: true

  defp row(assigns) do
    ~H"""
    <Icon.icon :if={@item[:icon]} name={@item[:icon]} class="text-ink-gray-5 size-4 shrink-0" />
    <span class="min-w-0 flex-1 truncate text-left">{@item.label}</span>
    <KeyboardShortcut.keyboard_shortcut :if={@item[:shortcut]} keys={@item[:shortcut]} />
    """
  end

  defp item_class,
    do:
      "fui-text-base text-ink-gray-8 flex w-full items-center gap-2 rounded-4 px-2 py-2 aria-selected:bg-surface-gray-3 hover:bg-surface-gray-2"

  defp nav?(item), do: Enum.any?([:navigate, :patch, :href], &Map.has_key?(item, &1))

  # Evento do servidor (string) ou comando JS; em ambos os casos a paleta fecha antes.
  defp action(%{click: %JS{} = js}, close), do: JS.concat(close, js)
  defp action(%{click: event}, close) when is_binary(event), do: JS.push(close, event)
  defp action(_item, close), do: close

  @doc "Texto minúsculo pesquisável do item (rótulo, grupo e palavras-chave)."
  @spec search_text(map()) :: String.t()
  def search_text(item) do
    [item.label, item[:group], item[:keywords]]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
    |> String.downcase()
  end

  @doc "Agrupa os itens preservando a ordem do primeiro aparecimento: `[{grupo | nil, [item]}]`."
  @spec group_items([map()]) :: [{String.t() | nil, [map()]}]
  def group_items(items) do
    order = items |> Enum.map(& &1[:group]) |> Enum.uniq()
    grouped = Enum.group_by(items, & &1[:group])
    for group <- order, do: {group, Map.fetch!(grouped, group)}
  end
end
