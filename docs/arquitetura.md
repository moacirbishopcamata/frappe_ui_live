# Arquitetura e engenharia

> Decisões de projeto, contratos e a revisão de arquitetura da v0.1. Para instalar e usar, veja o [README](../README.md).

## Engenharia (SOLID, DbC, testes)

- **DbC**: `FrappeUILive.Contract` — `require!/3` (pré-condição: `variant: :sombrio` levanta `ArgumentError`,
  não renderiza errado em silêncio) e `ensure!/2` (pós-condição/invariante). Entrada de usuário nunca levanta:
  vira `errors` do `FormField`; eventos forjados do cliente (ex.: data fora de `min`/`max`) são ignorados.
- **SOLID**: um módulo por componente; extensão por `@behaviour` (`IconResolver`, `ToastSink`, `ErrorTranslator`),
  sem herança de implementação; estilo e geometria em funções puras (`InputStyle`, `Button.classes/1`, `Charts.Scale`...).
- **Testes**: `mix test --cover` (limite mínimo 90%; hoje ~98%). Inclui testes de **costura**:
  tokens do Frappe UI (lidos por Node, da fonte) ⇄ CSS gerado; catálogo de ícones ⇄ `lucide-static` (arquivos, tags, aliases);
  Ecto changeset ⇄ `FormField` ⇄ componente; sessão ⇄ tema; DOM do editor ⇄ Markdown (executado em Node).

```sh
mix quality   # format --check-formatted, compile --warnings-as-errors, test --cover, deps.audit
```

## Revisão de arquitetura

Feita com três revisores (OO design, Clean Architecture, API design): sem ciclos de dependência e sem XSS explorável;
extensão por `@behaviour`, funções puras e `Contract` consistentes. Veredito inicial: mudanças solicitadas (1 crítico, 20
importantes). **Já corrigidos** (com testes de regressão):

- mix task grava arquivos mesmo com opção inválida (`--dryrun`);
- `?tab=lixo` derrubava Tabs/TabButtons/SettingsDialog/Sidebar; `DatePicker` sem fallback para evento forjado;
- `id` obrigatório com erro uniforme e validação central (`Anchor`, `Dialog`, `Field.require_id!/2`);
- protocolo de DOM do Sortable encapsulado, nome do hook derivado e Tree só reordena entre irmãos;
- Markdown (open-redirect `/\`, ordem de ênfase/links, `to_safe/1`) e Toast (contêiner `phx-update=ignore`, paleta única);
- `use FrappeUILive` com `only:` e validação de nomes; casca de painel única; `Plug.Static`/`Plug.Theme`; `Contract.require!/3`;
- item de navegação unificado: `Action` decide link ou botão (`NavItem`, `MenuItem`, `Tabs`) e os slots usam o mesmo vocabulário.

- `rest` global uniforme em todos os componentes com elemento raiz e textos fixos configuráveis (`FrappeUILive.Texts`).

- `Spec` saiu do pacote (é do mostruário); pontos de extensão (`IconResolver`, `ToastSink`, `ErrorTranslator`, `Translator`) com
  fachada e módulo configurado validado; `Field.assign_field/2` com precedência documentada; `List` com `selectable`/`selected`
  e `Tree` com `selected_id`; DatePicker alinhado aos outros campos.

Sem pendências da revisão. O tema padrão também vale no LiveView: `on_mount: [{FrappeUILive.Live.ThemeHook, default: "dark"}]`.
