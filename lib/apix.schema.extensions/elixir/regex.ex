defmodule Apix.Schema.Extensions.Elixir.Regex do
  use Apix.Schema

  @moduledoc """
  Schema for `t:#{inspect Regex}.t/0`
  """

  schema t: Struct.t(Regex)
end
