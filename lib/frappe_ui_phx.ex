defmodule FrappeUIPhx do
  @moduledoc """
  Componentes Phoenix LiveView com a identidade visual do Frappe UI.

  ## Uso

      defmodule MyAppWeb do
        defp html_helpers do
          quote do
            use FrappeUIPhx, except: [button: 1, icon: 1, list: 1]   # evita conflito com o core_components
          end
        end
      end

  Importa apenas os componentes do catálogo (`FrappeUIPhx.Components.catalog/0`)
  e `show_dialog/1`/`hide_dialog/1`. Opções (nomes desconhecidos falham na compilação):

    * `except: [button: 1]` — todos, menos estes;
    * `only: [badge: 1, alert: 1]` — apenas estes (útil para evitar colisões em massa).

  Adicionar um componente novo ao catálogo é uma mudança compatível para quem usa `only:`;
  para quem importa tudo, pode colidir com função local de mesmo nome (use `except:`). Componentes que conflitam com os do seu
  `core_components` podem ser chamados com o módulo:
  `<FrappeUIPhx.Components.Button.button>`.

  Veja o `README.md` para instalar CSS, hooks (colocated) e Tailwind.
  """

  @doc false
  defmacro __using__(opts) do
    known = FrappeUIPhx.Components.imports() |> Enum.flat_map(fn {_module, funs} -> funs end)
    except = validate!(Keyword.get(opts, :except, []), known, :except)
    only = if opts[:only], do: validate!(opts[:only], known, :only)

    imports =
      for {module, funs} <- FrappeUIPhx.Components.imports(),
          selected = Enum.filter(funs, &((only == nil or &1 in only) and &1 not in except)),
          selected != [] do
        quote do
          import unquote(module), only: unquote(selected)
        end
      end

    quote do
      (unquote_splicing(imports))
    end
  end

  # Nome desconhecido em `only:`/`except:` (typo, ou componente removido) falha na compilação do host.
  defp validate!(names, known, option) do
    unknown = names -- known

    if unknown != [] do
      raise ArgumentError,
            "use FrappeUIPhx: #{inspect(option)} contém componentes desconhecidos #{inspect(unknown)}. " <>
              "Conhecidos: #{known |> Enum.map(&elem(&1, 0)) |> Enum.sort() |> Enum.join(", ")}"
    end

    names
  end
end
