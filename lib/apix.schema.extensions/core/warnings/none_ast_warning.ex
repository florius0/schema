defmodule Apix.Schema.Extensions.Core.Warnings.NoneAstWarning do
  alias Apix.Schema.Ast
  alias Apix.Schema.Ast.Meta

  @moduledoc """
  `#{inspect __MODULE__}` is raised when `t:#{inspect Ast}.t/0` evaluates to `None.t()` (excluding plain `None.t()` definition), e.g.:

  ```elixir
  defmodule RecursiveSchema do
    use Apix.Schema

    # Will raise, since no value can be both integer and string at same time
    schema a: Integer.t() and String.t()

    # Won't raise
    schema b: None.t()
  end
  ```
  """

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
      message: """
      #{inspect ast} results in `#{inspect None}.t()`.
      If you intended it rewrite in as `#{inspect None}.t()`
      """,
      ast: ast,
      meta: ast.meta
    }
  end
end
