defmodule Apix.Schema.Core do
  alias Apix.Schema.Extension

  alias Apix.Schema.Ast.Parameter
  alias Apix.Schema.Context

  alias __MODULE__.{
    And,
    Or,
    Not,
    Any,
    Const
  }

  @behaviour Extension

  @impl Extension
  def manifest do
    %Extension{
      module: __MODULE__,
      delegates: [
        {
          {Elixir.Any, :t},
          {Any, :t}
        }
      ]
    }
  end

  @impl Extension
  def expression!(_context, {:shortdoc, _, [ast]}, schema_ast, env, _literal?) do
    {arg, _, _} = Code.eval_quoted_with_env(ast, [], env)

    struct(schema_ast, shortdoc: arg)
  end

  def expression!(_context, {:doc, _, [ast]}, schema_ast, env, _literal?) do
    {arg, _, _} = Code.eval_quoted_with_env(ast, [], env)

    struct(schema_ast, doc: arg)
  end

  def expression!(_context, {:example, _, [ast]}, schema_ast, env, _literal?) do
    {arg, _, _} = Code.eval_quoted_with_env(ast, [], env)

    struct(schema_ast, examples: [arg | schema_ast.examples])
  end

  def expression!(context, {:and, _, args}, schema_ast, env, false) do
    struct(schema_ast,
      module: And,
      schema: :t,
      args: Context.expression!(context, args, schema_ast, env)
    )
  end

  def expression!(context, {:or, _, args}, schema_ast, env, false) do
    struct(schema_ast,
      module: Or,
      schema: :t,
      args: Context.expression!(context, args, schema_ast, env)
    )
  end

  def expression!(context, {:not, _, args}, schema_ast, env, false) do
    struct(schema_ast,
      module: Not,
      schema: :t,
      args: Context.expression!(context, args, schema_ast, env)
    )
  end

  def expression!(context, {:@, _, _} = ast, schema_ast, env, false) do
    expression!(context, ast, schema_ast, env, true)
  end

  def expression!(_context, ast, schema_ast, env, true) do
    {arg, _, _} = Code.eval_quoted_with_env(ast, [], env)

    struct(schema_ast,
      module: Const,
      schema: :t,
      args: [arg]
    )
  end

  def expression!(_context, {name, _, nil}, _schema_ast, _env, false) do
    %Parameter{name: name}
  end

  def expression!(context, {{:., _, [module, schema]}, _, args}, schema_ast, env, false) do
    struct(schema_ast,
      module: Macro.expand(module, env),
      schema: schema,
      args: Enum.map(args, &Context.expression!(context, &1, schema_ast, env))
    )
  end

  # TODO: Local schema reference needs to be processed last
  # def expression!(context, {schema, _, args}, schema_ast, env, false) do
  #   struct(schema_ast,
  #     module: env.module,
  #     schema: schema,
  #     args: Enum.map(args, &Context.expression!(context, &1, schema_ast, env))
  #   )
  # end

  def expression!(_context, _ast, _schema_ast, _env, _literal?), do: false
end
