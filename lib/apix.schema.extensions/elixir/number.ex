defmodule Apix.Schema.Extensions.Elixir.Number do
  use Apix.Schema

  @moduledoc false

  schema t: Integer.t() or Float.t()
end
