defmodule Apix.Schema.Ast do
  alias Apix.Schema

  alias __MODULE__.Meta

  @moduledoc """
  This module and it's submodules hold structs and helper functions to work with AST.
  """

  @typedoc """
  Schema AST.

  Each AST struct in `#{inspect Schema}` is considered a pseudo-function and thus has args.

  ## Fields

  - `:module` – module in which this AST node is defined in.
  - `:schema` – schema in which this AST node is defined in.
  - `:args` – arguments of the AST node.
  - `:shortdoc` – shortdoc for this AST node.
  - `:doc` – doc for this AST node.
  - `:examples` – list of examples for this AST node.
  - `:validators` – list of `t:mfa()`'s of validators`t:mfa/0`. See `#{inspect Apix.Schema.Extensions.Validator}`
  - `:relates` – list of `t:mfa()`'s of `relate`'s `t:mfa/0`. See `#{inspect Apix.Schema.Extensions.TypeGraph}`
  - `:relationships` – list of `t:mfa()`'s of `relationships`'s `t:mfa/0`. See `#{inspect Apix.Schema.Extensions.TypeGraph}`
  - `:flags` – flags that are defined in this AST node.
  - `:meta` – See `t:#{inspect Meta}.t/0`.
  - `:parameter?` - is this AST node a parameter invocation?
  """
  @type t() :: %__MODULE__{
          module: module() | nil,
          schema: Schema.schema(),
          args: [any()],
          shortdoc: String.t() | nil,
          doc: String.t() | nil,
          examples: [any()] | nil,
          validators: [mfa()],
          relates: [mfa()],
          relationships: [mfa()],
          flags: keyword(),
          meta: Meta.t() | nil,
          parameter?: boolean()
        }

  defstruct module: nil,
            schema: nil,
            args: [],
            shortdoc: nil,
            doc: nil,
            examples: [],
            validators: [],
            relates: [],
            relationships: [],
            flags: [],
            meta: nil,
            parameter?: false

  @doc """
  Similar to `Macro.prewalk/2`
  """
  @spec prewalk(ast_like, (t() -> t())) :: ast_like when ast_like: t() | list() | tuple()
  def prewalk(%__MODULE__{} = ast, fun) when is_function(fun, 1) do
    ast
    |> prewalk(nil, fn ast, _acc -> {fun.(ast), nil} end)
    |> elem(0)
  end

  @doc """
  Similar to `Macro.prewalk/3`
  """
  @spec prewalk(ast_like, any(), (t(), any() -> {t(), any()})) :: {ast_like, any()} when ast_like: t() | list() | tuple()
  def prewalk(ast, acc, fun) when is_function(fun, 2) do
    traverse(ast, acc, fun, fn x, a -> {x, a} end)
  end

  @doc """
  Similar to `Macro.postwalk/2`
  """
  @spec postwalk(ast_like, (t() -> t())) :: ast_like when ast_like: t() | list() | tuple()
  def postwalk(ast, fun) when is_function(fun, 1) do
    ast
    |> postwalk(nil, fn ast, _acc -> {fun.(ast), nil} end)
    |> elem(0)
  end

  @doc """
  Similar to `Macro.postwalk/3`
  """
  @spec postwalk(ast_like, any(), (t(), any() -> {t(), any()})) :: {ast_like, any()} when ast_like: t() | list() | tuple()
  def postwalk(ast, acc, fun) when is_function(fun, 2) do
    traverse(ast, acc, fn x, a -> {x, a} end, fun)
  end

  @doc """
  Similar to `Macro.traverse/4`
  """
  @spec traverse(ast_like, any(), (t(), any() -> {t(), any()}), (t(), any() -> {t(), any()})) :: {ast_like, any()} when ast_like: t() | list() | tuple()
  def traverse(%__MODULE__{} = ast, acc, pre, post) when is_function(pre, 2) and is_function(post, 2) do
    {ast, acc} = pre.(ast, acc)

    {args, acc} =
      ast.args
      |> Enum.reverse()
      |> Enum.reduce({[], acc}, fn
        arg, {args, acc} ->
          {arg, acc} = traverse(arg, acc, pre, post)

          {[arg | args], acc}
      end)

    ast = struct(ast, args: args)

    post.(ast, acc)
  end

  def traverse(list, acc, pre, post) when is_list(list) and is_function(pre, 2) and is_function(post, 2) do
    Enum.reduce(list, {[], acc}, fn arg, {args, acc} ->
      {arg, acc} = traverse(arg, acc, pre, post)
      {[arg | args], acc}
    end)
  end

  # keyword() optimization
  def traverse({key, value}, acc, pre, post) when is_atom(key) and is_function(pre, 2) and is_function(post, 2) do
    {value, acc} = traverse(value, acc, pre, post)
    {{key, value}, acc}
  end

  def traverse(tuple, acc, pre, post) when is_tuple(tuple) and is_function(pre, 2) and is_function(post, 2) do
    {tuple, acc} =
      tuple
      |> Tuple.to_list()
      |> traverse(acc, pre, post)

    {List.to_tuple(tuple), acc}
  end

  def traverse(x, acc, pre, post) when is_function(pre, 2) and is_function(post, 2), do: {x, acc}

  @doc """
  Structurally compares `t:#{inspect __MODULE__}.t/0`'s.

  - If both Asts match, returns `true`.
  - If both Asts are have the same `module`, `schema` and their args are structurally equal, returns true
  - Otherwise `false`.
  """
  @spec equals?(t() | any(), t() | any()) :: boolean()
  def equals?(ast, ast), do: true

  def equals?(%__MODULE__{module: m, schema: s, args: a1} = ast1, %__MODULE__{module: m, schema: s, args: a2} = ast2) when length(a1) == length(a2) do
    Enum.zip_reduce(ast1.args, ast2.args, true, fn arg1, arg2, acc ->
      acc and equals?(arg1, arg2)
    end)
  end

  def equals?(_ast1, _ast2), do: false

  @doc """
  Structurally computes hash of `t:t/0`
  """
  @spec hash(t()) :: integer()
  def hash(%__MODULE__{} = ast), do: :erlang.phash2({ast.module, ast.schema, Enum.map(ast.args, &hash/1)})
  def hash(other), do: :erlang.phash2(other)

  @doc """
  Maps `fun` to `t:#{inspect __MODULE__}.t/0`'s keyword args
  """
  @spec map_keyword_args(t(), ([any()] -> [any()])) :: t()
  def map_keyword_args(%__MODULE__{} = ast, fun) do
    {last, rest} =
      ast.args
      |> Enum.reverse()
      |> case do
        [last | rest] ->
          {last, rest}

        [] ->
          {[], []}
      end

    struct(ast, args: Enum.reverse([fun.(last) | rest]))
  end

  @doc """
  Puts `keyword` to `t:#{inspect __MODULE__}.t/0`'s keyword args
  """
  @spec put_keyword_args(t(), keyword()) :: t()
  def put_keyword_args(%__MODULE__{} = ast, keyword), do: map_keyword_args(ast, fn _ -> keyword end)

  @doc """
  Adds `keyword` to `t:#{inspect __MODULE__}.t/0`'s keyword args
  """
  @spec add_keyword_args(t(), keyword()) :: t()
  def add_keyword_args(%__MODULE__{} = ast, keyword), do: map_keyword_args(ast, &(&1 ++ keyword))

  @doc """
  Removes `keyword` to `t:#{inspect __MODULE__}.t/0`'s keyword args
  """
  @spec remove_keyword_args(t(), keyword()) :: t()
  def remove_keyword_args(%__MODULE__{} = ast, keyword), do: map_keyword_args(ast, &(&1 -- keyword))
end
