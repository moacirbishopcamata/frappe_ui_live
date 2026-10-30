# phoenix-package-distribution Specification

## Purpose
Definir como a biblioteca é distribuída e consumida por apps Phoenix, para que a adoção seja uma dependência e poucos passos de configuração.

## Requirements

### Requirement: Dependência única consumível
A biblioteca SHALL ser adicionável a um app Phoenix 1.8 com LiveView 1.x por uma única entrada em `deps`, sem exigir Vue, Node além do esbuild do host, nem servidor Frappe.

#### Scenario: App host compila com a dependência
- **WHEN** um app Phoenix novo adiciona a biblioteca como dependência e roda `mix compile`
- **THEN** a compilação conclui sem warnings originados na biblioteca

### Requirement: Uso por import único
A biblioteca SHALL expor todos os componentes por um único `use` (ou `import`) que o app host coloca em seu módulo de componentes/HTML.

#### Scenario: Componente disponível em template
- **WHEN** o módulo web do host faz `use FrappeUILive`
- **THEN** `<.button>` e demais componentes ficam disponíveis em HEEx sem alias adicional

### Requirement: Instalador
A biblioteca SHALL oferecer uma task Mix de instalação que injeta, de forma idempotente, os assets necessários (CSS de tokens, registro de hooks) no app host.

#### Scenario: Instalação repetida
- **WHEN** a task de instalação roda duas vezes no mesmo app
- **THEN** a segunda execução não duplica nenhuma configuração

### Requirement: Hooks opcionais carregam sob demanda
Hooks que dependem de bibliotecas JS pesadas (charts, editores) SHALL ser opt-in, de modo que um app que não usa esses componentes não inclui essas dependências no bundle.

#### Scenario: App sem charts
- **WHEN** o host não importa o hook de charts
- **THEN** o bundle do host não contém código de charts

### Requirement: Atribuição de licença
O pacote SHALL incluir a licença MIT do Frappe UI e indicar a origem dos tokens e da identidade visual.

#### Scenario: Pacote publicado
- **WHEN** o pacote é construído para publicação
- **THEN** o arquivo de licença e a atribuição estão presentes nos arquivos do pacote
