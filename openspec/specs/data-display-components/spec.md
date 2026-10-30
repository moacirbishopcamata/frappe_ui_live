# data-display-components Specification

## Purpose
Fornecer List e Tree como representações reutilizáveis de coleções, com ações e drag-and-drop decididos pelo servidor.

## Requirements

### Requirement: List com colunas e linhas por slot
List SHALL renderizar colunas, linhas, seleção e ações por linha a partir de uma coleção recebida, com slots para células customizadas.

#### Scenario: Coluna customizada
- **WHEN** uma coluna define um slot de célula
- **THEN** cada linha renderiza o slot com os dados da linha

### Requirement: Tree
Tree SHALL renderizar nós aninhados, expansão e recolhimento e item selecionado a partir de dados recebidos.

#### Scenario: Expandir nó
- **WHEN** o usuário expande um nó com filhos
- **THEN** os filhos são exibidos

### Requirement: Drag-and-drop termina no servidor
Quando drag-and-drop estiver habilitado, o drop SHALL enviar ao servidor um evento com identificadores mínimos de origem e destino, sem persistir nada no cliente.

#### Scenario: Reordenar linha
- **WHEN** o usuário solta uma linha em outra posição
- **THEN** um evento com id da linha e posição de destino é enviado ao servidor

### Requirement: Sobrevivência a re-render
Os comportamentos do cliente de List e Tree SHALL continuar funcionando após atualizações de diff do LiveView.

#### Scenario: Atualização de diff
- **WHEN** o servidor atualiza a coleção
- **THEN** drag-and-drop continua operável sem recarregar a página
