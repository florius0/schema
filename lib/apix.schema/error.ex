defmodule Apix.Schema.Error do
  alias Apix.Schema.Ast
  alias Apix.Schema.Ast.Meta
  alias Apix.Schema.Context

  @moduledoc """
  Error type and common functions
  """

  @typedoc """
  Error.

  Every Error must implement `#{inspect Exception}` behaviour.
  """
  @type t() :: %{
          :__struct__ => module(),
          :__exception__ => true,
          :message => String.t(),
          optional(:ast) => Ast.t() | nil,
          optional(:context) => Context.t() | nil,
          optional(:meta) => Meta.t() | nil,
          optional(any()) => any()
        }
end
