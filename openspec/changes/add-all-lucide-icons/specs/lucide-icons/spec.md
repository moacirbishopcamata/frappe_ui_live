## Purpose
Oferecer o catálogo completo de ícones Lucide como componentes LiveView, com as propriedades do Lucide e metadados consultáveis, sem JavaScript no cliente.

## ADDED Requirements

### Requirement: Todos os ícones Lucide como componentes
A biblioteca SHALL fornecer um componente LiveView para cada ícone da versão fixada do Lucide, além de um componente genérico que recebe o nome do ícone.

#### Scenario: Componente por ícone
- **WHEN** um template usa o componente do ícone `plus`
- **THEN** é renderizado um `<svg>` com o desenho do ícone `plus`

#### Scenario: Componente genérico por nome
- **WHEN** o componente genérico recebe `name="circle-alert"`
- **THEN** é renderizado o mesmo desenho do componente do ícone `circle-alert`

#### Scenario: Cobertura completa
- **WHEN** o catálogo é comparado à lista de ícones da versão fixada do Lucide
- **THEN** todo ícone da lista tem componente e todo componente corresponde a um ícone da lista

### Requirement: Propriedades Lucide
Todo ícone SHALL aceitar as propriedades `size` (padrão 24), `color` (padrão `currentColor`), `stroke_width` (padrão 2), `absolute_stroke_width` (padrão falso), `class`, `title` e atributos globais adicionais.

#### Scenario: Tamanho e cor
- **WHEN** um ícone recebe `size={16}` e `color="red"`
- **THEN** o SVG tem largura e altura 16 e traço vermelho

#### Scenario: Espessura do traço
- **WHEN** um ícone recebe `stroke_width={1}`
- **THEN** o traço renderizado tem espessura 1

#### Scenario: Traço absoluto
- **WHEN** um ícone recebe `size={48}`, `stroke_width={2}` e `absolute_stroke_width`
- **THEN** a espessura visual do traço equivale a 2 pixels, independente do tamanho

#### Scenario: Valores inválidos
- **WHEN** `size` ou `stroke_width` recebe um valor que não é número positivo
- **THEN** o desenvolvedor recebe um erro de contrato claro em vez de um SVG quebrado

### Requirement: Acessibilidade
Um ícone SHALL ser ocultado de leitores de tela por padrão e SHALL expor um nome acessível quando recebe `title`.

#### Scenario: Decorativo
- **WHEN** um ícone é renderizado sem `title`
- **THEN** o SVG é marcado como oculto para tecnologias assistivas

#### Scenario: Com título
- **WHEN** um ícone recebe `title="Adicionar"`
- **THEN** o SVG expõe o texto "Adicionar" como nome acessível e não fica oculto

### Requirement: Nomes antigos e desconhecidos
O nome de um ícone SHALL aceitar tanto o nome atual quanto os nomes antigos (aliases) do Lucide; um nome inexistente SHALL falhar de forma explícita.

#### Scenario: Alias
- **WHEN** o componente genérico recebe `name="alert-circle"` (nome antigo)
- **THEN** é renderizado o ícone atual correspondente

#### Scenario: Nome inexistente
- **WHEN** o componente genérico recebe um nome que não existe nem como alias
- **THEN** ocorre um erro de contrato que cita o nome informado e sugere nomes parecidos

### Requirement: Metadados e busca
A biblioteca SHALL expor a lista de ícones com seus metadados (nome, tags, aliases) e uma busca por nome ou tag.

#### Scenario: Busca por tag
- **WHEN** a busca recebe um termo presente nas tags de um ícone mas não no nome
- **THEN** o ícone aparece no resultado

#### Scenario: Busca sem resultado
- **WHEN** a busca recebe um termo que nenhum ícone contém
- **THEN** o resultado é uma lista vazia

### Requirement: Ícones em outros componentes
Toda propriedade de ícone dos demais componentes SHALL aceitar qualquer ícone do catálogo pelo nome.

#### Scenario: Botão com ícone fora do conjunto antigo
- **WHEN** um botão recebe um ícone que não estava entre os 82 ícones originais
- **THEN** o ícone é exibido no botão
