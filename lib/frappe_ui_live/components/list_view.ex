defmodule FrappeUILive.Components.ListView do
  @moduledoc """
  Lista agrupada e recolhível: `group_by` (função linha → rótulo) forma os
  grupos; os recolhidos (`collapsed`) são um assign do servidor e o cabeçalho de
  cada grupo dispara `on_toggle` com `%{"group" => rótulo}`. Colunas por slot,
  como em `list`. Experimental.
  """
  use Phoenix.Component

  alias FrappeUILive.Texts

  alias FrappeUILive.Components.{Icon, Sortable}

  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :group_by, :any, default: nil, doc: "função linha -> rótulo do grupo (nil = sem grupos)"
  attr :collapsed, :list, default: [], doc: "rótulos dos grupos recolhidos"
  attr :on_toggle, :string, default: nil
  attr :row_id, :any, default: &Sortable.default_id/1
  attr :empty_text, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  slot :col, required: true do
    attr :label, :string, required: true
    attr :class, :string
  end

  def list_view(assigns) do
    assigns = assign(assigns, :empty_text, assigns.empty_text || Texts.t(:empty_list))
    assigns = assign(assigns, :groups, groups(assigns.rows, assigns.group_by))

    ~H"""
    <div class={["border-outline-gray-2 overflow-x-auto rounded-5 border", @class]} {@rest}>
      <table id={@id} class="fui-text-base w-full text-left">
        <thead class="bg-surface-gray-1 text-ink-gray-6 fui-text-sm">
          <tr>
            <th :for={col <- @col} class={["px-3 py-2 font-medium", col[:class]]}>{col.label}</th>
          </tr>
        </thead>
        <tbody :for={{label, rows} <- @groups} :key={label || "__sem_grupo__"} data-group={label}>
          <tr :if={label} class="bg-surface-gray-1 border-outline-gray-2 border-t">
            <th colspan="99" class="p-0 text-left font-normal">
              <button
                type="button"
                phx-click={@on_toggle}
                phx-value-group={label}
                aria-expanded={to_string(label not in @collapsed)}
                class="fui-text-sm-medium text-ink-gray-7 flex w-full items-center gap-1.5 px-3 py-1.5"
              >
                <Icon.icon
                  name={if label in @collapsed, do: "chevron-right", else: "chevron-down"}
                  class="size-4"
                />
                {label}
                <span class="text-ink-gray-5 font-normal">({length(rows)})</span>
              </button>
            </th>
          </tr>
          <tr
            :for={row <- rows}
            :key={@row_id.(row)}
            hidden={label in @collapsed}
            class="border-outline-gray-1 hover:bg-surface-gray-1 border-t"
          >
            <td :for={col <- @col} class={["text-ink-gray-8 px-3 py-2", col[:class]]}>
              {render_slot(col, row)}
            </td>
          </tr>
        </tbody>
        <tbody :if={@rows == []}>
          <tr>
            <td colspan="99" class="text-ink-gray-5 px-3 py-6 text-center">{@empty_text}</td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc "Agrupa as linhas preservando a ordem do primeiro aparecimento: `[{rótulo | nil, [linha]}]`."
  @spec groups([term()], (term() -> String.t()) | nil) :: [{String.t() | nil, [term()]}]
  def groups([], _group_by), do: []
  def groups(rows, nil), do: [{nil, rows}]

  def groups(rows, group_by) when is_function(group_by, 1) do
    labels = rows |> Enum.map(&to_string(group_by.(&1))) |> Enum.uniq()
    grouped = Enum.group_by(rows, &to_string(group_by.(&1)))
    for label <- labels, do: {label, Map.fetch!(grouped, label)}
  end
end
