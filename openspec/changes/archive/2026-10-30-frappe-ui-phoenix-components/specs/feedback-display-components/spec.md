## Purpose

Fornecer componentes de status e feedback, e substituir `toast()` e `dialog.*` do Frappe UI por um mecanismo dirigido pelo servidor.

## ADDED Requirements

### Requirement: Componentes de feedback e exibição
A biblioteca SHALL fornecer Alert, Badge, Progress, Skeleton, Spinner, LoadingText, ErrorMessage, Avatar, Icon, KeyboardShortcut e ItemListRow.

#### Scenario: Inventário completo
- **WHEN** a documentação de componentes é consultada
- **THEN** cada componente listado possui um correspondente

### Requirement: Ícones Lucide
Icon e as props de ícone dos demais componentes SHALL aceitar nomes Lucide e renderizar o ícone correspondente.

#### Scenario: Ícone por nome
- **WHEN** um botão recebe o ícone `plus`
- **THEN** o ícone Lucide `plus` é exibido no botão

### Requirement: Toasts dirigidos pelo servidor
A biblioteca SHALL fornecer um container de toasts que exibe mensagens enviadas pelo servidor com variante (info, sucesso, aviso, erro) e que as remove sozinho após um tempo.

#### Scenario: Toast após ação
- **WHEN** o servidor emite um toast de sucesso
- **THEN** o toast aparece e desaparece sem ação do usuário

### Requirement: Confirmação visual de mudança
Ações SHALL poder exibir um indicador transitório de "salvo" que aparece a cada sucesso e some sozinho, sem timer no servidor.

#### Scenario: Salvar duas vezes
- **WHEN** duas ações de salvar têm sucesso em sequência
- **THEN** o indicador reaparece a cada sucesso

### Requirement: Estados de carregamento e vazio
Skeleton e Spinner SHALL ser usáveis para estados de carregamento sem exigir JavaScript.

#### Scenario: Skeleton
- **WHEN** um Skeleton é renderizado
- **THEN** exibe um bloco animado com as dimensões informadas
