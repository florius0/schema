defmodule Apix.Schema.Ast do
  alias Apix.Schema.Validator

  alias __MODULE__.Meta

  @type schema() :: atom()

  @type t() :: %__MODULE__{
          module: module() | nil,
          schema: schema(),
          args: any(),
          shortdoc: String.t() | nil,
          doc: String.t() | nil,
          examples: [any()] | nil,
          validators: [Validator.t()],
          flags: keyword(),
          meta: Meta.t() | nil
        }

  defstruct module: nil,
            schema: nil,
            args: nil,
            shortdoc: nil,
            doc: nil,
            examples: [],
            validators: nil,
            flags: [],
            meta: nil
end
