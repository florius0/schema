defmodule Apix.Schema.Errors.InvalidAstError do
  alias Apix.Schema.Ast

  @type t() :: %__MODULE__{
          __exception__: true,
          message: String.t(),
          ast: Ast.t()
        }

  defexception [:message, :ast]

  @impl true
  def exception(%Ast{} = ast) do
    %__MODULE__{
      message: "invalid #{inspect ast} in #{ast.meta}",
      ast: ast
    }
  end
end
