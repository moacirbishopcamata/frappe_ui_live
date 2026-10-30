defmodule FrappeUILive.Components.Icon do
  @moduledoc """
  Ícone por máscara CSS (`lucide-<nome>`), colorido por `text-*`.

  A resolução do nome em classe é delegada a `FrappeUILive.IconResolver`.
  """
  use Phoenix.Component

  attr :name, :string, required: true, doc: ~s(nome Lucide, ex.: "plus")
  attr :class, :any, default: nil
  attr :rest, :global

  def icon(assigns) do
    ~H"""
    <span class={[FrappeUILive.IconResolver.class(@name), @class]} aria-hidden="true" {@rest}></span>
    """
  end
end
