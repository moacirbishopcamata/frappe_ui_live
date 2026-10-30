# navigation-layout-components Specification

## Purpose
Fornecer a estrutura de página do Frappe UI (shell, sidebar, cabeçalho, abas) com navegação integrada ao LiveView.

## Requirements

### Requirement: Componentes de navegação e layout
A biblioteca SHALL fornecer Sidebar, SidebarRail, DesktopShell, MobileShell, PageHeader, Breadcrumbs, Tabs, TabButtons, Divider e ScrollArea.

#### Scenario: Inventário completo
- **WHEN** a documentação de componentes é consultada
- **THEN** cada componente listado possui um correspondente

### Requirement: Navegação por LiveView
Itens de Sidebar, Breadcrumbs e Tabs SHALL aceitar `navigate`, `patch` e `href`, com o mesmo comportamento do componente `<.link>` do Phoenix.

#### Scenario: Item com navigate
- **WHEN** o usuário clica em um item com `navigate`
- **THEN** a navegação ocorre sem recarregar a página

### Requirement: Item ativo derivado do estado
O item ativo de Sidebar e Tabs SHALL ser determinado por um assign, não por estado local do cliente.

#### Scenario: Troca de rota
- **WHEN** o servidor atualiza o assign de item ativo
- **THEN** apenas o item correspondente é exibido como ativo

### Requirement: Shell responsivo
DesktopShell e MobileShell SHALL compor Sidebar, cabeçalho e área de conteúdo por slots.

#### Scenario: Conteúdo em slot
- **WHEN** um shell recebe conteúdo no slot principal
- **THEN** o conteúdo é renderizado na área central
