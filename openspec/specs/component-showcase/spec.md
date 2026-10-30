# component-showcase Specification

## Purpose
Oferecer um mostruário navegável em que cada componente pode ser explorado por formulários e tem a especificação visível, derivada do próprio código para nunca divergir.

## Requirements

### Requirement: Índice navegável por categoria
O mostruário SHALL listar todos os componentes da biblioteca agrupados por categoria e permitir navegar até cada um sem recarregar a página.

#### Scenario: Navegar do índice ao componente
- **WHEN** o usuário escolhe um componente no menu lateral
- **THEN** a página do componente é exibida e o item do menu fica marcado como atual

#### Scenario: Componente desconhecido
- **WHEN** o usuário acessa um componente que não existe
- **THEN** é redirecionado ao índice com um aviso

### Requirement: Playground por formulário
Para cada componente, o mostruário SHALL oferecer um formulário gerado dos atributos reais do componente, cuja alteração atualiza a prévia e o trecho de uso ao vivo.

#### Scenario: Alterar um atributo
- **WHEN** o usuário muda `variant` para `solid` no formulário de um botão
- **THEN** a prévia passa a usar o estilo sólido e o trecho de uso contém `variant={:solid}`

#### Scenario: Reiniciar
- **WHEN** o usuário aciona "Reiniciar"
- **THEN** os valores voltam aos iniciais

### Requirement: Especificação derivada do código
O mostruário SHALL exibir, por componente, atributos (nome, tipo, obrigatoriedade, padrão, valores permitidos, descrição) e slots, lidos das declarações reais do componente.

#### Scenario: Valores permitidos refletem o componente
- **WHEN** a especificação de um componente é exibida
- **THEN** os valores permitidos de cada atributo são os declarados no código do componente

### Requirement: Violação de contrato visível
Quando o formulário produzir um valor fora do contrato do componente, o mostruário SHALL exibir a violação em vez de renderizar o componente incorretamente, sem encerrar a sessão.

#### Scenario: Identificador inválido
- **WHEN** o usuário digita um `id` inválido para o diálogo
- **THEN** a prévia mostra "Contrato violado" com a mensagem, e corrigir o valor restaura a prévia

### Requirement: Tema
O mostruário SHALL permitir alternar entre tema claro e escuro, e lembrar a escolha nas visitas seguintes.

#### Scenario: Escolher tema escuro
- **WHEN** o usuário aciona o tema escuro
- **THEN** a página usa o tema escuro, e uma nova visita continua escura

### Requirement: Fundamentos, moléculas e experimentais no mostruário
O mostruário SHALL incluir uma seção de Fundamentos navegável, e SHALL agrupar os componentes em categorias que incluam Moléculas (List, Editor e CodeEditor) e Experimental.

#### Scenario: Navegar até um fundamento
- **WHEN** o usuário escolhe "Radius" no menu lateral
- **THEN** a página mostra uma amostra para cada raio da escala e o item do menu fica marcado

#### Scenario: Fundamento desconhecido
- **WHEN** o usuário acessa um fundamento que não existe
- **THEN** é redirecionado ao índice com um aviso

### Requirement: Home com todos os componentes
A página inicial do mostruário SHALL listar todos os componentes do catálogo, agrupados por categoria e no mesmo estilo de cartão, cada um com uma prévia renderizada, além dos fundamentos e dos blocos internos públicos.

#### Scenario: Cartão por componente
- **WHEN** a home é aberta
- **THEN** existe um cartão com prévia para cada componente do catálogo, e escolher o título abre a página do componente

#### Scenario: Prévia não interfere na navegação
- **WHEN** a prévia de um cartão contém botões ou links
- **THEN** a prévia é inerte e a página não contém links aninhados nem ids duplicados
