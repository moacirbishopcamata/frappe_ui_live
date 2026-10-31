defmodule FrappeUIPhx.Components.Action do
  @moduledoc """
  Único lugar onde se decide "link ou botão" para um item de ação (navegação, abas,
  menus). `NavItem`, `MenuItem` e `Tabs` renderizam por aqui.

  O `item` é o mapa de um slot e usa sempre o mesmo vocabulário:

    * destino: `patch`, `navigate` ou `href` → vira `<.link>`;
    * evento: `click` → `<button phx-click>`, aceitando um nome de evento do servidor
      **ou** um comando `%Phoenix.LiveView.JS{}`;
    * (outros campos, como `label`, `icon` e `theme`, são de quem desenha o item).

  Com `popover_id`, o botão fecha esse popover ao ser acionado.
  """
  use Phoenix.Component

  @link_keys ~w(patch navigate href)a

  @doc "Atributos de destino do item (`patch`/`navigate`/`href`); vazio se for um botão."
  @spec link_attrs(map()) :: map()
  def link_attrs(item), do: Map.take(item, @link_keys)

  @doc "O item navega (tem `patch`, `navigate` ou `href`)?"
  @spec link?(map()) :: boolean()
  def link?(item), do: link_attrs(item) != %{}

  attr :item, :map, required: true, doc: "patch | navigate | href | click"
  attr :class, :any, default: nil
  attr :popover_id, :string, default: nil, doc: "fecha este popover ao acionar (só botões)"
  attr :rest, :global, doc: "role, aria-*, title, data-*"
  slot :inner_block, required: true

  def action(assigns) do
    assigns =
      assigns
      |> assign(:target, link_attrs(assigns.item))
      |> assign(:link?, link?(assigns.item))
      |> assign(:click, Map.get(assigns.item, :click))

    ~H"""
    <.link :if={@link?} class={@class} {@target} {@rest}>{render_slot(@inner_block)}</.link>
    <button
      :if={!@link?}
      type="button"
      phx-click={@click}
      popovertarget={@popover_id}
      popovertargetaction={@popover_id && "hide"}
      class={@class}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end
end
