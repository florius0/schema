defmodule Apix.Schema.Warnings.VoidAstWarning do
  alias Apix.Schema.Ast
  alias Apix.Schema.Ast.Meta

  defexception [:message, :ast, :meta]

  @type t() :: %__MODULE__{
          __exception__: true,
          message: String.t(),
          ast: Ast.t(),
          meta: Meta.t() | nil
        }

  @impl true
  def exception(%Ast{} = ast) do
    %__MODULE__{
      message: "#{inspect ast} results in `#{inspect Void}.t()`",
      ast: ast,
      meta: ast.meta
    }
  end
end
