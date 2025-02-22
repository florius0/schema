defmodule Apix.Schema.Extensions.Elixir.Tuple do
  use Apix.Schema

  schema t: Any.t() do
    validate is_tuple(it)
  end
end
