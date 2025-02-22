defmodule Apix.Schema.Extensions.Core.Not do
  use Apix.Schema

  schema t: _, params: [:schema] do
    validate not valid?(it, schema)
  end
end
