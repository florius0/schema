defmodule Apix.Schema do
  alias Apix.Schema.Context

  @callback __apix_schemas__() :: [Context.t()]

  defmacro __using__(opts) do
    context =
      %Context{}
      |> Context.add_extensions(opts[:extensions])
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
    context = Module.get_attribute(__CALLER__.module, :apix_schema_context)

    {schema_name, type_ast} =
      case params do
        [{schema, type_ast} | _] -> {schema, type_ast}
      end

    params = Keyword.merge(block, params)

    context = Context.schema_definition_expression!(context, schema_name, type_ast, params[:params], params[:do], __CALLER__)

    Module.put_attribute(__CALLER__.module, :apix_schemas, context)
  end

  defmacro __before_compile__(env) do
    env.module
    |> Module.get_attribute(:apix_schemas, [])
    |> dbg()

    quote do
      def __apix_schemas__, do: @apix_schemas
    end
  end
end
