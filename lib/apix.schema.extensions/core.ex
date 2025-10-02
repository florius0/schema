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
      },
      {
        {Elixir.And, :t},
        {And, :t}
      },
      {
        {Elixir.Or, :t},
        {Or, :t}
      },
      {
        {Elixir.Not, :t},
        {Not, :t}
      },
      {
        {Elixir.Const, :t},
        {Const, :t}
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
  def normalize_ast!(_context, ast) do
    ast
    |> Ast.postwalk(&normalize_double_not/1)
    |> Ast.postwalk(&normalize_identity/1)
    |> Ast.postwalk(&normalize_absorption/1)
    |> Ast.postwalk(&normalize_idempotence/1)
    |> Ast.postwalk(&normalize_compact/1)
  end

  defp normalize_double_not(%Ast{module: Not, schema: :t, args: [%Ast{module: Not, schema: :t, args: [ast]}]}), do: ast

  defp normalize_double_not(ast), do: ast

  defp normalize_identity(%Ast{module: And, schema: :t, args: [ast, %Ast{module: Any, schema: :t, args: []}]}), do: ast
  defp normalize_identity(%Ast{module: And, schema: :t, args: [%Ast{module: Any, schema: :t, args: []}, ast]}), do: ast

  defp normalize_identity(%Ast{module: And, schema: :t, args: [ast, %Ast{module: None, schema: :t, args: []}]}), do: struct(ast, module: None, schema: :t, args: [])
  defp normalize_identity(%Ast{module: And, schema: :t, args: [%Ast{module: None, schema: :t, args: []}, ast]}), do: struct(ast, module: None, schema: :t, args: [])

  defp normalize_identity(%Ast{module: Or, schema: :t, args: [ast, %Ast{module: None, schema: :t, args: []}]}), do: ast
  defp normalize_identity(%Ast{module: Or, schema: :t, args: [%Ast{module: None, schema: :t, args: []}, ast]}), do: ast

  defp normalize_identity(%Ast{module: Or, schema: :t, args: [ast, %Ast{module: Any, schema: :t, args: []}]}), do: struct(ast, module: Any, schema: :t, args: [])
  defp normalize_identity(%Ast{module: Or, schema: :t, args: [%Ast{module: Any, schema: :t, args: []}, ast]}), do: struct(ast, module: Any, schema: :t, args: [])

  defp normalize_identity(ast), do: ast

  defp normalize_absorption(%Ast{module: And, schema: :t, args: [ast1, %Ast{module: Or, schema: :t, args: [ast2, ast3]}]} = ast) do
    if Ast.equals?(ast1, ast2) or Ast.equals?(ast1, ast3),
      do: ast1,
      else: ast
  end

  defp normalize_absorption(%Ast{module: And, schema: :t, args: [%Ast{module: Or, schema: :t, args: [ast2, ast3]}, ast1]} = ast) do
    if Ast.equals?(ast1, ast2) or Ast.equals?(ast1, ast3),
      do: ast1,
      else: ast
  end

  defp normalize_absorption(%Ast{module: Or, schema: :t, args: [ast1, %Ast{module: And, schema: :t, args: [ast2, ast3]}]} = ast) do
    if Ast.equals?(ast1, ast2) or Ast.equals?(ast1, ast3),
      do: ast1,
      else: ast
  end

  defp normalize_absorption(%Ast{module: Or, schema: :t, args: [%Ast{module: And, schema: :t, args: [ast2, ast3]}, ast1]} = ast) do
    if Ast.equals?(ast1, ast2) or Ast.equals?(ast1, ast3),
      do: ast1,
      else: ast
  end

  defp normalize_absorption(ast), do: ast

  defp normalize_idempotence(%Ast{module: And, schema: :t, args: [ast1, ast2]} = ast) do
    if Ast.equals?(ast1, ast2),
      do: ast1,
      else: ast
  end

  defp normalize_idempotence(%Ast{module: Or, schema: :t, args: [ast1, ast2]} = ast) do
    if Ast.equals?(ast1, ast2),
      do: ast1,
      else: ast
  end

  defp normalize_idempotence(ast), do: ast

  defp normalize_compact(%Ast{module: Or, schema: :t, args: [%Ast{module: And, schema: :t, args: [ast1, ast2]}, %Ast{module: And, schema: :t, args: [ast3, ast4]} = inner_ast]} = ast) do
    cond do
      Ast.equals?(ast1, ast3) ->
        struct(ast, module: And, schema: :t, args: [ast1, struct(inner_ast, module: Or, schema: :t, args: [ast2, ast4])])

      Ast.equals?(ast1, ast4) ->
        struct(ast, module: And, schema: :t, args: [ast1, struct(inner_ast, module: Or, schema: :t, args: [ast2, ast3])])

      Ast.equals?(ast2, ast3) ->
        struct(ast, module: And, schema: :t, args: [ast2, struct(inner_ast, module: Or, schema: :t, args: [ast1, ast4])])

      Ast.equals?(ast2, ast4) ->
        struct(ast, module: And, schema: :t, args: [ast2, struct(inner_ast, module: Or, schema: :t, args: [ast1, ast3])])

      true ->
        ast
    end
  end

  defp normalize_compact(ast), do: ast
end
