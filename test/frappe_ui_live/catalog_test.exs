defmodule FrappeUILive.CatalogTest do
  use ExUnit.Case, async: true

  alias FrappeUILive.Components, as: Catalog

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
    {:ok, mods} = :application.get_key(:frappe_ui_live, :modules)

    publicos =
      for mod <- mods,
          String.starts_with?(inspect(mod), "FrappeUILive.Components."),
          Code.ensure_loaded?(mod),
          function_exported?(mod, :__components__, 0),
          {name, %{kind: :def}} <- mod.__components__(),
          do: {mod, name}

    catalogados = for e <- Catalog.catalog(), do: {e.module, e.fun}

    assert publicos -- catalogados == [], "componentes fora do catálogo"
  end

  test "use FrappeUILive importa os componentes, respeitando :except" do
    defmodule UsaTudo do
      use Phoenix.Component
      use FrappeUILive

      def render(assigns) do
        ~H"""
        <.badge label="ok" />
        """
      end
    end

    defmodule UsaSemButton do
      use Phoenix.Component
      use FrappeUILive, except: [button: 1]
      def button(assigns), do: ~H"<b>meu</b>"
      def render(assigns), do: ~H"<.button />"
    end

    assert Phoenix.LiveViewTest.rendered_to_string(UsaTudo.render(%{__changed__: nil})) =~ "ok"

    assert Phoenix.LiveViewTest.rendered_to_string(UsaSemButton.render(%{__changed__: nil})) =~
             "meu"
  end
end
