defmodule Apix.Schema.Ast do
  alias Apix.Schema
  alias Apix.Schema.Validator

  alias __MODULE__.Meta

  @moduledoc """
  This module and it's submodules hold structs and helper functions to work with AST.
  """

  @typedoc """
  Schema AST.

  Each AST struct in `#{inspect Schema}` is considered a pseudo-function and thus has args.

  ## Fields

  - `:module` – module in which this AST node is defined in.
  - `:schema` – schema in which this AST node is defined in.
  - `:args` – arguments of the AST node.
  - `:shortdoc` – shortdoc for this AST node.
  - `:doc` – doc for this AST node.
  - `:examples` – list of examples for this AST node.
  - `:validators` – TODO.
  - `:flags` – flags that are defined in this AST node.
  - `:meta` – See `t:#{inspect Meta}.t/0`.
  - `:parameter?` - is this AST node a parameter invocation?
  """
  @type t() :: %__MODULE__{
          module: module() | nil,
          schema: Schema.schema(),
          args: [any()],
          shortdoc: String.t() | nil,
          doc: String.t() | nil,
          examples: [any()] | nil,
          validators: [Validator.t()],
          flags: keyword(),
          meta: Meta.t() | nil,
          parameter?: boolean()
        }

  defstruct module: nil,
            schema: nil,
            args: [],
            shortdoc: nil,
            doc: nil,
            examples: [],
            validators: [],
            flags: [],
            meta: nil,
            parameter?: false
end
