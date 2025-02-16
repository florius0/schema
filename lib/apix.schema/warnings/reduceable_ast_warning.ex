defmodule Apix.Schema.Warnings.ReduceableAstWarning do
  alias Apix.Schema.Ast
  alias Apix.Schema.Ast.Meta

  @moduledoc """
  `#{inspect __MODULE__}` is raised when `t:#{inspect Ast}.t/0` can be reduced further, e.g.:

  ```elixir
  defmodule RecursiveSchema do
    use Apix.Schema

    # Can be written as just Ant.t()
    schema a: Integer.t() or Any.t()
  end
  ```
  """

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
      message: """
      #{inspect original_ast} can be reduced to #{inspect reduced_ast} and remain equivalent.

      If you intended that rewrite it as #{inspect reduced_ast}.

      #{original_ast.meta}
      """,
      original_ast: original_ast,
      reduced_ast: reduced_ast,
      meta: original_ast.meta
    }
  end
end
