defmodule FrappeUIPhx.CatalogTest do
  use ExUnit.Case, async: true

  alias FrappeUIPhx.Components, as: Catalog

  test "toda entrada do catálogo aponta para um componente que existe" do
    for entry <- Catalog.catalog() do
      assert Code.ensure_loaded?(entry.module), "módulo #{inspect(entry.module)} ausente"

      assert function_exported?(entry.module, entry.fun, 1),
             "#{inspect(entry.module)}.#{entry.fun}/1 ausente"

      assert entry.category in Keyword.keys(Catalog.categories())
    end
  end

  test "ids são únicos e get/1 encontra por id" do
    ids = Enum.map(Catalog.catalog(), & &1.id)
    assert ids == Enum.uniq(ids)
    assert Catalog.get(:button).title == "Button"
    assert Catalog.get(:inexistente) == nil
  end

  test "todo componente público do pacote está no catálogo (nada fica sem documentação)" do
    {:ok, mods} = :application.get_key(:frappe_ui_phx, :modules)

    publicos =
      for mod <- mods,
          String.starts_with?(inspect(mod), "FrappeUIPhx.Components.") or
            String.starts_with?(inspect(mod), "FrappeUIPhx.Charts."),
          Code.ensure_loaded?(mod),
          function_exported?(mod, :__components__, 0),
          {name, %{kind: :def}} <- mod.__components__(),
          do: {mod, name}

    catalogados = for(e <- Catalog.catalog(), do: {e.module, e.fun}) ++ Catalog.internal()

    assert publicos -- catalogados == [], "componentes fora do catálogo"
  end

  test "use FrappeUIPhx importa os componentes, respeitando :except" do
    defmodule UsaTudo do
      use Phoenix.Component
      use FrappeUIPhx

      def render(assigns) do
        ~H"""
        <.badge label="ok" />
        """
      end
    end

    defmodule UsaSemButton do
      use Phoenix.Component
      use FrappeUIPhx, except: [button: 1]
      def button(assigns), do: ~H"<b>meu</b>"
      def render(assigns), do: ~H"<.button />"
    end

    # regressão: um segundo `import` do mesmo módulo sobrescrevia o primeiro e escondia `dialog/1`
    defmodule UsaDialog do
      use Phoenix.Component
      use FrappeUIPhx

      def render(assigns) do
        ~H"""
        <button phx-click={show_dialog("d")}>abrir</button>
        <.dialog id="d">corpo</.dialog>
        """
      end
    end

    dialog_html = Phoenix.LiveViewTest.rendered_to_string(UsaDialog.render(%{__changed__: nil}))
    assert dialog_html =~ "<dialog"
    assert dialog_html =~ "fui:dialog-open"

    assert Phoenix.LiveViewTest.rendered_to_string(UsaTudo.render(%{__changed__: nil})) =~ "ok"

    assert Phoenix.LiveViewTest.rendered_to_string(UsaSemButton.render(%{__changed__: nil})) =~
             "meu"
  end
end
