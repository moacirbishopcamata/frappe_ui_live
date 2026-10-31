# Changelog

Versionamento [semântico](https://semver.org/lang/pt-BR/). Todo commit incrementa a versão
(`feat` = minor, `fix`/`docs`/`chore` = patch).

## 0.2.0

### Adicionado
- **Ícones Lucide**: todos os ~2.000 ícones como componentes LiveView (`<Lucide.plus />`, `<.icon name="..." />`), com `size`, `color`,
  `stroke_width`, `absolute_stroke_width` e `title`; `FrappeUILive.Icons` (`names/get/search/version`); página `/icones` no mostruário.
- **`pin_code`**: código de verificação com uma caixa por caractere, colar o código inteiro e `on_complete`.
- **`dice_bear_avatar`** e `FrappeUILive.DiceBear`: avatares da API DiceBear 10.x, opções do núcleo tipadas e validadas, receita de placeholder.
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
