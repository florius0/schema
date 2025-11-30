defmodule Apix.Schema.Extensions.Elixir.Tuple do
  use Apix.Schema

  @moduledoc false

  schema t: Any.t() do
    validate is_tuple(it)
  end

  schema t: t(), params: [:items]
end
