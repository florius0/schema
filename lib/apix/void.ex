defmodule Apix.Void do
  @moduledoc """
  Type to represent empty value ("no added information here") in non-ambiguous way.
  """

  @type t() :: %__MODULE__{}

  defstruct []
end
