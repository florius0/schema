defmodule Apix.Schema.Errors.BottomAstError do
  alias Apix.Schema.Ast

  @moduledoc """
  `#{inspect __MODULE__}` is raised when operating on `t:#{inspect Ast}.t/0` which can't be evaluated, e.g. fully recursive schema definition:

  ```elixir
  defmodule RecursiveSchema do
    use Apix.Schema

    schema a: Map.t() do
      field :a, a()
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

  @impl Exception
  def exception(%Ast{} = ast) do
    %__MODULE__{
      message: "#{inspect ast} results in `#{inspect Bottom}.t()`",
      ast: ast
    }
  end
end
