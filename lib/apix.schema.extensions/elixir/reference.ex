defmodule Apix.Schema.Extensions.Elixir.Reference do
  use Apix.Schema

  @moduledoc false

  schema t: Any.t() do
    validate is_reference(it)
  end
end
