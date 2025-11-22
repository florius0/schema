defmodule Apix.Schema.Extensions.Elixir.Record do
  use Apix.Schema
  require Record

  @moduledoc false

  schema t: Tuple.t() do
    validate is_record(it)
  end

  schema t: t(), params: [:record] do
    validate Record.is_record(it, record() |> Const.value())
  end
end
