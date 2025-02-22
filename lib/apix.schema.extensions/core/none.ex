defmodule Apix.Schema.Extensions.Core.None do
  use Apix.Schema

  schema t: _ do
    validate false
  end
end
