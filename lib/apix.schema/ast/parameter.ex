defmodule Apix.Schema.Ast.Parameter do
  alias Apix.Void

  alias Apix.Schema.Ast.Meta

  @moduledoc """
  Special AST node to denote parameter reference
  """

  @typedoc """
  Struct to hold parameter reference in the AST

  ## Fields

  - `:name` – name of the parameter.
  - `:value` – value of the parameter, `t:#{inspect Void}.t/0` if missing.
  - `:meta` – optional metadata.
  """
  @type t() :: %__MODULE__{
          name: atom(),
          value: Void.t() | any(),
          meta: Meta.t() | nil
        }

  defstruct name: nil,
            value: %Void{},
            meta: %Meta{}
end
