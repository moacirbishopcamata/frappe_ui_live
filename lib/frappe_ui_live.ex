defmodule FrappeUILive do
  @moduledoc """
  Componentes Phoenix LiveView com a identidade visual do Frappe UI.

  ## Uso

      defmodule MyAppWeb do
        defp html_helpers do
          quote do
            use FrappeUILive, except: [button: 1, icon: 1]   # evita conflito com core_components
          end
        end
      end

  Componentes que conflitam com os do seu `core_components` podem ser
  chamados com o módulo: `<FrappeUILive.Components.Button.button>`.

  Veja o `README.md` para instalar CSS, hooks (colocated) e Tailwind.
  """

  defmacro __using__(opts) do
    except = Keyword.get(opts, :except, [])

    imports =
      for module <- FrappeUILive.Components.modules() do
        quote do
          import unquote(module), except: unquote(except)
        end
      end

    quote do
      (unquote_splicing(imports))
    end
  end
end
