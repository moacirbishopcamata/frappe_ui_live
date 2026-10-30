defmodule FrappeUILive.Components.PinDiceBearTest do
  use FrappeUILive.Case, async: true

  alias FrappeUILive.Components.{DiceBearAvatar, PinCode}
  alias FrappeUILive.DiceBear

  describe "PinCode" do
    test "uma caixa por caractere, campo oculto com o código e nada parcial com name" do
      assigns = %{}

      html =
        rendered_to_string(~H|<PinCode.pin_code id="otp" name="codigo" value="123" length={6} />|)

      assert Enum.count(query(html, "[data-pin-cell]")) == 6
      assert Enum.count(query(html, "[name]")) == 1
      assert html_attr(html, "input[name=codigo]", "type") == "hidden"
      assert html_attr(html, "input[name=codigo]", "value") == "123"

      values = html |> query("[data-pin-cell]") |> LazyHTML.attribute("value")
      assert values == ["1", "2", "3", "", "", ""]
    end

    test "acessibilidade e teclado: grupo rotulado, caractere N de T, one-time-code, numérico" do
      assigns = %{}
      html = rendered_to_string(~H|<PinCode.pin_code id="otp" name="c" length={4} />|)

      assert html_attr(html, "#otp", "role") == "group"
      assert html_attr(html, "#otp", "aria-label") == "Código de verificação"
      assert html_attr(html, "#otp", "phx-hook") == "FrappeUILive.Components.PinCode.PinCode"
      labels = html |> query("[data-pin-cell]") |> LazyHTML.attribute("aria-label")
      assert labels == for(n <- 1..4, do: "Caractere #{n} de 4")
      assert html_attr(html, "[data-pin-cell]", "autocomplete") == "one-time-code"
      assert html_attr(html, "[data-pin-cell]", "inputmode") == "numeric"
      assert html_attr(html, "[data-pin-cell]", "maxlength") == "4"
    end

    test "field: nome, id e valor do changeset; erro só depois de usado" do
      field = form_field(:codigo, "9876", [{"código inválido", []}])
      assigns = %{f: field}
      html = rendered_to_string(~H|<PinCode.pin_code field={@f} length={4} />|)

      assert html_attr(html, "input[type=hidden]", "name") == "f[codigo]"
      assert html_attr(html, "input[type=hidden]", "value") == "9876"
      assert html_attr(html, "[data-pin-cell]", "aria-invalid") == "true"

      assigns = %{f: form_field(:codigo, "", [{"x", []}], false)}
      html = rendered_to_string(~H|<PinCode.pin_code field={@f} length={4} />|)
      assert html_attr(html, "[data-pin-cell]", "aria-invalid") == nil
    end

    test "mask, alfanumérico, desabilitado e on_complete" do
      assigns = %{}

      html =
        rendered_to_string(~H|<PinCode.pin_code
  id="p"
  name="c"
  length={4}
  mask
  type={:alphanumeric}
  disabled
  on_complete="verificar"
/>|)

      assert html_attr(html, "[data-pin-cell]", "type") == "password"
      assert html_attr(html, "[data-pin-cell]", "inputmode") == "text"
      assert html_attr(html, "[data-pin-cell]", "disabled") != nil
      assert html_attr(html, "#p", "data-on-complete") == "verificar"
      assert html_attr(html, "#p", "data-type") == "alphanumeric"
    end

    test "valor inválido é limpo e cortado, nunca quebra" do
      assert PinCode.cells("12-34 56789", 6, :numeric) == ~w(1 2 3 4 5 6)
      assert PinCode.cells("a1", 3, :numeric) == ["1", "", ""]
      assert PinCode.cells(nil, 3, :numeric) == ["", "", ""]
      assert PinCode.cells(1234, 4, :numeric) == ~w(1 2 3 4)
      assert PinCode.cells("aB9-", 4, :alphanumeric) == ["a", "B", "9", ""]
      assert PinCode.sanitize(%{}, :numeric) == ""
    end

    test "contrato: length, type e id" do
      assigns = %{}
      msg = ~r/fora do contrato/

      assert_raise ArgumentError, msg, fn ->
        rendered_to_string(~H|<PinCode.pin_code id="a" name="c" length={2} />|)
      end

      assert_raise ArgumentError, msg, fn ->
        rendered_to_string(~H|<PinCode.pin_code id="a" name="c" length={13} />|)
      end

      assert_raise ArgumentError, msg, fn ->
        rendered_to_string(~H|<PinCode.pin_code id="a" name="c" type={:hex} />|)
      end

      assert_raise ArgumentError, fn ->
        rendered_to_string(~H|<PinCode.pin_code name="c" />|)
      end
    end

    test "o hook colocated existe no manifesto" do
      manifest = Path.join(Mix.Project.build_path(), "phoenix-colocated/frappe_ui_live/index.js")
      assert File.read!(manifest) =~ "PinCode"
    end

    @tag :node
    test "paridade: a regra de caracteres do hook (JS) limpa igual ao sanitize/2 (Elixir)" do
      source =
        File.read!(Path.expand("../../../lib/frappe_ui_live/components/pin_code.ex", __DIR__))

      [_, numeric] = Regex.run(~r{numeric: (/\[\^0-9\]/g)}, source)
      [_, alnum] = Regex.run(~r{alphanumeric: (/\[\^A-Za-z0-9\]/g)}, source)
      samples = ["123456", "12 34-56", "a1b2", "ａ１", "١٢٣", "ab\n12", "", "9é8", "_*#1"]

      script =
        "const R = {numeric: #{numeric}, alphanumeric: #{alnum}}; const s = #{Jason.encode!(samples)};" <>
          "process.stdout.write(JSON.stringify(['numeric','alphanumeric'].map((t) => s.map((x) => x.replace(R[t], '')))))"

      {out, 0} = System.cmd("node", ["-e", script])
      [js_num, js_alnum] = Jason.decode!(out)
      assert js_num == Enum.map(samples, &PinCode.sanitize(&1, :numeric))
      assert js_alnum == Enum.map(samples, &PinCode.sanitize(&1, :alphanumeric))
    end
  end

  describe "DiceBear.url/4" do
    test "monta a URL com seed e opções ordenadas e codificadas" do
      assert DiceBear.url("thumbs", "ana", %{
               backgroundColor: ["b6e3f4", "c0aede"],
               flip: "horizontal"
             }) ==
               "https://api.dicebear.com/10.x/thumbs/svg?backgroundColor=b6e3f4%2Cc0aede&flip=horizontal&seed=ana"
    end

    test "seed com caracteres especiais é codificada (sem injeção de parâmetros)" do
      url = DiceBear.url("initials", "a&radius=0 ü/?#", %{})

      assert url ==
               "https://api.dicebear.com/10.x/initials/svg?seed=a%26radius%3D0+%C3%BC%2F%3F%23"

      assert URI.decode_query(URI.parse(url).query) == %{"seed" => "a&radius=0 ü/?#"}
    end

    test "estilo novo, ainda fora da lista conhecida, não é recusado (o servidor decide)" do
      assert DiceBear.url("estilo-do-futuro", "x") ==
               "https://api.dicebear.com/10.x/estilo-do-futuro/svg?seed=x"
    end

    test "formato e servidor próprio" do
      assert DiceBear.url("bottts", "x", %{},
               format: "png",
               base_url: "https://av.meuapp.com/9.x/"
             ) ==
               "https://av.meuapp.com/9.x/bottts/png?seed=x"

      assert DiceBear.url("bottts", "x", %{}, base_url: "/avatares") ==
               "/avatares/bottts/svg?seed=x"
    end

    test "base_url vem da configuração e é validada" do
      Application.put_env(:frappe_ui_live, :dice_bear_base_url, "https://cfg.example/9.x")
      on_exit(fn -> Application.delete_env(:frappe_ui_live, :dice_bear_base_url) end)
      assert DiceBear.url("glass", "x") == "https://cfg.example/9.x/glass/svg?seed=x"

      Application.put_env(:frappe_ui_live, :dice_bear_base_url, "javascript:alert(1)")
      assert_raise ArgumentError, ~r/dice_bear_base_url/, fn -> DiceBear.base_url() end
    end

    test "contrato: estilo, seed, formato, base, chaves e valores das opções" do
      assert_raise ArgumentError, ~r/dice_bear style/, fn -> DiceBear.url("../x", "x") end
      assert_raise ArgumentError, ~r/dice_bear style/, fn -> DiceBear.url("Thumbs", "x") end
      assert_raise ArgumentError, ~r/dice_bear style/, fn -> DiceBear.url(:thumbs, "x") end
      assert_raise ArgumentError, ~r/dice_bear seed/, fn -> DiceBear.url("thumbs", "") end
      assert_raise ArgumentError, ~r/dice_bear seed/, fn -> DiceBear.url("thumbs", nil) end

      assert_raise ArgumentError, ~r/dice_bear format/, fn ->
        DiceBear.url("thumbs", "x", %{}, format: "gif")
      end

      assert_raise ArgumentError, ~r/base_url/, fn ->
        DiceBear.url("thumbs", "x", %{}, base_url: "ftp://x")
      end

      assert_raise ArgumentError, ~r/nome inválido/, fn ->
        DiceBear.url("thumbs", "x", %{"a=b&c" => 1})
      end

      assert_raise ArgumentError, ~r/não suportado/, fn ->
        DiceBear.url("thumbs", "x", %{a: %{}})
      end

      assert_raise ArgumentError, ~r/lista só aceita/, fn ->
        DiceBear.url("thumbs", "x", %{a: [%{}]})
      end
    end

    test "seed/1 é estável, opaca e não vaza o identificador" do
      assert DiceBear.seed("ana@exemplo.com") == DiceBear.seed("ana@exemplo.com")
      assert DiceBear.seed(42) == DiceBear.seed("42")
      refute DiceBear.seed("ana@exemplo.com") =~ "ana"
      assert DiceBear.seed("x") =~ ~r/\A[0-9a-f]{16}\z/
    end

    test "styles/0 e formats/0 não têm duplicados" do
      assert DiceBear.styles() == Enum.uniq(DiceBear.styles())
      assert length(DiceBear.styles()) == 61
      assert "thumbs" in DiceBear.styles() and "svg" in DiceBear.formats()
      assert Enum.all?(DiceBear.styles(), &(&1 =~ ~r/\A[a-z][a-z0-9]*(-[a-z0-9]+)*\z/))
    end
  end

  describe "DiceBearAvatar" do
    test "renderiza Avatar com a imagem do DiceBear, lazy e sem Referer" do
      assigns = %{}

      html =
        rendered_to_string(
          ~H|<DiceBearAvatar.dice_bear_avatar seed="ana" style="lorelei" label="Ana" size={:xl} />|
        )

      assert html_attr(html, "img", "src") == "https://api.dicebear.com/10.x/lorelei/svg?seed=ana"
      assert html_attr(html, "img", "alt") == "Ana"
      assert html_attr(html, "img", "loading") == "lazy"
      assert html_attr(html, "img", "referrerpolicy") == "no-referrer"
      assert html_attr(html, "span", "data-dice-bear-style") == "lorelei"
      assert html_attr(html, "span", "class") =~ "size-8"
    end

    test "sem label é decorativo (alt vazio); forma, opções e servidor próprio" do
      assigns = %{}

      html =
        rendered_to_string(~H|<DiceBearAvatar.dice_bear_avatar
  seed="b"
  shape={:square}
  options={%{borderRadius: 20}}
  base_url="/av"
  class="x"
/>|)

      assert html_attr(html, "img", "alt") == ""
      assert html_attr(html, "img", "src") == "/av/thumbs/svg?borderRadius=20&seed=b"
      assert html_attr(html, "span", "class") =~ "rounded-4"
      assert html_attr(html, "span", "class") =~ "x"
    end

    test "contrato: estilo e seed inválidos falham alto" do
      assigns = %{}

      assert_raise ArgumentError, ~r/dice_bear style/, fn ->
        rendered_to_string(~H|<DiceBearAvatar.dice_bear_avatar seed="a" style="../x" />|)
      end

      assert_raise ArgumentError, ~r/dice_bear seed/, fn ->
        rendered_to_string(~H|<DiceBearAvatar.dice_bear_avatar seed="" />|)
      end
    end

    test "Avatar comum também carrega imagem sob demanda e sem Referer" do
      assigns = %{}

      html =
        rendered_to_string(~H|<FrappeUILive.Components.Avatar.avatar image="/a.png" label="A" />|)

      assert html_attr(html, "img", "referrerpolicy") == "no-referrer"
    end
  end
end
