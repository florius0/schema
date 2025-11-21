defmodule Apix.Schema.Extensions.Elixir.Time do
  use Apix.Schema

  @moduledoc """
  Schema for `t:#{inspect Time}.t/0`
  """

  schema t: Struct.t(Time)
end
