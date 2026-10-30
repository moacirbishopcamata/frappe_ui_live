defmodule FrappeUILive.Field do
  @moduledoc """
  Costura entre `Phoenix.HTML.FormField` (changeset/Ecto) e os controles.

  `assign_field/1` deriva `id`, `name`, `value` e `errors` do `field` quando
  presente; sem `field`, mantém `name`/`value`/`id` avulsos. Erros só aparecem
  depois que o campo foi usado (`Phoenix.Component.used_input?/1`), igual ao
  `core_components` gerado pelo Phoenix.
  """
  import Phoenix.Component, only: [assign: 3, assign_new: 3]

  alias FrappeUILive.ErrorTranslator
  alias Phoenix.HTML.FormField

  @spec assign_field(Phoenix.LiveView.Socket.assigns()) :: Phoenix.LiveView.Socket.assigns()
  def assign_field(%{field: %FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(:field, nil)
    |> assign(:errors, Enum.map(errors, &ErrorTranslator.translate/1))
    |> assign(:id, assigns[:id] || field.id)
    |> assign(:name, if(assigns[:multiple], do: field.name <> "[]", else: field.name))
    |> assign_new(:value, fn -> field.value end)
  end

  def assign_field(assigns) do
    assigns
    |> assign_new(:value, fn -> nil end)
    |> assign_new(:name, fn -> nil end)
    |> assign(:errors, assigns[:errors] || [])
  end

  @doc """
  Garante um `id` DOM válido (de `id` ou do `field`) em componentes que o usam em
  hooks, popovers ou seletores. Falha alto, nomeando o componente.
  """
  @spec require_id!(map(), String.t()) :: map()
  def require_id!(assigns, component) do
    FrappeUILive.Components.Anchor.valid_id!(assigns[:id], component)
    assigns
  end

  @doc "Mensagens de erro já traduzidas de um `FormField`, só se o campo foi usado."
  @spec errors(FormField.t()) :: [String.t()]
  def errors(%FormField{} = field) do
    if Phoenix.Component.used_input?(field),
      do: Enum.map(field.errors, &ErrorTranslator.translate/1),
      else: []
  end
end
