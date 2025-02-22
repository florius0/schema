defmodule Apix.Schema.Extensions.Core do
  alias Apix.Schema

  alias Apix.Schema.Extension

  alias Apix.Schema.Ast
  alias Apix.Schema.Context

  alias Apix.Schema.Extensions.Core.Any
  alias Apix.Schema.Extensions.Core.None

  alias Apix.Schema.Extensions.Core.And
  alias Apix.Schema.Extensions.Core.Or
  alias Apix.Schema.Extensions.Core.Not

  alias Apix.Schema.Extensions.Core.Const

  alias Apix.Schema.Extensions.Core.TypeGraph

  @manifest %Extension{
    module: __MODULE__,
    delegates: [
      {
        {Elixir.Any, :t},
        {Any, :t}
      },
      {
        {Elixir.None, :t},
        {None, :t}
      }
    ]
  }

  @moduledoc """
  Core functionality of `#{inspect Schema}`.

  #{Extension.delegates_doc(@manifest)}

  ## Expressions

  - `shortdoc "smth"` - defines `:shortdoc` in `t:#{inspect Ast}.t/0`.
  - `doc "smth"` – defines `:doc` in `t:#{inspect Ast}.t/0`.
  - `example value` – adds example to `:examples` in `t:#{inspect Ast}.t/0`.
  - `a and b` – builds `and` schema expression – the value is expected to be valid against `a` and `b` schema expressions.
  - `a or b` – builds `or` schema expression – the value is expected to be valid against `a` or `b` schema expressions.
  - `not a` – builds `not` schema expression – the value is expected to be invalid against `a` schema expression
  - module attribute expansion as const – the value is expected to be equal to.
  - literal expansion as const – the value is expected to be equal to.
  - `_` – empty expression.
  - remote (defined in other module) schema referencing.
  - parameter referencing.

  > #### Info {: .info}
  >
  > Due to technical limitations, local (defied in same module) schema referencing is a separate extension #{inspect Apix.Schema.Extensions.Core.LocalReference}.
  > #{inspect Apix.Schema.Extensions.Core.LocalReference} should be installed as last extension to prevent all other expressions to be recognized as local references
  """

  @behaviour Extension

  @impl Extension
  def manifest, do: @manifest

  @impl Extension
  @spec expression!(any(), any(), any(), any(), any()) :: false | struct()
  def expression!(_context, {:shortdoc, _, [elixir_ast]}, schema_ast, env, _literal?) do
    {arg, _, _} = Code.eval_quoted_with_env(elixir_ast, [], env)

    struct(schema_ast, shortdoc: arg)
  end

  def expression!(_context, {:doc, _, [elixir_ast]}, schema_ast, env, _literal?) do
    {arg, _, _} = Code.eval_quoted_with_env(elixir_ast, [], env)

    struct(schema_ast, doc: arg)
  end

  def expression!(_context, {:example, _, [elixir_ast]}, schema_ast, env, _literal?) do
    {arg, _, _} = Code.eval_quoted_with_env(elixir_ast, [], env)

    struct(schema_ast, examples: [arg | schema_ast.examples])
  end

  # TODO: Validators
  def expression!(_context, {:validate, _, [_elixir_ast]}, schema_ast, _env, _literal?) do
    schema_ast
  end

  def expression!(context, {:and, _, args}, schema_ast, env, false) do
    struct(schema_ast,
      module: And,
      schema: :t,
      args: Enum.map(args, &Context.expression!(context, &1, schema_ast, env))
    )
  end

  def expression!(context, {:or, _, args}, schema_ast, env, false) do
    struct(schema_ast,
      module: Or,
      schema: :t,
      args: Enum.map(args, &Context.expression!(context, &1, schema_ast, env))
    )
  end

  def expression!(context, {:not, _, args}, schema_ast, env, false) do
    struct(schema_ast,
      module: Not,
      schema: :t,
      args: [Context.expression!(context, args, schema_ast, env)]
    )
  end

  def expression!(context, {:@, _, _} = elixir_ast, schema_ast, env, false) do
    expression!(context, elixir_ast, schema_ast, env, true)
  end

  def expression!(_context, elixir_ast, schema_ast, env, true) do
    {arg, _, _} = Code.eval_quoted_with_env(elixir_ast, [], env)

    struct(schema_ast,
      module: Const,
      schema: :t,
      args: [arg]
    )
  end

  def expression!(context, {{:., _, [module, schema]}, _, args}, schema_ast, env, false) do
    struct(schema_ast,
      module: Macro.expand(module, env),
      schema: schema,
      args: Enum.map(args, &Context.expression!(context, &1, schema_ast, env))
    )
  end

  def expression!(_context, {:_, _, _}, schema_ast, _env, _literal?) do
    schema_ast
  end

  def expression!(context, {name, _, args}, schema_ast, env, false) do
    args = args || []
    len_args = length(args)

    context.params
    |> Enum.any?(fn
      {^name, ^len_args, _} -> true
      _ -> false
    end)
    |> if do
      struct(schema_ast,
        module: nil,
        schema: name,
        args: Enum.map(args, &Context.expression!(context, &1, schema_ast, env)),
        parameter?: true
      )
    else
      false
    end
  end

  def expression!(_context, _elixir_ast, _schema_ast, _env, _literal?), do: false

  @impl Extension
  def validate_ast!(context) do
    TypeGraph.track!(context)

    # Don't do compile time val
    unless Code.can_await_module_compilation?() do
      TypeGraph.validate!()
    end

    context
  end
end
