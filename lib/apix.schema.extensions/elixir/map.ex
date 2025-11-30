defmodule Apix.Schema.Extensions.Elixir.Map do
  use Apix.Schema

  @moduledoc false

  schema t: Any.t() do
    validate is_map(it)
  end

  schema t: t(), params: [:fields]
end
