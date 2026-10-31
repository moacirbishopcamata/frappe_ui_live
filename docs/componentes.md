# Referência de componentes

> Gerado do código por `showcase/scripts/gen_reference.exs` (`cd showcase && mix run scripts/gen_reference.exs`).
> Não edite à mão: atributos, tipos, padrões e slots vêm dos `attr`/`slot` reais.
> Para ver cada componente funcionando, rode o mostruário (veja o [README](../README.md)).

- [Formulários](#formulários)
- [Feedback e exibição](#feedback-e-exibição)
- [Overlays](#overlays)
- [Navegação e layout](#navegação-e-layout)
- [Dados](#dados)
- [Charts](#charts)
- [Moléculas](#moléculas)
- [Experimental](#experimental)

## Formulários

### Button

`FrappeUILive.Components.Button.button/1` — Botão do Frappe UI: variantes `solid | subtle | outline | ghost`, temas `gray | blue | green | red`, tamanhos `xs | sm | md | lg`.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `disabled` | boolean | não | `false` |  |  |
| `icon` | string | não | — |  | botão só com ícone (nome Lucide) |
| `icon_left` | string | não | — |  |  |
| `icon_right` | string | não | — |  |  |
| `label` | string | não | — |  |  |
| `loading` | boolean | não | `false` |  |  |
| `loading_text` | string | não | — |  |  |
| `size` | atom | não | `:sm` | `:xs`, `:sm`, `:md`, `:lg` |  |
| `theme` | atom | não | `:gray` | `:gray`, `:blue`, `:green`, `:red` |  |
| `type` | string | não | `"button"` |  |  |
| `variant` | atom | não | `:subtle` | `:solid`, `:subtle`, `:outline`, `:ghost` |  |

**Slots**

- `:inner_block`

### TextInput

`FrappeUILive.Components.TextInput.text_input/1` — Campo de uma linha. Aceita `field={@form[:campo]}` (Phoenix/Ecto) ou `name`/`value` avulsos. Restrições (`required`, `maxlength`, `min`, `pattern`, `placeholder`...) vão direto ao `<input>`; o servidor continua sendo a barreira real (o `required` aqui espelha a regra do changeset).

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `disabled` | boolean | não | `false` |  |  |
| `errors` | list | não | `[]` |  |  |
| `field` | Phoenix.HTML.FormField | não | — |  |  |
| `id` | any | não | — |  |  |
| `name` | any | não | — |  |  |
| `size` | atom | não | `:sm` | `:xs`, `:sm`, `:md`, `:lg` |  |
| `type` | string | não | `"text"` | 13 valores (veja a documentação do módulo) |  |
| `value` | any | não | — |  |  |
| `variant` | atom | não | `:subtle` | `:subtle`, `:outline`, `:ghost` |  |

### Textarea

`FrappeUILive.Components.Textarea.textarea/1` — Campo de várias linhas; mesmo contrato de `FrappeUILive.Components.TextInput`.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `disabled` | boolean | não | `false` |  |  |
| `errors` | list | não | `[]` |  |  |
| `field` | Phoenix.HTML.FormField | não | — |  |  |
| `id` | any | não | — |  |  |
| `name` | any | não | — |  |  |
| `rows` | integer | não | `3` |  |  |
| `size` | atom | não | `:sm` | `:xs`, `:sm`, `:md`, `:lg` |  |
| `value` | any | não | — |  |  |
| `variant` | atom | não | `:subtle` | `:subtle`, `:outline`, `:ghost` |  |

### Password

`FrappeUILive.Components.Password.password/1` — Campo de senha com botão de mostrar/ocultar. A alternância é só visual (`JS.toggle_attribute` no `type`); o valor **nunca** é reenviado ao HTML.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `disabled` | boolean | não | `false` |  |  |
| `errors` | list | não | `[]` |  |  |
| `field` | Phoenix.HTML.FormField | não | — |  |  |
| `id` | any | não | — |  |  |
| `name` | any | não | — |  |  |
| `size` | atom | não | `:sm` | `:xs`, `:sm`, `:md`, `:lg` |  |
| `value` | any | não | — |  |  |
| `variant` | atom | não | `:subtle` | `:subtle`, `:outline`, `:ghost` |  |

### PinCode

`FrappeUILive.Components.PinCode.pin_code/1` — Código de verificação / PIN: uma caixa por caractere, com avanço automático, Backspace que volta, setas, colar o código inteiro e preenchimento por SMS (`autocomplete="one-time-code"`).

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `disabled` | boolean | não | `false` |  |  |
| `errors` | list | não | `[]` |  |  |
| `field` | Phoenix.HTML.FormField | não | — |  |  |
| `id` | any | não | — |  |  |
| `length` | integer | não | `6` |  | quantidade de caracteres (3..12) |
| `mask` | boolean | não | `false` |  | esconde os caracteres, como uma senha |
| `name` | any | não | — |  |  |
| `on_complete` | string | não | — |  | evento enviado ao servidor com o código quando todas as caixas estão preenchidas |
| `size` | atom | não | `:md` | `:xs`, `:sm`, `:md`, `:lg` |  |
| `type` | atom | não | `:numeric` | `:numeric`, `:alphanumeric` |  |
| `value` | any | não | — |  |  |
| `variant` | atom | não | `:subtle` | `:subtle`, `:outline`, `:ghost` |  |

### Select

`FrappeUILive.Components.Select.select/1` — Seleção nativa. `options` aceita lista de strings, `{rótulo, valor}` ou keyword; `prompt` adiciona uma primeira opção vazia.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `disabled` | boolean | não | `false` |  |  |
| `errors` | list | não | `[]` |  |  |
| `field` | Phoenix.HTML.FormField | não | — |  |  |
| `id` | any | não | — |  |  |
| `multiple` | boolean | não | `false` |  |  |
| `name` | any | não | — |  |  |
| `options` | list | sim | — |  |  |
| `prompt` | string | não | — |  |  |
| `size` | atom | não | `:sm` | `:xs`, `:sm`, `:md`, `:lg` |  |
| `value` | any | não | — |  |  |
| `variant` | atom | não | `:subtle` | `:subtle`, `:outline`, `:ghost` |  |

### Combobox

`FrappeUILive.Components.Combobox.combobox/1` — Seleção única com busca. Aceita `field` (Phoenix/Ecto); a escolha é um radio nativo do formulário.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `disabled` | boolean | não | `false` |  |  |
| `errors` | list | não | `[]` |  |  |
| `field` | Phoenix.HTML.FormField | não | — |  |  |
| `form` | string | não | — |  |  |
| `id` | any | não | — |  |  |
| `name` | any | não | — |  |  |
| `on_search` | string | não | — |  | evento do servidor para busca remota |
| `options` | list | sim | — |  |  |
| `placeholder` | string | não | — |  |  |
| `required` | boolean | não | `false` |  |  |
| `value` | any | não | — |  |  |

### MultiSelect

`FrappeUILive.Components.MultiSelect.multi_select/1` — Seleção múltipla com busca e selos. Envia `name[]` (mais um `""` para permitir esvaziar); combine com `FrappeUILive.Ecto.StringList`, que descarta o vazio.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `disabled` | boolean | não | `false` |  |  |
| `errors` | list | não | `[]` |  |  |
| `field` | Phoenix.HTML.FormField | não | — |  |  |
| `form` | string | não | — |  |  |
| `id` | any | não | — |  |  |
| `name` | any | não | — |  |  |
| `on_search` | string | não | — |  |  |
| `options` | list | sim | — |  |  |
| `placeholder` | string | não | — |  |  |
| `required` | boolean | não | `false` |  |  |
| `value` | any | não | — |  | lista de valores selecionados |

### Checkbox

`FrappeUILive.Components.Checkbox.checkbox/1` — Caixa de seleção com rótulo opcional. Emite o `hidden` com `"false"` como o `core_components` do Phoenix, para que o desmarcado chegue ao servidor.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `checked` | boolean | não | — |  | padrão: derivado de `value` |
| `class` | any | não | — |  |  |
| `disabled` | boolean | não | `false` |  |  |
| `errors` | list | não | `[]` |  |  |
| `field` | Phoenix.HTML.FormField | não | — |  |  |
| `id` | any | não | — |  |  |
| `label` | string | não | — |  |  |
| `name` | any | não | — |  |  |
| `value` | any | não | — |  |  |

### Radio

`FrappeUILive.Components.RadioGroup.radio_group/1` — Grupo de opções exclusivas (`<input type=radio>` nativos); `options` como em `Select`.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `disabled` | boolean | não | `false` |  |  |
| `errors` | list | não | `[]` |  |  |
| `field` | Phoenix.HTML.FormField | não | — |  |  |
| `id` | any | não | — |  |  |
| `label` | string | não | — |  |  |
| `name` | any | não | — |  |  |
| `options` | list | sim | — |  | strings ou {rótulo, valor} |
| `orientation` | atom | não | `:vertical` | `:vertical`, `:horizontal` |  |
| `value` | any | não | — |  |  |

### Switch

`FrappeUILive.Components.Switch.switch/1` — Interruptor. É um checkbox nativo (`peer`), então funciona em formulários sem JS.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `checked` | boolean | não | — |  |  |
| `class` | any | não | — |  |  |
| `disabled` | boolean | não | `false` |  |  |
| `errors` | list | não | `[]` |  |  |
| `field` | Phoenix.HTML.FormField | não | — |  |  |
| `id` | any | não | — |  |  |
| `label` | string | não | — |  |  |
| `name` | any | não | — |  |  |
| `size` | atom | não | `:sm` | `:sm`, `:md` |  |
| `value` | any | não | — |  |  |

### Slider

`FrappeUILive.Components.Slider.slider/1` — Controle deslizante (`<input type=range>`); `min <= value <= max` é pré-condição.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `disabled` | boolean | não | `false` |  |  |
| `errors` | list | não | `[]` |  |  |
| `field` | Phoenix.HTML.FormField | não | — |  |  |
| `id` | any | não | — |  |  |
| `max` | integer | não | `100` |  |  |
| `min` | integer | não | `0` |  |  |
| `name` | any | não | — |  |  |
| `show_value` | boolean | não | `false` |  |  |
| `step` | integer | não | `1` |  |  |
| `value` | any | não | — |  |  |

### Rating

`FrappeUILive.Components.Rating.rating/1` — Avaliação em estrelas (`1..max`). Cada estrela é um `<input type=radio>`, então funciona em formulários e `phx-change`; o preenchimento vem do valor no servidor. Combine com `FrappeUILive.Ecto.Rating` no schema.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `errors` | list | não | `[]` |  |  |
| `field` | Phoenix.HTML.FormField | não | — |  |  |
| `id` | any | não | — |  |  |
| `max` | integer | não | `5` |  |  |
| `name` | any | não | — |  |  |
| `readonly` | boolean | não | `false` |  |  |
| `value` | any | não | — |  |  |

### DatePicker

`FrappeUILive.Components.DatePicker.date_picker/1` — Seletor de data com calendário (LiveComponent: o mês exibido é estado próprio).

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `disabled` | boolean | não | `false` |  |  |
| `errors` | list | não | `[]` |  |  |
| `field` | Phoenix.HTML.FormField | não | — |  |  |
| `id` | string | sim | — |  |  |
| `max` | any | não | — |  | última data permitida |
| `min` | any | não | — |  | primeira data permitida |
| `name` | any | não | — |  |  |
| `placeholder` | string | não | — |  |  |
| `value` | any | não | — |  | data ISO (`2026-03-09`) ou `Date` |

### TimePicker

`FrappeUILive.Components.TimePicker.time_picker/1` — Seletor de horário (`<input type=time>` nativo, com o teclado/relógio do dispositivo); `step` em segundos.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `disabled` | boolean | não | `false` |  |  |
| `errors` | list | não | `[]` |  |  |
| `field` | Phoenix.HTML.FormField | não | — |  |  |
| `id` | any | não | — |  |  |
| `name` | any | não | — |  |  |
| `size` | atom | não | `:sm` | `:xs`, `:sm`, `:md`, `:lg` |  |
| `step` | integer | não | `60` |  | segundos; 60 = minutos, 1 = com segundos |
| `value` | any | não | — |  |  |
| `variant` | atom | não | `:subtle` | `:subtle`, `:outline`, `:ghost` |  |

### Duration

`FrappeUILive.Components.Duration.duration/1` — Campo de duração: mostra `1h 30m` quando o valor são segundos e aceita o que `FrappeUILive.Duration` entende. Combine com `FrappeUILive.Ecto.Duration` no schema.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `disabled` | boolean | não | `false` |  |  |
| `errors` | list | não | `[]` |  |  |
| `field` | Phoenix.HTML.FormField | não | — |  |  |
| `id` | any | não | — |  |  |
| `name` | any | não | — |  |  |
| `size` | atom | não | `:sm` | `:xs`, `:sm`, `:md`, `:lg` |  |
| `value` | any | não | — |  |  |
| `variant` | atom | não | `:subtle` | `:subtle`, `:outline`, `:ghost` |  |

### FileUploader

`FrappeUILive.Components.FileUploader.file_uploader/1` — Área de envio sobre `allow_upload/3` do LiveView: arrastar-e-soltar, lista de arquivos com progresso, cancelamento e erros em português. Quem decide o que fazer com o arquivo (`consume_uploaded_entries/3`) é o servidor.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `label` | string | não | — |  |  |
| `on_cancel` | string | não | `"cancel-upload"` |  | evento do servidor; recebe `ref` |
| `upload` | Phoenix.LiveView.UploadConfig | sim | — |  |  |

**Slots**

- `:hint`

### FormControl

`FrappeUILive.Components.FormControl.form_control/1` — Rótulo + controle + descrição + erros, escolhendo o controle por `type`.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `description` | string | não | — |  |  |
| `disabled` | boolean | não | `false` |  |  |
| `field` | Phoenix.HTML.FormField | sim | — |  |  |
| `label` | string | não | — |  |  |
| `options` | list | não | `[]` |  |  |
| `prompt` | string | não | — |  |  |
| `required` | boolean | não | `false` |  | espelha a regra `validate_required` do changeset |
| `size` | atom | não | `:sm` |  |  |
| `type` | string | não | `"text"` |  |  |
| `variant` | atom | não | `:subtle` |  |  |

### FormLabel

`FrappeUILive.Components.FormLabel.form_label/1` — Rótulo de campo; `required` acrescenta o asterisco e deve espelhar o `required` do controle.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `for` | string | não | — |  |  |
| `required` | boolean | não | `false` |  |  |

**Slots**

- `:inner_block` (obrigatório)

## Feedback e exibição

### Badge

`FrappeUILive.Components.Badge.badge/1` — Selo de status: temas `gray | blue | green | amber | red | violet`, variantes `solid | subtle | outline | ghost`.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `label` | string | não | — |  |  |
| `size` | atom | não | `:md` | `:sm`, `:md`, `:lg` |  |
| `theme` | atom | não | `:gray` | `:gray`, `:blue`, `:green`, `:amber`, `:red`, `:violet` |  |
| `variant` | atom | não | `:subtle` | `:solid`, `:subtle`, `:outline`, `:ghost` |  |

**Slots**

- `:inner_block`

### Alert

`FrappeUILive.Components.Alert.alert/1` — Alerta com título, descrição e ação opcional. Temas `gray | blue | green | amber | red`.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `icon` | string | não | — |  | sobrescreve o ícone do tema |
| `theme` | atom | não | `:gray` | `:gray`, `:blue`, `:green`, `:amber`, `:red` |  |
| `title` | string | sim | — |  |  |

**Slots**

- `:actions`
- `:inner_block`: descrição

### Progress

`FrappeUILive.Components.Progress.progress/1` — Barra de progresso (`value` de 0 a 100) com rótulo e valor opcionais.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `label` | string | não | — |  |  |
| `show_value` | boolean | não | `false` |  |  |
| `size` | atom | não | `:md` | `:sm`, `:md`, `:lg`, `:xl` |  |
| `value` | integer | sim | — |  | 0..100 |

### Skeleton

`FrappeUILive.Components.Skeleton.skeleton/1` — Bloco animado para estados de carregamento; dimensione por `class` (ex.: `h-4 w-32`).

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | `"h-4 w-full"` |  |  |

### Spinner

`FrappeUILive.Components.Spinner.spinner/1` — Indicador de carregamento; herda a cor do texto.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | `"size-4"` |  |  |

### LoadingText

`FrappeUILive.Components.LoadingText.loading_text/1` — Texto de carregamento com spinner.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `text` | string | não | — |  |  |

### Avatar

`FrappeUILive.Components.Avatar.avatar/1` — Avatar com imagem ou iniciais do `label`. Formas `circle | square`.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `image` | string | não | — |  |  |
| `label` | string | não | — |  |  |
| `shape` | atom | não | `:circle` | `:circle`, `:square` |  |
| `size` | atom | não | `:md` | `:xs`, `:sm`, `:md`, `:lg`, `:xl`, `:"2xl"`, `:"3xl"` |  |

### DiceBearAvatar

`FrappeUILive.Components.DiceBearAvatar.dice_bear_avatar/1` — Avatar gerado pelo [DiceBear](https://www.dicebear.com/) a partir de uma `seed`: a mesma `style` + `seed` + `options` dá sempre o mesmo desenho. Mesmos tamanhos e formas do `FrappeUILive.Components.Avatar`, de quem herda o visual (composição).

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `background_color` | any | não | — |  | hex (#RRGGBB), texto ou lista |
| `base_url` | string | não | — |  | servidor DiceBear (padrão: config ou API pública) |
| `border_radius` | any | não | — |  | 0 a 50 (% do canvas; 50 = círculo) |
| `class` | any | não | — |  |  |
| `flip` | string | não | — |  | none \| horizontal \| vertical \| both |
| `image` | string | não | — |  | foto real do usuário; quando presente ela é exibida no lugar do avatar gerado (placeholder) |
| `label` | string | não | — |  | nome acessível (alt) e dica; sem ele a imagem é decorativa |
| `options` | map | não | `%{}` |  | outros parâmetros da API, inclusive os do estilo (hairVariant...); listas viram a,b. Os atributos acima têm prioridade |
| `rotate` | any | não | — |  | -360 a 360 graus |
| `scale` | any | não | — |  | 0 a 10 (1 = tamanho original) |
| `seed` | string | sim | — |  | identificador estável e não pessoal do avatar |
| `shape` | atom | não | `:circle` | `:circle`, `:square` |  |
| `size` | atom | não | `:md` | `:xs`, `:sm`, `:md`, `:lg`, `:xl`, `:"2xl"`, `:"3xl"` |  |
| `style` | string | não | `"thumbs"` | 61 valores (veja a documentação do módulo) | estilo DiceBear (nome como "thumbs" ou "pixel-art"; veja DiceBear.styles/0) |
| `tags` | any | não | — |  | filtro de variantes, ex.: "animation" |
| `translate_x` | any | não | — |  | -1000 a 1000 (% da largura) |
| `translate_y` | any | não | — |  | -1000 a 1000 (% da altura) |

### Icon

`FrappeUILive.Components.Icon.icon/1` — Ícone Lucide por nome, renderizado como `<svg>` inline (veja `FrappeUILive.Icons`).

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `absolute_stroke_width` | boolean | não | `false` |  | mantém a espessura visual do traço igual em qualquer tamanho |
| `class` | any | não | — |  |  |
| `color` | string | não | `"currentColor"` |  | cor do traço (qualquer cor CSS) |
| `name` | string | sim | — |  | nome Lucide, ex.: "plus" |
| `size` | any | não | `24` |  | largura e altura em pixels (número positivo) |
| `stroke_width` | any | não | `2` |  | espessura do traço (número positivo) |
| `title` | string | não | — |  | nome acessível; sem ele o ícone é decorativo |

### KeyboardShortcut

`FrappeUILive.Components.KeyboardShortcut.keyboard_shortcut/1` — Atalho de teclado: uma `<kbd>` por tecla (`keys={["Ctrl", "K"]}`).

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `keys` | list | sim | — |  | lista de teclas, ex.: ["Ctrl", "K"] |

### ItemListRow

`FrappeUILive.Components.ItemListRow.item_list_row/1` — Linha de lista com ícone, título, subtítulo e ações; navegável por `navigate`/`patch`/`href`.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `subtitle` | string | não | — |  |  |
| `title` | string | sim | — |  |  |

**Slots**

- `:actions`
- `:icon`

### SavedIndicator

`FrappeUILive.Components.SavedIndicator.saved_indicator/1` — Confirmação visual transitória ("Salvo") sem `useEffect`/timer: o servidor devolve um valor que muda a cada sucesso (`at`, ex. um timestamp) e o `:key` remonta o elemento, reiniciando a animação CSS que termina em opacidade 0.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `at` | any | não | — |  | muda a cada sucesso; `nil` não mostra nada |
| `class` | any | não | — |  |  |
| `label` | string | não | — |  |  |

### ErrorMessage

`FrappeUILive.Components.ErrorMessage.error_message/1` — Mensagem(ns) de erro. Aceita uma string, uma lista de strings ou `nil` (não renderiza nada).

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `id` | string | não | — |  |  |
| `message` | any | não | — |  | String ou lista de strings |

### Toast

`FrappeUILive.Components.Toast.toast_container/1` — Container de toasts: mostra mensagens de `flash` (renderizadas no servidor) e as enviadas por `FrappeUILive.Toast.put_toast/4` (via hook colocated).

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `flash` | map | não | `%{}` |  |  |
| `id` | string | não | `"frappe-ui-toasts"` |  |  |

## Overlays

### Dialog

`FrappeUILive.Components.Dialog.dialog/1` — Diálogo modal sobre `<dialog>` nativo (foco preso, Esc e backdrop pelo navegador).

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `close_on_backdrop` | boolean | não | `true` |  |  |
| `id` | string | sim | — |  |  |
| `on_close` | string | não | — |  | evento enviado ao servidor quando o diálogo fecha |
| `open` | boolean | não | `false` |  |  |
| `placement` | atom | não | `:center` | `:center`, `:bottom` | `:bottom` vira uma folha inferior (BottomSheet) |
| `size` | atom | não | `:lg` | `:sm`, `:md`, `:lg`, `:xl`, `:"2xl"` |  |
| `title` | string | não | — |  |  |

**Slots**

- `:actions`
- `:inner_block` (obrigatório)

### BottomSheet

`FrappeUILive.Components.BottomSheet.bottom_sheet/1` — Folha inferior (mobile): um `Dialog` com `placement: :bottom`; abre/fecha com `show_dialog/1` e `hide_dialog/1`.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `id` | string | sim | — |  |  |
| `on_close` | string | não | — |  |  |
| `open` | boolean | não | `false` |  |  |
| `title` | string | não | — |  |  |

**Slots**

- `:actions`
- `:inner_block` (obrigatório)

### SettingsDialog

`FrappeUILive.Components.SettingsDialog.settings_dialog/1` — Diálogo de configurações: navegação lateral por seções (`:tab`) e o conteúdo da seção ativa. A seção ativa (`active`) é um assign do servidor.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `active` | string | sim | — |  | id da seção ativa |
| `id` | string | sim | — |  |  |
| `on_close` | string | não | — |  |  |
| `open` | boolean | não | `false` |  |  |
| `title` | string | não | — |  |  |

**Slots**

- `:inner_block` (obrigatório): conteúdo da seção ativa
- `:tab` (obrigatório) — atributos: `id*`, `label*`, `icon`, `patch`, `navigate`, `href`, `click`

### KeyboardShortcutsDialog

`FrappeUILive.Components.KeyboardShortcutsDialog.keyboard_shortcuts_dialog/1` — Diálogo com a lista de atalhos: `shortcuts={[%{label: "Buscar", keys: ["Ctrl", "K"]}]}`.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `id` | string | sim | — |  |  |
| `on_close` | string | não | — |  |  |
| `open` | boolean | não | `false` |  |  |
| `shortcuts` | list | sim | — |  | lista de %{label: String, keys: [String]} |
| `title` | string | não | — |  |  |

### Dropdown

`FrappeUILive.Components.Dropdown.dropdown/1` — Menu suspenso sem JavaScript: Popover API (light-dismiss e Esc nativos) + CSS Anchor Positioning (inverte para cima quando falta espaço).

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `icon` | string | não | — |  | ícone do botão padrão |
| `id` | string | sim | — |  |  |
| `label` | string | não | — |  | texto do botão padrão (ignorado se houver `:trigger`) |

**Slots**

- `:item` (obrigatório) — atributos: `label*`, `icon`, `click`, `navigate`, `patch`, `href`, `theme`
- `:trigger`: conteúdo do gatilho personalizado

### Popover

`FrappeUILive.Components.Popover.popover/1` — Painel flutuante com conteúdo livre: Popover API + CSS Anchor Positioning (sem JS).

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  | classes do painel |
| `id` | string | sim | — |  |  |
| `placement` | atom | não | `:bottom` | `:bottom`, `:top` |  |

**Slots**

- `:inner_block` (obrigatório): conteúdo do painel
- `:trigger` (obrigatório)

### ContextMenu

`FrappeUILive.Components.ContextMenu.context_menu/1` — Menu de contexto (botão direito) sobre uma região. O hook colocated só posiciona e abre o `popover` no cursor; o que cada item faz é decidido pelo servidor (`click`) ou por navegação.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `id` | string | sim | — |  |  |

**Slots**

- `:inner_block` (obrigatório): região que responde ao botão direito
- `:item` (obrigatório) — atributos: `label*`, `icon`, `click`, `navigate`, `patch`, `href`, `theme`

### HoverCard

`FrappeUILive.Components.HoverCard.hover_card/1` — Cartão que aparece em hover ou foco do gatilho, com pequeno atraso (CSS puro).

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  | classes do cartão |

**Slots**

- `:inner_block` (obrigatório): conteúdo do cartão
- `:trigger` (obrigatório)

### Tooltip

`FrappeUILive.Components.Tooltip.tooltip/1` — Dica visual sem JavaScript: aparece em hover e em foco do conteúdo envolvido.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `placement` | atom | não | `:top` | `:top`, `:bottom`, `:left`, `:right` |  |
| `text` | string | sim | — |  |  |

**Slots**

- `:inner_block` (obrigatório)

## Navegação e layout

### Tabs

`FrappeUILive.Components.Tabs.tabs/1` — Abas cujo item ativo é decidido por um assign (`active`), nunca por estado do cliente. Cada `:tab` navega (`patch`/`navigate`) ou dispara evento (`click`). O conteúdo do painel ativo vai no `inner_block`.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `active` | string | sim | — |  | id da aba ativa |
| `class` | any | não | — |  |  |
| `id` | string | sim | — |  |  |

**Slots**

- `:inner_block`: painel da aba ativa
- `:tab` (obrigatório) — atributos: `id*`, `label*`, `icon`, `patch`, `navigate`, `href`, `click`

### TabButtons

`FrappeUILive.Components.TabButtons.tab_buttons/1` — Abas em formato de botões segmentados; a ativa é um assign do servidor (`active`).

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `active` | string | sim | — |  | id do botão ativo |
| `class` | any | não | — |  |  |

**Slots**

- `:button` (obrigatório) — atributos: `id*`, `label*`, `icon`, `patch`, `navigate`, `href`, `click`

### Breadcrumbs

`FrappeUILive.Components.Breadcrumbs.breadcrumbs/1` — Trilha de navegação; o último item é a página atual (`aria-current="page"`).

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |

**Slots**

- `:item` (obrigatório) — atributos: `label*`, `navigate`, `patch`, `href`

### PageHeader

`FrappeUILive.Components.PageHeader.page_header/1` — Cabeçalho de página: breadcrumbs opcionais, título e ações.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `subtitle` | string | não | — |  |  |
| `title` | string | sim | — |  |  |

**Slots**

- `:actions`
- `:breadcrumbs`

### Sidebar

`FrappeUILive.Components.Sidebar.sidebar/1` — Barra lateral de navegação. O item ativo (`active`) e o recolhimento (`collapsed`) são assigns do servidor; recolhida, só os ícones aparecem.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `active` | string | não | — |  | id do item ativo (precisa existir se informado) |
| `class` | any | não | — |  |  |
| `collapsed` | boolean | não | `false` |  |  |

**Slots**

- `:footer`
- `:header`
- `:item` (obrigatório) — atributos: `id*`, `label*`, `icon`, `patch`, `navigate`, `href`, `click`

### SidebarRail

`FrappeUILive.Components.SidebarRail.sidebar_rail/1` — Trilho estreito só com ícones (rótulo acessível e `title`); ativo por assign.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `active` | string | não | — |  |  |
| `class` | any | não | — |  |  |

**Slots**

- `:footer`
- `:header`
- `:item` (obrigatório) — atributos: `id*`, `label*`, `icon*`, `patch`, `navigate`, `href`, `click`

### DesktopShell

`FrappeUILive.Components.DesktopShell.desktop_shell/1` — Casca de página para desktop: `:sidebar` à esquerda e o conteúdo rolável à direita.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |

**Slots**

- `:inner_block` (obrigatório)
- `:sidebar`

### MobileShell

`FrappeUILive.Components.MobileShell.mobile_shell/1` — Casca para telas estreitas: cabeçalho, conteúdo rolável e navegação inferior (`:nav`).

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `active` | string | não | — |  | id da aba inferior ativa |
| `class` | any | não | — |  |  |

**Slots**

- `:header`
- `:inner_block` (obrigatório)
- `:nav` — atributos: `id*`, `label*`, `icon`, `patch`, `navigate`, `href`, `click`

### ScrollArea

`FrappeUILive.Components.ScrollArea.scroll_area/1` — Região rolável com barras finas e discretas (CSS nativo); focável para rolagem por teclado.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  | defina a altura/largura máxima aqui, ex.: max-h-64 |
| `orientation` | atom | não | `:vertical` | `:vertical`, `:horizontal`, `:both` |  |

**Slots**

- `:inner_block` (obrigatório)

### Divider

`FrappeUILive.Components.Divider.divider/1` — Linha divisória horizontal ou vertical.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `orientation` | atom | não | `:horizontal` | `:horizontal`, `:vertical` |  |

## Dados

### Tree

`FrappeUILive.Components.Tree.tree/1` — Árvore de nós `%{id, label, icon, children}`. Expansão (`expanded`) e seleção (`selected`) são assigns do servidor; cada clique é um evento (`on_toggle`/`on_select` com `%{"id" => id}`). Com `on_drop`, os nós de um mesmo nível podem ser reordenados por arrastar-e-soltar.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `expanded` | list | não | `[]` |  | ids dos nós abertos |
| `id` | string | sim | — |  |  |
| `nodes` | list | sim | — |  |  |
| `on_drop` | string | não | — |  |  |
| `on_select` | string | não | — |  |  |
| `on_toggle` | string | não | — |  |  |
| `selected_id` | any | não | — |  | id do nó selecionado (comparado como texto) |

### Sortable

`FrappeUILive.Components.Sortable.sortable/1` — Lista reordenável por arrastar-e-soltar (HTML5 nativo).

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `id` | string | sim | — |  |  |
| `item_id` | any | não | `&FrappeUILive.Components.Sortable.default_id/1` |  | função item -> id (padrão: `item.id`) |
| `items` | list | sim | — |  |  |
| `on_drop` | string | sim | — |  | evento do servidor: %{"id", "to", "position"} |

**Slots**

- `:item` (obrigatório)

## Charts

### BarChart

`FrappeUILive.Charts.Bar.bar_chart/1` — Gráfico de barras agrupadas (SVG no servidor, cores do tema, estados loading/empty/error).

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `categories` | list | sim | — |  |  |
| `class` | any | não | — |  |  |
| `error` | string | não | — |  |  |
| `height` | integer | não | `240` |  |  |
| `legend` | boolean | não | `true` |  |  |
| `loading` | boolean | não | `false` |  |  |
| `series` | list | sim | — |  | [%{name: String, data: [number]}] |

### LineChart

`FrappeUILive.Charts.Line.line_chart/1` — Gráficos de linha e de área (SVG no servidor), com pontos, dicas e estados.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `categories` | list | sim | — |  |  |
| `class` | any | não | — |  |  |
| `error` | string | não | — |  |  |
| `height` | integer | não | `240` |  |  |
| `legend` | boolean | não | `true` |  |  |
| `loading` | boolean | não | `false` |  |  |
| `series` | list | sim | — |  | [%{name: String, data: [number]}] |

### AreaChart

`FrappeUILive.Charts.Line.area_chart/1` — Gráficos de linha e de área (SVG no servidor), com pontos, dicas e estados.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `categories` | list | sim | — |  |  |
| `class` | any | não | — |  |  |
| `error` | string | não | — |  |  |
| `height` | integer | não | `240` |  |  |
| `legend` | boolean | não | `true` |  |  |
| `loading` | boolean | não | `false` |  |  |
| `series` | list | sim | — |  | [%{name: String, data: [number]}] |

### DonutChart

`FrappeUILive.Charts.Donut.donut_chart/1` — Gráfico de rosca (SVG no servidor). `data` é `[%{label, value}]`; valores ≤ 0 são ignorados.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `center_label` | string | não | — |  | texto no centro (padrão: total) |
| `class` | any | não | — |  |  |
| `data` | list | sim | — |  |  |
| `error` | string | não | — |  |  |
| `legend` | boolean | não | `true` |  |  |
| `loading` | boolean | não | `false` |  |  |

### PercentageBarChart

`FrappeUILive.Charts.Proportion.percentage_bar_chart/1` — Gráficos de proporção: barra percentual empilhada e funil.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `data` | list | sim | — |  | [%{label, value}] |
| `error` | string | não | — |  |  |
| `legend` | boolean | não | `true` |  |  |
| `loading` | boolean | não | `false` |  |  |

### FunnelChart

`FrappeUILive.Charts.Proportion.funnel_chart/1` — Gráficos de proporção: barra percentual empilhada e funil.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `error` | string | não | — |  |  |
| `height` | integer | não | `260` |  |  |
| `loading` | boolean | não | `false` |  |  |
| `steps` | list | sim | — |  | [%{label, value}] em ordem de etapa |

### HeatmapChart

`FrappeUILive.Charts.Matrix.heatmap_chart/1` — Mapas de calor: matriz linhas × colunas e calendário (estilo contribuições).

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `cols` | list | sim | — |  | rótulos das colunas |
| `error` | string | não | — |  |  |
| `loading` | boolean | não | `false` |  |  |
| `rows` | list | sim | — |  | rótulos das linhas |
| `values` | list | sim | — |  | matriz: uma lista de números por linha |

### CalendarHeatmapChart

`FrappeUILive.Charts.Matrix.calendar_heatmap_chart/1` — Mapas de calor: matriz linhas × colunas e calendário (estilo contribuições).

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `data` | map | sim | — |  | %{Date => número} |
| `end_date` | any | não | — |  | último dia exibido (padrão: hoje) |
| `error` | string | não | — |  |  |
| `loading` | boolean | não | `false` |  |  |
| `weeks` | integer | não | `26` |  |  |

### ScatterChart

`FrappeUILive.Charts.Scatter.scatter_chart/1` — Gráfico de dispersão: séries de pontos `{x, y}` em eixos numéricos.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `error` | string | não | — |  |  |
| `height` | integer | não | `260` |  |  |
| `legend` | boolean | não | `true` |  |  |
| `loading` | boolean | não | `false` |  |  |
| `series` | list | sim | — |  | [%{name: String, points: [{x, y}]}] |

### SankeyChart

`FrappeUILive.Charts.Sankey.sankey_chart/1` — Diagrama de Sankey: `links` é `[%{source, target, value}]`; os nós e as colunas (profundidade) são derivados dos links. Ciclos não são suportados e falham alto.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `error` | string | não | — |  |  |
| `height` | integer | não | `280` |  |  |
| `links` | list | sim | — |  |  |
| `loading` | boolean | não | `false` |  |  |

### NumberCard

`FrappeUILive.Charts.NumberCard.number_card/1` — Cartão de indicador: rótulo, valor grande e variação percentual opcional (verde sobe, vermelho cai).

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `delta` | float | não | — |  | variação percentual (ex.: 12.5 ou -3.0) |
| `delta_label` | string | não | — |  |  |
| `error` | string | não | — |  |  |
| `label` | string | sim | — |  |  |
| `loading` | boolean | não | `false` |  |  |
| `value` | any | sim | — |  |  |

### ChartCard

`FrappeUILive.Charts.ChartCard.chart_card/1` — Cartão que enquadra um gráfico: título, subtítulo, ações e o gráfico no corpo.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `subtitle` | string | não | — |  |  |
| `title` | string | sim | — |  |  |

**Slots**

- `:actions`
- `:inner_block` (obrigatório)

### ChartLegend

`FrappeUILive.Charts.Legend.chart_legend/1` — Legenda: marcador colorido + nome. `items` é `[%{label, color}]` ou vem das séries.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `items` | list | sim | — |  | [%{label: String, color: String}] |

### ChartTooltip

`FrappeUILive.Charts.Tooltip.chart_tooltip/1` — Dica de um ponto de dado, desenhada em SVG: aparece quando o pai tem a classe `group` e está em hover/foco (CSS puro). Complementa o `<title>` nativo.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `text` | string | sim | — |  |  |
| `x` | float | sim | — |  | centro horizontal |
| `y` | float | sim | — |  | base da dica (acima do ponto) |

### ChartStates

`FrappeUILive.Charts.Frame.chart_frame/1` — Moldura comum dos gráficos com os estados `:loading`, `:empty` e `:error` (visualmente distintos); no estado `:ready` mostra o gráfico.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `empty_text` | string | não | — |  |  |
| `error` | string | não | — |  |  |
| `height` | integer | não | `240` |  |  |
| `state` | atom | sim | — | `:ready`, `:loading`, `:empty`, `:error` |  |

**Slots**

- `:inner_block` (obrigatório)

## Moléculas

### List

`FrappeUILive.Components.List.list/1` — Tabela de objetos: colunas por slot (`:col`), ações por linha (`:action`), seleção por checkbox e reordenação por arrastar-e-soltar. O estado (`selected`, ordem de `rows`) vive no servidor; cada interação é um evento.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `empty_text` | string | não | — |  |  |
| `id` | string | sim | — |  |  |
| `on_drop` | string | não | — |  | liga o arrastar-e-soltar; evento: %{"id", "to", "position"} |
| `on_select` | string | não | — |  | evento do servidor: %{"id" => id} |
| `row_id` | any | não | `&FrappeUILive.Components.Sortable.default_id/1` |  |  |
| `rows` | list | sim | — |  |  |
| `selectable` | boolean | não | `false` |  | mostra a coluna de seleção (um checkbox por linha) |
| `selected` | list | não | `[]` |  | ids selecionados, comparados como texto |

**Slots**

- `:action`
- `:col` (obrigatório) — atributos: `label*`, `class`

### Editor

`FrappeUILive.Components.Editor.editor/1` — Editor de texto rico (negrito, itálico, título, listas, código, link) que guarda **Markdown** num `<input type=hidden>`, então participa do formulário e do `phx-change` como qualquer campo.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `disabled` | boolean | não | `false` |  |  |
| `errors` | list | não | `[]` |  |  |
| `field` | Phoenix.HTML.FormField | não | — |  |  |
| `id` | any | não | — |  |  |
| `name` | any | não | — |  |  |
| `placeholder` | string | não | — |  |  |
| `value` | any | não | — |  |  |

### CodeEditor

`FrappeUILive.Components.CodeEditor.code_editor/1` — Editor de código: `<textarea>` monoespaçado com numeração de linhas, tecla Tab que indenta e rótulo da linguagem. É um campo de formulário comum (`name`, `phx-change`, `field`).

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `disabled` | boolean | não | `false` |  |  |
| `errors` | list | não | `[]` |  |  |
| `field` | Phoenix.HTML.FormField | não | — |  |  |
| `id` | any | não | — |  |  |
| `language` | string | não | `"text"` |  | rótulo (ex.: "json", "elixir") |
| `name` | any | não | — |  |  |
| `rows` | integer | não | `10` |  |  |
| `value` | any | não | — |  |  |

## Experimental

### Accordion

`FrappeUILive.Components.Accordion.accordion/1` — Seções recolhíveis sobre `<details>` nativo (teclado e leitores de tela de graça). Por padrão só uma seção fica aberta por vez (atributo `name` do HTML, agrupado pelo `id`); com `multiple`, qualquer combinação. `open` no item abre desde o servidor.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `id` | string | sim | — |  |  |
| `multiple` | boolean | não | `false` |  | permite várias seções abertas ao mesmo tempo |

**Slots**

- `:item` (obrigatório) — atributos: `id*`, `title*`, `open`

### Calendar

`FrappeUILive.Components.Calendar.calendar/1` — Calendário mensal com eventos (visão de agenda). O mês exibido e o dia selecionado são assigns do servidor; navegar e escolher são eventos (`on_prev`, `on_next`, `on_today`, `on_select` com `%{"date" => "2026-03-09"}`).

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `events` | list | não | `[]` |  | [%{date: Date \| ISO, title: String, theme: atom}] |
| `id` | string | sim | — |  |  |
| `month` | any | não | — |  | `Date` ou ISO de qualquer dia do mês (padrão: hoje) |
| `on_next` | string | não | — |  |  |
| `on_prev` | string | não | — |  |  |
| `on_select` | string | não | — |  |  |
| `on_today` | string | não | — |  |  |
| `selected` | any | não | — |  |  |
| `today` | any | não | — |  | sobrescreve "hoje" (testes) |

### CommandPalette

`FrappeUILive.Components.CommandPalette.command_palette/1` — Paleta de comandos (Ctrl/⌘ + K): busca, grupos e navegação por teclado. Abre como o `Dialog` (mesmo hook nativo: foco preso, Esc, backdrop) e o hook próprio só filtra a lista, move a seleção com ↑/↓ e aciona o item com Enter. O que cada item *faz* é decidido pelo servidor (`click`) ou por navegação.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `empty_text` | string | não | — |  |  |
| `id` | string | sim | — |  |  |
| `placeholder` | string | não | — |  |  |
| `shortcut` | boolean | não | `true` |  | liga Ctrl/⌘ + K para abrir |

**Slots**

- `:item` (obrigatório) — atributos: `label*`, `group`, `icon`, `keywords`, `shortcut`, `click`, `navigate`, `patch`, `href`

### ListView

`FrappeUILive.Components.ListView.list_view/1` — Lista agrupada e recolhível: `group_by` (função linha → rótulo) forma os grupos; os recolhidos (`collapsed`) são um assign do servidor e o cabeçalho de cada grupo dispara `on_toggle` com `%{"group" => rótulo}`. Colunas por slot, como em `list`. Experimental.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `collapsed` | list | não | `[]` |  | rótulos dos grupos recolhidos |
| `empty_text` | string | não | — |  |  |
| `group_by` | any | não | — |  | função linha -> rótulo do grupo (nil = sem grupos) |
| `id` | string | sim | — |  |  |
| `on_toggle` | string | não | — |  |  |
| `row_id` | any | não | `&FrappeUILive.Components.Sortable.default_id/1` |  |  |
| `rows` | list | sim | — |  |  |

**Slots**

- `:col` (obrigatório) — atributos: `label*`, `class`

### Stepper

`FrappeUILive.Components.Stepper.stepper/1` — Indicador de etapas. A etapa atual (`current`, índice a partir de 0; igual ao número de etapas = tudo concluído) é um assign do servidor, e o estado de cada etapa (`:done | :current | :upcoming`) é derivado dele. Com `on_go`, as etapas concluídas viram botões que voltam para elas (`%{"step" => índice}`). Experimental.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `current` | integer | sim | — |  |  |
| `on_go` | string | não | — |  |  |
| `orientation` | atom | não | `:horizontal` | `:horizontal`, `:vertical` |  |

**Slots**

- `:step` (obrigatório) — atributos: `label*`, `description`

### ThemeSwitcher

`FrappeUILive.Components.ThemeSwitcher.theme_switcher/1` — Alternador claro/escuro. Cada opção é um link `?theme=…` tratado por `FrappeUILive.Plug.Theme`, que persiste a escolha em sessão e cookie; o tema atual (`current`) vem do servidor (`@frappe_ui_theme`). Experimental.

| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |
|---|---|---|---|---|---|
| `class` | any | não | — |  |  |
| `current` | string | sim | — |  | tema ativo: "light" ou "dark" |
| `param` | string | não | `"theme"` |  | nome do parâmetro lido pelo Plug |

