defmodule FrappeUILive.ReviewFixesTest do
  @moduledoc "Regressões dos achados da revisão de arquitetura (tasks 17.x)."
  use FrappeUILive.Case, async: false

  import ExUnit.CaptureIO
  import Phoenix.LiveViewTest, only: [render_component: 2, rendered_to_string: 1]

  alias FrappeUILive.Components.{
    Anchor,
    CodeEditor,
    Combobox,
    DatePicker,
    Dialog,
    Editor,
    NavItem
  }

  alias FrappeUILive.Field
  alias Mix.Tasks.FrappeUiLive.Install
  alias Phoenix.LiveView.Socket

  describe "C-1: mix task com argumentos inválidos" do
    setup do
      dir = Path.join(System.tmp_dir!(), "fui_review_#{System.unique_integer([:positive])}")
      File.mkdir_p!(Path.join(dir, "assets/css"))
      File.mkdir_p!(Path.join(dir, "assets/js"))
      css = "@import \"tailwindcss\" source(none);\n"
      js = "import \"x\"\nnew LiveSocket(\"/live\", Socket, {hooks: {...colocatedHooks}})\n"
      File.write!(Path.join(dir, "assets/css/app.css"), css)
      File.write!(Path.join(dir, "assets/js/app.js"), js)
      File.write!(Path.join(dir, "mix.exs"), "compilers: [:phoenix_live_view]")
      on_exit(fn -> File.rm_rf!(dir) end)
      %{dir: dir, css: css, js: js}
    end

    defp run_in(dir, args) do
      capture_io(:stderr, fn ->
        capture_io(fn -> File.cd!(dir, fn -> Install.run(args ++ ["--dep-path", dir]) end) end)
      end)
    end

    test "opção desconhecida (typo de --dry-run) falha e NÃO grava nada", %{
      dir: dir,
      css: css,
      js: js
    } do
      assert_raise Mix.Error, ~r/argumentos inválidos: --dryrun/, fn ->
        run_in(dir, ["--dryrun"])
      end

      assert File.read!(Path.join(dir, "assets/css/app.css")) == css
      assert File.read!(Path.join(dir, "assets/js/app.js")) == js
    end

    test "argumento posicional também é rejeitado", %{dir: dir, css: css} do
      assert_raise Mix.Error, ~r/argumentos inválidos/, fn -> run_in(dir, ["extra"]) end
      assert File.read!(Path.join(dir, "assets/css/app.css")) == css
    end

    test "--help avisa o uso sem gravar", %{dir: dir, css: css} do
      assert_raise Mix.Error, ~r/uso:/, fn -> run_in(dir, ["--help"]) end
      assert File.read!(Path.join(dir, "assets/css/app.css")) == css
    end
  end

  describe "I-2: DatePicker ignora evento forjado" do
    test "pick sem a chave date não derruba o componente" do
      {:ok, socket} =
        DatePicker.update(%{id: "d", value: "2026-03-09", today: ~D[2026-03-15]}, %Socket{})

      assert {:noreply, same} = DatePicker.handle_event("pick", %{}, socket)
      assert same.assigns.selected == ~D[2026-03-09]
      assert {:noreply, _} = DatePicker.handle_event("pick", %{"outra" => "x"}, socket)
    end
  end

  describe "I-1: active vindo da URL" do
    test "NavItem.known_active/2 devolve nil para valor desconhecido" do
      assert NavItem.known_active("a", ["a", "b"]) == "a"
      assert NavItem.known_active("lixo", ["a", "b"]) == nil
      assert NavItem.known_active(nil, ["a"]) == nil
    end
  end

  describe "I-3/I-4: id obrigatório e validado em um só lugar" do
    test "editor, code_editor e combobox sem id falham nomeando o componente" do
      assigns = %{}

      assert_raise ArgumentError, ~r/editor id inválido: nil/, fn ->
        rendered_to_string(~H|<Editor.editor name="t" value="" />|)
      end

      assert_raise ArgumentError, ~r/code_editor id inválido: nil/, fn ->
        rendered_to_string(~H|<CodeEditor.code_editor name="c" />|)
      end

      assert_raise ArgumentError, ~r/combobox id inválido: nil/, fn ->
        rendered_to_string(~H|<Combobox.combobox name="c" options={[]} />|)
      end
    end

    test "o id vindo do field basta" do
      assigns = %{f: form_field(:texto, "")}
      assert rendered_to_string(~H|<Editor.editor field={@f} />|) =~ "f_texto"
    end

    test "Field.require_id!/2" do
      assert Field.require_id!(%{id: "ok"}, "x") == %{id: "ok"}

      assert_raise ArgumentError, ~r/x id inválido/, fn ->
        Field.require_id!(%{id: "a b"}, "x")
      end

      assert_raise ArgumentError, fn -> Field.require_id!(Map.new(), "x") end
    end

    test "Anchor valida o id dentro dos estilos (componente novo não esquece)" do
      assert_raise ArgumentError, ~r/anchor id inválido/, fn -> Anchor.trigger_style("a; b") end
      assert_raise ArgumentError, ~r/anchor id inválido/, fn -> Anchor.panel_style("x y") end

      assert_raise ArgumentError, ~r/anchor id inválido/, fn ->
        Anchor.trigger_style(List.first([]))
      end

      assert Anchor.trigger_style("ok-1") == "anchor-name: --fui-ok-1"
    end

    test "show_dialog/hide_dialog validam o id (vira seletor)" do
      assert_raise ArgumentError, ~r/dialog id inválido/, fn -> Dialog.show_dialog("a b") end

      assert_raise ArgumentError, ~r/dialog id inválido/, fn ->
        Dialog.hide_dialog(List.first([]))
      end

      assert %Phoenix.LiveView.JS{} = Dialog.show_dialog("ok")
    end

    test "render_component do date_picker com id inválido nomeia o componente" do
      assert_raise ArgumentError, ~r/date_picker id inválido/, fn ->
        render_component(DatePicker, id: "x y", name: "n")
      end
    end
  end

  describe "I-9: Markdown" do
    alias FrappeUILive.Markdown

    test "barra invertida não vira caminho relativo (open-redirect) e `//` segue barrado" do
      refute Markdown.safe_url?("/\\evil.com")
      refute Markdown.safe_url?("//evil.com")
      assert Markdown.safe_url?("/ok/rota")
      refute Markdown.to_html("[x](/\\evil.com)") =~ "<a "
    end

    test "_ no href não quebra o link nem vira ênfase" do
      html = Markdown.to_html("[ver](https://a.b/x_y_z) e _itálico_")
      assert html =~ ~s(<a href="https://a.b/x_y_z" rel="noopener noreferrer">ver</a>)
      assert html =~ "<em>itálico</em>"
      refute html =~ "<em>y</em>"
    end

    test "código não recebe ênfase" do
      assert Markdown.to_html("`a_b_c e **x**`") == "<p><code>a_b_c e **x**</code></p>"
    end

    test "to_safe/1 devolve HTML marcado como seguro (sem escape duplo)" do
      assert {:safe, html} = Markdown.to_safe("**oi**")
      assert IO.iodata_to_binary(html) == "<p><strong>oi</strong></p>"
      assert {:safe, ""} = Markdown.to_safe(nil)
    end

    @tag :node
    test "paridade: a regex de URL segura do Editor (JS) decide igual ao Elixir" do
      source = File.read!(Path.expand("../../lib/frappe_ui_live/components/editor.ex", __DIR__))
      [_, regex] = Regex.run(~r{const SAFE_URL = (/.*/i)}, source)

      urls = [
        "https://a.b",
        "http://a.b/c",
        "mailto:a@b.c",
        "/rota",
        "//evil.com",
        "/\\evil.com",
        "javascript:alert(1)",
        "data:text/html,x",
        "ftp://a",
        "rota",
        ""
      ]

      script =
        "const R = #{regex}; process.stdout.write(JSON.stringify(#{Jason.encode!(urls)}.map((u) => R.test(u))))"

      {out, 0} = System.cmd("node", ["-e", script])
      js = Jason.decode!(out)
      elixir = Enum.map(urls, &Markdown.safe_url?/1)
      assert js == elixir, "JS #{inspect(js)} != Elixir #{inspect(elixir)} para #{inspect(urls)}"
    end
  end

  describe "I-5: protocolo do Sortable encapsulado" do
    alias FrappeUILive.Components.{Sortable, Tree}

    test "o nome do hook existe no manifesto de hooks colocated (renomear módulo não quebra em silêncio)" do
      manifest = Path.join(Mix.Project.build_path(), "phoenix-colocated/frappe_ui_live/index.js")
      assert File.read!(manifest) =~ ~s(["#{Sortable.hook_name()}"])
    end

    test "root_attrs/1 e item_attrs/3" do
      assert Sortable.root_attrs(nil) == %{}

      assert Sortable.root_attrs("mover") == %{
               "phx-hook" => Sortable.hook_name(),
               "data-on-drop" => "mover"
             }

      assert Sortable.item_attrs(1, false) == %{}
      assert Sortable.item_attrs(1, true) == %{"data-sortable-id" => "1", "draggable" => "true"}
      assert %{"data-sortable-parent" => "7"} = Sortable.item_attrs(2, true, 7)
    end

    test "Tree marca o pai de cada nível (o hook só aceita soltar entre irmãos)" do
      assigns = %{n: [%{id: 1, label: "Pasta", children: [%{id: 2, label: "Arq"}]}]}

      html =
        rendered_to_string(~H|<Tree.tree id="t" nodes={@n} expanded={[1]} on_drop="mover" />|)

      assert html_attr(html, "li[data-sortable-id='1']", "data-sortable-parent") == nil
      assert html_attr(html, "li[data-sortable-id='2']", "data-sortable-parent") == "1"
    end
  end

  describe "I-8: Toast" do
    alias FrappeUILive.Components.Toast

    test "toasts do JS ficam num contêiner phx-update=ignore, separado dos flashes" do
      assigns = %{flash: %{"info" => "ok"}}
      html = rendered_to_string(~H|<Toast.toast_container flash={@flash} />|)
      assert html_attr(html, "#frappe-ui-toasts-stack", "phx-update") == "ignore"
      assert has?(html, "#frappe-ui-toasts-stack[data-toast-stack]")
      refute has?(html, "#frappe-ui-toasts-stack [role=status]")
    end

    test "uma paleta só: o hook recebe as mesmas classes do servidor e o flash info usa o estilo de sucesso" do
      assigns = %{flash: %{"info" => "ok"}}
      html = rendered_to_string(~H|<Toast.toast_container flash={@flash} />|)

      assert html_attr(html, "#frappe-ui-toasts", "data-styles") |> Jason.decode!() ==
               Toast.styles()

      assert Toast.flash_kind("info") == "success"
      assert Toast.flash_kind("error") == "error"
      assert html_attr(html, "#frappe-ui-toasts-flash-info", "class") =~ Toast.styles()["success"]
    end
  end

  describe "I-10: use FrappeUILive com only:/except: validados" do
    test "only: importa só o pedido" do
      mod =
        Code.compile_string("""
        defmodule FuiOnlyHost do
          use Phoenix.Component
          use FrappeUILive, only: [badge: 1]
          def ok(assigns), do: ~H|<.badge label="x" />|
        end
        """)

      assert [{FuiOnlyHost, _}] = mod

      html =
        Phoenix.LiveViewTest.rendered_to_string(apply(FuiOnlyHost, :ok, [%{__changed__: nil}]))

      assert html =~ "x"
    end

    test "nome desconhecido em except:/only: falha na compilação, listando os conhecidos" do
      assert_raise ArgumentError, ~r/:except contém componentes desconhecidos \[nope: 1\]/, fn ->
        Code.compile_string("defmodule FuiBadExcept do
 use FrappeUILive, except: [nope: 1]
end")
      end

      assert_raise ArgumentError,
                   ~r/:only contém componentes desconhecidos.*Conhecidos: .*badge/,
                   fn ->
                     Code.compile_string("defmodule FuiBadOnly do
 use FrappeUILive, only: [badg: 1]
end")
                   end
    end
  end

  describe "I-17: plugs" do
    import Plug.Test
    import Plug.Conn

    test "Plug.Static serve também o CSS de ícones" do
      opts = FrappeUILive.Plug.Static.init([])
      conn = conn(:get, "/frappe_ui/frappe_ui_icons.css") |> FrappeUILive.Plug.Static.call(opts)
      assert conn.status == 200 and conn.resp_body =~ ".lucide-plus"
    end

    test "Plug.Theme não regrava a sessão quando o tema não mudou" do
      base = conn(:get, "/") |> Plug.Test.init_test_session(%{"frappe_ui_theme" => "light"})
      conn = FrappeUILive.Plug.Theme.call(base, FrappeUILive.Plug.Theme.init([]))
      assert conn.assigns.frappe_ui_theme == "light"
      # sem alteração de sessão, o Plug.Session não precisa enviar Set-Cookie
      assert get_session(conn, "frappe_ui_theme") == "light"
      assert FrappeUILive.Plug.Theme.session_key() == "frappe_ui_theme"
    end
  end

  describe "I-19: Contract" do
    test "require!/3 aceita qualquer Enumerable (Range, MapSet)" do
      assert FrappeUILive.Contract.require!(3, 1..5, "n") == 3
      assert FrappeUILive.Contract.require!(:a, MapSet.new([:a]), "n") == :a
      assert_raise ArgumentError, fn -> FrappeUILive.Contract.require!(9, 1..5, "n") end
    end
  end

  describe "I-7: item de navegação unificado (Action)" do
    alias FrappeUILive.Components.{Action, MenuItem, SettingsDialog, TabButtons, Tabs}
    alias Phoenix.LiveView.JS

    test "Action decide link ou botão em um só lugar" do
      assert Action.link_attrs(%{patch: "/a", label: "x", click: "c"}) == %{patch: "/a"}
      assert Action.link?(%{navigate: "/x"})
      assert Action.link?(%{href: "https://a.b"})
      refute Action.link?(%{click: "evento", label: "x"})
    end

    test "link, botão com evento e botão com comando JS" do
      assigns = %{js: JS.push("outro")}

      link =
        rendered_to_string(
          ~H|<Action.action item={%{navigate: "/x"}} class="c">ir</Action.action>|
        )

      assert html_attr(link, "a", "href") == "/x"
      refute has?(link, "button")

      evento = rendered_to_string(~H|<Action.action item={%{click: "salvar"}}>go</Action.action>|)
      assert html_attr(evento, "button", "phx-click") == "salvar"
      assert html_attr(evento, "button", "type") == "button"

      js = rendered_to_string(~H|<Action.action item={%{click: @js}}>go</Action.action>|)
      assert html_attr(js, "button", "phx-click") =~ "outro"
    end

    test "popover_id só existe nos botões e fecha o popover" do
      assigns = %{}

      button =
        rendered_to_string(
          ~H|<Action.action item={%{click: "a"}} popover_id="menu">x</Action.action>|
        )

      assert html_attr(button, "button", "popovertarget") == "menu"
      assert html_attr(button, "button", "popovertargetaction") == "hide"

      link =
        rendered_to_string(
          ~H|<Action.action item={%{patch: "/a"}} popover_id="menu">x</Action.action>|
        )

      refute html_attr(link, "a", "popovertarget")
    end

    test "o mesmo vocabulário vale em Tabs, TabButtons, SettingsDialog e MenuItem (inclui href)" do
      assigns = %{js: JS.push("ir")}

      tabs =
        rendered_to_string(~H"""
        <Tabs.tabs id="t" active="a">
          <:tab id="a" label="A" href="https://a.b" />
          <:tab id="b" label="B" click={@js} />
        </Tabs.tabs>
        """)

      assert html_attr(tabs, "a[role=tab]", "href") == "https://a.b"
      assert html_attr(tabs, "button[role=tab]", "phx-click") =~ "ir"
      assert html_attr(tabs, "[aria-selected=true]", "aria-controls") == "t-panel"

      tb =
        rendered_to_string(
          ~H|<TabButtons.tab_buttons active="a"><:button id="a" label="A" href="/x" /></TabButtons.tab_buttons>|
        )

      assert html_attr(tb, "a[role=tab]", "href") == "/x"

      sd = rendered_to_string(~H|<SettingsDialog.settings_dialog id="s" active="a">
  <:tab id="a" label="A" navigate="/conta" />x
</SettingsDialog.settings_dialog>|)
      assert html_attr(sd, "a[href='/conta']", "href") == "/conta"

      menu =
        rendered_to_string(
          ~H|<MenuItem.menu_item item={%{label: "Sair", click: "sair"}} popover_id="p" />|
        )

      assert html_attr(menu, "button[role=menuitem]", "phx-click") == "sair"
    end

    test "NavItem repassa atributos extras (aria-controls) e mantém aria-selected só em abas" do
      assigns = %{}
      tab = rendered_to_string(~H|<FrappeUILive.Components.NavItem.nav_item
  item={%{label: "A", click: "a"}}
  role="tab"
  active
  aria-controls="p"
/>|)
      assert html_attr(tab, "button", "aria-controls") == "p"
      assert html_attr(tab, "button", "aria-selected") == "true"

      plain =
        rendered_to_string(
          ~H|<FrappeUILive.Components.NavItem.nav_item item={%{label: "A", click: "a"}} active />|
        )

      assert html_attr(plain, "button", "aria-current") == "page"
      refute html_attr(plain, "button", "aria-selected")
    end
  end

  describe "I-14: rest global uniforme" do
    alias FrappeUILive.Charts.{Legend, Tooltip}
    alias FrappeUILive.Components, as: Catalog

    alias FrappeUILive.Components.{
      CommandPalette,
      ErrorMessage,
      ListView,
      MultiSelect,
      SavedIndicator,
      Stepper,
      ThemeSwitcher
    }

    alias FrappeUILive.Components.{Tooltip, Tree}

    # fragmentos sem elemento raiz próprio: não há onde espalhar atributos
    @fragments [{FrappeUILive.Charts.Frame, :chart_frame}, {FrappeUILive.Charts.Axes, :axes}]

    test "todo componente público (catálogo e blocos internos) aceita atributos globais" do
      all = Enum.map(Catalog.catalog(), &{&1.module, &1.fun}) ++ Catalog.internal()

      missing =
        for {module, fun} <- Enum.uniq(all) -- @fragments,
            comp = Map.fetch!(module.__components__(), fun),
            not Enum.any?(comp.attrs, &(&1.type == :global)),
            do: {module, fun}

      assert missing == [], "sem `attr :rest, :global`: #{inspect(missing)}"
    end

    test "data-* e aria-* chegam ao elemento raiz" do
      assigns = %{}

      cases = [
        {~H|<ErrorMessage.error_message message="x" data-t="1" />|, "p[data-t='1']"},
        {~H|<SavedIndicator.saved_indicator at={1} data-t="1" />|, "span[data-t='1']"},
        {~H|<Tooltip.tooltip text="t" data-t="1">x</Tooltip.tooltip>|, "span[data-t='1']"},
        {~H|<Stepper.stepper current={0} data-t="1"><:step label="A" /></Stepper.stepper>|,
         "ol[data-t='1']"},
        {~H|<ThemeSwitcher.theme_switcher current="light" data-t="1" />|, "div[data-t='1']"},
        {~H|<Legend.chart_legend items={[%{label: "a", color: "red"}]} data-t="1" />|,
         "ul[data-t='1']"},
        {~H|<Tree.tree id="t" nodes={[]} data-t="1" />|, "ul[data-t='1']"},
        {~H|<ListView.list_view id="lv" rows={[]} data-t="1">
  <:col label="N">x</:col>
</ListView.list_view>|, "div[data-t='1']"},
        {~H|<CommandPalette.command_palette id="cp" data-t="1">
  <:item label="x" click="x" />
</CommandPalette.command_palette>|, "dialog[data-t='1']"},
        {~H|<MultiSelect.multi_select id="ms" name="x" options={[]} data-t="1" />|,
         "#ms[data-t='1']"}
      ]

      for {rendered, selector} <- cases do
        assert has?(rendered_to_string(rendered), selector), "rest não chegou em #{selector}"
      end
    end

    test "form e required chegam aos inputs nativos de Combobox/MultiSelect" do
      assigns = %{o: [{"A", "a"}, {"B", "b"}]}

      single =
        rendered_to_string(
          ~H|<FrappeUILive.Components.Combobox.combobox id="c" name="x" options={@o} form="f1" required />|
        )

      assert has?(single, "input[type=radio][form=f1][required]")

      multi =
        rendered_to_string(
          ~H|<MultiSelect.multi_select id="m" name="x" options={@o} form="f1" required />|
        )

      assert has?(multi, "input[type=checkbox][form=f1]")
      refute has?(multi, "input[type=checkbox][required]")
    end

    test "DatePicker espalha o rest na raiz do LiveComponent" do
      html =
        render_component(DatePicker,
          id: "d",
          name: "n",
          rest: %{"data-t" => "1"},
          today: ~D[2026-03-15]
        )

      assert has?(html, "#d[data-t='1']")
    end
  end

  describe "I-18: textos fixos configuráveis" do
    alias FrappeUILive.Components.{Dialog, Password, SavedIndicator, Stepper}
    alias FrappeUILive.Texts

    defmodule EnglishTranslator do
      @behaviour FrappeUILive.Translator
      @impl true
      def translate(:close, _default, _bindings), do: "Close"
      def translate(:go_back_to, _default, _bindings), do: "Back to %{label}"
      def translate(_key, default, _bindings), do: default
    end

    setup do
      on_exit(fn ->
        Application.delete_env(:frappe_ui_live, :texts)
        Application.delete_env(:frappe_ui_live, :translator)
      end)
    end

    test "padrão em português, com todas as chaves preenchidas" do
      assert Texts.t(:close) == "Fechar"
      assert Enum.all?(Texts.keys(), &(Texts.default(&1) |> String.trim() != ""))
      assert_raise KeyError, fn -> Texts.t(:chave_inexistente) end
    end

    test "interpolação de %{nome}" do
      assert Texts.t(:rating_item, n: 3, max: 5) == "3 de 5"
      assert Texts.t(:go_back_to, label: "Conta") == "Voltar para Conta"
    end

    test "config :texts sobrescreve pontualmente e chega ao componente" do
      Application.put_env(:frappe_ui_live, :texts, %{saved: "Saved", close: "Close"})
      assigns = %{}

      assert text(rendered_to_string(~H|<SavedIndicator.saved_indicator at={1} />|), "span span") =~
               "Saved"

      assert html_attr(
               rendered_to_string(~H|<Dialog.dialog id="d">x</Dialog.dialog>|),
               "button[aria-label]",
               "aria-label"
             ) == "Close"

      assert Texts.t(:today) == "Hoje"
    end

    test "módulo Translator tem prioridade e recebe o default já sobrescrito" do
      Application.put_env(:frappe_ui_live, :translator, EnglishTranslator)
      Application.put_env(:frappe_ui_live, :texts, %{search: "Find…"})
      assert Texts.t(:close) == "Close"
      assert Texts.t(:go_back_to, label: "Account") == "Back to Account"
      assert Texts.t(:search) == "Find…"
    end

    test "texto explícito do chamador vence o configurado" do
      Application.put_env(:frappe_ui_live, :texts, %{saved: "Saved"})
      assigns = %{}
      html = rendered_to_string(~H|<SavedIndicator.saved_indicator at={1} label="Guardado" />|)
      assert html =~ "Guardado"
      refute html =~ "Saved"
    end

    test "aria-labels e mensagens passam pelo Texts (senha, etapas, erros de upload)" do
      Application.put_env(:frappe_ui_live, :translator, EnglishTranslator)
      assigns = %{}

      assert html_attr(
               rendered_to_string(~H|<Stepper.stepper current={1} on_go="ir">
  <:step label="Conta" /><:step label="B" />
</Stepper.stepper>|),
               "button[phx-click=ir]",
               "aria-label"
             ) == "Back to Conta"

      pw = rendered_to_string(~H|<Password.password id="p" name="s" />|)
      assert html_attr(pw, "button", "aria-label") == "Mostrar ou ocultar a senha"
      assert FrappeUILive.Components.FileUploader.error_message(:too_large) =~ "maior"
    end

    test "todas as chaves usadas nos componentes existem (nenhum Texts.t com chave desconhecida)" do
      used =
        Path.wildcard(Path.expand("../../lib/**/*.ex", __DIR__))
        |> Enum.flat_map(fn file ->
          Regex.scan(~r/Texts\.t\(:([a-z_]+)/, File.read!(file), capture: :all_but_first)
        end)
        |> List.flatten()
        |> Enum.uniq()
        |> Enum.map(&String.to_atom/1)

      assert used -- Texts.keys() == []

      # e nenhuma chave definida ficou órfã (usada por átomo em qualquer lugar de lib/, exceto texts.ex)
      source =
        Path.wildcard(Path.expand("../../lib/**/*.ex", __DIR__))
        |> Enum.reject(&String.ends_with?(&1, "texts.ex"))
        |> Enum.map_join("\n", &File.read!/1)

      orphans = Enum.reject(Texts.keys(), &Regex.match?(~r/:#{&1}\b/, source))
      assert orphans == [], "chaves sem uso: #{inspect(orphans)}"
    end
  end

  describe "I-16: pontos de extensão validados" do
    alias FrappeUILive.{Config, ErrorTranslator, IconResolver, Texts, ToastSink}

    defmodule MeuIcones do
      def name(name), do: "meu-" <> name
    end

    defmodule SemCallback do
    end

    setup do
      on_exit(fn ->
        for key <- [:icon_resolver, :toast_sink, :error_translator, :translator],
            do: Application.delete_env(:frappe_ui_live, key)
      end)
    end

    test "Config.module!/4 devolve o padrão, o configurado e rejeita módulo sem o callback" do
      assert Config.module!(:icon_resolver, IconResolver.Lucide, :name, 1) == IconResolver.Lucide
      Application.put_env(:frappe_ui_live, :icon_resolver, MeuIcones)
      assert Config.module!(:icon_resolver, IconResolver.Lucide, :name, 1) == MeuIcones

      Application.put_env(:frappe_ui_live, :icon_resolver, SemCallback)

      assert_raise ArgumentError,
                   ~r/icon_resolver: .*SemCallback.* não implementa name\/1/,
                   fn -> IconResolver.resolve("plus") end

      Application.put_env(:frappe_ui_live, :icon_resolver, Modulo.Que.Nao.Existe)
      assert_raise ArgumentError, ~r/não implementa/, fn -> IconResolver.resolve("plus") end
    end

    test "IconResolver.resolve/1 usa a implementação configurada" do
      assert IconResolver.resolve("plus") == "plus"
      Application.put_env(:frappe_ui_live, :icon_resolver, MeuIcones)
      assert IconResolver.resolve("plus") == "meu-plus"
    end

    test "ToastSink, ErrorTranslator e Texts também validam o módulo configurado" do
      Application.put_env(:frappe_ui_live, :toast_sink, SemCallback)

      assert_raise ArgumentError, ~r/toast_sink/, fn ->
        ToastSink.deliver(%Phoenix.LiveView.Socket{}, %{kind: "info", message: "x", timeout: 1})
      end

      Application.put_env(:frappe_ui_live, :error_translator, SemCallback)

      assert_raise ArgumentError, ~r/error_translator/, fn ->
        ErrorTranslator.translate({"x", []})
      end

      Application.put_env(:frappe_ui_live, :translator, SemCallback)
      assert_raise ArgumentError, ~r/translator/, fn -> Texts.t(:close) end
    end

    test "o tradutor de erros padrão vive em ErrorTranslator.Default" do
      assert ErrorTranslator.translate({"mínimo %{count}", count: 3}) == "mínimo 3"
      assert ErrorTranslator.Default.translate({"x %{a}", a: {:t, 1}}) =~ "{:t, 1}"
    end
  end

  describe "I-12: precedência de Field.assign_field" do
    test "id e value explícitos vencem; name e errors sempre vêm do campo" do
      base = %{__changed__: nil, field: form_field(:nome, "Ana", [{"x", []}])}

      out =
        Field.assign_field(
          Map.merge(base, %{id: "meu-id", value: "Bia", name: "outro", errors: ["ignorado"]})
        )

      assert {out.id, out.value, out.name} == {"meu-id", "Bia", "f[nome]"}
      assert out.errors == ["x"]
    end

    test "multiple: true é opção explícita, não um atributo escondido" do
      out = Field.assign_field(%{__changed__: nil, field: form_field(:tags), multiple: true})
      assert out.name == "f[tags]"

      assert Field.assign_field(%{__changed__: nil, field: form_field(:tags)}, multiple: true).name ==
               "f[tags][]"
    end
  end

  describe "I-20: semântica de selected/expanded" do
    alias FrappeUILive.Components.{List, Tree}

    @rows [%{id: 1, n: "a"}, %{id: 2, n: "b"}]

    test "List: sem selectable não há coluna de seleção, mesmo com selected" do
      assigns = %{rows: @rows}
      html = rendered_to_string(~H|<List.list id="l" rows={@rows} selected={[1]}>
  <:col :let={r} label="N">{r.n}</:col>
</List.list>|)
      refute has?(html, "input[type=checkbox]")
      refute has?(html, "[aria-selected]")
    end

    test "List: selectable com selected vazio mostra caixas desmarcadas; ids comparados como texto" do
      assigns = %{rows: @rows}
      empty = rendered_to_string(~H|<List.list id="l" rows={@rows} selectable>
  <:col :let={r} label="N">{r.n}</:col>
</List.list>|)
      assert Enum.count(query(empty, "input[type=checkbox]")) == 2
      refute has?(empty, "input[checked]")

      texto = rendered_to_string(~H|<List.list id="l" rows={@rows} selectable selected={["2"]}>
  <:col :let={r} label="N">{r.n}</:col>
</List.list>|)
      assert has?(texto, "tr#l-2 input[checked]")
      refute has?(texto, "tr#l-1 input[checked]")
    end

    test "Tree: selected_id compara como texto" do
      assigns = %{n: [%{id: 1, label: "A"}, %{id: 2, label: "B"}]}
      html = rendered_to_string(~H|<Tree.tree id="t" nodes={@n} selected_id="2" />|)
      assert has?(html, "li[aria-selected=true]")
      assert Enum.count(query(html, "li[aria-selected=true]")) == 1
    end
  end

  describe "I-15: DatePicker alinhado" do
    alias Phoenix.LiveView.Socket

    test "value nil explícito limpa a data (update/2)" do
      {:ok, socket} =
        DatePicker.update(%{id: "d", value: "2026-03-09", today: ~D[2026-03-15]}, %Socket{})

      assert socket.assigns.selected == ~D[2026-03-09]
      {:ok, cleared} = DatePicker.update(%{id: "d", value: nil}, socket)
      assert cleared.assigns.selected == nil
    end

    test "class e errors chegam ao componente" do
      html =
        render_component(DatePicker,
          id: "d",
          name: "n",
          class: "minha-classe",
          errors: ["x"],
          today: ~D[2026-03-15]
        )

      assert has?(html, "#d.minha-classe")
    end
  end

  describe "ThemeHook com default configurável" do
    alias FrappeUILive.Live.ThemeHook

    test "default: do hook vale quando a sessão não tem tema válido" do
      socket = %Phoenix.LiveView.Socket{}
      assert {:cont, s} = ThemeHook.on_mount([default: "dark"], %{}, %{}, socket)
      assert s.assigns.frappe_ui_theme == "dark"

      assert {:cont, s} =
               ThemeHook.on_mount([default: "dark"], %{}, %{"frappe_ui_theme" => "xx"}, socket)

      assert s.assigns.frappe_ui_theme == "dark"
      # a sessão válida continua mandando
      assert {:cont, s} =
               ThemeHook.on_mount([default: "dark"], %{}, %{"frappe_ui_theme" => "light"}, socket)

      assert s.assigns.frappe_ui_theme == "light"
    end

    test "default inválido viola o contrato" do
      assert_raise ArgumentError, ~r/ThemeHook default/, fn ->
        ThemeHook.on_mount([default: "sepia"], %{}, %{}, %Phoenix.LiveView.Socket{})
      end
    end
  end
end
