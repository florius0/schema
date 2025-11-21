defmodule Apix.Schema.Extensions.Elixir.String do
  use Apix.Schema

  @moduledoc """
  Schema for `t:#{inspect String}.t/0`
  """

  schema t: Any.t() do
    validate is_binary(it)
  end
end
