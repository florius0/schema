defmodule Apix.Schema.Extensions.Elixir.NaiveDateTime do
  use Apix.Schema

  @moduledoc """
  Schema for `t:#{inspect NaiveDateTime}.t/0`
  """

  schema t: Struct.t(NaiveDateTime)
end
