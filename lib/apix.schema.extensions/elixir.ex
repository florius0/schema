defmodule Apix.Schema.Extensions.Elixir do
  alias Apix.Schema

  alias Apix.Schema.Extension

  alias Apix.Schema.Ast
  alias Apix.Schema.Context

  alias Apix.Schema.Extensions.Elixir.Atom
  alias Apix.Schema.Extensions.Elixir.String
  alias Apix.Schema.Extensions.Elixir.Integer
  alias Apix.Schema.Extensions.Elixir.Float
  alias Apix.Schema.Extensions.Elixir.Tuple
  alias Apix.Schema.Extensions.Elixir.List
  alias Apix.Schema.Extensions.Elixir.Map
  alias Apix.Schema.Extensions.Elixir.Function
  alias Apix.Schema.Extensions.Elixir.Module
  alias Apix.Schema.Extensions.Elixir.PID
  alias Apix.Schema.Extensions.Elixir.Port
  alias Apix.Schema.Extensions.Elixir.Reference
  alias Apix.Schema.Extensions.Elixir.Date
  alias Apix.Schema.Extensions.Elixir.Time
  alias Apix.Schema.Extensions.Elixir.DateTime
  alias Apix.Schema.Extensions.Elixir.NaiveDateTime
  alias Apix.Schema.Extensions.Elixir.Regex
  alias Apix.Schema.Extensions.Elixir.Uri
  alias Apix.Schema.Extensions.Elixir.Version
  alias Apix.Schema.Extensions.Elixir.Version

  @manifest %Extension{
    module: __MODULE__,
    delegates: [
      {
        {Elixir.Atom, :t},
        {Atom, :t}
      },
      {
        {Elixir.String, :t},
        {String, :t}
      },
      {
        {Elixir.Integer, :t},
        {Integer, :t}
      },
      {
        {Elixir.Float, :t},
        {Float, :t}
      },
      {
        {Elixir.Tuple, :t},
        {Tuple, :t}
      },
      {
        {Elixir.List, :t},
        {List, :t}
      },
      {
        {Elixir.Map, :t},
        {Map, :t}
      },
      {
        {Elixir.Function, :t},
        {Function, :t}
      },
      {
        {Elixir.Module, :t},
        {Module, :t}
      },
      {
        {Elixir.PID, :t},
        {PID, :t}
      },
      {
        {Elixir.Port, :t},
        {Port, :t}
      },
      {
        {Elixir.Reference, :t},
        {Reference, :t}
      },
      {
        {Elixir.Date, :t},
        {Date, :t}
      },
      {
        {Elixir.Time, :t},
        {Time, :t}
      },
      {
        {Elixir.DateTime, :t},
        {DateTime, :t}
      },
      {
        {Elixir.NaiveDateTime, :t},
        {NaiveDateTime, :t}
      },
      {
        {Elixir.Regex, :t},
        {Regex, :t}
      },
      {
        {Elixir.Uri, :t},
        {Uri, :t}
      },
      {
        {Elixir.Version, :t},
        {Version, :t}
      },
      {
        {Elixir.Version.Requirement, :t},
        {Version.Requirement, :t}
      }
    ]
  }

  @moduledoc """
  Defines `#{inspect Schema}` Extension to support Elixir types.

  #{Extension.delegates_doc(@manifest)}

  ## Expressions

  - `item`
  - `rest`
  - `field`
  """

  @behaviour Extension

  @impl Extension
  def manifest, do: @manifest

  @impl Extension
  def expression!(context, {:item, _, elixir_ast}, schema_ast, env, _literal?) do
    type = inner_expression!(context, elixir_ast, %Ast{}, env)

    struct(schema_ast, args: schema_ast.args ++ [item: type])
  end

  def expression!(context, {:rest, _, elixir_ast}, schema_ast, env, _literal?) do
    type = inner_expression!(context, elixir_ast, %Ast{}, env)

    struct(schema_ast, args: schema_ast.args ++ [rest: type])
  end

  def expression!(context, {:field, _, [[do: {:__block__, _, [{:key, _, key_elixir_ast}, {:value, _, value_elixir_ast} | _]}]]}, schema_ast, env, _literal?) do
    key_type = inner_expression!(context, key_elixir_ast, %Ast{}, env)
    value_type = inner_expression!(context, value_elixir_ast, %Ast{}, env)

    struct(schema_ast, args: schema_ast.args ++ [field: {key_type, value_type}])
  end

  def expression!(context, {:field, _, [key_elixir_ast | value_elixir_ast]}, schema_ast, env, _literal?) do
    key_type = Context.expression!(context, key_elixir_ast, %Ast{}, env)
    value_type = inner_expression!(context, value_elixir_ast, %Ast{}, env)

    struct(schema_ast, args: schema_ast.args ++ [field: {key_type, value_type}])
  end

  def expression!(_context, _ast, _schema_ast, _env, _literal?), do: false

  def inner_expression!(context, [type_elixir_ast], schema_ast, env) do
    Context.expression!(context, type_elixir_ast, schema_ast, env)
  end

  def inner_expression!(context, [type_elixir_ast, [do: block_elixir_ast]], schema_ast, env) do
    schema_ast = Context.expression!(context, type_elixir_ast, schema_ast, env)
    schema_ast = Context.expression!(context, block_elixir_ast, schema_ast, env)

    schema_ast
  end

  def inner_expression!(context, [type_elixir_ast, flags_elixir_ast], schema_ast, env) do
    {flags, _, _} = Code.eval_quoted_with_env(flags_elixir_ast, [], env)

    schema_ast = struct(schema_ast, flags: schema_ast.flags ++ flags)
    schema_ast = Context.expression!(context, type_elixir_ast, schema_ast, env)

    schema_ast
  end

  def inner_expression!(context, [type_elixir_ast, flags_elixir_ast, [do: block_elixir_ast]], schema_ast, env) do
    {flags, _, _} = Code.eval_quoted_with_env(flags_elixir_ast, [], env)

    schema_ast = struct(schema_ast, flags: schema_ast.flags ++ flags)
    schema_ast = Context.expression!(context, type_elixir_ast, schema_ast, env)
    schema_ast = Context.expression!(context, block_elixir_ast, schema_ast, env)

    schema_ast
  end
end
