defmodule FrappeUILive.Components.Combobox do
  @moduledoc "Seleção única com busca. Aceita `field` (Phoenix/Ecto); a escolha é um radio nativo do formulário."
  use Phoenix.Component

  alias FrappeUILive.Components.OptionList
  alias FrappeUILive.Field

  attr :field, Phoenix.HTML.FormField, default: nil
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :options, :list, required: true
  attr :placeholder, :string, default: "Selecione…"
  attr :on_search, :string, default: nil, doc: "evento do servidor para busca remota"
  attr :errors, :list, default: []
  attr :disabled, :boolean, default: false
  attr :class, :any, default: nil

  def combobox(assigns) do
    assigns = Field.assign_field(assigns)

    ~H"""
    <OptionList.option_list
      id={@id}
      name={@name}
      options={@options}
      selected={if @value in [nil, ""], do: [], else: [@value]}
      placeholder={@placeholder}
      on_search={@on_search}
      errors={@errors}
      disabled={@disabled}
      class={@class}
    />
    """
  end
end
