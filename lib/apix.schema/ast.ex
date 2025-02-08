defmodule Apix.Schema.Ast do
  alias Apix.Schema
  alias Apix.Schema.Validator

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
  - `:validators` – TODO.
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
          validators: [Validator.t()],
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
            flags: [],
            meta: nil,
            parameter?: false

  @doc """
  Similar to `Macro.prewalk/2`
  """
  @spec prewalk(t(), (t() -> t())) :: t()
  def prewalk(%__MODULE__{} = ast, fun) when is_function(fun, 1) do
    ast
    |> prewalk(nil, fn ast, _acc -> {fun.(ast), nil} end)
    |> elem(0)
  end

  @doc """
  Similar to `Macro.prewalk/3`
  """
  @spec prewalk(t(), any(), (t(), any() -> {t(), any()})) :: {t(), any()}
  def prewalk(%__MODULE__{} = ast, acc, fun) when is_function(fun, 2) do
    traverse(ast, acc, fun, fn x, a -> {x, a} end)
  end

  @doc """
  Similar to `Macro.postwalk/2`
  """
  @spec postwalk(t(), (t() -> t())) :: t()
  def postwalk(%__MODULE__{} = ast, fun) when is_function(fun, 1) do
    ast
    |> postwalk(nil, fn ast, _acc -> {fun.(ast), nil} end)
    |> elem(0)
  end

  @doc """
  Similar to `Macro.postwalk/3`
  """
  @spec postwalk(t(), any(), (t(), any() -> {t(), any()})) :: {t(), any()}
  def postwalk(%__MODULE__{} = ast, acc, fun) when is_function(fun, 2) do
    traverse(ast, acc, fn x, a -> {x, a} end, fun)
  end

  @doc """
  Similar to `Macro.traverse/4`
  """
  @spec traverse(t(), any(), (t(), any() -> {t(), any()}), (t(), any() -> {t(), any()})) :: {t(), any()}
  def traverse(%__MODULE__{} = ast, acc, pre, post) when is_function(pre, 2) and is_function(post, 2) do
    {ast, acc} = pre.(ast, acc)

    {args, acc} =
      ast.args
      |> Enum.reverse()
      |> Enum.reduce({[], acc}, fn
        %__MODULE__{} = arg, {args, acc} ->
          {arg, acc} = traverse(arg, acc, pre, post)

          {[arg | args], acc}

        {key, %__MODULE__{} = arg}, {args, acc} ->
          {arg, acc} = traverse(arg, acc, pre, post)

          {[{key, arg} | args], acc}

        arg, {args, acc} ->
          {[arg | args], acc}
      end)

    ast = struct(ast, args: args)

    post.(ast, acc)
  end
end
