defmodule FrappeUIPhx.Components.Accordion do
  @moduledoc """
  Seções recolhíveis sobre `<details>` nativo (teclado e leitores de tela de graça).
  Por padrão só uma seção fica aberta por vez (atributo `name` do HTML, agrupado
  pelo `id`); com `multiple`, qualquer combinação. `open` no item abre desde o servidor.

  Experimental: o estado aberto/fechado é efêmero de UI e não volta ao servidor.
  """
  use Phoenix.Component

  alias FrappeUIPhx.Components.{Anchor, Icon}
  alias FrappeUIPhx.Contract

  attr :id, :string, required: true
  attr :multiple, :boolean, default: false, doc: "permite várias seções abertas ao mesmo tempo"
  attr :class, :any, default: nil
  attr :rest, :global

  slot :item, required: true do
    attr :id, :string, required: true
    attr :title, :string, required: true
    attr :open, :boolean
  end

  def accordion(assigns) do
    Anchor.valid_id!(assigns.id, "accordion")
    ids = Enum.map(assigns.item, & &1.id)
    Contract.ensure!(ids == Enum.uniq(ids), "accordion: ids dos itens devem ser únicos")

    ~H"""
    <div
      id={@id}
      class={["border-outline-gray-2 divide-outline-gray-2 divide-y rounded-5 border", @class]}
      {@rest}
    >
      <details
        :for={item <- @item}
        :key={item.id}
        id={"#{@id}-#{item.id}"}
        name={!@multiple && @id}
        open={item[:open]}
        class="group"
      >
        <summary class="fui-text-base-medium text-ink-gray-8 hover:bg-surface-gray-1 flex cursor-pointer list-none items-center justify-between px-4 py-3 [&::-webkit-details-marker]:hidden">
          {item.title}
          <Icon.icon
            name="chevron-down"
            class="text-ink-gray-5 size-4 transition-transform group-open:rotate-180"
          />
        </summary>
        <div class="fui-text-p-base text-ink-gray-7 px-4 pb-4">{render_slot(item)}</div>
      </details>
    </div>
    """
  end
end
