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

      assert_raise ArgumentError, fn -> Field.require_id!(%{}, "x") end
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
      assert_raise ArgumentError, ~r/dialog id inválido/, fn -> Dialog.hide_dialog(List.first([])) end
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
end
