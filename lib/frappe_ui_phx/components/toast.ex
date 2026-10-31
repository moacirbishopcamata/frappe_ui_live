defmodule FrappeUIPhx.Components.Toast do
  @moduledoc """
  Container de toasts: mostra mensagens de `flash` (renderizadas no servidor) e
  as enviadas por `FrappeUIPhx.Toast.put_toast/4` (via hook colocated).
  """
  use Phoenix.Component

  alias FrappeUIPhx.Texts

  alias FrappeUIPhx.Components.Icon
  alias Phoenix.LiveView.JS

  # Paleta única: usada pelos flashes (servidor) e entregue ao hook em `data-styles`.
  @styles %{
    "info" => "bg-surface-gray-10 text-ink-base",
    "success" => "bg-surface-green-2 border-outline-green-2 text-ink-green-8",
    "warning" => "bg-surface-amber-2 border-outline-amber-2 text-ink-amber-7",
    "error" => "bg-surface-red-2 border-outline-red-2 text-ink-red-7"
  }

  @doc "Classes por tipo de toast (`info | success | warning | error`)."
  @spec styles() :: %{String.t() => String.t()}
  def styles, do: @styles

  @doc "Flash `info` do Phoenix é uma confirmação: usa o estilo de sucesso."
  @spec flash_kind(String.t()) :: String.t()
  def flash_kind("info"), do: "success"
  def flash_kind(kind), do: kind

  attr :id, :string, default: "frappe-ui-toasts"
  attr :flash, :map, default: %{}
  attr :class, :any, default: nil
  attr :rest, :global

  def toast_container(assigns) do
    assigns = assign(assigns, :styles, @styles)

    ~H"""
    <div
      id={@id}
      phx-hook=".Toast"
      data-styles={Jason.encode!(@styles)}
      aria-live="polite"
      class={["pointer-events-none fixed top-4 right-4 z-[100] flex w-80 flex-col gap-2", @class]}
      {@rest}
    >
      <%= for {kind, message} <- @flash, kind in ~w(info error), message not in [nil, ""] do %>
        <div
          id={"#{@id}-flash-#{kind}"}
          role="status"
          class={[
            "pointer-events-auto fui-text-base flex items-start gap-2 rounded-5 border px-3 py-2.5 shadow-elevation-lg",
            kind == "info" && @styles[flash_kind("info")],
            kind == "error" && @styles["error"]
          ]}
        >
          <p class="flex-1">{message}</p>
          <button
            type="button"
            aria-label={Texts.t(:close)}
            phx-click={
              JS.push("lv:clear-flash", value: %{key: kind}) |> JS.hide(to: "##{@id}-flash-#{kind}")
            }
          >
            <Icon.icon name="x" class="size-4" />
          </button>
        </div>
      <% end %>
      <%!-- toasts do JS ficam aqui: o LiveView não os remove em patches --%>
      <div id={"#{@id}-stack"} phx-update="ignore" data-toast-stack class="flex flex-col gap-2"></div>
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".Toast">
      export default {
        mounted() {
          this.styles = JSON.parse(this.el.dataset.styles || "{}")
          this.stack = this.el.querySelector("[data-toast-stack]")
          this.timers = new Set()
          this.handleEvent("frappe-ui:toast", (payload) => this.show(payload))
        },
        destroyed() {
          this.timers.forEach((timer) => clearTimeout(timer))
        },
        show({kind, message, timeout}) {
          const toast = document.createElement("div")
          toast.setAttribute("role", "status")
          toast.className =
            "pointer-events-auto fui-text-base rounded-5 border border-transparent px-3 py-2.5 shadow-elevation-lg " +
            (this.styles[kind] || this.styles.info || "")
          toast.textContent = message
          this.stack.appendChild(toast)
          const timer = setTimeout(() => {
            toast.remove()
            this.timers.delete(timer)
          }, timeout)
          this.timers.add(timer)
        }
      }
    </script>
    """
  end
end
