defmodule Apix.Schema.Extensions.Elixir.URI do
  use Apix.Schema

  @moduledoc """
  Schema for `t:#{inspect URI}.t/0`
  """

  schema t: Struct.t(URI)
end
