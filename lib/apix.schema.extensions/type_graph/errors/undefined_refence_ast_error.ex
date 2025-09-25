defmodule Apix.Schema.Extensions.TypeGraph.Errors.UndefinedReferenceAstError do
  alias Apix.Schema.Ast

  @undefined_reference """
  defmodule UndefinedReferenceSchema do
    use Apix.Schema

    schema a: Map.t() do
      field :a, b()
    end
  end
  """

  @moduledoc """
  `#{inspect __MODULE__}` is raised when operating on `t:#{inspect Ast}.t/0` which has an undefined reference

  ```elixir
  #{@undefined_reference}
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
      #{inspect ast, pretty: true} has an undefined reference in #{ast.meta}, e.g.:

      #{@undefined_reference}

      Check if schema you are referencing exists, or if there is a typo.

      #{ast.meta}
      """,
      ast: ast
    }
  end
end
