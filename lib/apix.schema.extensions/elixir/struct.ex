defmodule Apix.Schema.Extensions.Elixir.Struct do
  use Apix.Schema

  @moduledoc false

  schema t: Map.t(), recursion: :at_least_one do
    validate is_struct(it)
  end

  schema t: t(), params: [:fields], recursion: :at_least_one do
    validate is_struct(it, struct() |> Const.value())
  end
end
