defmodule Apix.Schema.Extension do
  alias Apix.Schema.Ast
  alias Apix.Schema.Context

  @type t() :: %__MODULE__{
          module: module(),
          delegates: [
            {
              {module(), atom()},
              {module(), atom()}
            }
          ]
        }

  defstruct module: nil,
            delegates: []

  @callback manifest :: t()

  @callback install!(Context.t()) :: Context.t()
  @callback validate_ast!(Context.t()) :: :ok
  @callback expression!(Context.t(), Macro.t(), Ast.t(), Macro.Env.t(), literal? :: boolean()) :: Ast.t() | false

  @callback cast(Context.t()) :: Context.t()

  @optional_callbacks [
    install!: 1,
    validate_ast!: 1,
    expression!: 5,
    cast: 1
  ]

  def manifest(%__MODULE__{} = manifest), do: manifest
  def manifest(module), do: module.manifest()

  def install!(%__MODULE__{module: m}, context) do
    if function_exported?(m, :install!, 1),
      do: m.install!(context),
      else: context
  end

  def validate_ast!(%__MODULE__{module: m}, context) do
    if function_exported?(m, :validate_ast!, 1),
      do: m.validate_ast!(context),
      else: context
  end

  def expression!(%__MODULE__{module: m}, context, elixir_ast, schema_ast, env, literal?) do
    if function_exported?(m, :expression!, 5) do
      m.expression!(context, elixir_ast, schema_ast, env, literal?)
    end
  end

  def require(%__MODULE__{module: m}) do
    quote do
      require unquote(m)
    end
  end

  def extensions_config, do: Application.get_env(:apix_schema, __MODULE__, [])
end
