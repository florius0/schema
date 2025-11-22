defmodule Apix.Schema.Extensions.Core.Or do
  use Apix.Schema

  alias Apix.Schema.Ast
  alias Apix.Schema.Context

  @moduledoc false

  schema t: _, params: [:schema1, :schema2] do
    validate valid?(it, schema1) or valid?(it, schema2)

    relate %Context{module: __MODULE__, schema: :t, params: [_schema1, _schema2]} = _it, _to, do: []
    relate _it, %Context{module: __MODULE__, schema: :t, params: [_schema1, _schema2]} = _to, do: []

    relate %Ast{args: [schema1, schema2]} = it, to do
      [
        # Default subtyping
        {:subtype, to, it},
        {:supertype, it, to},
        # Identity subtyping
        {:subtype, it, it},
        {:supertype, it, it},
        # Or-specific subtyping
        {:subtype, schema1, it},
        {:subtype, schema2, it},
        {:supertype, it, schema1},
        {:supertype, it, schema2}
      ]
    end
  end
end
