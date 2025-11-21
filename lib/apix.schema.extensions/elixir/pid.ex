defmodule Apix.Schema.Extensions.Elixir.PID do
  use Apix.Schema

  @moduledoc """
  Schema for `t:pid/0`
  """

  schema t: Any.t() do
    validate is_pid(it)
  end
end
