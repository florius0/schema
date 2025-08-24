defmodule Apix.Schema do
  alias Apix.Schema.Ast
  alias Apix.Schema.Context
  alias Apix.Schema.Extension

  @moduledoc "readme.md"
             |> File.read!()
             |> String.split("\n")
             |> Enum.drop(2)
             |> Enum.join("\n")

  @typedoc """
  Schema name
  """
  @type schema() :: atom()

  @typedoc """
  MFA but for Schemas
  """
  @type msa() :: {module(), schema(), arity()}

  @doc """
  Callback to return all schemas defined in the module
  """
  @callback __apix_schemas__() :: %{msa() => Context.t()}

  @doc """
  Sets default context and imports `schema/2` macro
  """
  defmacro __using__(opts) do
    extensions =
      opts[:extensions]
      |> Code.eval_quoted([], __CALLER__)
      |> elem(0)

    extensions = extensions || Extension.extensions_config()

    context =
      %Context{}
      |> Context.add_extensions(extensions)
      |> Context.install!()

    Module.put_attribute(__CALLER__.module, :apix_schema_context, context)
    Module.register_attribute(__CALLER__.module, :apix_schemas, accumulate: true)

    quote do
      import Apix.Schema, only: [schema: 1, schema: 2]

      unquote(Context.require(context))

      @before_compile unquote(__MODULE__)
      @after_compile unquote(__MODULE__)
    end
  end

  @spec schema(any()) :: {:__block__, [], [{:=, [], [...]} | {:__block__, [...], [...]}, ...]}
  defmacro schema(params, block \\ [do: {:__block__, [], []}]) do
    quote location: :keep,
          generated: true,
          bind_quoted: [
            params: Macro.escape(params),
            block: Macro.escape(block)
          ] do
      context = Module.get_attribute(__ENV__.module, :apix_schema_context)

      {schema_name, type_ast} =
        case params do
          [{schema, type_ast} | _] -> {schema, type_ast}
        end

      params = Keyword.merge(block, params)

      context = Context.schema_definition_expression!(context, schema_name, type_ast, params[:params], params[:do], __ENV__)

      Module.put_attribute(__ENV__.module, :apix_schemas, context)
    end
  end

  defmacro __before_compile__(env) do
    env.module
    |> Module.get_attribute(:apix_schemas, [])

    quote do
      def __apix_schemas__, do: Map.new(@apix_schemas, &{{&1.module, &1.schema, length(&1.params)}, &1})
    end
  end

  def __after_compile__(env, _bytecode), do: Enum.each(env.module.__apix_schemas__(), fn {_msa, context} -> Context.validate_ast!(context) end)

  @doc """
  Returns schemas defined in the `module`
  """
  @spec get_schemas(module()) :: %{msa() => Context.t()}
  def get_schemas(module) do
    Code.ensure_loaded(module)

    if function_exported?(module, :__apix_schemas__, 0),
      do: module.__apix_schemas__(),
      else: %{}
  end

  @doc """
  Structurally compares `t:#{inspect Context}.t/0`'s or `t:#{inspect Ast}.t/0`'s.
  """
  @spec equals?(context_or_ast, context_or_ast) :: boolean() when context_or_ast: Context.t() | Ast.t()
  def equals?(%Context{} = context1, %Context{} = context2), do: Context.equals?(context1, context2)
  def equals?(%Ast{} = ast1, %Ast{} = ast2), do: Ast.equals?(ast1, ast2)

  @doc """
  Structurally computes has of `t:#{inspect Context}.t/0` or `t:#{inspect Ast}.t/0`.
  """
  @spec hash(Context.t() | Ast.t()) :: integer()
  def hash(%Context{} = context), do: Context.hash(context)
  def hash(%Ast{} = ast), do: Ast.hash(ast)

  @doc """
  Returns `t:#{inspect Context}.t/0` for the given msa.
  """
  @spec get_schema(msa() | Context.t() | Ast.t()) :: Context.t() | nil
  def get_schema({module, schema, arity}), do: get_schema(module, schema, arity)
  def get_schema(%Context{} = context), do: get_schema(context.module, context.schema, length(context.params))
  def get_schema(%Ast{} = ast), do: get_schema(ast.module, ast.schema, length(ast.args))

  @doc """
  Returns `t:Context.t/0` for the given msa.
  """
  @spec get_schema(module(), schema(), arity()) :: Context.t() | nil
  def get_schema(nil, nil, 0), do: %Context{}
  def get_schema(module, schema, arity), do: get_schemas(module)[{module, schema, arity}]

  @doc """
  Returns `t:msa/0` for given `t:#{inspect Ast}.t/0` or `t:#{inspect Context}/0`
  """
  @spec msa(Context.t() | Ast.t()) :: msa()
  def msa(%Context{module: m, schema: s, params: p}), do: {m, s, length(p)}
  def msa(%Ast{module: m, schema: s, args: a}), do: {m, s, length(a)}
end
