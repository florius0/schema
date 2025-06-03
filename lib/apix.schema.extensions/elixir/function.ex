defmodule Apix.Schema.Extensions.Elixir.Function do
  use Apix.Schema

  alias Apix.Schema.Extensions.Core.Const

  schema t: Any.t() do
    validate is_function(it)
  end

  schema t: Function.t(), params: [arity: Integer.non_neg()] do
    validate is_function(it, arity() |> Const.value())
  end
end
