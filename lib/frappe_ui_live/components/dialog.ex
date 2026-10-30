defmodule FrappeUILive.Components.Dialog do
  @moduledoc """
  Diálogo modal sobre `<dialog>` nativo (foco preso, Esc e backdrop pelo navegador).

  Abre/fecha de duas formas, sem estado de negócio no cliente:

    * comando `JS` declarativo: `phx-click={show_dialog("meu-dialog")}` / `hide_dialog/1`;
    * assign do servidor: `open={@mostrar?}` (o hook só reage a *mudanças* do valor).

  Com `on_close="evento"`, o servidor é avisado quando o diálogo fecha por Esc,
  backdrop ou botão, para manter o assign coerente.
  """
  use Phoenix.Component

  alias FrappeUILive.Components.{Anchor, Icon}
  alias FrappeUILive.Contract
  alias Phoenix.LiveView.JS

  @sizes ~w(sm md lg xl 2xl)a
  @size_classes %{
    sm: "max-w-sm",
    md: "max-w-md",
    lg: "max-w-lg",
    xl: "max-w-xl",
    "2xl": "max-w-2xl"
  }

  @doc "Nome do hook colocated do diálogo (para componentes que montam o próprio `<dialog>`)."
  def hook_name, do: "FrappeUILive.Components.Dialog.Dialog"

  attr :id, :string, required: true
  attr :open, :boolean, default: false
  attr :title, :string, default: nil
  attr :size, :atom, default: :lg, values: @sizes

  attr :placement, :atom,
    default: :center,
    values: ~w(center bottom)a,
    doc: "`:bottom` vira uma folha inferior (BottomSheet)"

  attr :on_close, :string, default: nil, doc: "evento enviado ao servidor quando o diálogo fecha"
  attr :close_on_backdrop, :boolean, default: true
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true
  slot :actions

  def dialog(assigns) do
    Anchor.valid_id!(assigns.id, "dialog")

    Contract.require!(assigns.size, @sizes, "dialog size")
    Contract.require!(assigns.placement, ~w(center bottom)a, "dialog placement")

    assigns =
      assign(
        assigns,
        :size_class,
        if(assigns.placement == :bottom,
          do: "max-w-none mb-0 rounded-b-none",
          else: @size_classes[assigns.size]
        )
      )

    ~H"""
    <dialog
      id={@id}
      phx-hook=".Dialog"
      phx-mounted={JS.ignore_attributes(["open"])}
      data-open={to_string(@open)}
      data-on-close={@on_close}
      data-backdrop-close={to_string(@close_on_backdrop)}
      aria-labelledby={@title && "#{@id}-title"}
      class={[
        "bg-surface-elevation-1 text-ink-gray-8 w-full rounded-6 p-0 shadow-elevation-xl backdrop:bg-black/50",
        @placement == :center && "m-auto",
        @placement == :bottom && "mx-auto mt-auto",
        @size_class,
        @class
      ]}
      {@rest}
    >
      <div class="px-4 pt-4 pb-3 sm:px-6">
        <div class="flex items-start justify-between gap-3">
          <h2 :if={@title} id={"#{@id}-title"} class="fui-text-xl-semibold text-ink-gray-9">
            {@title}
          </h2>
          <button
            type="button"
            phx-click={hide_dialog(@id)}
            class="text-ink-gray-5 hover:bg-surface-gray-3 focus-visible:focus-ring ml-auto inline-flex size-7 items-center justify-center rounded-4"
            aria-label="Fechar"
          >
            <Icon.icon name="x" class="size-4" />
          </button>
        </div>
        <div class="fui-text-p-base text-ink-gray-7 mt-3">{render_slot(@inner_block)}</div>
      </div>
      <div :if={@actions != []} class="flex justify-end gap-2 px-4 pb-4 sm:px-6">
        {render_slot(@actions)}
      </div>
    </dialog>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".Dialog">
      export default {
        mounted() {
          this.lastOpen = null
          this.el.addEventListener("fui:dialog-open", () => {
            if (!this.el.open) this.el.showModal()
          })
          this.el.addEventListener("fui:dialog-close", () => {
            if (this.el.open) this.el.close()
          })
          this.el.addEventListener("click", (event) => {
            if (this.el.dataset.backdropClose === "true" && event.target === this.el) this.el.close()
          })
          this.el.addEventListener("close", () => {
            const name = this.el.dataset.onClose
            if (name) this.pushEventTo(this.el, name, {})
          })
          this.sync()
        },
        updated() {
          this.sync()
        },
        sync() {
          const open = this.el.dataset.open === "true"
          if (open === this.lastOpen) return
          this.lastOpen = open
          if (open && !this.el.open) this.el.showModal()
          if (!open && this.el.open) this.el.close()
        }
      }
    </script>
    """
  end

  @doc "Comando `JS` que abre o diálogo `id`."
  @spec show_dialog(String.t()) :: JS.t()
  def show_dialog(id),
    do: JS.dispatch("fui:dialog-open", to: "##{Anchor.valid_id!(id, "dialog")}")

  @doc "Comando `JS` que fecha o diálogo `id`."
  @spec hide_dialog(String.t()) :: JS.t()
  def hide_dialog(id),
    do: JS.dispatch("fui:dialog-close", to: "##{Anchor.valid_id!(id, "dialog")}")
end
