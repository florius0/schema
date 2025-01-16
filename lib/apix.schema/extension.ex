defmodule Apix.Schema.Extension do
  alias Apix.Schema
  alias Apix.Schema.Ast
  alias Apix.Schema.Context

  @moduledoc """
  Extension behaviour.

  `#{inspect Schema}` is built to be extensible by design.
  This module holds the extension manifest structure and callbacks that each extension need or may implement.
  Every feature (besides architectural scaffolding) is implemented as an extension.

  For examples, refer to:

  - `#{inspect Apix.Schema.Extensions.Core}`
  - `#{inspect Apix.Schema.Extensions.Core.LocalReference}`
  - `#{inspect Apix.Schema.Extensions.Elixir}`
  """

  @typedoc """
  Extension manifest.

  ## Fields

  - `:module` – module in which extension is defined.
  - `:delegates` – list of delegates extension is providing.
  """
  @type t() :: %__MODULE__{
          module: module(),
          delegates: [delegate()]
        }

  @typedoc """
  Delegate definition.

  Extensions may define delegates – instructions on how to re-write AST.

  E.g.:

  ```elixir
  {
    {                     Elixir.Any, :t, 0},
    {Apix.Schema.Extensions.Core.Any, :t, 0}
  }
  ```

  means to re-write all `Elixir.Any.t(...` schema expressions into `Apix.Schema.Extensions.Core.Any.t(...`.
  """
  @type delegate() :: {
          from :: delegate_target(),
          to :: delegate_target()
        }

  @type delegate_target() :: {module(), atom()}

  defstruct module: nil,
            delegates: []

  @doc """
  Callback to return extension's manifest
  """
  @callback manifest :: t()

  @doc """
  Optional callback to "install" extension into the context.

  When installing, extensions may want to validate the context to, e.g. check the other extensions for compatibility, dependencies etc
  """
  @callback install!(Context.t()) :: Context.t()

  @doc """
  Optional callback to validate resulting AST
  """
  @callback validate_ast!(Context.t()) :: :ok

  @doc """
  Optional callback to transforms schema expression from `t:#{inspect Macro}.t/0` into `t:#{inspect Ast}.t/0`.
  """
  @callback expression!(Context.t(), Macro.t(), Ast.t(), Macro.Env.t(), literal? :: boolean()) :: Ast.t() | false

  @doc """
  TODO: Optional callback to cast data
  """
  @callback cast(Context.t()) :: Context.t()

  @optional_callbacks [
    install!: 1,
    validate_ast!: 1,
    expression!: 5,
    cast: 1
  ]

  @doc """
  Invokes `c:manifest/0`
  """
  @spec manifest(module | t()) :: t()
  def manifest(%__MODULE__{} = manifest), do: manifest
  def manifest(module), do: module.manifest()

  @doc """
  Invokes `c:install!/1`
  """
  @spec install!(t(), Context.t()) :: Context.t()
  def install!(%__MODULE__{module: m}, context) do
    if function_exported?(m, :install!, 1),
      do: m.install!(context),
      else: context
  end

  @doc """
  Invokes `c:validate_ast!/1`
  """
  @spec validate_ast!(t(), Context.t()) :: Context.t() | no_return()
  def validate_ast!(%__MODULE__{module: m}, context) do
    if function_exported?(m, :validate_ast!, 1),
      do: m.validate_ast!(context),
      else: context
  end

  @doc """
  Invokes `c:expression!/5`
  """
  @spec expression!(t(), Context.t(), Macro.t(), Ast.t(), Macro.Env.t(), literal? :: boolean()) :: Ast.t() | false
  def expression!(%__MODULE__{module: m}, context, elixir_ast, schema_ast, env, literal?) do
    if function_exported?(m, :expression!, 5) do
      m.expression!(context, elixir_ast, schema_ast, env, literal?)
    else
      false
    end
  end

  @doc """
  Builds `#{inspect Kernel.SpecialForms}.require/2` into `t:#{inspect Macro}.t/0`
  """
  @spec require(t()) :: Macro.t()
  def require(%__MODULE__{module: m}) do
    quote do
      require unquote(m)
    end
  end

  @doc """
  Gets default extensions from `#{inspect Application}` environment (config).

  ```elixir
  config :apix_schema, #{inspect __MODULE__}, [
    # list of extensions
  ]
  ```
  """
  @spec extensions_config() :: Keyword.t()
  def extensions_config, do: Application.get_env(:apix_schema, __MODULE__, [])

  @doc """
  Builds documentation section on delegates for extensions.
  """
  @spec delegates_doc(t()) :: String.t()
  def delegates_doc(%__MODULE__{delegates: []}) do
    """
    ## Delegates

    This extension defines no delegates
    """
  end

  def delegates_doc(%__MODULE__{delegates: [_ | _] = d}) do
    d =
      Enum.map_join(d, "\n", fn {{fm, ft}, {tm, tt}} ->
        "- `#{inspect fm}.#{ft}` -> `#{inspect tm}.#{tt}`."
      end)

    """
    ## Delegates

    #{d}
    """
  end
end
