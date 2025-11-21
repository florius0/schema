defmodule Apix.Schema.Extensions.Elixir.Port do
  use Apix.Schema

  @moduledoc """
  Schema for `t:port/0`
  """

  schema t: Any.t() do
    validate is_port(it)
  end
end
