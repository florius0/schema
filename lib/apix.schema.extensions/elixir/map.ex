defmodule Apix.Schema.Extensions.Elixir.Map do
  use Apix.Schema

  @moduledoc false

  schema t: Any.t(), recursion: :at_least_one do
    validate is_map(it)
  end

  schema t: t(), params: [:fields], recursion: :at_least_one
end
