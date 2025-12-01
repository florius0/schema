defmodule Apix.Schema.Extensions.Elixir.Tuple do
  use Apix.Schema

  @moduledoc false

  schema t: Any.t(), recursion: :at_least_one do
    validate is_tuple(it)
  end

  schema t: t(), params: [:items], recursion: :at_least_one
end
