defmodule Apix.Schema.Extensions.Elixir.Date.Range do
  use Apix.Schema

  @moduledoc """
  Schema for `t:#{inspect Date.Range}.t/0`
  """

  schema t: Struct.t(Date.Range)
end
