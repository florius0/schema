defmodule Apix.Schema.Extensions.Elixir.List do
  use Apix.Schema

  @moduledoc false

  schema t: Any.t() do
    validate is_list(it)
  end

  schema t: t(), params: [:items]
end
