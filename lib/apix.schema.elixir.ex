defmodule Apix.Schema.Elixir do
  alias Apix.Schema.Extension

  alias Apix.Schema.Ast
  alias Apix.Schema.Context

  alias __MODULE__.{
    Atom,
    String,
    Integer,
    Float,
    Tuple,
    List,
    Map,
    Function,
    Module,
    PID,
    Port,
    Reference,
    Date,
    Time,
    DateTime,
    NaiveDateTime,
    Regex,
    Uri,
    Version,
    Version
  }

  @behaviour Extension

  @impl Extension
  def manifest do
    %Extension{
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
  end

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

  def expression!(_context, ast, _schema_ast, _env, _literal?) do
    dbg(ast)

    false
  end

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
