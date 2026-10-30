defmodule FrappeUILive.Components.FormsTest do
  use FrappeUILive.Case, async: true

  alias FrappeUILive.Components.{
    Checkbox,
    FormControl,
    FormLabel,
    InputStyle,
    Select,
    Switch,
    TextInput,
    Textarea
  }

  describe "TextInput" do
    test "deriva id, name e value do FormField e repassa restrições" do
      assigns = %{f: form_field(:nome, "Ana")}

      html =
        rendered_to_string(
          ~H|<TextInput.text_input field={@f} required maxlength="40" placeholder="Seu nome" />|
        )

      assert html_attr(html, "input", "id") == "f_nome"
      assert html_attr(html, "input", "name") == "f[nome]"
      assert html_attr(html, "input", "value") == "Ana"
      assert has?(html, "input[required][maxlength='40'][placeholder='Seu nome']")
    end

    test "erro de changeset marca aria-invalid e a borda" do
      assigns = %{f: form_field(:nome, "", [{"não pode ser vazio", []}])}
      html = rendered_to_string(~H|<TextInput.text_input field={@f} />|)
      assert html_attr(html, "input", "aria-invalid") == "true"
      assert html_attr(html, "input", "class") =~ "border-outline-red-3"
    end

    test "campo não usado não mostra estado inválido" do
      assigns = %{f: form_field(:nome, nil, [{"x", []}], false)}

      refute html_attr(
               rendered_to_string(~H|<TextInput.text_input field={@f} />|),
               "input",
               "aria-invalid"
             )
    end

    test "name e value avulsos funcionam sem field" do
      assigns = %{}
      html = rendered_to_string(~H|<TextInput.text_input name="q" value="abc" type="search" />|)

      assert {html_attr(html, "input", "name"), html_attr(html, "input", "value"),
              html_attr(html, "input", "type")} ==
               {"q", "abc", "search"}
    end

    test "disabled esmaece e contrato barra tipo e variante inválidos" do
      assigns = %{}
      html = rendered_to_string(~H|<TextInput.text_input name="q" disabled />|)
      assert has?(html, "input[disabled]")
      assert html_attr(html, "input", "class") =~ "cursor-not-allowed"

      assert_raise ArgumentError, ~r/type/, fn ->
        rendered_to_string(~H|<TextInput.text_input name="q" type="foo" />|)
      end

      assert_raise ArgumentError, ~r/variant/, fn ->
        rendered_to_string(~H|<TextInput.text_input name="q" variant={:x} />|)
      end
    end
  end

  describe "Textarea" do
    test "renderiza valor escapado e linhas" do
      assigns = %{f: form_field(:bio, "<b>oi</b>")}
      html = rendered_to_string(~H|<Textarea.textarea field={@f} rows={5} />|)
      assert html_attr(html, "textarea", "rows") == "5"
      assert html =~ "&lt;b&gt;oi&lt;/b&gt;"
      refute html =~ "<b>oi</b>"
    end

    test "erro marca inválido" do
      assigns = %{f: form_field(:bio, "", [{"curto", []}])}

      assert html_attr(
               rendered_to_string(~H|<Textarea.textarea field={@f} />|),
               "textarea",
               "aria-invalid"
             ) == "true"
    end
  end

  describe "Select" do
    test "marca a opção selecionada e aceita prompt" do
      assigns = %{f: form_field(:status, "b")}

      html =
        rendered_to_string(
          ~H|<Select.select field={@f} options={[{"A", "a"}, {"B", "b"}]} prompt="Escolha" />|
        )

      assert has?(html, "option[value='']")
      assert has?(html, "option[value='b'][selected]")
      refute has?(html, "option[value='a'][selected]")
      assert html =~ "lucide-chevron-down"
    end

    test "multiple usa name com [] e sem chevron" do
      assigns = %{f: form_field(:tags)}
      html = rendered_to_string(~H|<Select.select field={@f} options={["x"]} multiple />|)
      assert html_attr(html, "select", "name") == "f[tags][]"
      refute html =~ "lucide-chevron-down"
    end
  end

  describe "Checkbox e Switch" do
    test "checkbox: hidden false + marcado conforme o valor" do
      assigns = %{on: form_field(:ativo, "true"), off: form_field(:ativo, "false")}
      on = rendered_to_string(~H|<Checkbox.checkbox field={@on} label="Ativo" />|)
      off = rendered_to_string(~H|<Checkbox.checkbox field={@off} label="Ativo" />|)
      assert has?(on, "input[type=hidden][value=false]")
      assert has?(on, "input[type=checkbox][checked]")
      refute has?(off, "input[type=checkbox][checked]")
      assert text(on, "label") =~ "Ativo"
    end

    test "switch é um checkbox com role=switch" do
      assigns = %{f: form_field(:ativo, "true")}
      html = rendered_to_string(~H|<Switch.switch field={@f} label="Notificar" size={:md} />|)
      assert has?(html, "input[role=switch][checked]")
      assert html =~ "h-5 w-8"

      assert_raise ArgumentError, ~r/switch size/, fn ->
        rendered_to_string(~H|<Switch.switch name="x" size={:enorme} />|)
      end
    end

    test "checked explícito vence o value" do
      assigns = %{}

      assert has?(
               rendered_to_string(~H|<Checkbox.checkbox name="x" checked />|),
               "input[type=checkbox][checked]"
             )
    end
  end

  describe "FormLabel e FormControl" do
    test "rótulo obrigatório mostra asterisco" do
      assigns = %{}

      html =
        rendered_to_string(~H|<FormLabel.form_label for="x" required>Nome</FormLabel.form_label>|)

      assert html_attr(html, "label", "for") == "x"
      assert html =~ "*"
    end

    test "FormControl liga rótulo ao campo e mostra erros traduzidos" do
      assigns = %{f: form_field(:nome, "", [{"deve ter %{count} letras", count: 3}])}

      html =
        rendered_to_string(
          ~H|<FormControl.form_control field={@f} label="Nome" description="Como no RG" required />|
        )

      assert html_attr(html, "label", "for") == "f_nome"
      assert html_attr(html, "input", "id") == "f_nome"
      assert has?(html, "input[required]")
      assert text(html, "[role=alert]") == "deve ter 3 letras"
      assert html =~ "Como no RG"
    end

    test "despacha por tipo" do
      assigns = %{f: form_field(:x, "v")}

      assert has?(
               rendered_to_string(
                 ~H|<FormControl.form_control field={@f} type="textarea" label="L" />|
               ),
               "textarea"
             )

      assert has?(
               rendered_to_string(
                 ~H|<FormControl.form_control field={@f} type="select" options={["v"]} label="L" />|
               ),
               "select"
             )

      assert has?(
               rendered_to_string(
                 ~H|<FormControl.form_control field={@f} type="checkbox" label="L" />|
               ),
               "input[type=checkbox]"
             )

      assert has?(
               rendered_to_string(
                 ~H|<FormControl.form_control field={@f} type="switch" label="L" />|
               ),
               "input[role=switch]"
             )

      assert has?(
               rendered_to_string(
                 ~H|<FormControl.form_control field={@f} type="email" label="L" />|
               ),
               "input[type=email]"
             )
    end
  end

  test "InputStyle: variantes e tamanhos conhecidos" do
    assert InputStyle.variants() == ~w(subtle outline ghost)a
    assert InputStyle.sizes() == ~w(xs sm md lg)a

    assert InputStyle.classes(:ghost, :xs, class: "extra")
           |> List.flatten()
           |> Enum.member?("extra")
  end
end
