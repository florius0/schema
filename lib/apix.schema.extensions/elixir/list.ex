defmodule Apix.Schema.Extensions.Elixir.List do
  use Apix.Schema

  @moduledoc false

  schema t: Any.t(), recursion: :at_least_one do
    validate is_list(it)
  end

  schema t: t(), params: [:items], recursion: :at_least_one
end
