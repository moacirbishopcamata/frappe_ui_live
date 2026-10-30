## Purpose

Fornecer camadas flutuantes (diálogos, menus, popovers) cujo estado de abertura é decidido pelo servidor ou por comandos `JS` declarativos.

## ADDED Requirements

### Requirement: Componentes de overlay
A biblioteca SHALL fornecer Dialog, Dropdown, Popover, Tooltip, HoverCard, ContextMenu, BottomSheet, SettingsDialog e KeyboardShortcutsDialog.

#### Scenario: Inventário completo
- **WHEN** a documentação de componentes é consultada
- **THEN** cada overlay listado possui um componente correspondente

### Requirement: Abertura e fechamento controláveis
Dialog SHALL abrir e fechar tanto por comando `JS` no cliente quanto por assign do servidor, e SHALL fechar com Esc e clique fora, a menos que desabilitado.

#### Scenario: Fechar com Esc
- **WHEN** um Dialog está aberto e o usuário pressiona Esc
- **THEN** o Dialog fecha e o foco retorna ao elemento que o abriu

### Requirement: Foco preso no diálogo modal
Enquanto um Dialog modal estiver aberto, o foco SHALL permanecer dentro dele.

#### Scenario: Tab no último elemento
- **WHEN** o foco está no último elemento focável do Dialog e o usuário pressiona Tab
- **THEN** o foco vai ao primeiro elemento focável do Dialog

### Requirement: Posicionamento de flutuantes
Dropdown, Popover, Tooltip e HoverCard SHALL posicionar-se junto ao gatilho e inverter de lado quando faltar espaço na viewport.

#### Scenario: Pouco espaço abaixo
- **WHEN** um Dropdown é aberto perto da borda inferior da janela
- **THEN** o painel é exibido acima do gatilho

### Requirement: Estado não persistido no cliente
Overlays SHALL NOT guardar estado de negócio no cliente; o resultado de qualquer ação SHALL ser enviado ao servidor por evento.

#### Scenario: Item de menu
- **WHEN** o usuário escolhe um item de Dropdown com evento definido
- **THEN** o evento é enviado ao servidor e o menu fecha
