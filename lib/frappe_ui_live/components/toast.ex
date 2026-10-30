defmodule FrappeUILive.Components.Toast do
  @moduledoc """
  Container de toasts: mostra mensagens de `flash` (renderizadas no servidor) e
  as enviadas por `FrappeUILive.Toast.put_toast/4` (via hook colocated).
  """
  use Phoenix.Component

  alias FrappeUILive.Components.Icon
  alias Phoenix.LiveView.JS

  attr :id, :string, default: "frappe-ui-toasts"
  attr :flash, :map, default: %{}
  attr :class, :any, default: nil

  def toast_container(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook=".Toast"
      aria-live="polite"
      class={["pointer-events-none fixed top-4 right-4 z-[100] flex w-80 flex-col gap-2", @class]}
    >
      <%= for {kind, message} <- @flash, kind in ~w(info error), message not in [nil, ""] do %>
        <div
          id={"#{@id}-flash-#{kind}"}
          role="status"
          class={[
            "pointer-events-auto fui-text-base flex items-start gap-2 rounded-5 border px-3 py-2.5 shadow-elevation-lg",
            kind == "info" && "bg-surface-green-2 border-outline-green-2 text-ink-green-8",
            kind == "error" && "bg-surface-red-2 border-outline-red-2 text-ink-red-7"
          ]}
        >
          <p class="flex-1">{message}</p>
          <button
            type="button"
            aria-label="Fechar"
            phx-click={JS.push("lv:clear-flash", value: %{key: kind}) |> JS.hide(to: "##{@id}-flash-#{kind}")}
          >
            <Icon.icon name="x" class="size-4" />
          </button>
        </div>
      <% end %>
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".Toast">
      const styles = {
        info: "bg-surface-gray-9 text-ink-base",
        success: "bg-surface-green-2 border-outline-green-2 text-ink-green-8",
        warning: "bg-surface-amber-2 border-outline-amber-2 text-ink-amber-7",
        error: "bg-surface-red-2 border-outline-red-2 text-ink-red-7"
      }

      export default {
        mounted() {
          this.handleEvent("frappe-ui:toast", (payload) => this.show(payload))
        },
        show({kind, message, timeout}) {
          const toast = document.createElement("div")
          toast.setAttribute("role", "status")
          toast.className =
            "pointer-events-auto fui-text-base rounded-5 border border-transparent px-3 py-2.5 shadow-elevation-lg " +
            (styles[kind] || styles.info)
          toast.textContent = message
          this.el.appendChild(toast)
          setTimeout(() => toast.remove(), timeout)
        }
      }
    </script>
    """
  end
end
