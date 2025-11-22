defmodule Apix.Schema.Extensions.Core.Const do
  use Apix.Schema

  @moduledoc false

  schema t: Any.t(), params: [:value] do
    validate it == value
  end
end
