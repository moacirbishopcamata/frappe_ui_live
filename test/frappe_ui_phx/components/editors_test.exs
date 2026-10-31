defmodule FrappeUIPhx.Components.EditorsTest do
  use FrappeUIPhx.Case, async: true

  alias FrappeUIPhx.Components.{CodeEditor, Editor}

  @editor_source Path.expand("../../../lib/frappe_ui_phx/components/editor.ex", __DIR__)

  describe "Editor" do
    test "campo de formulário com Markdown escapado no hidden e HTML seguro na área editável" do
      assigns = %{f: form_field(:texto, "## Olá\n\n**negrito** <script>x</script>")}
      html = rendered_to_string(~H|<Editor.editor field={@f} />|)
      assert html_attr(html, "input[type=hidden]", "name") == "f[texto]"
      assert html_attr(html, "input[type=hidden]", "value") =~ "## Olá"
      assert html_attr(html, "#f_texto", "phx-hook") =~ "Editor"
      assert html_attr(html, "[data-editable]", "contenteditable") == "true"
      assert has?(html, "[data-editable] h2")
      assert has?(html, "[data-editable] strong")
      refute has?(html, "[data-editable] script")
      refute html =~ "<script>x</script>"
      assert Enum.count(query(html, "[data-command]")) == 7
    end

    test "disabled desliga a edição e os botões; erro marca a borda" do
      assigns = %{f: form_field(:texto, "x", [{"curto", []}])}
      html = rendered_to_string(~H|<Editor.editor field={@f} disabled />|)
      assert html_attr(html, "[data-editable]", "contenteditable") == "false"
      assert has?(html, "button[data-command][disabled]")
      assert html_attr(html, "[data-editable]", "aria-invalid") == "true"
      assert html_attr(html, "#f_texto", "class") =~ "border-outline-red-3"
    end

    test "o servidor consegue redefinir o valor: o template com o HTML acompanha o hidden" do
      assigns = %{f: form_field(:texto, "novo valor")}
      html = rendered_to_string(~H|<Editor.editor field={@f} />|)
      assert html_attr(html, "input[type=hidden]", "value") == "novo valor"
      assert html =~ "<template data-html"
    end
  end

  describe "conversor DOM -> Markdown do hook (executado em Node)" do
    @describetag :node

    defp convert(cases) do
      source = File.read!(@editor_source)
      [_, converter] = Regex.run(~r{// <md-converter>\n(.*?)// </md-converter>}s, source)

      script = """
      #{converter}
      const t = (s) => ({nodeType: 3, textContent: s, childNodes: []})
      const el = (name, children = [], attrs = {}) =>
        ({nodeType: 1, nodeName: name, childNodes: children, getAttribute: (k) => attrs[k] ?? null})
      const root = (...children) => ({nodeType: 1, nodeName: "DIV", childNodes: children, getAttribute: () => null})
      const cases = #{cases}
      process.stdout.write(JSON.stringify(cases.map((c) => domToMarkdown(c))))
      """

      path = Path.join(System.tmp_dir!(), "fui_md_#{System.unique_integer([:positive])}.mjs")
      File.write!(path, script)
      on_exit(fn -> File.rm(path) end)
      {out, 0} = System.cmd("node", [path])
      Jason.decode!(out)
    end

    test "formatação inline, blocos, listas e links" do
      [bold, blocks, ol, code] =
        convert("""
        [
          root(el("DIV", [t("Olá "), el("B", [t("mundo")]), t(" e "), el("EM", [t("você")])])),
          root(el("H2", [t("Título")]), el("P", [t("texto")]), el("UL", [el("LI", [t("x")]), el("LI", [t("y")])])),
          root(el("OL", [el("LI", [t("a")]), el("LI", [t("b")])])),
          root(el("P", [t("use "), el("CODE", [t("mix test")])]))
        ]
        """)

      assert bold == "Olá **mundo** e _você_"
      assert blocks == "## Título\n\ntexto\n\n- x\n- y"
      assert ol == "1. a\n2. b"
      assert code == "use `mix test`"
    end

    test "links seguros viram Markdown; javascript:/data: viram só o texto" do
      [safe, js, data, protocol_relative] =
        convert("""
        [
          root(el("P", [el("A", [t("site")], {href: "https://a.b/c"})])),
          root(el("P", [el("A", [t("x")], {href: "javascript:alert(1)"})])),
          root(el("P", [el("A", [t("y")], {href: "data:text/html;base64,AAA"})])),
          root(el("P", [el("A", [t("z")], {href: "//evil.com"})]))
        ]
        """)

      assert safe == "[site](https://a.b/c)"
      assert js == "x" and data == "y" and protocol_relative == "z"
    end

    test "saída do conversor re-renderizada pelo Markdown seguro não contém tags perigosas" do
      [md] =
        convert(~s|[root(el("P", [t("<img src=x onerror=alert(1)> "), el("B", [t("ok")])]))]|)

      html = FrappeUIPhx.Markdown.to_html(md)
      refute html =~ "<img"
      assert html =~ "&lt;img" and html =~ "<strong>ok</strong>"
    end
  end

  describe "CodeEditor" do
    test "textarea com numeração de linhas, linguagem e contagem" do
      assigns = %{f: form_field(:codigo, "a\nb\nc")}
      html = rendered_to_string(~H|<CodeEditor.code_editor field={@f} language="elixir" />|)
      assert html_attr(html, "textarea", "name") == "f[codigo]"
      assert html_attr(html, "[data-language]", "data-language") == "elixir"
      assert text(html, "[data-gutter]") == "1\n2\n3"
      assert text(html, "[data-line-count]") == "3 linhas"
      assert html_attr(html, "[data-language]", "phx-hook") =~ "CodeEditor"
      assert html =~ "a\nb\nc"
    end

    test "uma linha, vazio e valor escapado" do
      assert CodeEditor.line_count("") == 1
      assert CodeEditor.line_count("a") == 1
      assert CodeEditor.line_count("a\nb") == 2
      assert CodeEditor.gutter(3) == "1\n2\n3"

      assigns = %{f: form_field(:codigo, "<b>x</b>")}
      html = rendered_to_string(~H|<CodeEditor.code_editor field={@f} />|)
      assert html =~ "&lt;b&gt;x&lt;/b&gt;"
      assert text(html, "[data-line-count]") == "1 linha"
    end

    test "contratos: linguagem e rows" do
      assigns = %{}

      assert_raise ArgumentError, ~r/language inválida/, fn ->
        rendered_to_string(~H|<CodeEditor.code_editor name="c" language="x y" />|)
      end

      assert_raise ArgumentError, ~r/rows/, fn ->
        rendered_to_string(~H|<CodeEditor.code_editor name="c" rows={0} />|)
      end
    end

    test "erro marca inválido" do
      assigns = %{f: form_field(:codigo, "", [{"vazio", []}])}

      assert html_attr(
               rendered_to_string(~H|<CodeEditor.code_editor field={@f} />|),
               "textarea",
               "aria-invalid"
             ) == "true"
    end
  end
end
