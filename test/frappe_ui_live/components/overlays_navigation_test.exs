defmodule FrappeUILive.Components.OverlaysNavigationTest do
  use FrappeUILive.Case, async: true

  alias FrappeUILive.Components.{
    Breadcrumbs,
    Dialog,
    Dropdown,
    PageHeader,
    Tabs,
    Toast,
    Tooltip
  }

  alias Phoenix.LiveView.JS

  describe "Dialog" do
    test "é um <dialog> nativo com hook colocated e título associado" do
      assigns = %{}

      html =
        rendered_to_string(~H|<Dialog.dialog id="d1" title="Confirmar">Corpo</Dialog.dialog>|)

      assert has?(html, "dialog#d1")
      assert html_attr(html, "dialog", "aria-labelledby") == "d1-title"
      assert text(html, "#d1-title") == "Confirmar"
      assert html_attr(html, "dialog", "data-open") == "false"
      assert html_attr(html, "dialog", "phx-hook") =~ "Dialog"
      assert html =~ "Corpo"
    end

    test "open, on_close e backdrop viram data-attributes lidos pelo hook" do
      assigns = %{}

      html =
        rendered_to_string(
          ~H|<Dialog.dialog id="d2" open on_close="fechou" close_on_backdrop={false} size={:sm}>
  <:actions>OK</:actions>x
</Dialog.dialog>|
        )

      assert html_attr(html, "dialog", "data-open") == "true"
      assert html_attr(html, "dialog", "data-on-close") == "fechou"
      assert html_attr(html, "dialog", "data-backdrop-close") == "false"
      assert html_attr(html, "dialog", "class") =~ "max-w-sm"
      assert html =~ "OK"
    end

    test "show_dialog/hide_dialog geram comandos JS para o elemento" do
      assert %JS{ops: [["dispatch", %{event: "fui:dialog-open", to: "#d1"}]]} =
               Dialog.show_dialog("d1")

      assert %JS{ops: [["dispatch", %{event: "fui:dialog-close", to: "#d1"}]]} =
               Dialog.hide_dialog("d1")
    end

    test "id inválido e tamanho inválido violam o contrato" do
      assigns = %{}

      assert_raise ArgumentError, ~r/dialog id/, fn ->
        rendered_to_string(~H|<Dialog.dialog id="1 inválido">x</Dialog.dialog>|)
      end

      assert_raise ArgumentError, ~r/dialog size/, fn ->
        rendered_to_string(~H|<Dialog.dialog id="ok" size={:xxl}>x</Dialog.dialog>|)
      end
    end
  end

  describe "Dropdown" do
    test "usa Popover API: gatilho aponta para o menu e o menu ancora no gatilho" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Dropdown.dropdown id="menu" label="Ações">
          <:item label="Editar" click="editar" icon="plus" />
          <:item label="Abrir" navigate="/x" />
          <:item label="Excluir" click="excluir" theme={:red} />
        </Dropdown.dropdown>
        """)

      assert html_attr(html, "button[popovertarget=menu]", "style") =~ "anchor-name: --fui-menu"
      assert has?(html, "div#menu[popover]")
      assert html_attr(html, "#menu", "style") =~ "position-anchor: --fui-menu"
      assert html_attr(html, "#menu", "style") =~ "flip-block"
      assert html_attr(html, "[role=menuitem][phx-click=editar]", "popovertargetaction") == "hide"
      assert html_attr(html, "a[role=menuitem]", "href") == "/x"
      assert html_attr(html, "[phx-click=excluir]", "class") =~ "text-ink-red-3"
    end

    test "gatilho personalizado substitui o botão padrão" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Dropdown.dropdown id="m2">
          <:trigger>Abrir</:trigger>
          <:item label="a" click="a" />
        </Dropdown.dropdown>
        """)

      assert text(html, "button[aria-haspopup=menu]") == "Abrir"
      refute html =~ "lucide-chevron-down"
    end

    test "id vira parte de CSS inline, então tem pré-condição de formato" do
      assigns = %{}

      assert_raise ArgumentError, ~r/dropdown id/, fn ->
        rendered_to_string(
          ~H|<Dropdown.dropdown id="x; color: red"><:item label="a" click="a" /></Dropdown.dropdown>|
        )
      end
    end
  end

  describe "Tooltip" do
    test "mostra em hover e foco, posicionado" do
      assigns = %{}

      html =
        rendered_to_string(
          ~H|<Tooltip.tooltip text="Dica" placement={:bottom}><button>?</button></Tooltip.tooltip>|
        )

      assert html_attr(html, "[role=tooltip]", "class") =~ "top-full"
      assert html_attr(html, "[role=tooltip]", "class") =~ "group-focus-within/tooltip:visible"
      assert text(html, "[role=tooltip]") == "Dica"
    end

    test "posição inválida viola o contrato" do
      assigns = %{}

      assert_raise ArgumentError, ~r/tooltip placement/, fn ->
        rendered_to_string(~H|<Tooltip.tooltip text="x" placement={:meio}>y</Tooltip.tooltip>|)
      end
    end
  end

  describe "Tabs" do
    defp tabs_html(active) do
      assigns = %{active: active}

      rendered_to_string(~H"""
      <Tabs.tabs id="t" active={@active}>
        <:tab id="a" label="Geral" patch="/a" />
        <:tab id="b" label="Itens" click="ir_b" icon="plus" /> Painel
      </Tabs.tabs>
      """)
    end

    test "o item ativo vem do assign" do
      html = tabs_html("b")
      assert html_attr(html, "[role=tab][aria-selected=true]", "phx-click") == "ir_b"
      assert has?(html, "a[role=tab][aria-selected=false]")
      assert html_attr(html, "a[role=tab]", "data-phx-link") == "patch"
      assert has?(html, "#t-panel[role=tabpanel]")
    end

    test "trocar o assign troca só a aba ativa (releitura por outro caminho)" do
      a = tabs_html("a")
      assert has?(a, "a[role=tab][aria-selected=true]")
      assert has?(a, "button[role=tab][aria-selected=false]")
    end

    test "aba ativa desconhecida (ex.: ?tab=lixo) não derruba: nenhuma fica ativa" do
      html = tabs_html("zzz")
      refute has?(html, "[aria-selected=true]")
      assert Enum.count(query(html, "[role=tab]")) == 2
    end
  end

  describe "Breadcrumbs e PageHeader" do
    test "último item é a página atual, os anteriores são links" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Breadcrumbs.breadcrumbs>
          <:item label="Início" navigate="/" />
          <:item label="Pedidos" patch="/p" />
          <:item label="#42" />
        </Breadcrumbs.breadcrumbs>
        """)

      assert Enum.count(query(html, "a")) == 2
      assert text(html, "[aria-current=page]") == "#42"
      assert html =~ "lucide-chevron-right"
    end

    test "PageHeader mostra título, subtítulo, breadcrumbs e ações" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <PageHeader.page_header title="Pedidos" subtitle="Todos">
          <:breadcrumbs>BC</:breadcrumbs>
          <:actions>Novo</:actions>
        </PageHeader.page_header>
        """)

      assert text(html, "h1") == "Pedidos"
      assert html =~ "Todos"
      assert html =~ "BC"
      assert html =~ "Novo"
    end
  end

  describe "Toast container" do
    test "renderiza flash info e error, com hook colocated" do
      assigns = %{flash: %{"info" => "Salvo", "error" => "Falhou", "outro" => "ignorado"}}
      html = rendered_to_string(~H|<Toast.toast_container flash={@flash} />|)
      assert html_attr(html, "#frappe-ui-toasts", "phx-hook") =~ "Toast"
      assert text(html, "#frappe-ui-toasts-flash-info") =~ "Salvo"
      assert text(html, "#frappe-ui-toasts-flash-error") =~ "Falhou"
      refute html =~ "ignorado"
    end

    test "sem flash não renderiza itens" do
      assigns = %{}
      refute has?(rendered_to_string(~H|<Toast.toast_container />|), "[role=status]")
    end
  end
end
