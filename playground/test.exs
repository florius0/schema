defmodule A do
  use Apix.Schema

  schema a: _ do
    doc "123"
  end
end

Apix.Schema.get_schema(A, :a, 0)
