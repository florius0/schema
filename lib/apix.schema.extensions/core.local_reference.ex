defmodule Apix.Schema.Extensions.Core.LocalReference do
  alias Apix.Schema.Extension

  alias Apix.Schema.Context

  @behaviour Extension

  @impl Extension
  def manifest do
    %Extension{
      module: __MODULE__
    }
  end

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
