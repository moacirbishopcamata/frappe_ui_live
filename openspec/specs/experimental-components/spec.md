# experimental-components Specification

## Purpose
Disponibilizar os componentes experimentais do Frappe UI (cuja API ainda pode mudar) com o mesmo modelo dos demais: estado decidido no servidor, JS só para o que é efêmero de UI.

## Requirements

### Requirement: Componentes experimentais disponíveis
A biblioteca SHALL fornecer Accordion, Calendar, CommandPalette, ListView, Stepper e ThemeSwitcher, identificados como experimentais no catálogo e no mostruário.

#### Scenario: Inventário completo
- **WHEN** a categoria Experimental do mostruário é consultada
- **THEN** cada componente listado possui página com playground e especificação

### Requirement: Accordion
O Accordion SHALL expor seções recolhíveis acessíveis por teclado, com abertura exclusiva por padrão e abertura múltipla opcional, e SHALL permitir que o servidor defina quais seções começam abertas.

#### Scenario: Exclusividade
- **WHEN** o Accordion não é múltiplo e o usuário abre uma seção
- **THEN** a seção anteriormente aberta fecha

#### Scenario: Ids repetidos
- **WHEN** duas seções têm o mesmo id
- **THEN** a renderização falha com erro de contrato

### Requirement: Calendar de eventos
O Calendar SHALL exibir um mês com eventos por dia, e o mês exibido e o dia selecionado SHALL ser decididos pelo servidor; navegar, voltar a hoje e escolher um dia SHALL ser eventos.

#### Scenario: Muitos eventos no dia
- **WHEN** um dia tem mais eventos do que cabem
- **THEN** são exibidos alguns e um contador dos restantes

#### Scenario: Data de evento inválida
- **WHEN** um evento tem data inválida
- **THEN** o evento é descartado sem erro

### Requirement: CommandPalette
A CommandPalette SHALL abrir por comando e por atalho de teclado, filtrar itens pelo texto digitado (rótulo, grupo e palavras-chave), permitir navegar com setas e acionar com Enter, e SHALL fechar antes de executar o item escolhido.

#### Scenario: Filtro sem resultado
- **WHEN** o texto digitado não corresponde a nenhum item
- **THEN** a mensagem de vazio é exibida e os grupos ficam ocultos

### Requirement: ListView agrupada
O ListView SHALL agrupar linhas por uma função, preservar a ordem de primeira aparição dos grupos e permitir recolher grupos, sendo os grupos recolhidos decididos pelo servidor.

#### Scenario: Grupo recolhido
- **WHEN** o servidor marca um grupo como recolhido
- **THEN** as linhas do grupo ficam ocultas e o cabeçalho indica o estado

#### Scenario: Grupo inexistente
- **WHEN** chega um evento para recolher um grupo que não existe
- **THEN** o estado não muda

### Requirement: Stepper
O Stepper SHALL derivar o estado de cada etapa (concluída, atual, futura) da etapa atual informada pelo servidor, e SHALL permitir voltar às etapas concluídas por evento quando configurado.

#### Scenario: Etapa atual fora do intervalo
- **WHEN** a etapa atual é maior que o número de etapas
- **THEN** a renderização falha com erro de contrato

### Requirement: ThemeSwitcher
O ThemeSwitcher SHALL oferecer as opções de tema claro e escuro, marcar a opção ativa e aplicar a escolha por requisição, de forma que a preferência seja lembrada.

#### Scenario: Tema desconhecido
- **WHEN** o tema atual informado não é claro nem escuro
- **THEN** a renderização falha com erro de contrato
