# credo:disable-for-next-line
defmodule Apix.Schema.Warnings.ReduceableAstWarning do
  alias Apix.Schema.Ast
  alias Apix.Schema.Ast.Meta

  @type t() :: %__MODULE__{
          __exception__: true,
          message: String.t(),
          original_ast: Ast.t(),
          reduced_ast: Ast.t(),
          meta: Meta.t()
        }

  defexception [:message, :original_ast, :reduced_ast, :meta]

  @impl true
  def exception(original_ast: %Ast{} = original_ast, reduced_ast: %Ast{} = reduced_ast) do
    %__MODULE__{
      message: "#{inspect original_ast} can be reduced to #{inspect reduced_ast} and remain equivalent",
      original_ast: original_ast,
      reduced_ast: reduced_ast,
      meta: original_ast.meta
    }
  end
end
