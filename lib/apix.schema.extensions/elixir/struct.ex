defmodule Apix.Schema.Extensions.Elixir.Struct do
  use Apix.Schema

  @moduledoc """
  Schema for `t:map/0`
  """

  schema t: Map.t() do
    validate is_struct(it)
  end

  schema t: t(), params: [:struct] do
    validate is_struct(it, struct() |> Const.value())
  end
end
