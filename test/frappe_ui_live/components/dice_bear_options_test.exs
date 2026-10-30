defmodule FrappeUILive.Components.DiceBearOptionsTest do
  use FrappeUILive.Case, async: true

  alias FrappeUILive.Components.DiceBearAvatar
  alias FrappeUILive.DiceBear

  describe "DiceBear.options/1 (opções do núcleo)" do
    test "converte snake_case para os parâmetros da API" do
      assert DiceBear.options(
               flip: "horizontal",
               rotate: -10,
               scale: 0.9,
               border_radius: 50,
               translate_x: 5,
               translate_y: -5,
               background_color: ["#b6e3f4", "C0AEDE"],
               background_color_fill: "linear",
               background_color_angle: 45,
               tags: "animation"
             ) == %{
               "flip" => "horizontal",
               "rotate" => -10,
               "scale" => 0.9,
               "borderRadius" => 50,
               "translateX" => 5,
               "translateY" => -5,
               "backgroundColor" => ["b6e3f4", "C0AEDE"],
               "backgroundColorFill" => "linear",
               "backgroundColorAngle" => 45,
               "tags" => ["animation"]
             }
    end

    test "limites documentados valem nos dois extremos" do
      for {key, ok, bad} <- [
            {:rotate, [-360, 360], [-361, 361]},
            {:scale, [0, 10], [-0.1, 10.1]},
            {:border_radius, [0, 50], [-1, 51]},
            {:translate_x, [-1000, 1000], [-1001, 1001]},
            {:background_color_angle, [-360, 360], [-361, 361]}
          ] do
        for value <- ok, do: assert(DiceBear.options([{key, value}]) != %{})

        for value <- bad do
          assert_raise ArgumentError, ~r/fora do contrato/, fn ->
            DiceBear.options([{key, value}])
          end
        end
      end

      assert_raise ArgumentError, ~r/fora do contrato/, fn -> DiceBear.options(rotate: "10") end
    end

    test "enum, cor e tags inválidos falham; chave desconhecida também" do
      assert_raise ArgumentError, ~r/dice_bear flip/, fn -> DiceBear.options(flip: "diagonal") end

      assert_raise ArgumentError, ~r/cor "red"/, fn ->
        DiceBear.options(background_color: "red")
      end

      assert_raise ArgumentError, ~r/cor "#12"/, fn ->
        DiceBear.options(background_color: ["#12"])
      end

      assert_raise ArgumentError, ~r/ao menos uma cor/, fn ->
        DiceBear.options(background_color: [])
      end

      assert_raise ArgumentError, ~r/tags/, fn -> DiceBear.options(tags: "a b&c") end
      assert_raise ArgumentError, ~r/desconhecida/, fn -> DiceBear.options(cor_da_pele: "x") end
    end

    test "cores de 3, 4, 6 e 8 dígitos são aceitas e o # é removido" do
      assert DiceBear.options(background_color: ["#fff", "abcd", "#aabbcc", "aabbccdd"]) ==
               %{"backgroundColor" => ["fff", "abcd", "aabbcc", "aabbccdd"]}
    end
  end

  describe "API pública x instância própria" do
    test "opções que a API pública não suporta são recusadas com explicação" do
      for key <- ~w(idRandomization fontFamily fontWeight title) do
        assert_raise ArgumentError, ~r/não funciona na API pública/, fn ->
          DiceBear.url("thumbs", "x", %{key => "1"})
        end
      end
    end

    test "em instância própria (base_url) elas passam" do
      assert DiceBear.url("thumbs", "x", %{title: "Ana"}, base_url: "https://av.meuapp.com/10.x") ==
               "https://av.meuapp.com/10.x/thumbs/svg?seed=x&title=Ana"

      assert DiceBear.url("thumbs", "x", %{idRandomization: true}, base_url: "/av") ==
               "/av/thumbs/svg?idRandomization=true&seed=x"
    end
  end

  describe "DiceBear.initials/1 (receita placeholder)" do
    test "primeira e última palavra, em maiúsculas" do
      assert DiceBear.initials("Ana Souza") == "AS"
      assert DiceBear.initials("  maria da silva  ") == "MS"
      assert DiceBear.initials("ana") == "A"
      assert DiceBear.initials("Édson  Álvares") == "ÉÁ"
    end

    test "sem letras ou valor inválido devolve nil" do
      assert DiceBear.initials("") == nil
      assert DiceBear.initials("  --  ") == nil
      assert DiceBear.initials(nil) == nil
      assert DiceBear.initials(42) == nil
    end
  end

  describe "DiceBearAvatar com opções tipadas e placeholder" do
    test "atributos tipados viram parâmetros e vencem o mapa options" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <DiceBearAvatar.dice_bear_avatar
          seed="ana"
          border_radius={50}
          flip="horizontal"
          background_color={["#b6e3f4"]}
          options={%{borderRadius: 10, hairVariant: ["short01", "short02"]}}
        />
        """)

      query =
        html |> html_attr("img", "src") |> URI.parse() |> Map.fetch!(:query) |> URI.decode_query()

      assert query == %{
               "seed" => "ana",
               "borderRadius" => "50",
               "flip" => "horizontal",
               "backgroundColor" => "b6e3f4",
               "hairVariant" => "short01,short02"
             }
    end

    test "valor tipado inválido falha alto" do
      assigns = %{}

      assert_raise ArgumentError, ~r/fora do contrato/, fn ->
        rendered_to_string(~H|<DiceBearAvatar.dice_bear_avatar seed="a" scale={11} />|)
      end
    end

    test "placeholder: com foto mostra a foto; sem foto, o avatar gerado" do
      assigns = %{}

      with_photo =
        rendered_to_string(
          ~H|<DiceBearAvatar.dice_bear_avatar seed="ana" image="/uploads/ana.jpg" label="Ana" />|
        )

      assert html_attr(with_photo, "img", "src") == "/uploads/ana.jpg"

      without =
        rendered_to_string(
          ~H|<DiceBearAvatar.dice_bear_avatar seed="ana" image={nil} label="Ana" />|
        )

      assert html_attr(without, "img", "src") =~ "dicebear.com"
    end

    test "placeholder de iniciais do nome" do
      assigns = %{name: "Ana Souza"}

      html =
        rendered_to_string(
          ~H|<DiceBearAvatar.dice_bear_avatar seed={DiceBear.initials(@name)} style="initials" label={@name} />|
        )

      assert html_attr(html, "img", "src") == "https://api.dicebear.com/10.x/initials/svg?seed=AS"
    end
  end
end
