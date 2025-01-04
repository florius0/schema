defmodule Apix.Schema.MixProject do
  use Mix.Project

  def project do
    [
      app: :apix_schema,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # Docs
      name: "MyApp",
      source_url: "https://github.com/USER/PROJECT",
      homepage_url: "http://YOUR_PROJECT_HOMEPAGE",
      docs: &docs/0,
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_check, "~> 0.14.0", only: [:dev, :test], runtime: false},
      {:mix_machine, github: "florius0/mix_machine"},
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:doctor, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:sobelow, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:mix_audit, ">= 0.0.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp docs do
    [
      main: inspect(Apix.Schema)
    ]
  end

  defp aliases do
    [
      check: ["cmd rm -rf reports", "check --manifest reports/manifest"]
    ]
  end
end
