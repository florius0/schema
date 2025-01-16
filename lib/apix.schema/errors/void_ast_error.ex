defmodule Apix.Schema.Errors.VoidAstError do
  alias Apix.Schema.Ast

  defexception [:message, :ast]

  @type t() :: %__MODULE__{
          __exception__: true,
          message: String.t(),
          ast: Ast.t()
        }

  @impl true
  def exception(%Ast{} = ast) do
    %__MODULE__{
      message: "#{inspect ast} results in `#{inspect Void}.t()`",
      ast: ast
    }
  end
end
