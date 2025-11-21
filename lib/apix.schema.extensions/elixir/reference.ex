defmodule Apix.Schema.Extensions.Elixir.Reference do
  use Apix.Schema

  @moduledoc """
  Schema for `t:reference/0`
  """

  schema t: Any.t() do
    validate is_reference(it)
  end
end
