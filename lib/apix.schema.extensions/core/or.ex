defmodule Apix.Schema.Extensions.Core.Or do
  use Apix.Schema

  schema t: _, params: [:schema1, :schema2] do
    validate valid?(it, schema1) or valid?(it, schema2)
  end
end
