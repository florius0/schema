defmodule Apix.Schema.Extensions.Elixir.Integer do
  use Apix.Schema

  schema t: Any.t() or non_neg() do
    validate is_integer(it)
  end

  schema non_neg: Integer.t() do
    validate it >= 0
  end
end
