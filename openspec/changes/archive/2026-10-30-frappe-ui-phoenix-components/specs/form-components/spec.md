## Purpose

Oferecer os controles de formulário do Frappe UI integrados ao modelo de formulário do Phoenix (`Phoenix.HTML.Form`, changesets, `phx-change`/`phx-submit`).

## ADDED Requirements

### Requirement: Integração com formulários Phoenix
Todo controle de entrada SHALL aceitar um `Phoenix.HTML.FormField` e derivar dele `id`, `name`, `value` e mensagens de erro.

#### Scenario: Campo com erro de changeset
- **WHEN** um controle recebe um `FormField` cujo changeset tem erro
- **THEN** o controle exibe o estado inválido e a mensagem de erro

### Requirement: Controles disponíveis
A biblioteca SHALL fornecer Button, FormControl, FormLabel, TextInput, Textarea, Password, Select, Combobox, MultiSelect, Checkbox, Radio, Switch, Slider, Rating, DatePicker, TimePicker, Duration e FileUploader.

#### Scenario: Inventário completo
- **WHEN** a documentação de componentes é consultada
- **THEN** cada controle listado possui um componente correspondente

### Requirement: Variantes e estados de Button
Button SHALL suportar as variantes `solid`, `subtle`, `outline` e `ghost`, os temas `gray`, `blue`, `green` e `red`, tamanhos, ícones à esquerda e à direita, estado `loading` e `disabled`.

#### Scenario: Botão em carregamento
- **WHEN** um botão é renderizado com `loading`
- **THEN** exibe um spinner e não dispara o evento de clique

### Requirement: Restrições visíveis antes do submit
Controles SHALL repassar os atributos de validação nativos (`required`, `min`, `max`, `maxlength`, `pattern`, `placeholder`) ao elemento HTML.

#### Scenario: Campo obrigatório
- **WHEN** um controle é renderizado com `required`
- **THEN** o elemento HTML tem o atributo `required` e o rótulo indica obrigatoriedade

### Requirement: Acessibilidade
Cada controle SHALL associar rótulo e campo e SHALL ser operável por teclado.

#### Scenario: Rótulo associado
- **WHEN** um FormControl é renderizado com rótulo
- **THEN** o rótulo referencia o campo pelo mesmo `id`
