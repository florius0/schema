defmodule Apix.Schema.Extensions.Elixir.String do
  use Apix.Schema

  @moduledoc false

  schema t: Any.t() do
    validate is_binary(it)
  end
end
