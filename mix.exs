defmodule Apix.Schema.MixProject do
  use Mix.Project

  def project do
    [
      app: :apix_schema,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      dialyzer: dialyzer(),
      docs: docs(),
      aliases: aliases()
    ]
  end

  def application do
    [
      mod: {Apix.Schema.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

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

  defp dialyzer do
    [
      plt_add_apps: [:mix, :elixir]
    ]
  end

  defp docs do
    [
      name: inspect(Apix.Schema),
      source_url: "https://github.com/florius0/schema",
      homepage_url: "https://github.com/florius0/schema",
      groups_for_modules: [
        # Apix.Schema
        Architecture: [
          Apix.Schema.Ast,
          Apix.Schema.Ast.Meta,
          Apix.Schema.Context,
          Apix.Schema.Error,
          Apix.Schema.Extension,
          Apix.Schema.Validator,
          Apix.Schema.Warning
        ],
        Extensions: [
          Apix.Schema.Extensions.TypeGraph,
          Apix.Schema.Extensions.Core,
          Apix.Schema.Extensions.Core.LocalReference,
          Apix.Schema.Extensions.Elixir
        ],
        Internal: [
          Apix.Schema.Extensions.TypeGraph.Definition,
          Apix.Schema.Extensions.TypeGraph.Dot,
          Apix.Schema.Extensions.TypeGraph.Graph,
          Apix.Schema.Extensions.TypeGraph.OnCompilation
        ]
      ],
      nest_modules_by_prefix: [
        Apix.Schema,
        Apix.Schema.Extensions
      ]
    ]
  end

  defp aliases do
    [
      check: ["cmd rm -rf reports", "check --manifest reports/manifest"]
    ]
  end
end
