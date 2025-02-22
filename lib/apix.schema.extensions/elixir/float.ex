defmodule Apix.Schema.Extensions.Elixir.Float do
  use Apix.Schema

  schema t: Any.t() do
    validate is_float(it)
  end
end
