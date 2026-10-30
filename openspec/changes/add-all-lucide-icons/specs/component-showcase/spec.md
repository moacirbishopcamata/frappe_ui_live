## ADDED Requirements

### Requirement: Página de ícones
O mostruário SHALL ter uma página que lista todos os ícones Lucide com busca por nome ou tag e controles ao vivo das propriedades de tamanho, cor e traço.

#### Scenario: Busca
- **WHEN** o usuário digita um termo na busca
- **THEN** a grade mostra somente os ícones cujo nome ou tags contêm o termo, e informa quando não há resultado

#### Scenario: Propriedades ao vivo
- **WHEN** o usuário altera tamanho, cor ou espessura do traço
- **THEN** todos os ícones visíveis refletem o novo valor

#### Scenario: Detalhe do ícone
- **WHEN** o usuário escolhe um ícone
- **THEN** o mostruário exibe seu nome, tags, aliases e o trecho de código para usá-lo
