defmodule FrappeUIPhx.Components.Breadcrumbs do
  @moduledoc "Trilha de navegação; o último item é a página atual (`aria-current=\"page\"`)."
  use Phoenix.Component

  alias FrappeUIPhx.Texts

  alias FrappeUIPhx.Components.Icon

  attr :class, :any, default: nil
  attr :rest, :global

  slot :item, required: true do
    attr :label, :string, required: true
    attr :navigate, :string
    attr :patch, :string
    attr :href, :string
  end

  def breadcrumbs(assigns) do
    assigns = assign(assigns, :last_index, length(assigns.item) - 1)

    ~H"""
    <nav aria-label={Texts.t(:breadcrumbs)} class={@class} {@rest}>
      <ol class="fui-text-base flex items-center gap-1">
        <%= for {item, index} <- Enum.with_index(@item) do %>
          <li class="flex items-center gap-1">
            <Icon.icon :if={index > 0} name="chevron-right" class="text-ink-gray-4 size-4" />
            <%= if index == @last_index do %>
              <span aria-current="page" class="text-ink-gray-9 fui-text-base-medium">{item.label}</span>
            <% else %>
              <.link
                class="text-ink-gray-5 hover:text-ink-gray-8 transition-colors"
                {Map.take(item, [:navigate, :patch, :href])}
              >
                {item.label}
              </.link>
            <% end %>
          </li>
        <% end %>
      </ol>
    </nav>
    """
  end
end
