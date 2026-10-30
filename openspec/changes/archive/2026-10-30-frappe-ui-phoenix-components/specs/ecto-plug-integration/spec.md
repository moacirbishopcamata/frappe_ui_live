## Purpose

Integrar a biblioteca ao ecossistema do app Phoenix (Ecto, changesets, Plug, sessão), para que valores de formulário, erros e tema atravessem as camadas sem código de cola no app.

## ADDED Requirements

### Requirement: Tipos Ecto para controles do Frappe UI
A biblioteca SHALL fornecer tipos Ecto opcionais para os valores dos controles: duração (texto digitado ⇄ segundos), avaliação (inteiro de 0 a um máximo) e lista de textos (lista ou texto separado por vírgula).

#### Scenario: Duração digitada
- **WHEN** o usuário informa `1h 30m`, `90m` ou `1:30`
- **THEN** o valor é convertido para 5400 segundos, e converter de volta para texto e novamente para segundos preserva o valor

#### Scenario: Avaliação fora da faixa
- **WHEN** o valor enviado excede o máximo configurado
- **THEN** o changeset fica inválido

#### Scenario: Lista de textos
- **WHEN** o usuário envia `a, b,, a`
- **THEN** o valor é `["a", "b"]`, sem vazios nem repetidos

### Requirement: Erros de changeset nos controles
Os controles SHALL aceitar um campo de formulário Phoenix e exibir os erros do changeset traduzidos, somente depois que o campo foi usado.

#### Scenario: Campo ainda não tocado
- **WHEN** um campo obrigatório não foi enviado e o changeset tem erro para ele
- **THEN** o erro não é exibido

#### Scenario: Campo enviado com valor inválido
- **WHEN** o usuário envia um valor que falha no cast
- **THEN** o controle fica marcado como inválido e exibe a mensagem

### Requirement: Opções a partir de enum Ecto
A biblioteca SHALL gerar as opções de seleção a partir de um campo `Ecto.Enum`, rejeitando campos que não sejam enum.

#### Scenario: Campo que não é enum
- **WHEN** as opções são pedidas para um campo de outro tipo
- **THEN** a operação falha com um erro de contrato

### Requirement: Plug de tema
A biblioteca SHALL fornecer um Plug que resolve o tema (claro ou escuro) nesta ordem: parâmetro da requisição, sessão, cookie, padrão configurado, ignorando valores inválidos, e o disponibiliza ao layout e ao LiveView.

#### Scenario: Parâmetro persiste
- **WHEN** a requisição traz `theme=dark`
- **THEN** o tema é escuro e a requisição seguinte, sem parâmetro, continua escura

#### Scenario: Valor inválido
- **WHEN** o parâmetro ou o cookie traz um tema desconhecido
- **THEN** o valor é ignorado e o tema padrão é usado

### Requirement: Entrega dos assets de tokens
A biblioteca SHALL oferecer um Plug que serve o CSS de tokens a partir da própria dependência, e nada além dele.

#### Scenario: Outro arquivo
- **WHEN** é pedido um arquivo diferente do CSS de tokens
- **THEN** o Plug não responde e deixa a requisição seguir
