defmodule Apix.Schema.Extensions.Elixir.Tuple do
  use Apix.Schema

  @moduledoc """
  Schema for `t:tuple/0`
  """

  schema t: Any.t() do
    validate is_tuple(it)
  end
end
