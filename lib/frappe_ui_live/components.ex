defmodule FrappeUILive.Components do
  @moduledoc """
  Catálogo de componentes: módulo, categoria e título. Fonte única usada por
  `use FrappeUILive` (imports) e pelo mostruário (navegação e especificações).
  """

  alias FrappeUILive.Components, as: C

  @catalog [
    %{id: :button, module: C.Button, fun: :button, category: :forms, title: "Button"},
    %{id: :text_input, module: C.TextInput, fun: :text_input, category: :forms, title: "TextInput"},
    %{id: :textarea, module: C.Textarea, fun: :textarea, category: :forms, title: "Textarea"},
    %{id: :select, module: C.Select, fun: :select, category: :forms, title: "Select"},
    %{id: :checkbox, module: C.Checkbox, fun: :checkbox, category: :forms, title: "Checkbox"},
    %{id: :switch, module: C.Switch, fun: :switch, category: :forms, title: "Switch"},
    %{id: :form_control, module: C.FormControl, fun: :form_control, category: :forms, title: "FormControl"},
    %{id: :form_label, module: C.FormLabel, fun: :form_label, category: :forms, title: "FormLabel"},
    %{id: :badge, module: C.Badge, fun: :badge, category: :feedback, title: "Badge"},
    %{id: :alert, module: C.Alert, fun: :alert, category: :feedback, title: "Alert"},
    %{id: :progress, module: C.Progress, fun: :progress, category: :feedback, title: "Progress"},
    %{id: :skeleton, module: C.Skeleton, fun: :skeleton, category: :feedback, title: "Skeleton"},
    %{id: :spinner, module: C.Spinner, fun: :spinner, category: :feedback, title: "Spinner"},
    %{id: :avatar, module: C.Avatar, fun: :avatar, category: :feedback, title: "Avatar"},
    %{id: :icon, module: C.Icon, fun: :icon, category: :feedback, title: "Icon"},
    %{id: :error_message, module: C.ErrorMessage, fun: :error_message, category: :feedback, title: "ErrorMessage"},
    %{id: :toast_container, module: C.Toast, fun: :toast_container, category: :feedback, title: "Toast"},
    %{id: :dialog, module: C.Dialog, fun: :dialog, category: :overlays, title: "Dialog"},
    %{id: :dropdown, module: C.Dropdown, fun: :dropdown, category: :overlays, title: "Dropdown"},
    %{id: :tooltip, module: C.Tooltip, fun: :tooltip, category: :overlays, title: "Tooltip"},
    %{id: :tabs, module: C.Tabs, fun: :tabs, category: :navigation, title: "Tabs"},
    %{id: :breadcrumbs, module: C.Breadcrumbs, fun: :breadcrumbs, category: :navigation, title: "Breadcrumbs"},
    %{id: :page_header, module: C.PageHeader, fun: :page_header, category: :navigation, title: "PageHeader"},
    %{id: :divider, module: C.Divider, fun: :divider, category: :navigation, title: "Divider"}
  ]

  @categories [
    forms: "Formulários",
    feedback: "Feedback e exibição",
    overlays: "Overlays",
    navigation: "Navegação e layout"
  ]

  @doc "Entradas do catálogo."
  def catalog, do: @catalog

  @doc "Categorias na ordem de exibição: `[{id, título}]`."
  def categories, do: @categories

  @doc "Entrada do catálogo por `id` (átomo) ou `nil`."
  def get(id) when is_atom(id), do: Enum.find(@catalog, &(&1.id == id))

  @doc "Módulos distintos que definem componentes."
  def modules, do: @catalog |> Enum.map(& &1.module) |> Enum.uniq()
end
