defmodule Apix.Schema.Context do
  alias Apix.Schema
  alias Apix.Schema.Ast
  alias Apix.Schema.Error
  alias Apix.Schema.Extension

  @moduledoc """
  The Context of all `#{inspect Schema}` operations.

  This module provides data structure and high-level interface functions to run all `#{inspect Schema}` operations in.
  """

  @typedoc """
  The Context struct.

  ## Fields

  - `ast` – AST of the current schema.
  - `data` – data the current operation operation in being run on.
  - `module` – module in which current schema is defined.
  - `schema` - name of the schema in the module.
  - `params` – parameters the schema takes in, in a form of `[parameter_name: parameter arity]`.
  - `errors` – errors the current operation resulted in.
  - `flags` – flags for the current schema/operation.
  - `extensions` – extensions the schema was defined with.
  """
  @type t() :: %__MODULE__{
          ast: Ast.t() | nil,
          data: any(),
          module: module(),
          schema: Schema.schema(),
          params: params(),
          errors: [Error.t()],
          flags: keyword(),
          extensions: [Extension.t()]
        }

  @typedoc """
  Parameters the schema takes in.

  Normalized to keyword of `t:arity/0`.
  """
  @type params() :: [{atom(), arity(), nil | Ast.t()}]

  @typedoc """
  Parameters the schema takes in in their raw form:

  A list of either:

  - `:parameter_name` – zero-arity parameter
  - `parameter_name: parameter_arity` – parameter in normal form
  """
  @type raw_params() :: [
          atom()
          | {atom(), arity()}
          | {atom(), Macro.t()}
          | {atom(), arity(), nil}
          | {atom(), arity(), Ast.t()}
        ]

  defstruct ast: nil,
            data: nil,
            module: nil,
            schema: nil,
            params: [],
            errors: [],
            flags: [],
            extensions: []

  @doc """
  Adds an extension to the context.

  Extension can be passed as module which implements `#{inspect Extension}` behaviour, or the extension manifest (see `t:#{inspect Extension}.t/0`)
  Same extensions can not be added twice
  """
  @spec add_extensions(t(), module() | Extension.t()) :: t()
  def add_extensions(%__MODULE__{} = context, extensions) do
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

  @doc """
  Installs all extensions in the context.

  See `#{inspect Extension}.install!/2` and `c:#{inspect Extension}.install!/1`.
  """
  @spec install!(t()) :: t()
  def install!(%__MODULE__{} = context), do: Enum.reduce(context.extensions, context, &Extension.install!/2)

  @doc """
  Requires all extensions in the context.

  See `#{inspect Extension}.require/1`.
  """
  @spec require(t()) :: Macro.t()
  def require(%__MODULE__{} = context), do: Enum.map(context.extensions, &Extension.require/1)

  @doc """
  Validates AST through all extensions.

  See `#{inspect Extension}.validate_ast!/2` and `c:#{inspect Extension}.validate_ast!/1`.
  """
  @spec validate_ast!(t()) :: :ok
  def validate_ast!(%__MODULE__{} = context), do: Enum.each(context.extensions, &Extension.validate_ast!(&1, context))

  @doc """
  Transforms schema expression from `t:#{inspect Macro}.t/0` into `t:#{inspect Ast}.t/0` through all extensions.

  See `#{inspect Extension}.expression!/6` and `c:#{inspect Extension}.expression!/5`.
  """
  @spec expression!(t(), Macro.t(), nil | Ast.t(), Macro.Env.t()) :: Ast.t()
  def expression!(%__MODULE__{} = context, elixir_ast, schema_ast \\ nil, env) do
    schema_ast = schema_ast || context.ast || %Ast{}
    delegates = build_delegates(context)

    prewalker = fn elixir_ast, schema_ast ->
      context.extensions
      |> Enum.find_value(fn extension ->
        extension
        |> Extension.expression!(context, elixir_ast, schema_ast, env, Macro.quoted_literal?(elixir_ast))
        |> rewrite_delegates(delegates)
        |> Ast.Meta.maybe_put_in(env: env, elixir_ast: elixir_ast, generated_by: extension)
      end)
      |> case do
        %Ast{} = schema_ast -> {schema_ast, schema_ast}
        _ -> {elixir_ast, schema_ast}
      end
    end

    elixir_ast
    |> Macro.prewalk(schema_ast, prewalker)
    |> elem(1)
  end

  @doc """
  Transforms schema definition from `t:#{inspect Macro}.t/0` into `t:#{inspect Ast}.t/0`.

  See `expression!/4`.
  """
  @spec schema_definition_expression!(t(), schema_name :: atom(), Macro.t(), params(), Macro.t(), Macro.Env.t()) :: t()
  def schema_definition_expression!(%__MODULE__{} = context, schema_name, elixir_type_ast, params, elixir_do_block_ast, env) do
    env = Code.env_for_eval(env)

    context
    |> struct(
      module: env.module,
      schema: schema_name,
      params: normalize_params!(context, params, env)
    )
    |> map_ast(&expression!(&1, elixir_type_ast, env))
    |> map_ast(&expression!(&1, elixir_do_block_ast, env))
  end

  @doc """
  TODO: Casts types.
  """
  @spec cast(t()) :: t()
  def cast(%__MODULE__{} = context) do
    context
  end

  @doc """
  Normalizes params from `t:raw_params/0` to `t:params/0`
  """
  @spec normalize_params!(t(), any(), Macro.Env.t()) :: params()
  def normalize_params!(%__MODULE__{} = context, [_ | _] = raw_params, env) do
    Enum.map(raw_params, fn
      zero_arity when is_atom(zero_arity) -> {zero_arity, 0, nil}
      {name, arity} when is_atom(name) and is_integer(arity) and arity >= 0 -> {name, arity, nil}
      {name, {{:., _, _}, _, _} = elixir_ast} when is_atom(name) -> {name, 0, expression!(context, elixir_ast, nil, env)}
      {name, {:\\, _, [arity, {{:., _, _}, _, _} = elixir_ast]}} when is_atom(name) and is_integer(arity) and arity >= 0 -> {name, arity, expression!(context, elixir_ast, nil, env)}
    end)
  end

  def normalize_params!(_context, _raw_params, _env), do: []

  @doc """
  Builds map of delegates for efficient rewriting in `rewrite_delegates/2`.
  """
  @spec build_delegates(t()) :: %{Extension.delegate_target() => Extension.delegate_target()}
  def build_delegates(%__MODULE__{extensions: e}) do
    e
    |> Enum.flat_map(& &1.delegates)
    |> Map.new()
  end

  @doc """
  Rewrites delegates in the AST node
  """
  @spec rewrite_delegates(maybe_ast, %{Extension.delegate_target() => Extension.delegate_target()}) :: maybe_ast when maybe_ast: Ast.t() | any()
  def rewrite_delegates(%Ast{module: m, schema: s} = ast, delegates) do
    delegates
    |> Map.get({m, s})
    |> case do
      {m, s} -> struct(ast, module: m, schema: s)
      _ -> ast
    end
  end

  def rewrite_delegates(maybe_ast, _delegates), do: maybe_ast

  @doc """
  Context functor on `:ast`.
  """
  @spec map_ast(atom() | struct(), (any() -> any())) :: struct()
  def map_ast(%__MODULE__{} = context, fun), do: struct(context, ast: fun.(context))
end
