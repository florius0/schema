defmodule Apix.Schema.Context do
  alias Apix.Schema.{
    Ast,
    Error,
    Extension
  }

  @default_extensions [
    Apix.Schema.Core.manifest(),
    Apix.Schema.Elixir.manifest()
  ]

  @type t() :: %__MODULE__{
          ast: Ast.t() | nil,
          data: any(),
          errors: [Error.t()],
          flags: keyword(),
          extensions: [Extension.t()]
        }

  defstruct ast: nil,
            data: nil,
            module: nil,
            schema: nil,
            params: [],
            errors: [],
            flags: [],
            extensions: @default_extensions

  def add_extensions(context, extensions) do
    extensions =
      extensions
      |> List.wrap()
      |> Enum.map(&Extension.manifest/1)

    extensions =
      context.extensions
      |> Kernel.++(extensions)
      |> Enum.uniq_by(& &1.module)

    struct(context, extensions: extensions)
  end

  def install!(context), do: Enum.reduce(context.extensions, context, &Extension.install!/2)

  def require(context), do: Enum.map(context.extensions, &Extension.require/1)

  def validate_ast!(context), do: Enum.each(context.extension, &Extension.validate_ast!(&1, context))

  def expression!(context, elixir_ast, schema_ast \\ nil, env) do
    schema_ast = schema_ast || context.ast || %Ast{}

    prewalker = fn elixir_node, schema_ast ->
      context.extensions
      |> Enum.find_value(&Extension.expression!(&1, context, elixir_node, schema_ast, env, Macro.quoted_literal?(elixir_node)))
      |> Ast.maybe_put_meta(env, elixir_node)
      |> case do
        %Ast{} = schema_ast -> {schema_ast, schema_ast}
        %Ast.Parameter{} = schema_ast -> {schema_ast, schema_ast}
        _ -> {elixir_ast, schema_ast}
      end
    end

    elixir_ast
    |> Macro.prewalk(schema_ast, prewalker)
    |> elem(1)
  end

  def schema_definition_expression!(context, schema_name, elixir_type_ast, params, elixir_do_block_ast, env) do
    env = Code.env_for_eval(env)

    context
    |> struct(
      module: env.module,
      schema: schema_name,
      params: params
    )
    |> map_ast(&expression!(&1, elixir_type_ast, env))
    |> map_ast(&expression!(&1, elixir_do_block_ast, env))
  end

  def cast(context) do
    context
  end

  @spec map_ast(atom() | struct(), (any() -> any())) :: struct()
  def map_ast(context, fun), do: struct(context, ast: fun.(context))
end
