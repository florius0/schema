defmodule Apix.Schema.Case do
  use ExUnit.CaseTemplate

  alias Apix.Schema.Extensions.TypeGraph.Graph

  setup do
    Graph.vertices()
    |> Graph.del_vertices()

    :ok
  end
end
