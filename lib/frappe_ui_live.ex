defmodule FrappeUILive do
  @moduledoc """
  Componentes Phoenix LiveView com a identidade visual do Frappe UI.

  ## Uso

      defmodule MyAppWeb do
        defp html_helpers do
          quote do
            use FrappeUILive, except: [button: 1, icon: 1, list: 1]   # evita conflito com o core_components
          end
        end
      end

  Importa apenas os componentes do catálogo (`FrappeUILive.Components.catalog/0`)
  e `show_dialog/1`/`hide_dialog/1`. Componentes que conflitam com os do seu
  `core_components` podem ser chamados com o módulo:
  `<FrappeUILive.Components.Button.button>`.

  Veja o `README.md` para instalar CSS, hooks (colocated) e Tailwind.
  """

  defmacro __using__(opts) do
    except = Keyword.get(opts, :except, [])

    imports =
      for {module, funs} <- FrappeUILive.Components.imports(),
          only = funs -- except,
          only != [] do
        quote do
          import unquote(module), only: unquote(only)
        end
      end

    quote do
      (unquote_splicing(imports))
    end
  end
end
