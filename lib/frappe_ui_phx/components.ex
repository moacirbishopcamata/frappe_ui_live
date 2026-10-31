defmodule FrappeUIPhx.Components do
  @moduledoc """
  Catálogo de componentes: módulo, função, categoria e título. Fonte única usada
  por `use FrappeUIPhx` (imports), pelo mostruário (navegação e especificação)
  e pelo teste que garante que nenhum componente público fica sem catálogo.
  """

  alias FrappeUIPhx.Charts, as: Ch
  alias FrappeUIPhx.Components, as: C

  @catalog [
    # Formulários
    %{id: :button, module: C.Button, fun: :button, category: :forms, title: "Button"},
    %{
      id: :text_input,
      module: C.TextInput,
      fun: :text_input,
      category: :forms,
      title: "TextInput"
    },
    %{id: :textarea, module: C.Textarea, fun: :textarea, category: :forms, title: "Textarea"},
    %{id: :password, module: C.Password, fun: :password, category: :forms, title: "Password"},
    %{
      id: :pin_code,
      module: C.PinCode,
      fun: :pin_code,
      category: :forms,
      title: "PinCode"
    },
    %{id: :select, module: C.Select, fun: :select, category: :forms, title: "Select"},
    %{id: :combobox, module: C.Combobox, fun: :combobox, category: :forms, title: "Combobox"},
    %{
      id: :multi_select,
      module: C.MultiSelect,
      fun: :multi_select,
      category: :forms,
      title: "MultiSelect"
    },
    %{id: :checkbox, module: C.Checkbox, fun: :checkbox, category: :forms, title: "Checkbox"},
    %{
      id: :radio_group,
      module: C.RadioGroup,
      fun: :radio_group,
      category: :forms,
      title: "Radio"
    },
    %{id: :switch, module: C.Switch, fun: :switch, category: :forms, title: "Switch"},
    %{id: :slider, module: C.Slider, fun: :slider, category: :forms, title: "Slider"},
    %{id: :rating, module: C.Rating, fun: :rating, category: :forms, title: "Rating"},
    %{
      id: :date_picker,
      module: C.DatePicker,
      fun: :date_picker,
      category: :forms,
      title: "DatePicker"
    },
    %{
      id: :time_picker,
      module: C.TimePicker,
      fun: :time_picker,
      category: :forms,
      title: "TimePicker"
    },
    %{id: :duration, module: C.Duration, fun: :duration, category: :forms, title: "Duration"},
    %{
      id: :file_uploader,
      module: C.FileUploader,
      fun: :file_uploader,
      category: :forms,
      title: "FileUploader"
    },
    %{
      id: :form_control,
      module: C.FormControl,
      fun: :form_control,
      category: :forms,
      title: "FormControl"
    },
    %{
      id: :form_label,
      module: C.FormLabel,
      fun: :form_label,
      category: :forms,
      title: "FormLabel"
    },
    # Feedback e exibição
    %{id: :badge, module: C.Badge, fun: :badge, category: :feedback, title: "Badge"},
    %{id: :alert, module: C.Alert, fun: :alert, category: :feedback, title: "Alert"},
    %{id: :progress, module: C.Progress, fun: :progress, category: :feedback, title: "Progress"},
    %{id: :skeleton, module: C.Skeleton, fun: :skeleton, category: :feedback, title: "Skeleton"},
    %{id: :spinner, module: C.Spinner, fun: :spinner, category: :feedback, title: "Spinner"},
    %{
      id: :loading_text,
      module: C.LoadingText,
      fun: :loading_text,
      category: :feedback,
      title: "LoadingText"
    },
    %{id: :avatar, module: C.Avatar, fun: :avatar, category: :feedback, title: "Avatar"},
    %{
      id: :dice_bear_avatar,
      module: C.DiceBearAvatar,
      fun: :dice_bear_avatar,
      category: :feedback,
      title: "DiceBearAvatar"
    },
    %{id: :icon, module: C.Icon, fun: :icon, category: :feedback, title: "Icon"},
    %{
      id: :keyboard_shortcut,
      module: C.KeyboardShortcut,
      fun: :keyboard_shortcut,
      category: :feedback,
      title: "KeyboardShortcut"
    },
    %{
      id: :item_list_row,
      module: C.ItemListRow,
      fun: :item_list_row,
      category: :feedback,
      title: "ItemListRow"
    },
    %{
      id: :saved_indicator,
      module: C.SavedIndicator,
      fun: :saved_indicator,
      category: :feedback,
      title: "SavedIndicator"
    },
    %{
      id: :error_message,
      module: C.ErrorMessage,
      fun: :error_message,
      category: :feedback,
      title: "ErrorMessage"
    },
    %{
      id: :toast_container,
      module: C.Toast,
      fun: :toast_container,
      category: :feedback,
      title: "Toast"
    },
    # Overlays
    %{id: :dialog, module: C.Dialog, fun: :dialog, category: :overlays, title: "Dialog"},
    %{
      id: :bottom_sheet,
      module: C.BottomSheet,
      fun: :bottom_sheet,
      category: :overlays,
      title: "BottomSheet"
    },
    %{
      id: :settings_dialog,
      module: C.SettingsDialog,
      fun: :settings_dialog,
      category: :overlays,
      title: "SettingsDialog"
    },
    %{
      id: :keyboard_shortcuts_dialog,
      module: C.KeyboardShortcutsDialog,
      fun: :keyboard_shortcuts_dialog,
      category: :overlays,
      title: "KeyboardShortcutsDialog"
    },
    %{id: :dropdown, module: C.Dropdown, fun: :dropdown, category: :overlays, title: "Dropdown"},
    %{id: :popover, module: C.Popover, fun: :popover, category: :overlays, title: "Popover"},
    %{
      id: :context_menu,
      module: C.ContextMenu,
      fun: :context_menu,
      category: :overlays,
      title: "ContextMenu"
    },
    %{
      id: :hover_card,
      module: C.HoverCard,
      fun: :hover_card,
      category: :overlays,
      title: "HoverCard"
    },
    %{id: :tooltip, module: C.Tooltip, fun: :tooltip, category: :overlays, title: "Tooltip"},
    # Navegação e layout
    %{id: :tabs, module: C.Tabs, fun: :tabs, category: :navigation, title: "Tabs"},
    %{
      id: :tab_buttons,
      module: C.TabButtons,
      fun: :tab_buttons,
      category: :navigation,
      title: "TabButtons"
    },
    %{
      id: :breadcrumbs,
      module: C.Breadcrumbs,
      fun: :breadcrumbs,
      category: :navigation,
      title: "Breadcrumbs"
    },
    %{
      id: :page_header,
      module: C.PageHeader,
      fun: :page_header,
      category: :navigation,
      title: "PageHeader"
    },
    %{id: :sidebar, module: C.Sidebar, fun: :sidebar, category: :navigation, title: "Sidebar"},
    %{
      id: :sidebar_rail,
      module: C.SidebarRail,
      fun: :sidebar_rail,
      category: :navigation,
      title: "SidebarRail"
    },
    %{
      id: :desktop_shell,
      module: C.DesktopShell,
      fun: :desktop_shell,
      category: :navigation,
      title: "DesktopShell"
    },
    %{
      id: :mobile_shell,
      module: C.MobileShell,
      fun: :mobile_shell,
      category: :navigation,
      title: "MobileShell"
    },
    %{
      id: :scroll_area,
      module: C.ScrollArea,
      fun: :scroll_area,
      category: :navigation,
      title: "ScrollArea"
    },
    %{id: :divider, module: C.Divider, fun: :divider, category: :navigation, title: "Divider"},
    # Dados
    %{id: :list, module: C.List, fun: :list, category: :molecules, title: "List"},
    %{id: :tree, module: C.Tree, fun: :tree, category: :data, title: "Tree"},
    %{id: :sortable, module: C.Sortable, fun: :sortable, category: :data, title: "Sortable"},
    # Charts
    %{id: :bar_chart, module: Ch.Bar, fun: :bar_chart, category: :charts, title: "BarChart"},
    %{id: :line_chart, module: Ch.Line, fun: :line_chart, category: :charts, title: "LineChart"},
    %{id: :area_chart, module: Ch.Line, fun: :area_chart, category: :charts, title: "AreaChart"},
    %{
      id: :donut_chart,
      module: Ch.Donut,
      fun: :donut_chart,
      category: :charts,
      title: "DonutChart"
    },
    %{
      id: :percentage_bar_chart,
      module: Ch.Proportion,
      fun: :percentage_bar_chart,
      category: :charts,
      title: "PercentageBarChart"
    },
    %{
      id: :funnel_chart,
      module: Ch.Proportion,
      fun: :funnel_chart,
      category: :charts,
      title: "FunnelChart"
    },
    %{
      id: :heatmap_chart,
      module: Ch.Matrix,
      fun: :heatmap_chart,
      category: :charts,
      title: "HeatmapChart"
    },
    %{
      id: :calendar_heatmap_chart,
      module: Ch.Matrix,
      fun: :calendar_heatmap_chart,
      category: :charts,
      title: "CalendarHeatmapChart"
    },
    %{
      id: :scatter_chart,
      module: Ch.Scatter,
      fun: :scatter_chart,
      category: :charts,
      title: "ScatterChart"
    },
    %{
      id: :sankey_chart,
      module: Ch.Sankey,
      fun: :sankey_chart,
      category: :charts,
      title: "SankeyChart"
    },
    %{
      id: :number_card,
      module: Ch.NumberCard,
      fun: :number_card,
      category: :charts,
      title: "NumberCard"
    },
    %{
      id: :chart_card,
      module: Ch.ChartCard,
      fun: :chart_card,
      category: :charts,
      title: "ChartCard"
    },
    %{
      id: :chart_legend,
      module: Ch.Legend,
      fun: :chart_legend,
      category: :charts,
      title: "ChartLegend"
    },
    %{
      id: :chart_tooltip,
      module: Ch.Tooltip,
      fun: :chart_tooltip,
      category: :charts,
      title: "ChartTooltip"
    },
    %{
      id: :chart_frame,
      module: Ch.Frame,
      fun: :chart_frame,
      category: :charts,
      title: "ChartStates"
    },
    # Experimental (API ainda pode mudar)
    %{
      id: :accordion,
      module: C.Accordion,
      fun: :accordion,
      category: :experimental,
      title: "Accordion"
    },
    %{
      id: :calendar,
      module: C.Calendar,
      fun: :calendar,
      category: :experimental,
      title: "Calendar"
    },
    %{
      id: :command_palette,
      module: C.CommandPalette,
      fun: :command_palette,
      category: :experimental,
      title: "CommandPalette"
    },
    %{
      id: :list_view,
      module: C.ListView,
      fun: :list_view,
      category: :experimental,
      title: "ListView"
    },
    %{id: :stepper, module: C.Stepper, fun: :stepper, category: :experimental, title: "Stepper"},
    %{
      id: :theme_switcher,
      module: C.ThemeSwitcher,
      fun: :theme_switcher,
      category: :experimental,
      title: "ThemeSwitcher"
    },
    # Moléculas (continuação)
    %{id: :editor, module: C.Editor, fun: :editor, category: :molecules, title: "Editor"},
    %{
      id: :code_editor,
      module: C.CodeEditor,
      fun: :code_editor,
      category: :molecules,
      title: "CodeEditor"
    }
  ]

  @categories [
    forms: "Formulários",
    feedback: "Feedback e exibição",
    overlays: "Overlays",
    navigation: "Navegação e layout",
    data: "Dados",
    charts: "Charts",
    molecules: "Moléculas",
    experimental: "Experimental"
  ]

  # Blocos de construção públicos que não são componentes de catálogo (sem exemplo isolado).
  @internal [
    {C.Action, :action},
    {C.NavItem, :nav_item},
    {C.MenuItem, :menu_item},
    {C.OptionList, :option_list},
    {Ch.Axes, :axes}
  ]

  # Funções auxiliares (não-componentes) importadas junto do módulo.
  @helpers %{C.Dialog => [show_dialog: 1, hide_dialog: 1]}

  @doc "Entradas do catálogo."
  def catalog, do: @catalog

  @doc "Categorias na ordem de exibição: `[{id, título}]`."
  def categories, do: @categories

  @doc "Entrada do catálogo por `id` (átomo) ou `nil`."
  def get(id) when is_atom(id), do: Enum.find(@catalog, &(&1.id == id))

  @doc "Módulos distintos que definem componentes do catálogo."
  def modules, do: @catalog |> Enum.map(& &1.module) |> Enum.uniq()

  @doc "Blocos de construção públicos fora do catálogo: `[{módulo, função}]`."
  def internal, do: @internal

  @doc """
  Funções importadas por `use FrappeUIPhx` de cada módulo: só os componentes do
  catálogo (e helpers como `show_dialog/1`), nunca funções utilitárias do módulo.
  """
  @spec imports() :: [{module(), [{atom(), 1}]}]
  def imports do
    @catalog
    |> Enum.group_by(& &1.module, &{&1.fun, 1})
    |> Enum.map(fn {module, funs} ->
      {module, Enum.uniq(funs ++ Map.get(@helpers, module, []))}
    end)
  end
end
