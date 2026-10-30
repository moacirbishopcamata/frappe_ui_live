## Purpose

Fornecer os tokens visuais semânticos do Frappe UI para que todo componente tenha aparência consistente e troque de tema sem classes `dark:`.

## ADDED Requirements

### Requirement: Tokens semânticos
A biblioteca SHALL expor as famílias de token `surface`, `ink` e `outline` como variáveis CSS e como utilitários de classe (`bg-surface-*`, `text-ink-*`, `border-outline-*`).

#### Scenario: Classe de token resolve cor
- **WHEN** um elemento usa `bg-surface-gray-2 text-ink-gray-8`
- **THEN** o fundo e o texto assumem os valores do tema ativo

### Requirement: Dark mode por atributo
O tema escuro SHALL ser ativado por `data-theme="dark"` no elemento raiz, e todo componente SHALL trocar de aparência sem exigir variantes `dark:` no markup.

#### Scenario: Troca de tema
- **WHEN** o atributo `data-theme` do `<html>` passa a `dark`
- **THEN** todos os componentes renderizados usam os valores escuros dos tokens

### Requirement: Escalas de radius, sombra e foco
A biblioteca SHALL expor as escalas de radius, sombras e focus ring do Frappe UI com os mesmos nomes de token.

#### Scenario: Focus ring visível
- **WHEN** um controle interativo recebe foco por teclado
- **THEN** o anel de foco do token de foco é exibido

### Requirement: Valores iguais ao original
Os valores dos tokens SHALL ser idênticos aos publicados pelo Frappe UI na versão de referência, documentada no pacote.

#### Scenario: Paridade de token
- **WHEN** os tokens do pacote são comparados com a fonte de referência
- **THEN** não há diferença de valor para nenhum nome de token

### Requirement: Documentação visual dos fundamentos
A biblioteca SHALL oferecer páginas de Fundamentos (cores, tipografia, raios, sombras, anel de foco e cores de gráficos) geradas da mesma fonte dos tokens do CSS, exibindo cada valor pelas variáveis do tema.

#### Scenario: Todo token documentado funciona
- **WHEN** a página de cores é gerada
- **THEN** cada token exibido existe como variável e como utilitário no CSS distribuído

#### Scenario: Acompanha o tema
- **WHEN** o tema escuro está ativo
- **THEN** as amostras de cor mostram os valores escuros sem alterar o markup

#### Scenario: Cores de gráficos
- **WHEN** a página de cores de gráficos é exibida
- **THEN** a ordem das séries é a mesma usada pelos gráficos da biblioteca
