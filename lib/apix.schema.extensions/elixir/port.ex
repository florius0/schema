defmodule Apix.Schema.Extensions.Elixir.Port do
  use Apix.Schema

  @moduledoc false

  schema t: Any.t() do
    validate is_port(it)
  end
end
