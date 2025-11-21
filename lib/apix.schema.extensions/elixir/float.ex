defmodule Apix.Schema.Extensions.Elixir.Float do
  use Apix.Schema

  @moduledoc """
  Schema for `t:float/0`
  """

  schema t: Any.t() do
    validate is_float(it)
  end
end
