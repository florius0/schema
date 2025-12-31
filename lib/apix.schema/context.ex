defmodule Apix.Schema.Context do
  alias Apix.Schema
  alias Apix.Schema.Ast
  alias Apix.Schema.Ast.Meta
  alias Apix.Schema.Error
  alias Apix.Schema.Extension
  alias Apix.Schema.Warning

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
  - `warnings` – warnings the current operation resulted in.
  - `errors` – errors the current operation resulted in.
  - `flags` – flags for the current schema/operation.
  - `extensions` – extensions the schema was defined with.
  """
  @type t() :: %__MODULE__{
          ast: Ast.t(),
          data: any(),
          module: module(),
          schema: Schema.schema(),
          params: params(),
          warnings: [Warning.t()],
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

  defstruct ast: %Ast{},
            data: nil,
            module: nil,
            schema: nil,
            params: [],
            warnings: [],
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
  @spec require!(t()) :: Macro.t()
  def require!(%__MODULE__{} = context), do: Enum.map(context.extensions, &Extension.require!/1)

  @doc """
  Validates AST through all extensions.

  See `#{inspect Extension}.validate_ast!/2` and `c:#{inspect Extension}.validate_ast!/1`.
  """
  @spec validate_ast!(t()) :: t() | no_return()
  def validate_ast!(%__MODULE__{} = context) do
    context = Enum.reduce(context.extensions, context, &Extension.validate_ast!(&1, &2))

    Enum.each(context.errors, &raise/1)
    Enum.each(context.warnings, &Warning.print/1)

    context
  end

  @dialyzer {:no_return, expression!: 4}

  @doc """
  Transforms schema expression from `t:#{inspect Macro}.t/0` into `t:#{inspect Ast}.t/0` through all extensions.

  See `#{inspect Extension}.expression!/6` and `c:#{inspect Extension}.expression!/5`.
  """
  @spec expression!(t(), Macro.t(), nil | Ast.t(), Macro.Env.t()) :: Ast.t()
  def expression!(%__MODULE__{} = context, elixir_ast, schema_ast \\ nil, env) do
    schema_ast = schema_ast || context.ast
    delegates = build_delegates(context)

    prewalker = fn elixir_ast, schema_ast ->
      context.extensions
      |> Enum.find_value(fn extension ->
        extension
        |> Extension.expression!(context, elixir_ast, schema_ast, env, Macro.quoted_literal?(elixir_ast))
        |> rewrite_delegates(delegates)
        |> Meta.maybe_put_in(env: env, elixir_ast: elixir_ast, generated_by: extension)
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
  @spec schema_definition_expression!(t(), schema_name :: atom(), Macro.t(), params(), keyword(), Macro.t(), Macro.Env.t()) :: t()
  def schema_definition_expression!(%__MODULE__{} = context, schema_name, elixir_type_ast, params, flags, elixir_do_block_ast, env) do
    env = Code.env_for_eval(env)

    context
    |> struct(
      module: env.module,
      schema: schema_name,
      params: normalize_params!(context, params, env),
      flags: flags
    )
    |> map_ast(&expression!(&1, elixir_type_ast, env))
    |> map_ast(&expression!(&1, elixir_do_block_ast, env))
  end

  @doc """
  Handles additional syntax of inner expressions.

  Supported additional syntax:

  ```elixir
  use Apix.Schema

  schema a: _ do
    outer_expression [ ... ], [ schema ] Some.t([ ... ]) [ , flags: :flags ] [ , do: ...]
    outer_expression [ ... ], [ schema ] Some.t([ ... ]) [ , flags: :flags ] [ do ... end]
  end
  ```.

  Regular `expression!/4` only supports `Some.t([ ... ])`.

  See `expression!/4` and `#{inspect Apix.Schema.Extensions.Elixir}.expression!/6` for usage examples.
  """
  @spec inner_expression!(t(), Macro.t(), Ast.t(), Macro.Env.t()) :: Ast.t()
  def inner_expression!(%__MODULE__{} = context, {:schema, _meta, [type_elixir_ast]}, schema_ast, env), do: expression!(context, type_elixir_ast, schema_ast, env)

  def inner_expression!(%__MODULE__{} = context, {:schema, _meta, [type_elixir_ast, params]}, schema_ast, env) do
    block_elixir_ast = params[:do] || {:__block__, [], []}
    flags = Keyword.drop(params, [:params, :do])

    schema_ast = expression!(context, type_elixir_ast, schema_ast, env)
    schema_ast = expression!(context, block_elixir_ast, schema_ast, env)

    schema_ast =
      struct(schema_ast,
        params: normalize_params!(context, params, env),
        flags: flags
      )

    schema_ast
  end

  def inner_expression!(%__MODULE__{} = context, {:schema, _meta, [type_elixir_ast, params, [do: block_elixir_ast]]}, schema_ast, env) do
    flags = Keyword.drop(params, [:params, :do])

    schema_ast = expression!(context, type_elixir_ast, schema_ast, env)
    schema_ast = expression!(context, block_elixir_ast, schema_ast, env)

    schema_ast =
      struct(schema_ast,
        params: normalize_params!(context, params, env),
        flags: flags
      )

    schema_ast
  end

  def inner_expression!(%__MODULE__{} = context, {type_elixir_ast, _meta, [[do: block_elixir_ast]]}, schema_ast, env) do
    schema_ast = expression!(context, type_elixir_ast, schema_ast, env)
    schema_ast = expression!(context, block_elixir_ast, schema_ast, env)

    schema_ast
  end

  def inner_expression!(%__MODULE__{} = context, [type_elixir_ast], schema_ast, env), do: expression!(context, type_elixir_ast, schema_ast, env)

  def inner_expression!(%__MODULE__{} = context, [type_elixir_ast, [do: block_elixir_ast]], schema_ast, env) do
    schema_ast = expression!(context, type_elixir_ast, schema_ast, env)
    schema_ast = expression!(context, block_elixir_ast, schema_ast, env)

    schema_ast
  end

  def inner_expression!(%__MODULE__{} = context, [type_elixir_ast, flags_elixir_ast], schema_ast, env) do
    {flags, _binding} = Code.eval_quoted(flags_elixir_ast, [], env)

    schema_ast = struct(schema_ast, flags: schema_ast.flags ++ flags)
    schema_ast = expression!(context, type_elixir_ast, schema_ast, env)

    schema_ast
  end

  def inner_expression!(%__MODULE__{} = context, [type_elixir_ast, flags_elixir_ast, [do: block_elixir_ast]], schema_ast, env) do
    {flags, _binding} = Code.eval_quoted(flags_elixir_ast, [], env)

    schema_ast = struct(schema_ast, flags: schema_ast.flags ++ flags)
    schema_ast = expression!(context, type_elixir_ast, schema_ast, env)
    schema_ast = expression!(context, block_elixir_ast, schema_ast, env)

    schema_ast
  end

  def inner_expression!(%__MODULE__{} = context, type_elixir_ast, schema_ast, env), do: expression!(context, type_elixir_ast, schema_ast, env)

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
  Normalizes `t:#{inspect Ast}.t/0`. through all extensions.

  Same as `normalize_ast!/2` with `context.ast`.
  """
  @spec normalize_ast!(t() | Ast.t()) :: Ast.t()
  def normalize_ast!(%__MODULE__{} = context), do: normalize_ast!(context, context.ast)

  def normalize_ast!(%Ast{} = ast) do
    context = Apix.Schema.get_schema(ast)

    if context,
      do: normalize_ast!(context, ast),
      else: ast
  end

  @doc """
  Normalizes `t:#{inspect Ast}.t/0`. through all extensions.
  """
  @spec normalize_ast!(t(), Ast.t()) :: Ast.t()
  def normalize_ast!(%__MODULE__{} = context, %Ast{} = ast) do
    context.extensions
    |> Enum.reverse()
    |> Enum.reduce(ast, &Extension.normalize_ast!(&1, context, &2))
  end

  @doc """
  Builds map of delegates for efficient rewriting in `rewrite_delegates/2`.
  """
  @spec build_delegates(t()) :: %{Extension.delegate_target() => {Extension.delegate_target(), Extension.t()}}
  def build_delegates(%__MODULE__{} = context) do
    context.extensions
    |> Enum.flat_map(fn extension ->
      Enum.map(extension.delegates, fn {from, to} ->
        {from, {to, extension}}
      end)
    end)
    |> Map.new()
  end

  @doc """
  Rewrites delegates in the AST node
  """
  @spec rewrite_delegates(maybe_ast, %{Extension.delegate_target() => {Extension.delegate_target(), Extension.t()}}) :: maybe_ast when maybe_ast: Ast.t() | any()
  def rewrite_delegates(%Ast{} = ast, delegates) do
    delegates
    |> Map.get({ast.module, ast.schema})
    |> case do
      {{module, schema}, extension} ->
        ast
        |> struct(module: module, schema: schema)
        |> Meta.maybe_put_in(generated_by: extension)

      _ ->
        ast
    end
  end

  def rewrite_delegates(maybe_ast, _delegates), do: maybe_ast

  @doc """
  Context functor on `:ast`.
  """
  @spec map_ast(atom() | struct(), (any() -> any())) :: struct()
  def map_ast(%__MODULE__{} = context, fun), do: struct(context, ast: fun.(context))

  @doc """
  Structurally compares `t:#{inspect Context}.t/0`'s.

  - If both Contexts match, returns `true`.
  - If both Contexts have the same `module`, `schema`, number of `params` and their ASTs are structurally equal, returns `true`.
  - Otherwise `false`
  """
  @spec equals?(t(), t()) :: boolean()
  def equals?(%__MODULE__{} = context, %__MODULE__{} = context), do: true

  def equals?(%__MODULE__{module: m, schema: s, params: p1} = context1, %__MODULE__{module: m, schema: s, params: p2} = context2) when length(p1) == length(p2) do
    Ast.equals?(context1.ast, context2.ast)
  end

  def equals?(_context1, _context2), do: false

  @doc """
  Structurally computes hash of `t:t/0`
  """
  @spec hash(t()) :: integer()
  def hash(%__MODULE__{} = context), do: :erlang.phash2({context.module, context.schema, length(context.params), Ast.hash(context.ast)})
end
