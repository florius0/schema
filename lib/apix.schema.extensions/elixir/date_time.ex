defmodule Apix.Schema.Extensions.Elixir.DateTime do
  use Apix.Schema

  @moduledoc """
  Schema for `t:#{inspect DateTime}.t/0`
  """

  schema t: Struct.t(DateTime)
end
