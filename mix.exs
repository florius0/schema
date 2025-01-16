defmodule Apix.Schema.MixProject do
  use Mix.Project

  def project do
    [
      app: :apix_schema,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

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
          Apix.Schema.Extensions.Core,
          Apix.Schema.Extensions.Core.LocalReference,
          Apix.Schema.Extensions.Elixir
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
