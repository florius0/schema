defmodule Apix.Schema do
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

  @doc """
  Callback to return all schemas defined in the module
  """
  @callback __apix_schemas__() :: [Context.t()]

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
    end
  end

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

      context =
        context
        |> Context.schema_definition_expression!(schema_name, type_ast, params[:params], params[:do], __ENV__)
        |> Context.validate_ast!()

      Module.put_attribute(__ENV__.module, :apix_schemas, context)
    end
  end

  defmacro __before_compile__(env) do
    env.module
    |> Module.get_attribute(:apix_schemas, [])

    quote do
      def __apix_schemas__, do: @apix_schemas
    end
  end

  @doc """
  Returns schemas defined in the module
  """
  @spec schemas(module()) :: [Context.t()]
  def schemas(module) do
    if function_exported?(module, :__apix_schemas__, 0),
      do: module.__apix_schemas__(),
      else: []
  end

  @doc """
  Returns true if `module` defines `schema` with `arity`, false otherwise.
  """
  @spec defines_schema?(module(), schema(), arity()) :: boolean()
  def defines_schema?(module, schema, arity) do
    module
    |> schemas()
    |> Enum.any?(&match?(%Context{module: ^module, schema: ^schema, params: p} when length(p) == arity, &1))
  end
end
