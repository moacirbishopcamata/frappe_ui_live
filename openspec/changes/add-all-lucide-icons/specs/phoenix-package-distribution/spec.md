## ADDED Requirements

### Requirement: Ícones sem CSS adicional
Os ícones SHALL funcionar sem importar CSS de ícones nem JavaScript, e o pacote SHALL conter os dados dos ícones gerados de forma reprodutível a partir da versão fixada do Lucide.

#### Scenario: Projeto sem CSS de ícones
- **WHEN** um projeto usa o pacote sem importar nenhum CSS de ícones
- **THEN** todos os ícones são exibidos normalmente

#### Scenario: Geração reprodutível
- **WHEN** os dados dos ícones são regenerados com a mesma versão do Lucide
- **THEN** o resultado é idêntico ao que está no pacote
