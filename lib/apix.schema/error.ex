defmodule Apix.Schema.Error do
  @moduledoc """
  Error type and common functions
  """

  @typedoc """
  Error.

  Every Error must implement `#{inspect Exception}` behaviour.
  """
  @type t() :: %{
          __struct__: module(),
          __exception__: true,
          message: String.t()
        }
end
