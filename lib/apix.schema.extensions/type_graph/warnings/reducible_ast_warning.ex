defmodule Apix.Schema.Extensions.TypeGraph.Warnings.ReducibleAstWarning do
  alias Apix.Schema.Ast
  alias Apix.Schema.Ast.Meta
  alias Apix.Schema.Context

  @moduledoc """
  `#{inspect __MODULE__}` is raised when `t:#{inspect Ast}.t/0` can be reduced further, e.g.:

  ```elixir
  defmodule RedundantSchema do
    use Apix.Schema

    # Can be written as just Ant.t()
    schema a: Any.t() or Any.t()
  end
  ```
  """

  @type t() :: %__MODULE__{
          __exception__: true,
          message: String.t(),
          ast: Ast.t(),
          reduced_ast: Ast.t(),
          meta: Meta.t()
        }

  defexception [:message, :ast, :reduced_ast, :meta]

  @impl true
  def exception(ast: ast, reduced_ast: reduced_ast) when (is_struct(ast, Ast) or is_struct(ast, Context)) and (is_struct(reduced_ast, Ast) or is_struct(reduced_ast, Context)) do
    ast =
      case ast do
        %Context{} ->
          ast.ast

        %Ast{} ->
          ast
      end

    reduced_ast =
      case reduced_ast do
        %Context{} ->
          reduced_ast.ast

        %Ast{} ->
          reduced_ast
      end

    %__MODULE__{
      message: """
      #{inspect ast} can be reduced to #{inspect reduced_ast} and remain equivalent.

      If you intended that, rewrite it as #{inspect reduced_ast}.

      #{ast.meta}
      """,
      ast: ast,
      reduced_ast: reduced_ast,
      meta: ast.meta
    }
  end
end
