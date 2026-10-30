defmodule FrappeUILive.Components.FeedbackTest do
  use FrappeUILive.Case, async: true

  alias FrappeUILive.Components.{
    Alert,
    Avatar,
    Badge,
    Divider,
    ErrorMessage,
    Icon,
    Progress,
    Skeleton,
    Spinner
  }

  describe "Badge" do
    test "renderiza rótulo com classes de tema e variante" do
      assigns = %{}
      html = rendered_to_string(~H|<Badge.badge theme={:green} variant={:solid} label="Pago" />|)
      assert text(html, "span") == "Pago"
      assert html_attr(html, "span", "class") =~ "bg-surface-green-7"
    end

    test "aceita conteúdo por slot no lugar do rótulo" do
      assigns = %{}
      html = rendered_to_string(~H|<Badge.badge>Slot</Badge.badge>|)
      assert text(html, "span") == "Slot"
    end

    test "tema inválido falha alto (contrato)" do
      assigns = %{}

      assert_raise ArgumentError, ~r/badge theme/, fn ->
        rendered_to_string(~H|<Badge.badge theme={:neon} label="x" />|)
      end
    end

    test "todas as combinações de tema e variante têm classes" do
      for theme <- ~w(gray blue green amber red violet)a,
          variant <- ~w(solid subtle outline ghost)a do
        classes =
          [theme: theme, variant: variant, size: :md]
          |> Map.new()
          |> Badge.classes()
          |> List.flatten()
          |> Enum.join(" ")

        assert classes =~ "text-"
      end
    end
  end

  describe "Alert" do
    test "mostra título, descrição e ícone do tema" do
      assigns = %{}

      html =
        rendered_to_string(~H|<Alert.alert theme={:red} title="Falhou">Detalhe</Alert.alert>|)

      assert html_attr(html, "div", "role") == "alert"
      assert text(html, "p") == "Falhou"
      assert html =~ "lucide-circle-alert"
      assert html =~ "Detalhe"
    end

    test "ícone próprio sobrescreve o do tema" do
      assigns = %{}
      html = rendered_to_string(~H|<Alert.alert title="x" icon="rocket" />|)
      assert html =~ "lucide-rocket"
    end

    test "renderiza ações" do
      assigns = %{}
      html = rendered_to_string(~H|<Alert.alert title="x">
  <:actions>Desfazer</:actions>
</Alert.alert>|)
      assert html =~ "Desfazer"
    end
  end

  describe "Progress" do
    test "expõe aria e largura da barra" do
      assigns = %{}
      html = rendered_to_string(~H|<Progress.progress value={40} label="Envio" show_value />|)
      assert html_attr(html, "[role=progressbar]", "aria-valuenow") == "40"
      assert html =~ "width: 40%"
      assert html =~ "40%"
      assert html =~ "Envio"
    end

    test "valor fora de 0..100 viola a pré-condição" do
      assigns = %{}

      assert_raise ArgumentError, ~r/fora de 0..100/, fn ->
        rendered_to_string(~H|<Progress.progress value={101} />|)
      end
    end
  end

  describe "Avatar" do
    test "usa a inicial maiúscula do rótulo" do
      assigns = %{}
      assert text(rendered_to_string(~H|<Avatar.avatar label="  maria" />|), "span span") == "M"
    end

    test "usa imagem quando houver" do
      assigns = %{}
      html = rendered_to_string(~H|<Avatar.avatar label="Ana" image="/a.png" shape={:square} />|)
      assert html_attr(html, "img", "src") == "/a.png"
      assert html_attr(html, "span", "class") =~ "rounded-4"
    end

    test "initial/1 cobre nil e vazio" do
      assert Avatar.initial(nil) == ""
      assert Avatar.initial("") == ""
    end
  end

  describe "ErrorMessage" do
    test "nil e lista vazia não renderizam nada" do
      assigns = %{}
      refute rendered_to_string(~H|<ErrorMessage.error_message message={nil} />|) =~ "<p"
      refute rendered_to_string(~H|<ErrorMessage.error_message message={[]} />|) =~ "<p"
    end

    test "junta várias mensagens e descarta vazias" do
      assert ErrorMessage.lines(["a", "  ", "b"]) == ["a", "b"]
      assigns = %{}
      html = rendered_to_string(~H|<ErrorMessage.error_message message={["a", "b"]} id="e" />|)
      assert html_attr(html, "p", "role") == "alert"
      assert text(html, "p") =~ "a"
    end

    test "aceita string única" do
      assert ErrorMessage.lines("só uma") == ["só uma"]
    end
  end

  describe "Divider, Skeleton, Spinner, Icon" do
    test "Divider horizontal e vertical" do
      assigns = %{}

      assert html_attr(rendered_to_string(~H|<Divider.divider />|), "hr", "class") =~
               "border-t-[1px]"

      assert html_attr(
               rendered_to_string(~H|<Divider.divider orientation={:vertical} />|),
               "hr",
               "class"
             ) =~ "border-l-[1px]"

      assert_raise ArgumentError, fn ->
        rendered_to_string(~H|<Divider.divider orientation={:diagonal} />|)
      end
    end

    test "Skeleton aceita dimensões" do
      assigns = %{}

      assert html_attr(
               rendered_to_string(~H|<Skeleton.skeleton class="h-8 w-8" />|),
               "div",
               "class"
             ) =~ "h-8 w-8"
    end

    test "Spinner tem papel de status" do
      assigns = %{}
      assert html_attr(rendered_to_string(~H|<Spinner.spinner />|), "svg", "role") == "status"
    end

    test "Icon resolve nome por IconResolver, inclusive já prefixado" do
      assigns = %{}

      assert html_attr(rendered_to_string(~H|<Icon.icon name="plus" />|), "span", "class") =~
               "lucide-plus"

      assert html_attr(rendered_to_string(~H|<Icon.icon name="lucide-x" />|), "span", "class") ==
               "lucide-x"
    end
  end
end
