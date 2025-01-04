defmodule Apix.Schema.Extensions.Core.LocalReference do
  alias Apix.Schema

  alias Apix.Schema.Extension

  alias Apix.Schema.Context

  @manifest %Extension{
    module: __MODULE__
  }

  @behaviour Extension

  @moduledoc """
  Core functionality of `#{inspect Schema}`.

  #{Extension.delegates_doc(@manifest)}

  ## Expressions

  - local (defied in same module) schema referencing.

  > #### Info {: .info}
  >
  > Due to technical limitations, local (defied in same module) schema referencing is a separate extension #{inspect Apix.Schema.Extensions.Core.LocalReference}.
  > #{inspect Apix.Schema.Extensions.Core.LocalReference} should be installed as last extension to prevent all other expressions to be recognized as local references
  """

  @impl Extension
  def manifest, do: @manifest

  @impl Extension
  def expression!(context, {schema, _, elixir_ast}, schema_ast, env, false) when schema != :__block__ do
    struct(schema_ast,
      module: env.module,
      schema: schema,
      args: Enum.map(elixir_ast, &Context.expression!(context, &1, schema_ast, env))
    )
  end

  def expression!(_context, _ast, _schema_ast, _env, _literal?), do: false
end
