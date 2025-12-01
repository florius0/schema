defmodule Apix.Schema.Extensions.Elixir.Integer do
  use Apix.Schema

  @moduledoc false

  schema t: Any.t() do
    validate is_integer(it)
  end

  schema non_neg: t() do
    validate it >= 0
  end
end
