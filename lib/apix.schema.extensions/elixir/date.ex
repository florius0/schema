defmodule Apix.Schema.Extensions.Elixir.Date do
  use Apix.Schema

  @moduledoc """
  Schema for `t:#{inspect Date}.t/0`
  """

  schema t: Struct.t(Date)
end
