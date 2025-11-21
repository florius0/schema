defmodule Apix.Schema.Extensions.Elixir.Module do
  use Apix.Schema

  @moduledoc """
  Schema for `t:module/0`
  """

  schema t: Atom.t()
end
