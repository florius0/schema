defmodule Apix.Schema.Extensions.Elixir.List do
  use Apix.Schema

  schema t: Any.t() do
    validate is_list(it)
  end
end
