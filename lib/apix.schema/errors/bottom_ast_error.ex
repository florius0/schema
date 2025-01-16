defmodule Apix.Schema.Errors.BottomAstError do
  alias Apix.Schema.Ast

  @type t() :: %__MODULE__{
          __exception__: true,
          message: String.t(),
          ast: Ast.t()
        }

  defexception [:message, :ast]

  @impl Exception
  def exception(%Ast{} = ast) do
    %__MODULE__{
      message: "#{inspect ast} results in `#{inspect Bottom}.t()`",
      ast: ast
    }
  end
end
