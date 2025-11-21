defmodule Apix.Schema.Extensions.Elixir.List do
  use Apix.Schema

  @moduledoc """
  Schema for `t:list/0`
  """

  schema t: Any.t() do
    validate is_list(it)
  end
end
