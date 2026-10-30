defmodule FrappeUILive.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/frappe_ui_live/frappe_ui_live"

  def project do
    [
      app: :frappe_ui_live,
      version: @version,
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      test_coverage: [summary: [threshold: 90]],
      description: "Componentes Phoenix LiveView com a identidade visual do Frappe UI.",
      package: package(),
      docs: [main: "readme", extras: ["README.md", "LICENSE"], source_ref: "v#{@version}"],
      source_url: @source_url
    ]
  end

  def application, do: [extra_applications: [:logger]]

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.8"},
      {:phoenix_live_view, "~> 1.2"},
      {:phoenix_html, "~> 4.3"},
      {:lazy_html, "~> 0.1", only: :test},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false},
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      "tokens.sync": ["cmd node scripts/sync_tokens.mjs"],
      quality: ["format --check-formatted", "compile --warnings-as-errors", "test --cover", "deps.audit"]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"Frappe UI" => "https://ui.frappe.io"},
      files: ~w(lib priv scripts mix.exs README.md LICENSE .formatter.exs)
    ]
  end
end
