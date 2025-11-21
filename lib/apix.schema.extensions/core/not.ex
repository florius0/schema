defmodule Apix.Schema.Extensions.Core.Not do
  use Apix.Schema

  alias Apix.Schema.Ast
  alias Apix.Schema.Context

  @moduledoc """
  Schema for `not` operation.

  See #{inspect Apix.Schema.Extensions.Core}
  """

  schema t: _, params: [:schema] do
    validate not valid?(it, schema)

    relate %Context{module: __MODULE__, schema: :t, params: [_schema]} = _it, _to, do: []
    relate _it, %Context{module: __MODULE__, schema: :t, params: [_schema]} = _to, do: []

    relate %Ast{args: [schema]} = it, to do
      [
        # Default subtyping
        {:subtype, it, to},
        {:supertype, to, it},
        # Identity subtyping
        {:subtype, it, it},
        {:supertype, it, it},
        # Not-specific subtyping
        {:not_subtype, schema, it},
        {:not_subtype, it, schema},
        {:not_supertype, it, schema},
        {:not_supertype, schema, it}
      ]
    end
  end
end
