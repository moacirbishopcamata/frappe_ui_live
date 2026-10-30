defmodule FrappeUILive.Components.MultiSelect do
  @moduledoc """
  Seleção múltipla com busca e selos. Envia `name[]` (mais um `""` para permitir
  esvaziar); combine com `FrappeUILive.Ecto.StringList`, que descarta o vazio.
  """
  use Phoenix.Component

  alias FrappeUILive.Components.OptionList
  alias FrappeUILive.Field

  attr :field, Phoenix.HTML.FormField, default: nil
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any, doc: "lista de valores selecionados"
  attr :options, :list, required: true
  attr :placeholder, :string, default: nil
  attr :on_search, :string, default: nil
  attr :errors, :list, default: []
  attr :disabled, :boolean, default: false
  attr :form, :string, default: nil
  attr :required, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global

  def multi_select(assigns) do
    assigns =
      assigns
      |> Map.put(:multiple, true)
      |> Field.assign_field()
      |> Field.require_id!("multi_select")

    ~H"""
    <OptionList.option_list
      id={@id}
      name={@name}
      options={@options}
      selected={List.wrap(@value)}
      multiple
      placeholder={@placeholder}
      on_search={@on_search}
      errors={@errors}
      disabled={@disabled}
      class={@class}
      form={@form}
      required={@required}
      {@rest}
    />
    """
  end
end
