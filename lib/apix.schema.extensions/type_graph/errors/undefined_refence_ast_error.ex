defmodule Apix.Schema.Extensions.TypeGraph.Errors.UndefinedReferenceAstError do
  alias Apix.Schema.Ast
  alias Apix.Schema.Ast.Meta

  @moduledoc """
  `#{inspect __MODULE__}` is raised when operating on `t:#{inspect Ast}.t/0` which has an undefined reference, e.g.:

  ```elixir
  defmodule UndefinedReferenceSchema do
    use Apix.Schema

    schema a: Map.t() do
      field :a, b()
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
  def exception(%Ast{} = ast) do
    %__MODULE__{
      message: """
      #{inspect ast, pretty: true} is undefined in #{ast.meta}
      """,
      ast: ast,
      meta: ast.meta
    }
  end
end
