defmodule Apix.Schema.Extensions.Elixir.NaiveDateTime do
  use Apix.Schema

  @moduledoc false

  schema t: Struct.t(NaiveDateTime)
end
