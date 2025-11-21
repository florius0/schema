defmodule Apix.Schema.Extensions.Elixir.Number do
  use Apix.Schema

  @moduledoc """
  Schema for `t:number/0`
  """

  schema t: Integer.t() or Float.t()
end
