defmodule FrappeUILive.Components.LayoutMoreTest do
  use FrappeUILive.Case, async: true

  alias FrappeUILive.Components.{
    BottomSheet,
    ContextMenu,
    DesktopShell,
    Dialog,
    HoverCard,
    ItemListRow,
    KeyboardShortcut,
    KeyboardShortcutsDialog,
    List,
    LoadingText,
    MenuItem,
    MobileShell,
    NavItem,
    Popover,
    SavedIndicator,
    ScrollArea,
    SettingsDialog,
    Sidebar,
    SidebarRail,
    Sortable,
    TabButtons,
    Tree
  }

  describe "peças simples" do
    test "LoadingText, KeyboardShortcut e ItemListRow" do
      assigns = %{}

      assert text(rendered_to_string(~H|<LoadingText.loading_text text="Buscando…" />|), "span") =~
               "Buscando…"

      assert has?(rendered_to_string(~H|<LoadingText.loading_text />|), "svg[role=status]")

      keys = rendered_to_string(~H|<KeyboardShortcut.keyboard_shortcut keys={["Ctrl", "K"]} />|)
      assert Enum.count(query(keys, "kbd")) == 2

      row =
        rendered_to_string(
          ~H|<ItemListRow.item_list_row title="Pedido" subtitle="#42" navigate="/p/42">
  <:icon>I</:icon><:actions>A</:actions>
</ItemListRow.item_list_row>|
        )

      assert html_attr(row, "a", "href") == "/p/42"
      assert row =~ "#42" and row =~ "I" and row =~ "A"
      refute has?(rendered_to_string(~H|<ItemListRow.item_list_row title="x" />|), "a")
    end

    test "SavedIndicator só aparece com valor e cada valor novo é um elemento novo (chave)" do
      assigns = %{}
      refute has?(rendered_to_string(~H|<SavedIndicator.saved_indicator />|), ".fui-saved")

      shown =
        rendered_to_string(
          ~H|<SavedIndicator.saved_indicator at={1_700_000_000} label="Salvo!" />|
        )

      assert has?(shown, ".fui-saved")
      assert shown =~ "Salvo!"
      assert shown =~ "lucide-check"
    end
  end

  describe "Dialog e derivados" do
    test "bottom_sheet é um dialog ancorado embaixo" do
      assigns = %{}
      html = rendered_to_string(~H|<BottomSheet.bottom_sheet id="bs" title="Filtros">
  corpo<:actions>OK</:actions>
</BottomSheet.bottom_sheet>|)
      cls = html_attr(html, "dialog#bs", "class")
      assert cls =~ "mt-auto" and cls =~ "max-w-none" and cls =~ "rounded-b-none"
      refute cls =~ "m-auto"
      assert html =~ "corpo" and html =~ "OK"
    end

    test "dialog padrão continua centralizado; placement inválido viola o contrato" do
      assigns = %{}

      assert html_attr(
               rendered_to_string(~H|<Dialog.dialog id="d">x</Dialog.dialog>|),
               "dialog",
               "class"
             ) =~ "m-auto"

      assert_raise ArgumentError, ~r/dialog placement/, fn ->
        rendered_to_string(~H|<Dialog.dialog id="d" placement={:topo}>x</Dialog.dialog>|)
      end
    end

    test "settings_dialog: seção ativa por assign e contrato" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <SettingsDialog.settings_dialog id="cfg" active="conta">
          <:tab id="conta" label="Conta" click="ir_conta" />
          <:tab id="perfil" label="Perfil" icon="user" patch="/cfg/perfil" /> Conteúdo da conta
        </SettingsDialog.settings_dialog>
        """)

      assert html_attr(html, "[aria-current=page]", "phx-click") == "ir_conta"
      assert html_attr(html, "a[href='/cfg/perfil']", "href") == "/cfg/perfil"
      assert html =~ "Conteúdo da conta" and html =~ "Configurações"

      assert_raise ArgumentError, ~r/settings_dialog active/, fn ->
        rendered_to_string(~H|<SettingsDialog.settings_dialog id="c" active="x">
  <:tab id="a" label="A" click="a" />c
</SettingsDialog.settings_dialog>|)
      end
    end

    test "keyboard_shortcuts_dialog lista atalhos e valida o formato" do
      assigns = %{s: [%{label: "Buscar", keys: ["Ctrl", "K"]}, %{label: "Ajuda", keys: ["?"]}]}

      html =
        rendered_to_string(
          ~H|<KeyboardShortcutsDialog.keyboard_shortcuts_dialog id="ks" shortcuts={@s} />|
        )

      assert Enum.count(query(html, "li")) == 2 and Enum.count(query(html, "kbd")) == 3

      assert_raise ArgumentError, ~r/atalho precisa/, fn ->
        rendered_to_string(
          ~H|<KeyboardShortcutsDialog.keyboard_shortcuts_dialog id="ks" shortcuts={[%{label: "x"}]} />|
        )
      end
    end
  end

  describe "flutuantes" do
    test "popover ancora no gatilho e respeita placement" do
      assigns = %{}

      html =
        rendered_to_string(
          ~H|<Popover.popover id="pop" placement={:top}><:trigger>Abrir</:trigger>conteúdo</Popover.popover>|
        )

      assert html_attr(html, "button", "style") =~ "anchor-name: --fui-pop"
      assert html_attr(html, "#pop", "style") =~ "top span-right"
      assert has?(html, "#pop[popover]") and html =~ "conteúdo"

      assert_raise ArgumentError, ~r/popover id/, fn ->
        rendered_to_string(
          ~H|<Popover.popover id="a b"><:trigger>x</:trigger>y</Popover.popover>|
        )
      end
    end

    test "hover_card aparece em hover e foco" do
      assigns = %{}

      html =
        rendered_to_string(
          ~H|<HoverCard.hover_card><:trigger>@ana</:trigger>Perfil</HoverCard.hover_card>|
        )

      cls = html_attr(html, "[role=tooltip]", "class")

      assert cls =~ "group-hover/hovercard:visible" and
               cls =~ "group-focus-within/hovercard:visible"

      assert html =~ "Perfil"
    end

    test "context_menu: região + menu popover com hook" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <ContextMenu.context_menu id="ctx">
          <p>Região</p>
          <:item label="Copiar" click="copiar" />
          <:item label="Apagar" click="apagar" theme={:red} />
        </ContextMenu.context_menu>
        """)

      assert html_attr(html, "#ctx", "data-menu") == "ctx-menu"
      assert html_attr(html, "#ctx", "phx-hook") =~ "ContextMenu"
      assert has?(html, "#ctx-menu[popover][role=menu]")
      assert Enum.count(query(html, "[role=menuitem]")) == 2
    end

    test "menu_item: link ou evento, tema e fecha o popover" do
      assigns = %{}

      button =
        rendered_to_string(
          ~H|<MenuItem.menu_item item={%{label: "A", click: "a", icon: "plus"}} popover_id="p" />|
        )

      assert html_attr(button, "button", "popovertarget") == "p"
      assert button =~ "lucide-plus"

      link =
        rendered_to_string(
          ~H|<MenuItem.menu_item item={%{label: "B", navigate: "/b"}} popover_id="p" />|
        )

      assert html_attr(link, "a", "href") == "/b"
      assert MenuItem.classes(:red) =~ "text-ink-red-3"
      assert MenuItem.classes(:gray) =~ "text-ink-gray-7"
    end
  end

  describe "navegação" do
    @nav [
      %{id: "a", label: "Início", icon: "house", patch: "/"},
      %{id: "b", label: "Itens", click: "ir_b"}
    ]

    test "nav_item: link, botão, só ícone e empilhado" do
      assigns = %{items: @nav}
      link = rendered_to_string(~H|<NavItem.nav_item item={hd(@items)} active />|)
      assert html_attr(link, "a", "aria-current") == "page"

      button =
        rendered_to_string(~H|<NavItem.nav_item item={Enum.at(@items, -1)} role="tab" active />|)

      assert html_attr(button, "button", "aria-selected") == "true"
      assert html_attr(button, "button", "phx-click") == "ir_b"
      icon_only = rendered_to_string(~H|<NavItem.nav_item item={hd(@items)} icon_only />|)
      assert html_attr(icon_only, "a", "title") == "Início" and has?(icon_only, "span.sr-only")

      assert html_attr(
               rendered_to_string(~H|<NavItem.nav_item item={hd(@items)} stacked />|),
               "a",
               "class"
             ) =~ "flex-col"
    end

    test "tab_buttons: ativo vem do assign e contrato do id" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <TabButtons.tab_buttons active="b">
          <:button id="a" label="A" click="a" />
          <:button id="b" label="B" click="b" />
        </TabButtons.tab_buttons>
        """)

      assert html_attr(html, "[aria-selected=true]", "phx-click") == "b"
      assert Enum.count(query(html, "[aria-selected=false]")) == 1

      assert_raise ArgumentError, ~r/tab_buttons active/, fn ->
        rendered_to_string(
          ~H|<TabButtons.tab_buttons active="z"><:button id="a" label="A" click="a" /></TabButtons.tab_buttons>|
        )
      end
    end

    test "sidebar: expandida, recolhida, cabeçalho/rodapé e contrato" do
      assigns = %{}

      full =
        rendered_to_string(~H"""
        <Sidebar.sidebar active="a">
          <:header>Logo</:header>
          <:item id="a" label="Início" icon="house" patch="/" />
          <:item id="b" label="Itens" click="b" />
          <:footer>Rodapé</:footer>
        </Sidebar.sidebar>
        """)

      assert html_attr(full, "aside", "class") =~ "w-60"
      assert html_attr(full, "[aria-current=page]", "href") == "/"
      assert full =~ "Logo" and full =~ "Rodapé"

      collapsed = rendered_to_string(~H|<Sidebar.sidebar collapsed>
  <:item id="a" label="Início" icon="house" patch="/" />
</Sidebar.sidebar>|)
      assert html_attr(collapsed, "aside", "class") =~ "w-14"
      assert has?(collapsed, "span.sr-only")

      assert_raise ArgumentError, ~r/sidebar active/, fn ->
        rendered_to_string(
          ~H|<Sidebar.sidebar active="z"><:item id="a" label="A" click="a" /></Sidebar.sidebar>|
        )
      end
    end

    test "sidebar_rail e mobile_shell" do
      assigns = %{}
      rail = rendered_to_string(~H|<SidebarRail.sidebar_rail active="a">
  <:item id="a" label="Início" icon="house" patch="/" />
</SidebarRail.sidebar_rail>|)
      assert html_attr(rail, "aside", "class") =~ "w-12"
      assert html_attr(rail, "a", "title") == "Início"

      mobile =
        rendered_to_string(~H"""
        <MobileShell.mobile_shell active="a">
          <:header>Topo</:header>
          <:nav id="a" label="Início" icon="house" patch="/" />
          <:nav id="b" label="Itens" icon="list" click="b" /> Conteúdo
        </MobileShell.mobile_shell>
        """)

      assert mobile =~ "Topo" and mobile =~ "Conteúdo"
      assert has?(mobile, "nav[aria-label=Principal]")
      assert Enum.count(query(mobile, "nav a, nav button")) == 2

      assert_raise ArgumentError, ~r/mobile_shell active/, fn ->
        rendered_to_string(~H|<MobileShell.mobile_shell active="z">
  <:nav id="a" label="A" click="a" />x
</MobileShell.mobile_shell>|)
      end
    end

    test "desktop_shell e scroll_area" do
      assigns = %{}
      shell = rendered_to_string(~H|<DesktopShell.desktop_shell>
  <:sidebar><aside>S</aside></:sidebar>Principal
</DesktopShell.desktop_shell>|)
      assert has?(shell, "aside") and has?(shell, "main")

      area =
        rendered_to_string(
          ~H|<ScrollArea.scroll_area orientation={:both} class="max-h-10">x</ScrollArea.scroll_area>|
        )

      assert html_attr(area, "div", "class") =~ "overflow-auto"
      assert html_attr(area, "div", "tabindex") == "0"

      assert_raise ArgumentError, ~r/scroll_area orientation/, fn ->
        rendered_to_string(
          ~H|<ScrollArea.scroll_area orientation={:x}>x</ScrollArea.scroll_area>|
        )
      end
    end
  end

  describe "dados: Sortable, List e Tree" do
    test "sortable: itens arrastáveis com id e evento de drop" do
      assigns = %{items: [%{id: 1, n: "a"}, %{id: 2, n: "b"}]}

      html =
        rendered_to_string(~H"""
        <Sortable.sortable id="ordem" items={@items} on_drop="reordenar">
          <:item :let={item}>{item.n}</:item>
        </Sortable.sortable>
        """)

      assert html_attr(html, "#ordem", "data-on-drop") == "reordenar"
      assert html_attr(html, "#ordem", "phx-hook") =~ "Sortable"
      assert Enum.count(query(html, "[draggable=true][data-sortable-id]")) == 2
      assert Sortable.hook_name() == "FrappeUILive.Components.Sortable.Sortable"
    end

    test "list: colunas, ações, seleção e estado vazio" do
      assigns = %{rows: [%{id: 1, nome: "Ana"}, %{id: 2, nome: "Bia"}]}

      html =
        rendered_to_string(~H"""
        <List.list id="l" rows={@rows} selected={[2]} on_select="sel">
          <:col :let={r} label="Nome">{r.nome}</:col>
          <:action :let={r}>ver {r.id}</:action>
        </List.list>
        """)

      assert Enum.count(query(html, "tbody tr")) == 2
      assert has?(html, "tr#l-2[aria-selected=true]")
      assert has?(html, "tr#l-1[aria-selected=false]")
      assert has?(html, "tr#l-2 input[checked]")
      assert html_attr(html, "tr#l-1 input", "phx-value-id") == "1"
      assert html =~ "ver 2" and html =~ "Bia"
      refute has?(html, "tbody[phx-hook]")

      empty = rendered_to_string(~H|<List.list id="l" rows={[]} empty_text="Vazio">
  <:col label="N">x</:col>
</List.list>|)
      assert empty =~ "Vazio"
      refute has?(empty, "input[type=checkbox]")
    end

    test "list com on_drop liga o hook e torna as linhas arrastáveis" do
      assigns = %{rows: [%{id: 1, nome: "Ana"}]}

      html =
        rendered_to_string(~H"""
        <List.list id="l" rows={@rows} on_drop="reordenar">
          <:col :let={r} label="N">{r.nome}</:col>
        </List.list>
        """)

      assert html_attr(html, "tbody", "phx-hook") == Sortable.hook_name()
      assert html_attr(html, "tbody", "data-on-drop") == "reordenar"
      assert has?(html, "tr[draggable=true][data-sortable-id='1']")
    end

    @nodes [
      %{
        id: 1,
        label: "Pasta",
        children: [
          %{id: 2, label: "Arquivo", icon: "file-text"},
          %{id: 3, label: "Sub", children: [%{id: 4, label: "Fundo"}]}
        ]
      },
      %{id: 5, label: "Solto"}
    ]

    test "tree: só mostra filhos de nós expandidos, com aria" do
      assigns = %{n: @nodes}

      closed =
        rendered_to_string(~H|<Tree.tree id="t" nodes={@n} on_toggle="tog" on_select="sel" />|)

      assert Enum.count(query(closed, "[role=treeitem]")) == 2
      assert html_attr(closed, "li", "aria-expanded") == "false"

      assigns = %{n: @nodes}

      open =
        rendered_to_string(
          ~H|<Tree.tree id="t" nodes={@n} expanded={[1, 3]} selected={4} on_toggle="tog" on_select="sel" />|
        )

      assert Enum.count(query(open, "[role=treeitem]")) == 5
      assert has?(open, "li[aria-selected=true]")
      assert html_attr(open, "button[aria-label=Recolher]", "phx-click") == "tog"
      assert open =~ "lucide-file-text"
    end

    test "tree: ids como texto e on_drop liga o hook de ordenação" do
      assigns = %{n: @nodes}

      html =
        rendered_to_string(~H|<Tree.tree id="t" nodes={@n} expanded={["1"]} on_drop="mover" />|)

      assert html_attr(html, "#t", "phx-hook") == Sortable.hook_name()
      assert has?(html, "li[draggable=true][data-sortable-id='1']")
      assert Enum.count(query(html, "[role=treeitem]")) == 4
    end
  end
end
