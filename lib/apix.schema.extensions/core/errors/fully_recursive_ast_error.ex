defmodule Apix.Schema.Extensions.Core.Errors.FullyRecursiveAstError do
  alias Apix.Schema.Ast

  @fully_recursive """
  defmodule FullyRecursiveSchema do
    use Apix.Schema

    schema a: Map.t() do
      field :a, a()
    end
  end
  """

  @partially_recursive """
  defmodule PartiallyRecursiveSchema do
    use Apix.Schema

    schema a: Map.t() do
      # Notice how `Any.t()` allows for recursion to exit
      field :a, a() or Any.t()
    end
  end
  """

  @moduledoc """
  `#{inspect __MODULE__}` is raised when operating on `t:#{inspect Ast}.t/0` which has fully recursive expression, e.g.:

  ```elixir
  #{@fully_recursive}
  ```
  """

  @type t() :: %__MODULE__{
          __exception__: true,
          message: String.t(),
          ast: Ast.t()
        }

  defexception [:message, :ast]

  @impl Exception
  def exception(%Ast{} = ast) do
    %__MODULE__{
      message: """
      #{inspect ast, pretty: true} is fully recursive in #{ast.meta}, e.g.:

      #{@fully_recursive}

      If you intended for the definition to be recursive, you should rewrite it as partially recursive:

      #{@partially_recursive}

      #{ast.meta}
      """,
      ast: ast
    }
  end
end
