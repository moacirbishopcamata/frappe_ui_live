defmodule FrappeUIPhx.Field do
  @moduledoc """
  Costura entre `Phoenix.HTML.FormField` (changeset/Ecto) e os controles.

  `assign_field/1` deriva `id`, `name`, `value` e `errors` do `field` quando
  presente; sem `field`, mantém `name`/`value`/`id` avulsos. Erros só aparecem
  depois que o campo foi usado (`Phoenix.Component.used_input?/1`), igual ao
  `core_components` gerado pelo Phoenix.
  """
  import Phoenix.Component, only: [assign: 3, assign_new: 3]

  alias FrappeUIPhx.ErrorTranslator
  alias Phoenix.HTML.FormField

  @doc """
  Deriva `id`, `name`, `value` e `errors` de um `Phoenix.HTML.FormField` (`field`).

  Precedência quando há `field` (valor explícito do chamador **vence** o do campo, exceto onde indicado):

  | atributo | fonte |
  |---|---|
  | `id` | `id` explícito, senão `field.id` |
  | `name` | sempre o do campo (com `[]` se `multiple: true`) |
  | `value` | `value` explícito, senão `field.value` |
  | `errors` | sempre os do campo, traduzidos, só se o campo foi usado (`used_input?/1`) |

  Sem `field`, `name`/`value`/`errors` ficam como o chamador passou (ou `nil`/`[]`).
  Opções: `multiple: true` acrescenta `[]` ao `name` (MultiSelect, Select múltiplo).
  """
  @spec assign_field(map(), keyword()) :: map()
  def assign_field(assigns, opts \\ [])

  def assign_field(%{field: %FormField{} = field} = assigns, opts) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(:field, nil)
    |> assign(:errors, Enum.map(errors, &ErrorTranslator.translate/1))
    |> assign(:id, assigns[:id] || field.id)
    |> assign(
      :name,
      if(Keyword.get(opts, :multiple, false), do: field.name <> "[]", else: field.name)
    )
    |> assign_new(:value, fn -> field.value end)
  end

  def assign_field(assigns, _opts) do
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
    FrappeUIPhx.Components.Anchor.valid_id!(assigns[:id], component)
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
