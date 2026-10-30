defmodule FrappeUILive.Installer do
  @moduledoc """
  Edições idempotentes nos arquivos do app host (CSS, JS, `mix.exs`), em funções
  puras `conteúdo -> {:ok, novo, mudou?} | {:error, motivo}`. A task
  `mix frappe_ui_live.install` só lê/escreve arquivos em volta delas.

  Idempotência é a pós-condição principal: aplicar duas vezes devolve o mesmo
  conteúdo e `mudou? == false` na segunda.
  """

  @js_import ~s|import {hooks as frappeUiHooks} from "phoenix-colocated/frappe_ui_live"|

  @type result :: {:ok, String.t(), boolean()} | {:error, atom()}

  @doc """
  Acrescenta os `@import` do CSS de tokens e o `@source` dos componentes
  logo depois de `@import "tailwindcss"`. `rel` é o caminho da dependência a partir
  do `app.css` (ex.: `"../../deps/frappe_ui_live"`).
  """
  @spec patch_css(String.t(), String.t()) :: result()
  def patch_css(content, rel) do
    cond do
      String.contains?(content, "frappe_ui.css") ->
        {:ok, content, false}

      not Regex.match?(~r/^@import\s+["']tailwindcss["']/m, content) ->
        {:error, :no_tailwind_import}

      true ->
        block =
          ~s|@import "#{rel}/priv/static/frappe_ui.css";\n| <>
            ~s|@source "#{rel}/lib";|

        patched =
          Regex.replace(~r/^(@import\s+["']tailwindcss["'][^\n]*)$/m, content, "\\1\n" <> block,
            global: false
          )

        {:ok, patched, true}
    end
  end

  @doc """
  Importa os hooks colocated da biblioteca e os junta ao objeto `hooks:` do
  `LiveSocket` (acompanha o `colocatedHooks` do Phoenix 1.8 quando existe).
  """
  @spec patch_js(String.t()) :: result()
  def patch_js(content) do
    cond do
      String.contains?(content, "phoenix-colocated/frappe_ui_live") ->
        {:ok, content, false}

      not Regex.match?(~r/hooks:\s*\{/, content) ->
        {:error, :no_hooks_option}

      not Regex.match?(~r/^import .*$/m, content) ->
        {:error, :no_imports}

      true ->
        {:ok, content |> add_js_import() |> add_hooks_spread(), true}
    end
  end

  defp add_js_import(content) do
    lines = String.split(content, "\n")

    last_import =
      lines
      |> Enum.with_index()
      |> Enum.filter(fn {l, _} -> String.starts_with?(l, "import ") end)
      |> List.last()
      |> elem(1)

    lines |> List.insert_at(last_import + 1, @js_import) |> Enum.join("\n")
  end

  defp add_hooks_spread(content) do
    if Regex.match?(~r/hooks:\s*\{\s*\.\.\.colocatedHooks\s*\}/, content) do
      Regex.replace(
        ~r/hooks:\s*\{\s*\.\.\.colocatedHooks\s*\}/,
        content,
        "hooks: {...colocatedHooks, ...frappeUiHooks}",
        global: false
      )
    else
      Regex.replace(~r/hooks:\s*\{/, content, "hooks: {...frappeUiHooks, ", global: false)
    end
  end

  @doc """
  O `mix.exs` do host compila com `:phoenix_live_view` (necessário para extrair os
  hooks colocated)? Não edita o arquivo; devolve `:ok` ou `{:missing, instrução}`.
  """
  @spec check_compilers(String.t()) :: :ok | {:missing, String.t()}
  def check_compilers(mix_exs) do
    if Regex.match?(~r/compilers:\s*\[\s*:phoenix_live_view/, mix_exs),
      do: :ok,
      else:
        {:missing,
         "adicione `compilers: [:phoenix_live_view] ++ Mix.compilers()` ao project/0 do mix.exs"}
  end

  @doc "Caminho da dependência relativo a `from_dir` (ambos absolutos)."
  @spec relative(String.t(), String.t()) :: String.t()
  def relative(dep_path, from_dir),
    do: Path.relative_to(Path.expand(dep_path), Path.expand(from_dir), force: true)
end
