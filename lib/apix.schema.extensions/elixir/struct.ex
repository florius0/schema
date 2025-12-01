defmodule Apix.Schema.Extensions.Elixir.Struct do
  use Apix.Schema

  @moduledoc false

  schema t: Map.t() do
    validate is_struct(it)
  end

  schema t: t(), params: [:fields] do
    validate is_struct(it, struct() |> Const.value())
  end
end
