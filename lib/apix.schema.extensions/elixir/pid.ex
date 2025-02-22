defmodule Apix.Schema.Extensions.Elixir.PID do
  use Apix.Schema

  schema t: Any.t() do
    validate is_pid(it)
  end
end
