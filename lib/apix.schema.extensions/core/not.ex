defmodule Apix.Schema.Extensions.Core.Not do
  use Apix.Schema

  alias Apix.Schema.Ast
  alias Apix.Schema.Context

  @moduledoc false

  schema t: _, params: [:schema] do
    validate not valid?(it, schema())

    relate %Context{module: __MODULE__, schema: :t, params: [_schema]} = _it, _to, do: []
    relate _it, %Context{module: __MODULE__, schema: :t, params: [_schema]} = _to, do: []

    relate %Ast{} = it, to do
      [
        # Identity subtyping
        {:subtype, it, it},
        {:supertype, it, it},
        # Not-specific subtyping
        # {:not_subtype, to, it},
        {:not_subtype, it, to},
        # {:not_supertype, it, to},
        {:not_supertype, to, it}
      ]
    end
  end
end
