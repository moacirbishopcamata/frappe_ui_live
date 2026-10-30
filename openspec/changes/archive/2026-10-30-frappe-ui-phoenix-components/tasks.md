## 1. Pacote e governança

- [x] 1.1 Criar `frappe_ui_live/` com `mix.exs`, `.formatter.exs`, `.gitignore`, `LICENSE` (MIT, atribuição ao Frappe) e `README.md`; verificado com `mix compile --warnings-as-errors`
- [x] 1.2 Inicializar repositório git próprio em `frappe_ui_live/` e fazer o commit inicial; verificado com `git log` (branch de trabalho `worktree-componentes-fase1`)
- [x] 1.3 Configurar `mix test --cover` com limite mínimo de 90%; verificado: rodar um único arquivo de teste falha com exit 3 ("threshold not met")
- [x] 1.4 Dependências nas versões estáveis mais recentes e sem CVE; verificado com `mix deps.audit`, `mix hex.audit` e `npm audit` (0 vulnerabilidades)

## 2. Contratos (DbC) e extensão (SOLID)

- [x] 2.1 `FrappeUILive.Contract` (`require!/3`, `ensure!/2`) com testes de sucesso e de violação
- [x] 2.2 Behaviours `IconResolver`, `ToastSink` e `ErrorTranslator` com implementação padrão e testes

## 3. Design tokens e ícones

- [x] 3.1 `scripts/sync_tokens.mjs` gera `priv/static/frappe_ui.css` e `priv/tokens.provenance.json` a partir dos tokens vendorizados do frappe-ui 1.1.0; verificado rodando o script
- [x] 3.2 Teste de costura: CSS gerado vs. tokens lidos por Node da fonte (todo token claro e escuro, utilitários de cor, proveniência)
- [x] 3.3 `scripts/sync_icons.mjs` gera `priv/static/frappe_ui_icons.css` (Lucide, ISC); teste de costura: todo `lucide-*` renderizado existe no CSS

## 4. Feedback e exibição

- [x] 4.1 Button (variantes, temas, tamanhos, ícones, loading, disabled, link) com `classes/1` pura; testes de render e contrato
- [x] 4.2 Badge, Alert, Spinner, Progress, Skeleton, Avatar, Divider, ErrorMessage e Icon; testes
- [x] 4.3 Toast (container + `put_toast/4` via ToastSink) com colocated hook; teste do evento enviado
- [x] 4.4 LoadingText, KeyboardShortcut e ItemListRow; testes
- [x] 4.5 SavedIndicator: animação CSS remontada por `:key` (sem timer); testes de render e no mostruário

## 5. Formulários

- [x] 5.1 FormLabel, FormControl, TextInput, Textarea com `FormField` e erros; testes de integração com changeset
- [x] 5.2 Checkbox, Switch e Select; testes
- [x] 5.3 Password (valor nunca reenviado), Radio, Slider, Rating (estrelas cheias vindas do servidor); testes e contratos
- [x] 5.4 Combobox e MultiSelect sobre `OptionList` (radios/checkboxes nativos + hook de filtro, `on_search` remoto) — ver D11; testes
- [x] 5.5 DatePicker (LiveComponent + `Calendar` puro), TimePicker, Duration (núcleo `FrappeUILive.Duration` compartilhado com o tipo Ecto), FileUploader sobre `allow_upload` (testado com upload real no mostruário)

## 6. Overlays

- [x] 6.1 Dialog sobre `<dialog>` nativo com colocated hook (JS.ignore_attributes, on_close, backdrop); testes
- [x] 6.2 Dropdown (Popover API + CSS Anchor Positioning) e Tooltip (CSS); testes
- [x] 6.3 Popover, HoverCard, ContextMenu (hook), BottomSheet e SettingsDialog (sobre Dialog com `placement`), KeyboardShortcutsDialog; testes

## 7. Navegação e layout

- [x] 7.1 Tabs (ativo por assign), Breadcrumbs, PageHeader; testes
- [x] 7.2 TabButtons, Sidebar, SidebarRail, DesktopShell, MobileShell, ScrollArea (+ NavItem/MenuItem/Anchor compartilhados); testes

## 8. Dados

- [x] 8.1 List (colunas/ações/seleção por slot e evento) e Tree recursiva com `:key`; testes
- [x] 8.2 Sortable com colocated hook (payload mínimo id/to/position, `Sortable.move/5` puro); reordenação verificada no mostruário

## 9. Charts

- [x] 9.1 BarChart, LineChart, AreaChart, DonutChart em SVG no servidor (ver D9, revisa o plano de ECharts); testes de geometria e estados
- [x] 9.2 Percentage, Funnel, Heatmap, CalendarHeatmap, Scatter, Sankey, NumberCard, ChartCard, ChartLegend, ChartTooltip e estados loading/empty/error; testes

## 10. Editores

- [x] 10.1 Editor (Markdown seguro, ver D10; conversor DOM→Markdown testado em Node) e CodeEditor (numeração, Tab; sem realce de sintaxe — limite documentado no spec)

## 11. Instalação e documentação

- [x] 11.1 `mix frappe_ui_live.install` idempotente (`Installer` puro + task fina, `--dry-run`); testes em app temporário
- [x] 11.2 README com instalação, catálogo, integrações e limites de paridade
- [x] 11.3 Verificado num app gerado do zero com `mix phx.new` (Phoenix 1.8.16): instalador, `use FrappeUILive` convivendo com o `core_components`, compilação sem warnings, assets (CSS/JS) e GET / com 200

## 12. Qualidade

- [x] 12.1 Cobertura ≥ 90% (biblioteca 99%, mostruário 98%), `mix format --check-formatted`, `compile --warnings-as-errors` e `deps.audit` verdes (`mix quality`)
- [x] 12.2 Revisão de arquitetura (OO design, Clean Architecture e API design) executada; achados críticos e importantes corrigidos (seção 17) com testes de regressão

## 13. Mostruário navegável (`showcase/`)

- [x] 13.1 `FrappeUILive.Spec`: especificação derivada de `__components__/0` (atributos, valores, slots, moduledoc), `defaults/1` e `cast/2`; testes
- [x] 13.2 App `showcase/` (Phoenix + Bandit + esbuild + Tailwind v4) consumindo a lib por `path:` e os hooks colocated; `mix assets.build` gera CSS e JS
- [x] 13.3 Índice por categoria, menu lateral, playground por formulário com prévia ao vivo e trecho de uso, aba de especificação, violação de contrato visível, tema
- [x] 13.4 Testes do mostruário (LiveViewTest): todos os componentes montam, playground, contrato, ícones, tema, assets; verificado também subindo o servidor e consultando por HTTP (200 em todas as rotas)

## 14. Integrações Ecto e Plug

- [x] 14.1 `Ecto.Type` Duration, `Ecto.ParameterizedType` Rating, `Ecto.Type` StringList, `Options.from_enum/2`; testes incluindo ida e volta
- [x] 14.2 `Plug.Theme`, `Plug.Static`, `Live.ThemeHook`; testes com `Plug.Test` e releitura por requisição independente
- [x] 14.3 Teste de costura Ecto changeset → `FormField` → erros dos controles (campo tocado vs. não tocado)

## 15. Fundamentos

- [x] 15.1 `scripts/lib/build_foundations.mjs` + `priv/foundations.json` gerados junto do CSS (`mix tokens.sync`); `@theme static` para raios e sombras ficarem disponíveis às páginas
- [x] 15.2 `FrappeUILive.Foundations` (dados dos fundamentos, chaves átomo) e teste de costura JSON ⇄ CSS (todo token documentado existe como variável e utilitário)
- [x] 15.3 Páginas Colors, Typography, Radius, Shadows, Focus ring e Chart colors no mostruário (`/f/:id`), pelas variáveis do tema; testes de navegação e de conteúdo

## 16. Moléculas e Experimentais

- [x] 16.1 Categoria Moléculas (List, Editor, CodeEditor) no catálogo e no mostruário
- [x] 16.2 Accordion, Calendar, CommandPalette, ListView, Stepper e ThemeSwitcher com testes unitários e de contrato
- [x] 16.3 Amostras e estado de servidor dos experimentais no mostruário (calendário, grupos recolhidos, etapas, paleta); testes de comportamento

## 17. Achados da revisão de arquitetura (12.2)

- [x] 17.0 Revisão executada com os três revisores (OO design, Clean Architecture, API design); relatório resumido na conversa e no README
- [x] 17.1 C-1: a mix task falha com opção inválida/posicional/`--help` e não grava nada (testes de regressão)
- [x] 17.2 I-2: fallback de `handle_event` no DatePicker e no CatalogLive (evento forjado é ignorado)
- [x] 17.3 I-1: `active` desconhecido (ex.: `?tab=lixo`) não derruba Tabs, TabButtons, SettingsDialog, Sidebar, SidebarRail e MobileShell (`NavItem.known_active/2`)
- [x] 17.4 I-3/I-4: `Field.require_id!/2` (Editor, CodeEditor, Combobox, MultiSelect, Password) e validação de id dentro de `Anchor`, `Dialog`, `show_dialog/1` e `hide_dialog/1`
- [x] 17.5 I-5: `Sortable.root_attrs/1`, `item_attrs/3` e nome do hook derivado do módulo (teste contra o manifesto); Tree só reordena entre irmãos
- [x] 17.6 I-6/I-7: casca de painel única (`Anchor.panel_classes/0`) e item de navegação unificado: `Action` decide link ou botão; `NavItem`, `MenuItem` e `Tabs` usam; slots com o mesmo vocabulário (`id`, `label`, `icon`, `patch`, `navigate`, `href`, `click`). **Fora**: gatilho de campo compartilhado entre OptionList/DatePicker (menor)
- [x] 17.7 I-8/I-9: Toast com contêiner `phx-update=ignore`, paleta única e timers limpos; Markdown sem open-redirect `/\`, código e links antes da ênfase, `to_safe/1`, teste de paridade JS ⇄ Elixir da regex de URL
- [x] 17.8 I-10/I-11: `use FrappeUILive` com `only:`/validação; `Spec` movido para o mostruário (`Showcase.Spec`, fora do pacote Hex); amostras explícitas por componente (`Samples.generic_ids/0`; id novo sem amostra falha alto) com testes
- [x] 17.9 I-12/I-14/I-15/I-16/I-18/I-20: `rest` global uniforme; textos via `Texts`/`Translator`; precedência documentada de `Field.assign_field/2` (`multiple:` explícito); DatePicker com `class`/`errors` e `value` nil limpando; behaviours com fachada e módulo configurado validado (`FrappeUILive.Config`), tradutor padrão em `ErrorTranslator.Default`; `List` com `selectable` + `selected` e `Tree` com `selected_id`. `ThemeHook` com `default:` e chave da sessão compartilhada com o `Plug.Theme`
- [x] 17.10 I-17/I-19: `Plug.Static` serve também o CSS de ícones; `Plug.Theme` só grava a sessão quando muda; `Contract.require!/3` aceita qualquer Enumerable

## 18. Home do mostruário

- [x] 18.1 A home lista todos os componentes do catálogo em cartões do mesmo estilo, agrupados por categoria, cada um com **prévia ao vivo** inerte (título como "stretched link", sem `<a>` aninhado), mais Fundamentos e a lista de blocos internos; testes (prévia em todo cartão, HTML sem links aninhados e ids únicos, contagens)
