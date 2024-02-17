defmodule Apix.Schema.Validator do
  alias Apix.Schema.Context

  @type t() :: (Context.t() -> Context.t())
end
