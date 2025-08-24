defmodule Apix.Schema.Extensions.Elixir.Struct do
  use Apix.Schema

  alias Apix.Schema.Extensions.Core.Const

  schema t: Map.t() do
    validate is_struct(it)
  end

  schema t: Struct.t(), params: [:struct] do
    validate is_struct(it, struct() |> Const.value())
  end
end
