defmodule Apix.Schema.Errors.InvalidElixirAstError do
  alias Apix.Schema.Ast.Meta

  @type t() :: %__MODULE__{
          __exception__: true,
          message: String.t(),
          elixir_ast: Macro.t()
        }

  defexception [:message, :elixir_ast]

  @impl true
  def exception(elixir_ast: elixir_ast, env: env) do
    %__MODULE__{
      message: "invalid #{Macro.to_string(elixir_ast)} in #{Meta.new(elixir_ast: elixir_ast, env: env)}",
      elixir_ast: elixir_ast
    }
  end
end
