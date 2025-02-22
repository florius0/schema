defmodule Apix.Schema.Extensions.Elixir.Atom do
  use Apix.Schema

  schema t: Any.t() do
    validate is_atom(it)
  end
end
