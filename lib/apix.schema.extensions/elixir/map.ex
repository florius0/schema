defmodule Apix.Schema.Extensions.Elixir.Map do
  use Apix.Schema

  schema t: Any.t() do
    validate is_map(it)
  end

  schema t: t(), params: [:fields] do
    validate is_map(it)
  end
end
