defmodule Apix.Schema.Extensions.Elixir.MapSet do
  use Apix.Schema

  schema t: Struct.t(MapSet)

  schema t: MapSet.t(), params: [subtype: 0] do
    validate Enum.all?(it, &valid?(&1, subtype()))
  end
end
