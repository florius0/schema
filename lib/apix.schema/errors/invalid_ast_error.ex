defmodule Apix.Schema.Errors.InvalidAstError do
  alias Apix.Schema.Ast

  @moduledoc """
  `#{inspect __MODULE__}` is raised when `t:#{inspect Ast}.t/0` validation fails, e.g.:

  ```elixir
  defmodule RecursiveSchema do
    use Apix.Schema

    schema a: Map.t() do
      item Any.t() # invalid since Map.t() only supports `field` definitions
    end
  end
  ```
  """

  @type t() :: %__MODULE__{
          __exception__: true,
          message: String.t(),
          ast: Ast.t()
        }

  defexception [:message, :ast]

  @impl true
  def exception(%Ast{} = ast) do
    %__MODULE__{
      message: """
      invalid #{inspect ast, pretty: true} in #{ast.meta}
      """,
      ast: ast
    }
  end
end
