defmodule Apix.Schema.Extensions.Elixir.MapSet do
  use Apix.Schema

  @moduledoc """
  Schema for `t:#{inspect MapSet}.t/0`
  """

  schema t: Struct.t(MapSet)

  schema t: t(), params: [subtype: 0] do
    validate Enum.all?(it, &valid?(&1, subtype()))
  end
end
