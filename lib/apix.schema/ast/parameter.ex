defmodule Apix.Schema.Ast.Parameter do
  alias Apix.Void

  alias Apix.Schema.Ast.Meta

  @type t() :: %__MODULE__{
          name: atom(),
          value: Void.t() | any(),
          meta: Meta.t() | nil
        }

  defstruct name: nil,
            value: %Void{},
            meta: %Meta{}
end
