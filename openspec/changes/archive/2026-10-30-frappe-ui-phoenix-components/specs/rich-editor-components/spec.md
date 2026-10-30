## Purpose

Fornecer editores de rich text e de código cujo conteúdo é controlado pelo servidor.

## ADDED Requirements

### Requirement: Editor de rich text
A biblioteca SHALL fornecer um Editor de rich text com barra de formatação, que envia o conteúdo ao servidor por evento e é compatível com formulários.

#### Scenario: Conteúdo no submit
- **WHEN** o usuário edita o texto e submete o formulário
- **THEN** o servidor recebe o conteúdo editado no campo do formulário

### Requirement: Conteúdo do Editor é Markdown, nunca HTML
O Editor SHALL guardar o conteúdo como Markdown restrito (título, negrito, itálico, código, listas, links), e o conteúdo exibido a partir dele SHALL ter todo texto escapado e aceitar apenas links `http(s)`, `mailto:` ou relativos.

#### Scenario: HTML digitado ou colado
- **WHEN** o usuário cola ou digita marcação HTML no Editor
- **THEN** o valor enviado ao servidor é Markdown e a marcação aparece como texto, sem ser executada

#### Scenario: Link perigoso
- **WHEN** o conteúdo contém um link `javascript:` ou `data:`
- **THEN** ele não vira um link clicável

### Requirement: Editor de código
A biblioteca SHALL fornecer um CodeEditor como campo de formulário, com numeração de linhas, indentação pela tecla Tab, contagem de linhas e rótulo da linguagem. O realce de sintaxe está fora desta versão.

#### Scenario: Numeração acompanha o conteúdo
- **WHEN** o texto do CodeEditor tem três linhas
- **THEN** a numeração mostra 1, 2 e 3 e a contagem indica "3 linhas"

#### Scenario: Linguagem inválida
- **WHEN** o rótulo de linguagem contém caracteres fora do permitido
- **THEN** a renderização falha com um erro de contrato

### Requirement: Valor do servidor prevalece
Quando o servidor atualiza o valor de um editor, o editor SHALL refletir o novo valor sem perder o foco indevidamente nem duplicar eventos.

#### Scenario: Valor redefinido
- **WHEN** o servidor altera o valor do editor
- **THEN** o editor exibe o novo valor

### Requirement: Opt-in de dependências
As dependências JS dos editores SHALL ser carregadas somente quando um editor for usado.

#### Scenario: Página sem editor
- **WHEN** uma página não renderiza nenhum editor
- **THEN** nenhum código de editor é carregado nela
