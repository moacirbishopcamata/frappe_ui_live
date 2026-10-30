defmodule Mix.Tasks.FrappeUiLive.Install do
  @shortdoc "Configura CSS, hooks e compilers do app host para usar frappe_ui_live"

  @moduledoc """
  Configura o app Phoenix atual para usar a biblioteca. Idempotente: pode rodar
  quantas vezes quiser.

      mix frappe_ui_live.install            # aplica
      mix frappe_ui_live.install --dry-run  # só mostra o que faria

  O que faz:

    * `assets/css/app.css`: importa `frappe_ui.css` (tokens) e `frappe_ui_icons.css`
      e adiciona `@source` para os componentes (depois de `@import "tailwindcss"`);
    * `assets/js/app.js`: importa os hooks colocated e os soma ao `hooks:` do `LiveSocket`;
    * `mix.exs`: **só verifica** `compilers: [:phoenix_live_view] ++ Mix.compilers()`.

  Opções: `--dry-run`, `--dep-path CAMINHO` (padrão: onde o Mix achou a dependência).
  """
  use Mix.Task

  alias FrappeUILive.Installer

  @css "assets/css/app.css"
  @js "assets/js/app.js"

  @impl Mix.Task
  def run(args) do
    {opts, positional, invalid} =
      OptionParser.parse(args, strict: [dry_run: :boolean, dep_path: :string, help: :boolean])

    # Pré-condição: opção desconhecida (ex.: --dryrun) nunca pode virar "aplicar de verdade".
    if invalid != [] or positional != [] do
      bad = Enum.map(invalid, &elem(&1, 0)) ++ positional

      Mix.raise(
        "argumentos inválidos: #{Enum.join(bad, ", ")}. Veja `mix help frappe_ui_live.install`"
      )
    end

    if opts[:help],
      do: Mix.raise("uso: mix frappe_ui_live.install [--dry-run] [--dep-path CAMINHO]")

    dep_path = opts[:dep_path] || dep_path!()
    dry? = Keyword.get(opts, :dry_run, false)

    css_rel = Installer.relative(dep_path, Path.dirname(@css))

    results = [
      edit(@css, &Installer.patch_css(&1, css_rel), dry?),
      edit(@js, &Installer.patch_js/1, dry?),
      check_mix_exs()
    ]

    if Enum.any?(results, &(&1 == :error)) do
      Mix.raise("instalação incompleta; veja as mensagens acima")
    end

    Mix.shell().info("""

    Falta só usar os componentes. No módulo `html_helpers` do seu `MyAppWeb`:

        use FrappeUILive, except: [button: 1, icon: 1, list: 1]   # evita conflito com o core_components

    e, no layout raiz, `<html data-theme={@frappe_ui_theme}>` com `plug FrappeUILive.Plug.Theme`.
    """)
  end

  defp dep_path! do
    Mix.Project.deps_paths()[:frappe_ui_live] ||
      Mix.raise("dependência :frappe_ui_live não encontrada; use --dep-path CAMINHO")
  end

  defp edit(path, patch, dry?) do
    case File.read(path) do
      {:ok, content} -> apply_patch(path, patch.(content), dry?)
      {:error, _} -> error("#{path} não existe (rode na raiz de um app Phoenix 1.8)")
    end
  end

  defp apply_patch(path, {:ok, _content, false}, _dry?), do: info("#{path}: já configurado")

  defp apply_patch(path, {:ok, patched, true}, true),
    do: info("#{path}: seria atualizado (#{byte_size(patched)} bytes)")

  defp apply_patch(path, {:ok, patched, true}, false) do
    File.write!(path, patched)
    info("#{path}: atualizado")
  end

  defp apply_patch(path, {:error, :no_tailwind_import}, _),
    do: error("#{path}: não achei `@import \"tailwindcss\"` (Tailwind v4 é requisito)")

  defp apply_patch(path, {:error, :no_hooks_option}, _),
    do: error("#{path}: não achei a opção `hooks:` do LiveSocket")

  defp apply_patch(path, {:error, :no_imports}, _),
    do: error("#{path}: não achei nenhum `import` (o app.js do Phoenix 1.8 tem vários)")

  defp apply_patch(path, {:error, reason}, _), do: error("#{path}: #{inspect(reason)}")

  defp check_mix_exs do
    case File.read("mix.exs") do
      {:ok, content} ->
        case Installer.check_compilers(content) do
          :ok -> info("mix.exs: compilers ok")
          {:missing, instruction} -> error("mix.exs: " <> instruction)
        end

      {:error, _} ->
        error("mix.exs não encontrado")
    end
  end

  defp info(message), do: Mix.shell().info("  ✓ " <> message)

  defp error(message) do
    Mix.shell().error("  ✗ " <> message)
    :error
  end
end
