# chart-components Specification

## Purpose
Fornecer os gráficos do Frappe UI alimentados por dados do servidor, atualizados por diff do LiveView.

## Requirements

### Requirement: Tipos de gráfico
A biblioteca SHALL fornecer BarChart, LineChart, AreaChart, DonutChart, PercentageBarChart, FunnelChart, HeatmapChart, CalendarHeatmapChart, ScatterChart e SankeyChart, além de NumberCard, ChartCard, ChartLegend, ChartTooltip e estados de carregamento, vazio e erro.

#### Scenario: Inventário completo
- **WHEN** a documentação de componentes é consultada
- **THEN** cada gráfico e cartão listado possui um correspondente

### Requirement: Dados vindos do servidor
Gráficos SHALL ser configurados por dados e opções serializáveis enviados pelo servidor, e SHALL atualizar quando os dados mudam.

#### Scenario: Dados atualizados
- **WHEN** o servidor altera os dados de um gráfico
- **THEN** o gráfico redesenha com os novos valores sem recriar a página

### Requirement: Cores do tema
Gráficos SHALL usar a paleta de cores do Frappe UI e respeitar o tema claro e escuro.

#### Scenario: Troca de tema
- **WHEN** o tema muda para escuro
- **THEN** o gráfico passa a usar as cores do tema escuro

### Requirement: Estados vazio e de erro
Gráficos SHALL exibir estados visuais distintos para carregando, vazio e erro.

#### Scenario: Sem dados
- **WHEN** um gráfico recebe uma coleção vazia
- **THEN** exibe o estado vazio em vez de um eixo em branco
