defmodule Apix.Schema.Extensions.Core.None do
  use Apix.Schema

  alias Apix.Schema.Ast
  alias Apix.Schema.Context

  alias Apix.Schema.Ast.Meta

  alias Apix.Schema.Extensions.Core

  @moduledoc false

  @boolean_schemas Core.boolean_schemas()
  @it_ast %Ast{module: __MODULE__, schema: :t, args: []} |> Meta.maybe_put_in(env: __ENV__, generated_by: Core.manifest())

  schema t: _ do
    validate false

    relate it, to do
      [
        {:subtype, it, to},
        {:supertype, to, it},
        {:subtype, it, it},
        {:supertype, it, it}
      ]
    end

    relationship _it, %Context{module: m} = _peer, existing when m in @boolean_schemas, do: existing

    relationship %Context{} = it, peer, existing do
      [
        {:subtype, it, @it_ast},
        {:subtype, @it_ast, peer},
        {:supertype, peer, @it_ast},
        {:supertype, @it_ast, it}
        | existing
      ]
    end
  end
end
