defmodule FrappeUILive.Components.FormControl do
  @moduledoc """
  Rótulo + controle + descrição + erros, escolhendo o controle por `type`.

  `type`: `"textarea"`, `"select"`, `"checkbox"`, `"switch"` ou qualquer tipo de
  `FrappeUILive.Components.TextInput`. Erros vêm do `field` (changeset) e só
  aparecem depois que o campo foi usado.
  """
  use Phoenix.Component

  alias FrappeUILive.Components.{
    Checkbox,
    ErrorMessage,
    FormLabel,
    Select,
    Switch,
    TextInput,
    Textarea
  }

  alias FrappeUILive.Field

  attr :field, Phoenix.HTML.FormField, required: true
  attr :type, :string, default: "text"
  attr :label, :string, default: nil
  attr :description, :string, default: nil
  attr :options, :list, default: []
  attr :prompt, :string, default: nil
  attr :variant, :atom, default: :subtle
  attr :size, :atom, default: :sm

  attr :required, :boolean,
    default: false,
    doc: "espelha a regra `validate_required` do changeset"

  attr :disabled, :boolean, default: false
  attr :class, :any, default: nil

  attr :rest, :global,
    include: ~w(autocomplete maxlength minlength min max pattern placeholder rows step)

  def form_control(assigns) do
    field = assigns.field

    assigns =
      assigns
      |> assign(:errors, Field.errors(field))
      |> assign(:control_id, field.id)

    ~H"""
    <div class={["space-y-1.5", @class]}>
      <FormLabel.form_label
        :if={@label && @type not in ~w(checkbox switch)}
        for={@control_id}
        required={@required}
      >
        {@label}
      </FormLabel.form_label>

      {control(assigns)}

      <p :if={@description} class="fui-text-p-sm text-ink-gray-5">{@description}</p>
      <ErrorMessage.error_message message={@errors} id={"#{@control_id}-error"} />
    </div>
    """
  end

  defp control(%{type: "textarea"} = assigns) do
    ~H"""
    <Textarea.textarea
      field={@field}
      variant={@variant}
      size={@size}
      disabled={@disabled}
      required={@required}
      {@rest}
    />
    """
  end

  defp control(%{type: "select"} = assigns) do
    ~H"""
    <Select.select
      field={@field}
      options={@options}
      variant={@variant}
      size={@size}
      disabled={@disabled}
      required={@required}
      prompt={@prompt}
    />
    """
  end

  defp control(%{type: "checkbox"} = assigns) do
    ~H"""
    <Checkbox.checkbox field={@field} label={@label} disabled={@disabled} />
    """
  end

  defp control(%{type: "switch"} = assigns) do
    ~H"""
    <Switch.switch field={@field} label={@label} disabled={@disabled} />
    """
  end

  defp control(assigns) do
    ~H"""
    <TextInput.text_input
      field={@field}
      type={@type}
      variant={@variant}
      size={@size}
      disabled={@disabled}
      required={@required}
      {@rest}
    />
    """
  end
end
