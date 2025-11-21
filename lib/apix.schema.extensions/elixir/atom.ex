defmodule Apix.Schema.Extensions.Elixir.Atom do
  use Apix.Schema

  @moduledoc """
  Schema for `t:atom/0`
  """

  schema t: Any.t() do
    validate is_atom(it)
  end
end
