defmodule Apix.Schema.Extensions.Elixir.Number do
  use Apix.Schema

  schema t: Integer.t() or Float.t()
end
