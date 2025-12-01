defmodule Apix.Schema.Extensions.TypeGraph.Errors.FullyRecursiveAstError do
  alias Apix.Schema.Ast
  alias Apix.Schema.Ast.Meta
  alias Apix.Schema.Context

  @moduledoc """
  `#{inspect __MODULE__}` is raised when operating on `t:#{inspect Ast}.t/0` which has fully recursive expression, e.g.:

  ```elixir
  defmodule FullyRecursiveSchema do
    use Apix.Schema

    schema a: Map.t() do
      field :a, a()
    end
  end
  ```

  If you intend for the definition to be recursive, you should rewrite it as partially recursive:

  ```elixir
  defmodule PartiallyRecursiveSchema do
    use Apix.Schema

    schema a: Map.t() do
      # Notice how `Any.t()` allows for recursion to exit
      field :a, a() or Any.t()
    end
  end
  ```
  """

  @type t() :: %__MODULE__{
          __exception__: true,
          message: String.t(),
          ast: Ast.t(),
          meta: Meta.t()
        }

  defexception [:message, :ast, :meta]

  @impl Exception
  def exception(%Context{} = context), do: exception(context.ast)

  def exception(%Ast{} = ast) do
    %__MODULE__{
      message: """
      #{inspect ast, pretty: true} is fully recursive in #{ast.meta}
      """,
      ast: ast,
      meta: ast.meta
    }
  end
end
