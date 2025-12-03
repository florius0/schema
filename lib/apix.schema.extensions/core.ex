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

  @boolean_schemas [
    And,
    Or,
    Not
  ]

  @doc false
  def boolean_schemas, do: @boolean_schemas

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
      },
      {
        {Elixir.Const, :value},
        {Const, :value}
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
  - `validate ...` – builds validator
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
  > Due to technical limitations, local (defied in same module) schema referencing is a separate extension `#{inspect Apix.Schema.Extensions.Core.LocalReference}`.
  > `#{inspect Apix.Schema.Extensions.Core.LocalReference}` should be installed as last extension to prevent all other expressions to be recognized as local references
  """

  @behaviour Extension

  @doc """
  Returns true if `it` is valid against given schema.
  """
  defmacro valid?(_it, _schema) do
    false
  end

  @doc """
  Returns :ok if `it` is valid against given schema.
  """
  defmacro validate(_it, _schema) do
    false
  end

  @impl Extension
  def manifest, do: @manifest

  @impl Extension
  def require! do
    quote generated: true do
      require unquote(__MODULE__)
      import unquote(__MODULE__), only: [valid?: 2, validate: 2]
    end
  end

  @impl Extension
  def expression!(_context, {:shortdoc, _, [elixir_ast]}, schema_ast, env, _literal?) do
    {arg, _binding} = Code.eval_quoted(elixir_ast, [], env)

    struct(schema_ast, shortdoc: arg)
  end

  def expression!(_context, {:doc, _, [elixir_ast]}, schema_ast, env, _literal?) do
    {arg, _binding} = Code.eval_quoted(elixir_ast, [], env)

    struct(schema_ast, doc: arg)
  end

  def expression!(_context, {:example, _, [elixir_ast]}, schema_ast, env, _literal?) do
    {arg, _binding} = Code.eval_quoted(elixir_ast, [], env)

    struct(schema_ast, examples: [arg | schema_ast.examples])
  end

  # TODO: Validators
  def expression!(_context, {:validate, _, [{:&, _, [{:/, _, [{{:., _, [module, function]}, _, []}, 1]}]}]} = elixir_ast, schema_ast, env, _literal?) do
    {module, _binding} = Code.eval_quoted(module, [], env)

    name = :"__apix_schema_validate_#{:erlang.phash2(elixir_ast)}"

    quote generated: true do
      def unquote(name)(%Apix.Schema.Context{data: var!(it)} = _context), do: unquote(module).unquote(function)(it)
    end
    |> Code.eval_quoted([], env)

    struct(schema_ast, validators: [{env.module, name, []}])
  end

  def expression!(_context, {:validate, _, [{:&, _, [{:/, _, [{{:., _, [module, function]}, _, []}, 2]}]}]} = elixir_ast, schema_ast, env, _literal?) do
    {module, _binding} = Code.eval_quoted(module, [], env)

    name = :"__apix_schema_validate_#{:erlang.phash2(elixir_ast)}"

    quote generated: true do
      def unquote(name)(%Apix.Schema.Context{data: var!(it)} = var!(context)), do: unquote(module).unquote(function)(it, context)
    end
    |> Code.eval_quoted([], env)

    struct(schema_ast, validators: [{env.module, name, []}])
  end

  def expression!(_context, {:validate, _, [{:&, _, [{:/, _, [{function, _, _}, 1]}]}]} = elixir_ast, schema_ast, env, _literal?) do
    name = :"__apix_schema_validate_#{:erlang.phash2(elixir_ast)}"

    quote generated: true do
      def unquote(name)(%Apix.Schema.Context{data: var!(it)} = _context), do: unquote(function)(it)
    end
    |> Code.eval_quoted([], env)

    struct(schema_ast, validators: [{env.module, name, []}])
  end

  def expression!(_context, {:validate, _, [{:&, _, [{:/, _, [{function, _, _}, 2]}]}]} = elixir_ast, schema_ast, env, _literal?) do
    name = :"__apix_schema_validate_#{:erlang.phash2(elixir_ast)}"

    quote generated: true do
      def unquote(name)(%Apix.Schema.Context{data: var!(it)} = var!(context)), do: unquote(function)(it, context)
    end
    |> Code.eval_quoted([], env)

    struct(schema_ast, validators: [{env.module, name, []}])
  end

  def expression!(_context, {:validate, _, [{:{}, _, [m, _f, _a]} = mfa]} = elixir_ast, schema_ast, env, _literal?) when m != :error do
    {{module, function, args}, _binding} = Code.eval_quoted(mfa, [], env)

    name = :"__apix_schema_validate_#{:erlang.phash2(elixir_ast)}"

    quote generated: true do
      def unquote(name)(%Apix.Schema.Context{data: var!(it)} = var!(context)), do: unquote(module).unquote(function)(it, context, unquote_splicing(args))
    end
    |> Code.eval_quoted([], env)

    struct(schema_ast, validators: [{env.module, name, []}])
  end

  def expression!(context, {:validate, _, [[do: block]]} = elixir_ast, schema_ast, env, _literal?) do
    name = :"__apix_schema_validate_#{:erlang.phash2(elixir_ast)}"

    block = validate_block(context, block, env)

    quote generated: true do
      def unquote(name)(%Apix.Schema.Context{data: var!(it)} = var!(context)), do: unquote(block)
    end
    |> Code.eval_quoted([], env)

    struct(schema_ast, validators: [{env.module, name, []}])
  end

  def expression!(context, {:validate, _, [block]} = elixir_ast, schema_ast, env, _literal?) do
    name = :"__apix_schema_validate_#{:erlang.phash2(elixir_ast)}"

    block = validate_block(context, block, env)

    quote generated: true do
      def unquote(name)(%Apix.Schema.Context{data: var!(it)} = var!(context)), do: unquote(block)
    end
    |> Code.eval_quoted([], env)

    struct(schema_ast, validators: [{env.module, name, []}])
  end

  def expression!(context, {:validate, _, [{:when, _, [arg1, guard]}, [do: block]]} = elixir_ast, schema_ast, env, _literal?) do
    name = :"__apix_schema_validate_#{:erlang.phash2(elixir_ast)}"

    block = validate_block(context, block, env)

    quote generated: true do
      def unquote(name)(%Apix.Schema.Context{data: unquote(arg1) = var!(it)} = var!(context)) when unquote(guard), do: unquote(block)
      def unquote(name)(%Apix.Schema.Context{} = _context), do: :error
    end
    |> Code.eval_quoted([], env)

    struct(schema_ast, validators: [{env.module, name, []}])
  end

  def expression!(context, {:validate, _, [arg1, [do: block]]} = elixir_ast, schema_ast, env, _literal?) do
    name = :"__apix_schema_validate_#{:erlang.phash2(elixir_ast)}"

    block = validate_block(context, block, env)

    quote generated: true do
      def unquote(name)(%Apix.Schema.Context{data: unquote(arg1) = var!(it)} = var!(context)), do: unquote(block)
      def unquote(name)(%Apix.Schema.Context{} = _context), do: :error
    end
    |> Code.eval_quoted([], env)

    struct(schema_ast, validators: [{env.module, name, []}])
  end

  def expression!(context, {:validate, _, [arg1, {:when, _, [arg2, guard]}, [do: block]]} = elixir_ast, schema_ast, env, _literal?) do
    name = :"__apix_schema_validate_#{:erlang.phash2(elixir_ast)}"

    block = validate_block(context, block, env)

    quote generated: true do
      def unquote(name)(%Apix.Schema.Context{data: unquote(arg1) = var!(it)} = unquote(arg2) = var!(context)) when unquote(guard), do: unquote(block)
      def unquote(name)(%Apix.Schema.Context{} = _context), do: :error
    end
    |> Code.eval_quoted([], env)

    struct(schema_ast, validators: [{env.module, name, []}])
  end

  def expression!(context, {:validate, _, [arg1, arg2, [do: block]]} = elixir_ast, schema_ast, env, _literal?) do
    name = :"__apix_schema_validate_#{:erlang.phash2(elixir_ast)}"

    block = validate_block(context, block, env)

    quote generated: true do
      def unquote(name)(%Apix.Schema.Context{data: unquote(arg1) = var!(it)} = unquote(arg2) = var!(context)), do: unquote(block)
      def unquote(name)(%Apix.Schema.Context{} = _context), do: :error
    end
    |> Code.eval_quoted([], env)

    struct(schema_ast, validators: [{env.module, name, []}])
  end

  def expression!(context, {:and, _, args}, schema_ast, env, false) do
    struct(schema_ast,
      module: And,
      schema: :t,
      args: Enum.map(args, &Context.inner_expression!(context, &1, schema_ast, env))
    )
  end

  def expression!(context, {:or, _, args}, schema_ast, env, false) do
    struct(schema_ast,
      module: Or,
      schema: :t,
      args: Enum.map(args, &Context.inner_expression!(context, &1, schema_ast, env))
    )
  end

  def expression!(context, {:not, _, args}, schema_ast, env, false) do
    struct(schema_ast,
      module: Not,
      schema: :t,
      args: [Context.inner_expression!(context, args, schema_ast, env)]
    )
  end

  def expression!(context, {:@, _, _} = elixir_ast, schema_ast, env, false) do
    expression!(context, elixir_ast, schema_ast, env, true)
  end

  def expression!(_context, elixir_ast, schema_ast, env, true) do
    {arg, _binding} = Code.eval_quoted(elixir_ast, [], env)

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
      args: Enum.map(args, &Context.inner_expression!(context, &1, schema_ast, env))
    )
  end

  def expression!(_context, {:_, _, _}, schema_ast, _env, _literal?) do
    schema_ast
  end

  def expression!(context, {name, _, args}, schema_ast, env, false) do
    args = args || []
    arity = length(args)

    Enum.find_value(context.params, fn
      {^name, ^arity, _} ->
        struct(schema_ast,
          module: nil,
          schema: name,
          args: Enum.map(args, &Context.inner_expression!(context, &1, schema_ast, env)),
          parameter?: true
        )

      _ ->
        false
    end)
  end

  def expression!(_context, _elixir_ast, _schema_ast, _env, _literal?), do: false

  defp validate_block(context, block, env) do
    params =
      Map.new(context.params, fn {name, arity, default} ->
        {{name, arity}, default}
      end)

    delegates = Context.build_delegates(context)

    Macro.postwalk(block, fn
      {name, _meta, args} when (is_nil(args) and is_map_key(params, {name, 0})) or is_map_key(params, {name, length(args)}) ->
        args = List.wrap(args)
        arity = length(args)

        default = Map.fetch!(params, {name, arity})

        args = Enum.map(args, &Context.inner_expression!(context, &1, %Ast{}, env))

        quote do
          struct(var!(context).params[unquote(name)] || unquote(default), args: unquote(args))
        end

      {{:., meta1, [{:__aliases__, _meta2, _args} = module, schema]}, meta3, args} ->
        {module, _binding} = Code.eval_quoted(module, [], env)

        {{module, schema}, _extension} = Map.get(delegates, {module, schema}, {{module, schema}, nil})

        {{:., meta1, [module, schema]}, meta3, args}

      ast ->
        ast
    end)
  end

  @impl Extension
  def normalize_ast!(_context, ast) do
    ast
    |> Ast.postwalk(&normalize_double_negation/1)
    |> Ast.postwalk(&normalize_identity/1)
    |> Ast.postwalk(&normalize_absorption/1)
    |> Ast.postwalk(&normalize_idempotence/1)
    |> Ast.postwalk(&normalize_compact/1)
  end

  defp normalize_double_negation(%Ast{module: Not, schema: :t, args: [%Ast{module: Not, schema: :t, args: [ast]}]}), do: ast

  defp normalize_double_negation(ast), do: ast

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
