defmodule Apix.Schema.Extensions.Core.TypeGraphTest do
  use Apix.Schema.Case

  alias Apix.Schema.Extensions.Core.TypeGraph
  alias Apix.Schema.Extensions.Core.TypeGraph.Graph

  describe "#{inspect Apix.Schema.Extensions.Core.TypeGraph}" do
    test "track/1 | tracks schema definitions" do
      defmodule TestSchema1 do
        use Apix.Schema

        schema a: Any.t()

        schema b: a()

        schema c: Tuple.t() do
          item a()
          item b()
        end
      end

      any = {Apix.Schema.Extensions.Core.Any, :t, 0}
      tuple = {Apix.Schema.Extensions.Elixir.Tuple, :t, 2}

      a = {TestSchema1, :a, 0}
      b = {TestSchema1, :b, 0}
      c = {TestSchema1, :c, 0}

      expected_vertices = [any, tuple, a, b, c]

      expected_edges = [
        {any, a, :supertype},
        {a, any, :subtype},
        {a, b, :supertype},
        {b, a, :subtype},
        {tuple, c, :supertype},
        {c, tuple, :subtype},
        {a, c, :referenced},
        {c, a, :references},
        {b, c, :referenced},
        {c, b, :references}
      ]

      assert [] = Graph.vertices() -- expected_vertices
      assert [] = Graph.edges() -- expected_edges
    end

    test "prune/0 | keeps only actual data" do
      defmodule TestSchema2 do
        use Apix.Schema

        schema a: Any.t()

        schema b: a()

        schema c: Tuple.t() do
          item a()
          item b()
        end
      end

      a = {TestSchema2, :a, 0}
      b = {TestSchema2, :b, 0}
      c = {TestSchema2, :c, 0}

      TypeGraph.prune()

      expected_vertices = [a, b, c]

      expected_edges = [
        {a, b, :supertype},
        {b, a, :subtype},
        {a, c, :referenced},
        {c, a, :references},
        {b, c, :referenced},
        {c, b, :references}
      ]

      assert [] = Graph.vertices() -- expected_vertices
      assert [] = Graph.edges() -- expected_edges
    end
  end
end
