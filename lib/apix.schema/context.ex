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
          errors: [{message :: any(), path :: [any()]} | Error.t()],
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
            extensions: [],
            path: [],
            delegates: %{},
            function_delegates: %{},
            binding: [],
            env: nil

  def default(extensions \\ nil) do
    extensions =
      if is_list(extensions),
        do: extensions,
        else: Extension.config()

    %__MODULE__{}
    |> add_extensions(extensions)
    |> install!()
  end

  def get(module) do
    Module.get_attribute(module, :apix_schema_context)
  rescue
    _ in [ArgumentError, FunctionClauseError] ->
      module && is_atom(module) && Code.ensure_loaded?(module) && module.module_info(:attributes)[:apix_schema_context]
  end

  def get_or_default(module_or_extensions \\ nil), do: get(module_or_extensions) || default(module_or_extensions)

  def put(%__MODULE__{} = context, module) do
    Module.register_attribute(module, :apix_schema_context, persist: true)
    Module.put_attribute(module, :apix_schema_context, context)

    context
  rescue
    ArgumentError ->
      context
  end

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
  def install!(%__MODULE__{} = context) do
    context.extensions
    |> Enum.reduce(context, &Extension.install!/2)
    |> struct(
      delegates:
        context.extensions
        |> Enum.flat_map(fn extension ->
          Enum.map(extension.delegates, fn {from, to} ->
            {from, {to, extension}}
          end)
        end)
        |> Map.new(),
      function_delegates:
        context.extensions
        |> Enum.flat_map(fn extension ->
          Enum.map(extension.function_delegates, fn {from, to} ->
            {from, {to, extension}}
          end)
        end)
        |> Map.new()
    )
  end

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

  @dialyzer {:no_return, expression!: 3}

  @doc """
  Transforms schema expression from `t:#{inspect Macro}.t/0` into `t:#{inspect Ast}.t/0` through all extensions.

  See `#{inspect Extension}.expression!/6` and `c:#{inspect Extension}.expression!/5`.
  """
  @spec expression!(t(), Macro.t(), nil | Ast.t()) :: Ast.t()
  def expression!(%__MODULE__{} = context, elixir_ast, schema_ast \\ nil) do
    schema_ast = schema_ast || context.ast

    prewalker = fn elixir_ast, schema_ast ->
      context.extensions
      |> Enum.find_value(fn extension ->
        extension
        |> Extension.expression!(context, elixir_ast, schema_ast, Macro.quoted_literal?(elixir_ast))
        |> rewrite_delegates(context)
        |> Meta.maybe_put_in(env: context.env, elixir_ast: elixir_ast, generated_by: extension)
      end)
      |> case do
        %Ast{} = schema_ast -> {schema_ast, schema_ast}
        %__MODULE__{} = context -> {context, context}
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
  @spec schema_definition_expression!(t(), schema_name :: atom(), Macro.t(), params(), Macro.t(), keyword(), Macro.t()) :: t()
  def schema_definition_expression!(%__MODULE__{} = context, schema_name, elixir_type_ast, params, validators, flags, elixir_do_block_ast) do
    context
    |> struct(
      module: context.env.module,
      schema: schema_name,
      params: normalize_params!(context, params),
      flags: flags
    )
    |> map_ast(&expression!(&1, elixir_type_ast))
    |> map_ast(&expression!(&1, elixir_do_block_ast))
    |> map_ast(fn context ->
      Enum.reduce(validators, context.ast, &expression!(context, {:validate, [], [&1]}, &2))
    end)
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
  @spec inner_expression!(t(), Macro.t(), Ast.t()) :: Ast.t()
  def inner_expression!(%__MODULE__{} = context, {:schema, _meta, [type_elixir_ast]}, schema_ast), do: expression!(context, type_elixir_ast, schema_ast)

  def inner_expression!(%__MODULE__{} = context, {:schema, _meta, [type_elixir_ast, params]}, schema_ast) do
    block_elixir_ast = params[:do] || {:__block__, [], []}
    flags = Keyword.drop(params, [:params, :do])

    schema_ast = expression!(context, type_elixir_ast, schema_ast)
    schema_ast = expression!(context, block_elixir_ast, schema_ast)

    schema_ast =
      struct(schema_ast,
        params: normalize_params!(context, params),
        flags: flags
      )

    schema_ast
  end

  def inner_expression!(%__MODULE__{} = context, {:schema, _meta, [type_elixir_ast, params, [do: block_elixir_ast]]}, schema_ast) do
    flags = Keyword.drop(params, [:params, :do])

    schema_ast = expression!(context, type_elixir_ast, schema_ast)
    schema_ast = expression!(context, block_elixir_ast, schema_ast)

    schema_ast =
      struct(schema_ast,
        params: normalize_params!(context, params),
        flags: flags
      )

    schema_ast
  end

  def inner_expression!(%__MODULE__{} = context, {type_elixir_ast, _meta, [[do: block_elixir_ast]]}, schema_ast) do
    schema_ast = expression!(context, type_elixir_ast, schema_ast)
    schema_ast = expression!(context, block_elixir_ast, schema_ast)

    schema_ast
  end

  def inner_expression!(%__MODULE__{} = context, [type_elixir_ast], schema_ast), do: expression!(context, type_elixir_ast, schema_ast)

  def inner_expression!(%__MODULE__{} = context, [type_elixir_ast, [do: block_elixir_ast]], schema_ast) do
    schema_ast = expression!(context, type_elixir_ast, schema_ast)
    schema_ast = expression!(context, block_elixir_ast, schema_ast)

    schema_ast
  end

  def inner_expression!(%__MODULE__{} = context, [type_elixir_ast, flags_elixir_ast], schema_ast) do
    {flags, _binding} = eval_quoted(flags_elixir_ast, context)

    schema_ast = struct(schema_ast, flags: schema_ast.flags ++ flags)
    schema_ast = expression!(context, type_elixir_ast, schema_ast)

    schema_ast
  end

  def inner_expression!(%__MODULE__{} = context, [type_elixir_ast, flags_elixir_ast, [do: block_elixir_ast]], schema_ast) do
    {flags, _binding} = eval_quoted(flags_elixir_ast, context)

    schema_ast = struct(schema_ast, flags: schema_ast.flags ++ flags)
    schema_ast = expression!(context, type_elixir_ast, schema_ast)
    schema_ast = expression!(context, block_elixir_ast, schema_ast)

    schema_ast
  end

  def inner_expression!(%__MODULE__{} = context, type_elixir_ast, schema_ast), do: expression!(context, type_elixir_ast, schema_ast)

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
  @spec normalize_params!(t(), any()) :: params()
  def normalize_params!(%__MODULE__{} = context, [_ | _] = raw_params) do
    Enum.map(raw_params, fn
      zero_arity when is_atom(zero_arity) -> {zero_arity, 0, nil}
      {name, arity} when is_atom(name) and is_integer(arity) and arity >= 0 -> {name, arity, nil}
      {name, {{:., _, _}, _, _} = elixir_ast} when is_atom(name) -> {name, 0, expression!(context, elixir_ast, nil)}
      {name, {:\\, _, [arity, {{:., _, _}, _, _} = elixir_ast]}} when is_atom(name) and is_integer(arity) and arity >= 0 -> {name, arity, expression!(context, elixir_ast, nil)}
    end)
  end

  def normalize_params!(_context, _raw_params), do: []

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
  Delegates to `Code.eval_quoted/3` with already defined binding
  """
  @spec eval_quoted(Macro.t(), t()) :: {term(), keyword()}
  def eval_quoted(elixir_ast, context), do: Code.eval_quoted(elixir_ast, context.binding, context.env)

  @doc """
  Rewrites delegates in the AST node
  """
  @spec rewrite_delegates(maybe_ast, t()) :: maybe_ast when maybe_ast: Ast.t() | any()
  def rewrite_delegates(%Ast{} = ast, context) do
    context.delegates
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

  def rewrite_delegates(maybe_ast, _context), do: maybe_ast

  @doc """
  Binds arguments to parameters.
  """
  @spec bind_args(t(), [Ast.t()]) :: t()
  def bind_args(context, args) do
    required = Enum.count(context.params, &match?({_name, _arity, nil}, &1))

    struct(context, params: do_bind_args(context.params, args, required))
  end

  defp do_bind_args([], [], _required), do: []
  defp do_bind_args([], _args, _required), do: raise(ArgumentError, "too many arguments")
  defp do_bind_args([{name, _arity, nil} | _params], [], _required), do: raise(ArgumentError, "missing required argument #{inspect(name)}")
  defp do_bind_args([{name, arity, nil} | params], [a | args], required), do: [{name, arity, a} | do_bind_args(params, args, required - 1)]
  defp do_bind_args([{name, arity, default} | params], args, required) when default != nil and length(args) == required, do: [{name, arity, default} | do_bind_args(params, args, required)]
  defp do_bind_args([{name, arity, _default} | params], [a | args], required), do: [{name, arity, a} | do_bind_args(params, args, required)]

  @doc """
  Context functor on `:ast`.
  """
  @spec map_ast(t(), (any() -> any())) :: struct()
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
