defmodule FrappeUIPhx.Components.ButtonTest do
  use FrappeUIPhx.Case, async: true

  alias FrappeUIPhx.Components.Button

  test "botão padrão: type=button, rótulo e classes subtle/gray" do
    assigns = %{}
    html = rendered_to_string(~H|<Button.button label="Salvar" />|)
    assert html_attr(html, "button", "type") == "button"
    assert text(html, "button") == "Salvar"
    assert html_attr(html, "button", "class") =~ "bg-surface-gray-2"
  end

  test "slot tem precedência sobre label" do
    assigns = %{}

    assert text(rendered_to_string(~H|<Button.button label="x">Slot</Button.button>|), "button") ==
             "Slot"
  end

  test "variante solid e tema vermelho carregam variante dark e foco" do
    assigns = %{}
    html = rendered_to_string(~H|<Button.button theme={:red} variant={:solid} label="Excluir" />|)
    class = html_attr(html, "button", "class")
    assert class =~ "bg-surface-red-7"
    assert class =~ "dark:text-ink-red-9"
    assert class =~ "focus-visible:focus-ring-red"
  end

  test "botão só com ícone usa dimensões quadradas e oculta o rótulo" do
    assigns = %{}
    html = rendered_to_string(~H|<Button.button icon="plus" label="Novo" size={:md} />|)
    assert html_attr(html, "button", "class") =~ "h-8 w-8"
    assert html =~ "lucide-plus"
    refute html =~ "Novo"
  end

  test "ícones à esquerda e à direita" do
    assigns = %{}

    html =
      rendered_to_string(
        ~H|<Button.button label="Ir" icon_left="plus" icon_right="chevron-right" />|
      )

    assert html =~ "lucide-plus"
    assert html =~ "lucide-chevron-right"
  end

  test "loading: spinner, inerte, sem esmaecer e com texto de carregamento" do
    assigns = %{}

    html =
      rendered_to_string(~H|<Button.button label="Salvar" loading loading_text="Salvando…" />|)

    assert has?(html, "button[disabled]")
    assert has?(html, "svg[role=status]")
    assert text(html, "button") =~ "Salvando…"
    class = html_attr(html, "button", "class")
    assert class =~ "pointer-events-none"
    refute class =~ "text-ink-gray-4"
  end

  test "disabled usa as classes esmaecidas do tema" do
    assigns = %{}
    html = rendered_to_string(~H|<Button.button label="x" disabled />|)
    assert has?(html, "button[disabled]")
    assert html_attr(html, "button", "class") =~ "text-ink-gray-4"
  end

  test "navigate vira link; desabilitado volta a ser botão" do
    assigns = %{}
    link = rendered_to_string(~H|<Button.button label="Ir" navigate="/x" />|)
    assert html_attr(link, "a", "href") == "/x"
    refute has?(link, "button")

    inert = rendered_to_string(~H|<Button.button label="Ir" navigate="/x" disabled />|)
    assert has?(inert, "button[disabled]")
    refute has?(inert, "a")
  end

  test "href externo e patch também viram link" do
    assigns = %{}
    assert has?(rendered_to_string(~H|<Button.button label="x" href="https://a.b" />|), "a[href]")
    assert has?(rendered_to_string(~H|<Button.button label="x" patch="/p" />|), "a")
  end

  test "valores fora do contrato falham alto" do
    assigns = %{}

    assert_raise ArgumentError, ~r/button theme/, fn ->
      rendered_to_string(~H|<Button.button theme={:neon} />|)
    end

    assert_raise ArgumentError, ~r/button variant/, fn ->
      rendered_to_string(~H|<Button.button variant={:fosco} />|)
    end

    assert_raise ArgumentError, ~r/button size/, fn ->
      rendered_to_string(~H|<Button.button size={:gigante} />|)
    end
  end

  test "classes/1 é pura e cobre as 16 combinações de tema x variante" do
    for theme <- ~w(gray blue green red)a, variant <- ~w(solid subtle outline ghost)a do
      normal = Button.classes(%{theme: theme, variant: variant, size: :sm}) |> Enum.join(" ")

      disabled =
        Button.classes(%{theme: theme, variant: variant, size: :sm, disabled: true})
        |> Enum.join(" ")

      assert normal =~ "hover:"
      refute disabled =~ "hover:"
    end
  end
end
