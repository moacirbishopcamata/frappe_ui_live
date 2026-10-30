defmodule FrappeUILive.InstallerTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  alias FrappeUILive.Installer
  alias Mix.Tasks.FrappeUiLive.Install

  @css """
  /* See the Tailwind configuration guide */
  @import "tailwindcss" source(none);
  @source "../css";
  @source "../js";
  @source "../../lib/my_app_web";

  @plugin "../vendor/heroicons";
  """

  @js """
  import "phoenix_html"
  import {Socket} from "phoenix"
  import {LiveSocket} from "phoenix_live_view"
  import {hooks as colocatedHooks} from "phoenix-colocated/my_app"
  import topbar from "../vendor/topbar"

  const liveSocket = new LiveSocket("/live", Socket, {
    longPollFallbackMs: 2500,
    params: {_csrf_token: csrfToken},
    hooks: {...colocatedHooks},
  })
  """

  @mix_ok ~s|def project, do: [app: :my_app, compilers: [:phoenix_live_view] ++ Mix.compilers()]|
  @mix_bad ~s|def project, do: [app: :my_app, compilers: Mix.compilers()]|

  describe "patch_css/2" do
    test "insere imports e @source logo depois do @import do tailwind" do
      {:ok, css, true} = Installer.patch_css(@css, "../../deps/frappe_ui_live")
      lines = String.split(css, "\n")
      tailwind = Enum.find_index(lines, &String.starts_with?(&1, ~s(@import "tailwindcss")))

      assert Enum.at(lines, tailwind + 1) ==
               ~s(@import "../../deps/frappe_ui_live/priv/static/frappe_ui.css";)

      assert Enum.at(lines, tailwind + 2) =~ "frappe_ui_icons.css"
      assert Enum.at(lines, tailwind + 3) == ~s(@source "../../deps/frappe_ui_live/lib";)
      assert css =~ ~s(@plugin "../vendor/heroicons";)
    end

    test "idempotente" do
      {:ok, once, true} = Installer.patch_css(@css, "../../deps/frappe_ui_live")
      assert {:ok, ^once, false} = Installer.patch_css(once, "../../deps/frappe_ui_live")
    end

    test "sem tailwind v4 falha com motivo claro" do
      assert {:error, :no_tailwind_import} = Installer.patch_css("@tailwind base;", "x")
    end
  end

  describe "patch_js/1" do
    test "importa os hooks e os soma ao colocatedHooks do Phoenix 1.8" do
      {:ok, js, true} = Installer.patch_js(@js)
      assert js =~ ~s(import {hooks as frappeUiHooks} from "phoenix-colocated/frappe_ui_live")
      assert js =~ "hooks: {...colocatedHooks, ...frappeUiHooks}"
      lines = String.split(js, "\n")
      import_index = Enum.find_index(lines, &(&1 =~ "frappe_ui_live"))
      assert Enum.at(lines, import_index - 1) =~ "import topbar"
    end

    test "idempotente" do
      {:ok, once, true} = Installer.patch_js(@js)
      assert {:ok, ^once, false} = Installer.patch_js(once)
    end

    test "hooks: {} sem colocatedHooks recebe só o da lib" do
      js = String.replace(@js, "{...colocatedHooks}", "{}")
      {:ok, patched, true} = Installer.patch_js(js)
      assert patched =~ "hooks: {...frappeUiHooks, }"
    end

    test "sem opção hooks falha com motivo claro" do
      assert {:error, :no_hooks_option} =
               Installer.patch_js("import \"x\"\nnew LiveSocket(\"/live\", Socket, {})")

      assert {:error, :no_imports} = Installer.patch_js("const a = {hooks: {}}")
    end
  end

  test "check_compilers/1" do
    assert Installer.check_compilers(@mix_ok) == :ok
    assert {:missing, msg} = Installer.check_compilers(@mix_bad)
    assert msg =~ "compilers: [:phoenix_live_view]"
  end

  test "relative/2 calcula o caminho da dependência a partir do app.css" do
    root = Path.expand("meu_app")

    assert Installer.relative(
             Path.join(root, "deps/frappe_ui_live"),
             Path.join(root, "assets/css")
           ) == "../../deps/frappe_ui_live"

    assert Installer.relative(Path.expand("outro/frappe_ui_live"), Path.join(root, "assets/css")) =~
             "../../../outro/frappe_ui_live"
  end

  describe "mix frappe_ui_live.install (em um app temporário)" do
    setup do
      dir = Path.join(System.tmp_dir!(), "fui_install_#{System.unique_integer([:positive])}")
      File.mkdir_p!(Path.join(dir, "assets/css"))
      File.mkdir_p!(Path.join(dir, "assets/js"))
      File.write!(Path.join(dir, "assets/css/app.css"), @css)
      File.write!(Path.join(dir, "assets/js/app.js"), @js)
      File.write!(Path.join(dir, "mix.exs"), @mix_ok)
      on_exit(fn -> File.rm_rf!(dir) end)
      %{dir: dir}
    end

    defp run_install(dir, args) do
      capture_io(fn ->
        capture_io(:stderr, fn ->
          File.cd!(dir, fn ->
            Install.run(["--dep-path", Path.join(dir, "deps/frappe_ui_live")] ++ args)
          end)
        end)
      end)
    end

    test "aplica, e a segunda execução não muda nada", %{dir: dir} do
      out = run_install(dir, [])

      assert out =~ "app.css: atualizado" and out =~ "app.js: atualizado" and
               out =~ "compilers ok"

      css = File.read!(Path.join(dir, "assets/css/app.css"))
      js = File.read!(Path.join(dir, "assets/js/app.js"))
      assert css =~ "frappe_ui.css" and js =~ "frappeUiHooks"

      again = run_install(dir, [])
      assert again =~ "app.css: já configurado" and again =~ "app.js: já configurado"
      assert File.read!(Path.join(dir, "assets/css/app.css")) == css
      assert File.read!(Path.join(dir, "assets/js/app.js")) == js
    end

    test "--dry-run não escreve nada", %{dir: dir} do
      out = run_install(dir, ["--dry-run"])
      assert out =~ "seria atualizado"
      assert File.read!(Path.join(dir, "assets/css/app.css")) == @css
      assert File.read!(Path.join(dir, "assets/js/app.js")) == @js
    end

    test "mix.exs sem compilers falha alto, mas ainda edita os assets", %{dir: dir} do
      File.write!(Path.join(dir, "mix.exs"), @mix_bad)

      assert_raise Mix.Error, ~r/instalação incompleta/, fn ->
        File.cd!(dir, fn ->
          capture_io(:stderr, fn -> capture_io(fn -> Install.run(["--dep-path", dir]) end) end)
        end)
      end

      assert File.read!(Path.join(dir, "assets/css/app.css")) =~ "frappe_ui.css"
    end

    test "fora de um app Phoenix (sem assets) falha alto", %{dir: dir} do
      File.rm_rf!(Path.join(dir, "assets"))

      assert_raise Mix.Error, fn ->
        File.cd!(dir, fn ->
          capture_io(:stderr, fn -> capture_io(fn -> Install.run(["--dep-path", dir]) end) end)
        end)
      end
    end
  end
end
