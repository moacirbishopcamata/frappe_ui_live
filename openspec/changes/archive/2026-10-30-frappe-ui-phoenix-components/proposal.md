## Why

Os projetos Phoenix do workspace (`erpnt_saude_sus`, `predman`) reimplementam à mão, em cada app, o que o Frappe UI já resolve: botão, formulário, diálogo, tabela, sidebar, toast, tokens de cor e dark mode. O Frappe UI é a linguagem visual dos apps Frappe/ERPNext (a base do restante do workspace), mas só existe como biblioteca Vue 3, inutilizável num app LiveView sem trazer um SPA inteiro. Uma biblioteca reusável de function components e LiveComponents dá aos apps Phoenix a mesma identidade visual e os mesmos objetos de UI, sem Vue e com o estado autoritativo no servidor.

## What Changes

- Novo pacote Hex/Mix reusável (nome provisório `frappe_ui_live`, módulo raiz `FrappeUILive`) consumível por qualquer app Phoenix 1.8 / LiveView 1.x via dependência `path:` ou Hex.
- Portar os design tokens do Frappe UI (famílias `surface-*`, `ink-*`, `outline-*`, radius, shadows, focus ring, tipografia Inter, dark mode via `data-theme="dark"`) para CSS/Tailwind distribuído pelo pacote.
- Portar os 51 componentes do Frappe UI como function components (stateless) ou `Phoenix.LiveComponent` (stateful), agrupados por categoria: feedback, overlays, navegação/layout, formulários, dados.
- Portar os componentes de charts (Bar, Line, Area, Donut, Funnel, Heatmap etc.) e as moléculas Editor (rich text) e CodeEditor, como hooks JS mínimos que apenas renderizam o que o servidor enviou.
- Interações que `Phoenix.LiveView.JS` cobre (abrir/fechar, toggle, foco) usam `JS.*`; hooks próprios só onde não há equivalente (dialog nativo, popover/posicionamento, charts, editores, drag-and-drop de Tree/List).
- Substituir `FrappeUIProvider`/`toast()`/`dialog.*` por um mecanismo server-side: container de toasts e de diálogos alimentados por assigns/`push_event`.
- Instalador (`mix frappe_ui_live.install`) e guia de integração para apps Phoenix existentes.
- Fora do escopo desta change: data fetching (`useCall`, `useDoc`, `useList` e resources v1). No LiveView o dado já chega pelos assigns, e acoplar a lib ao REST do Frappe a tornaria específica de backend. Os componentes de experimental (Accordion, Calendar, CommandPalette, ListView, Stepper, ThemeSwitcher) entram numa fase posterior.

## Capabilities

### New Capabilities
- `phoenix-package-distribution`: estrutura do pacote Mix, dependências mínimas, instalador, assets (CSS, hooks JS) e como o app host os consome; versionamento e paridade com o Frappe UI 1.x.
- `design-tokens-theming`: tokens semânticos surface/ink/outline, radius, shadows, focus ring, tipografia e dark mode, expostos como preset Tailwind e variáveis CSS.
- `form-components`: Button, FormControl, FormLabel, TextInput, Textarea, Password, Select, Combobox, MultiSelect, Checkbox, Radio, Switch, Slider, Rating, DatePicker, TimePicker, Duration e FileUploader, integrados a `Phoenix.HTML.Form`/`Phoenix.Component.form`.
- `overlay-components`: Dialog, Dropdown, Popover, Tooltip, HoverCard, ContextMenu, BottomSheet, SettingsDialog e KeyboardShortcutsDialog.
- `navigation-layout-components`: Sidebar, SidebarRail, DesktopShell, MobileShell, PageHeader, Breadcrumbs, Tabs, TabButtons, Divider e ScrollArea.
- `feedback-display-components`: Alert, Badge, Progress, Skeleton, Spinner, LoadingText, ErrorMessage, Avatar, Icon, KeyboardShortcut e ItemListRow, mais container de toasts e de diálogos de confirmação.
- `data-display-components`: List e Tree, com ações por objeto e drag-and-drop cujo drop termina em evento para o servidor.
- `chart-components`: família de charts e seus cartões/legendas/tooltips/estados, renderizados a partir de dados enviados pelo servidor.
- `rich-editor-components`: Editor (rich text) e CodeEditor como hooks cujo conteúdo volta ao servidor por evento.
- `component-showcase`: mostruário navegável, com playground por formulário e especificação derivada do código.
- `experimental-components`: Accordion, Calendar, CommandPalette, ListView, Stepper e ThemeSwitcher.
- `ecto-plug-integration`: tipos Ecto, erros de changeset, opções de enum, Plug de tema e entrega de assets.

### Modified Capabilities
<!-- Nenhuma: openspec/specs/ está vazio. -->

## Impact

- **Código novo**: um diretório de pacote Mix na raiz de `V:\PROJECTS` (ex.: `frappe_ui_live/`), com `lib/`, `assets/` e testes. Nenhum código existente é alterado.
- **Apps consumidores** (`erpnt_saude_sus`, `predman`): nenhuma mudança obrigatória. A adoção é incremental e fica para changes próprias, substituindo `core_components.ex` componente a componente.
- **Dependências**: `phoenix_live_view ~> 1.0` e `phoenix ~> 1.8`. JS opcional via esbuild do host: biblioteca de posicionamento (ex.: Floating UI), ECharts, TipTap e CodeMirror, carregados só nos hooks que os usam.
- **Tailwind**: o pacote precisa convergir com a versão de Tailwind do app host. O Frappe UI exige o v3 e substitui as escalas stock de cor, screens, radius e shadows, enquanto Phoenix 1.8 gera apps com Tailwind v4. Essa decisão é central e está tratada em `design.md`.
- **Licença**: o Frappe UI é MIT. O pacote deve preservar a atribuição e o texto da licença original.
