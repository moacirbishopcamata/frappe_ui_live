defmodule FrappeUILive.Components.List do
  @moduledoc """
  Tabela de objetos: colunas por slot (`:col`), ações por linha (`:action`),
  seleção por checkbox e reordenação por arrastar-e-soltar. O estado
  (`selected`, ordem de `rows`) vive no servidor; cada interação é um evento.

      <.list id="pedidos" rows={@pedidos} selected={@selected} on_select="select" on_drop="reorder">
        <:col :let={pedido} label="Número">{pedido.numero}</:col>
        <:action :let={pedido}><.button label="Abrir" navigate={~p"/pedidos/\#{pedido.id}"} /></:action>
      </.list>

  Em apps que já têm `list/1` no `core_components`, use `use FrappeUILive, except: [list: 1]`.
  """
  use Phoenix.Component

  alias FrappeUILive.Components.Sortable

  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: &Sortable.default_id/1
  attr :selected, :list, default: nil, doc: "ids selecionados; `nil` desliga a coluna de seleção"
  attr :on_select, :string, default: nil, doc: "evento do servidor: %{\"id\" => id}"

  attr :on_drop, :string,
    default: nil,
    doc: "liga o arrastar-e-soltar; evento: %{\"id\", \"to\", \"position\"}"

  attr :empty_text, :string, default: "Nada por aqui."
  attr :class, :any, default: nil

  slot :col, required: true do
    attr :label, :string, required: true
    attr :class, :string
  end

  slot :action

  def list(assigns) do
    assigns =
      assigns
      |> assign(:selectable?, assigns.selected != nil)
      |> assign(:sortable?, assigns.on_drop != nil)

    ~H"""
    <div class={["border-outline-gray-2 overflow-x-auto rounded-5 border", @class]}>
      <table class="fui-text-base w-full text-left">
        <thead class="bg-surface-gray-1 text-ink-gray-6 fui-text-sm">
          <tr>
            <th :if={@sortable?} class="w-6 px-2"><span class="sr-only">Reordenar</span></th>
            <th :if={@selectable?} class="w-8 px-3"><span class="sr-only">Selecionar</span></th>
            <th :for={col <- @col} class={["px-3 py-2 font-medium", col[:class]]}>{col.label}</th>
            <th :if={@action != []} class="px-3 py-2"><span class="sr-only">Ações</span></th>
          </tr>
        </thead>
        <tbody
          id={@id}
          phx-hook={@sortable? && Sortable.hook_name()}
          data-on-drop={@on_drop}
        >
          <tr
            :for={row <- @rows}
            :key={@row_id.(row)}
            id={"#{@id}-#{@row_id.(row)}"}
            data-sortable-id={@sortable? && @row_id.(row)}
            draggable={@sortable? && "true"}
            aria-selected={
              @selectable? && to_string(to_string(@row_id.(row)) in Enum.map(@selected, &to_string/1))
            }
            class="border-outline-gray-1 hover:bg-surface-gray-1 border-t"
          >
            <td :if={@sortable?} class="text-ink-gray-4 cursor-grab px-2" aria-hidden="true">⋮⋮</td>
            <td :if={@selectable?} class="px-3">
              <input
                type="checkbox"
                checked={to_string(@row_id.(row)) in Enum.map(@selected, &to_string/1)}
                phx-click={@on_select}
                phx-value-id={@row_id.(row)}
                aria-label="Selecionar linha"
                class="border-outline-gray-4 checked:bg-surface-gray-10 checked:border-surface-gray-10 size-4 rounded-1 border"
              />
            </td>
            <td :for={col <- @col} class={["text-ink-gray-8 px-3 py-2", col[:class]]}>
              {render_slot(col, row)}
            </td>
            <td :if={@action != []} class="px-3 py-2 text-right">
              <div class="flex items-center justify-end gap-1">{render_slot(@action, row)}</div>
            </td>
          </tr>
          <tr :if={@rows == []}>
            <td colspan="99" class="text-ink-gray-5 px-3 py-6 text-center">{@empty_text}</td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end
end
