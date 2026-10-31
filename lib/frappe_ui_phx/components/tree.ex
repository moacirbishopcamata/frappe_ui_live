defmodule FrappeUIPhx.Components.Tree do
  @moduledoc """
  Árvore de nós `%{id, label, icon, children}`. Expansão (`expanded`) e seleção
  (`selected`) são assigns do servidor; cada clique é um evento
  (`on_toggle`/`on_select` com `%{"id" => id}`). Com `on_drop`, os nós de um
  mesmo nível podem ser reordenados por arrastar-e-soltar.
  """
  use Phoenix.Component

  alias FrappeUIPhx.Texts

  alias FrappeUIPhx.Components.{Icon, Sortable}

  attr :id, :string, required: true
  attr :nodes, :list, required: true
  attr :expanded, :list, default: [], doc: "ids dos nós abertos"
  attr :selected_id, :any, default: nil, doc: "id do nó selecionado (comparado como texto)"
  attr :on_toggle, :string, default: nil
  attr :on_select, :string, default: nil
  attr :on_drop, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  def tree(assigns) do
    assigns = assign(assigns, :open, MapSet.new(assigns.expanded, &to_string/1))

    ~H"""
    <ul
      id={@id}
      role="tree"
      {Sortable.root_attrs(@on_drop)}
      class={["fui-text-base", @class]}
      {@rest}
    >
      <.branch
        :for={node <- @nodes}
        node={node}
        open={@open}
        selected={@selected_id}
        tree={Map.take(assigns, [:on_toggle, :on_select, :on_drop])}
        level={0}
      />
    </ul>
    """
  end

  attr :node, :map, required: true
  attr :open, :any, required: true
  attr :selected, :any, required: true
  attr :tree, :map, required: true
  attr :level, :integer, required: true
  attr :parent, :any, default: nil

  defp branch(assigns) do
    node = assigns.node
    children = Map.get(node, :children, [])
    id = to_string(node.id)

    assigns =
      assigns
      |> assign(:children, children)
      |> assign(:node_id, id)
      |> assign(:expandable?, children != [])
      |> assign(:expanded?, id in assigns.open)
      |> assign(:selected?, assigns.selected != nil and to_string(assigns.selected) == id)

    ~H"""
    <li
      role="treeitem"
      aria-expanded={@expandable? && to_string(@expanded?)}
      aria-selected={to_string(@selected?)}
      {Sortable.item_attrs(@node_id, @tree.on_drop != nil, @parent)}
    >
      <div
        class={[
          "flex items-center gap-1 rounded-4 py-1 pr-2",
          @selected? && "bg-surface-gray-3 text-ink-gray-9",
          !@selected? && "text-ink-gray-7 hover:bg-surface-gray-2"
        ]}
        style={"padding-left: #{@level * 16 + 4}px"}
      >
        <button
          :if={@expandable?}
          type="button"
          phx-click={@tree.on_toggle}
          phx-value-id={@node_id}
          aria-label={if @expanded?, do: Texts.t(:collapse), else: Texts.t(:expand)}
          class="hover:bg-surface-gray-3 rounded-3 p-0.5"
        >
          <Icon.icon name={if @expanded?, do: "chevron-down", else: "chevron-right"} class="size-4" />
        </button>
        <span :if={!@expandable?} class="size-5"></span>
        <button
          type="button"
          phx-click={@tree.on_select}
          phx-value-id={@node_id}
          class="flex min-w-0 flex-1 items-center gap-1.5 text-left"
        >
          <Icon.icon :if={@node[:icon]} name={@node[:icon]} class="text-ink-gray-5 size-4 shrink-0" />
          <span class="truncate">{@node.label}</span>
        </button>
      </div>
      <ul :if={@expandable? and @expanded?} role="group">
        <.branch
          :for={child <- @children}
          node={child}
          open={@open}
          selected={@selected}
          tree={@tree}
          level={@level + 1}
          parent={@node_id}
        />
      </ul>
    </li>
    """
  end
end
