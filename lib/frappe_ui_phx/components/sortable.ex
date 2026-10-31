defmodule FrappeUIPhx.Components.Sortable do
  @moduledoc """
  Lista reordenável por arrastar-e-soltar (HTML5 nativo).

  O cliente só serializa o mínimo (`id`, `to`, `position`) e o drop termina em
  `pushEvent` — a persistência é decisão do servidor (use `move/5` para
  reordenar o assign e salve numa transação). O hook (`Sortable`) é reutilizado
  por `List` e `Tree` pelo nome completo `FrappeUIPhx.Components.Sortable.Sortable`.
  """
  use Phoenix.Component

  @doc """
  Nome do hook colocated, derivado do módulo (renomear o módulo não quebra `List`/`Tree`
  em silêncio; um teste confere que o nome existe no manifesto de hooks).
  """
  def hook_name, do: inspect(__MODULE__) <> ".Sortable"

  @doc """
  Atributos da raiz da lista reordenável (`phx-hook` e o evento de drop). Vazio sem `on_drop`.
  Único dono do protocolo de DOM, usado por `sortable`, `list` e `tree`.
  """
  @spec root_attrs(String.t() | nil) :: map()
  def root_attrs(nil), do: %{}

  def root_attrs(on_drop) when is_binary(on_drop),
    do: %{"phx-hook" => hook_name(), "data-on-drop" => on_drop}

  @doc """
  Atributos de um item arrastável. `parent` identifica o nível (Tree): o hook só aceita
  soltar entre itens com o mesmo `parent`. Vazio quando `enabled?` é falso.
  """
  @spec item_attrs(term(), boolean(), term()) :: map()
  def item_attrs(id, enabled?, parent \\ nil)
  def item_attrs(_id, false, _parent), do: %{}

  def item_attrs(id, true, parent) do
    base = %{"data-sortable-id" => to_string(id), "draggable" => "true"}
    if parent == nil, do: base, else: Map.put(base, "data-sortable-parent", to_string(parent))
  end

  attr :id, :string, required: true
  attr :items, :list, required: true

  attr :item_id, :any,
    default: &__MODULE__.default_id/1,
    doc: "função item -> id (padrão: `item.id`)"

  attr :on_drop, :string,
    required: true,
    doc: "evento do servidor: %{\"id\", \"to\", \"position\"}"

  attr :class, :any, default: nil
  attr :rest, :global
  slot :item, required: true

  def sortable(assigns) do
    ~H"""
    <div id={@id} phx-hook=".Sortable" data-on-drop={@on_drop} class={@class} {@rest}>
      <div
        :for={item <- @items}
        :key={@item_id.(item)}
        {item_attrs(@item_id.(item), true)}
        class="cursor-grab active:cursor-grabbing"
      >
        {render_slot(@item, item)}
      </div>
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".Sortable">
      export default {
        mounted() {
          const root = this.el
          let dragged = null

          root.addEventListener("dragstart", (event) => {
            const item = event.target.closest("[data-sortable-id]")
            if (!item || !root.contains(item)) return
            dragged = item
            event.dataTransfer.effectAllowed = "move"
            event.dataTransfer.setData("text/plain", item.dataset.sortableId)
            item.classList.add("opacity-50")
          })

          root.addEventListener("dragover", (event) => {
            if (!dragged) return
            event.preventDefault()
            event.dataTransfer.dropEffect = "move"
          })

          root.addEventListener("drop", (event) => {
            if (!dragged) return
            event.preventDefault()
            const target = event.target.closest("[data-sortable-id]")
            if (!target || target === dragged) return
            // só reordena entre irmãos (mesmo nível); Tree marca o pai em data-sortable-parent
            if (target.dataset.sortableParent !== dragged.dataset.sortableParent) return
            const rect = target.getBoundingClientRect()
            const after = event.clientY - rect.top > rect.height / 2
            // payload mínimo: só ids e posição; quem persiste é o servidor
            this.pushEventTo(root, root.dataset.onDrop, {
              id: dragged.dataset.sortableId,
              to: target.dataset.sortableId,
              position: after ? "after" : "before"
            })
          })

          root.addEventListener("dragend", () => {
            if (dragged) dragged.classList.remove("opacity-50")
            dragged = null
          })
        }
      }
    </script>
    """
  end

  @doc false
  def default_id(%{id: id}), do: id

  @doc """
  Move o item `id` para antes/depois de `to` (função pura, para o `handle_event` do drop).

  Ids são comparados como texto (vêm do DOM). Id inexistente ou igual ao destino
  devolve a lista inalterada — evento forjado não corrompe a ordem.
  """
  @spec move([term()], (term() -> term()), String.t(), String.t(), :before | :after | String.t()) ::
          [term()]
  def move(items, item_id, id, to, position) do
    id = to_string(id)
    to = to_string(to)
    key = &to_string(item_id.(&1))

    with false <- id == to,
         {[moved], rest} <- Enum.split_with(items, &(key.(&1) == id)),
         idx when is_integer(idx) <- Enum.find_index(rest, &(key.(&1) == to)) do
      at = if position in [:after, "after"], do: idx + 1, else: idx
      List.insert_at(rest, at, moved)
    else
      _ -> items
    end
  end
end
