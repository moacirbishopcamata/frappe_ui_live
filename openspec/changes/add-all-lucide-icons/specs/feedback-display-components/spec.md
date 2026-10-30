## MODIFIED Requirements

### Requirement: Ícones Lucide
Icon e as props de ícone dos demais componentes SHALL aceitar qualquer nome do catálogo completo de ícones Lucide (inclusive nomes antigos) e renderizar o ícone correspondente, respeitando as propriedades de tamanho, cor e traço.

#### Scenario: Ícone por nome
- **WHEN** um botão recebe o ícone `plus`
- **THEN** o ícone Lucide `plus` é exibido no botão

#### Scenario: Ícone com propriedades
- **WHEN** o componente Icon recebe `name="plus"`, `size={32}` e `stroke_width={1.5}`
- **THEN** o ícone é exibido com 32 de tamanho e traço 1,5
