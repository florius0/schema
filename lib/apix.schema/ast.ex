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

  def maybe_put_meta(%__MODULE__{} = ast, env, node), do: struct(ast, meta: Meta.new(env, node))
  def maybe_put_meta(ast, _env, _node), do: ast
end
