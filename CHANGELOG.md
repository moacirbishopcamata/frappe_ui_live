# Changelog

Versionamento [semântico](https://semver.org/lang/pt-BR/). Todo commit incrementa a versão
(`feat` = minor, `fix`/`docs`/`chore` = patch).

## 0.3.1

### Alterado
- CI: o job do Elixir 1.18 (versão mínima do `mix.exs`) passa a ser bloqueante, como o do 1.20.

## 0.3.0

### Alterado (incompatível)
- **Renomeado para Frappe UI Phx.** Pacote e app `frappe_ui_live` → `frappe_ui_phx`; módulos `FrappeUILive.*` → `FrappeUIPhx.*`;
  tarefa `mix frappe_ui_live.install` → `mix frappe_ui_phx.install`; chave de configuração `:frappe_ui_live` → `:frappe_ui_phx`;
  hooks `phoenix-colocated/frappe_ui_live` → `phoenix-colocated/frappe_ui_phx`.
  Migração: troque o nome da dependência e do import dos hooks, rode `mix frappe_ui_phx.install` e faça a substituição
  `FrappeUILive` → `FrappeUIPhx` / `frappe_ui_live` → `frappe_ui_phx` no seu código e no `config/`.

### Adicionado
- **CI no GitHub Actions** (`.github/workflows/ci.yml`): formatação, compilação sem warnings, testes unitários com cobertura mínima
  (lib 90%, mostruário 80%), testes de costura em Node, auditoria de dependências e bloqueio de dependência com vulnerabilidade
  conhecida no Hex; relatório de cobertura no resumo do job e como artefato.

### Segurança
- `phoenix_html` 4.3.0 → 4.4.0 (EEF-CVE-2026-117645, injeção de atributos em `attributes_escape/1`); o mínimo exigido passa a `~> 4.4`.

## 0.2.0

### Adicionado
- **Ícones Lucide**: todos os ~2.000 ícones como componentes LiveView (`<Lucide.plus />`, `<.icon name="..." />`), com `size`, `color`,
  `stroke_width`, `absolute_stroke_width` e `title`; `FrappeUIPhx.Icons` (`names/get/search/version`); página `/icones` no mostruário.
- **`pin_code`**: código de verificação com uma caixa por caractere, colar o código inteiro e `on_complete`.
- **`dice_bear_avatar`** e `FrappeUIPhx.DiceBear`: avatares da API DiceBear 10.x, opções do núcleo tipadas e validadas, receita de placeholder.
- README completo de instalação e uso, `docs/componentes.md` (referência gerada do código), `docs/arquitetura.md` e `THIRD_PARTY_LICENSES.md`.

### Alterado
- `IconResolver` passa a ter o callback `name/1` (era `class/1`).
- `avatar`: imagens carregam sob demanda e sem `Referer`.
- O instalador não importa mais o CSS de ícones.

### Descontinuado
- `priv/static/frappe_ui_icons.css` e as classes `.lucide-*` (82 ícones, congelado); serão removidos na próxima versão.

## 0.1.0

- Primeira versão: ~76 componentes (formulários, feedback, overlays, navegação, dados, charts, moléculas e experimentais), fundamentos,
  integrações com Ecto e Plug, instalador e mostruário.
