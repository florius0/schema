defmodule Apix.Schema.Extensions.TypeGraphTest do
  use Apix.Schema.Case

  alias Apix.Schema.Extensions.TypeGraph
  alias Apix.Schema.Extensions.TypeGraph.Graph

  describe "#{inspect Apix.Schema.Extensions.TypeGraph}" do
    test "track!/1 | tracks schema definitions" do
      defmodule TestSchema1 do
        use Apix.Schema

        schema a: Any.t()

        schema b: a()

        schema c: Tuple.t() do
          item a()
          item b()
        end
      end

      expected_vertices = [
        412_488,
        31_224_562,
        35_678_900,
        65_673_262,
        84_784_011,
        97_769_855,
        103_281_375
      ]

      expected_edges = [
        {412_488, 31_224_562, :subtype},
        {412_488, 31_224_562, :supertype},
        {412_488, 412_488, :subtype},
        {412_488, 412_488, :supertype},
        {412_488, 97_769_855, :subtype},
        {31_224_562, 103_281_375, :referenced},
        {31_224_562, 103_281_375, :supertype},
        {31_224_562, 31_224_562, :subtype},
        {31_224_562, 31_224_562, :supertype},
        {31_224_562, 65_673_262, :subtype},
        {31_224_562, 65_673_262, :supertype},
        {35_678_900, 31_224_562, :subtype},
        {35_678_900, 31_224_562, :supertype},
        {35_678_900, 35_678_900, :subtype},
        {35_678_900, 35_678_900, :supertype},
        {35_678_900, 84_784_011, :subtype},
        {65_673_262, 31_224_562, :supertype},
        {65_673_262, 65_673_262, :subtype},
        {65_673_262, 65_673_262, :supertype},
        {84_784_011, 31_224_562, :subtype},
        {84_784_011, 31_224_562, :supertype},
        {84_784_011, 35_678_900, :supertype},
        {97_769_855, 103_281_375, :subtype},
        {97_769_855, 31_224_562, :subtype},
        {97_769_855, 31_224_562, :supertype},
        {97_769_855, 412_488, :supertype},
        {97_769_855, 97_769_855, :subtype},
        {97_769_855, 97_769_855, :supertype},
        {103_281_375, 103_281_375, :subtype},
        {103_281_375, 103_281_375, :supertype},
        {103_281_375, 31_224_562, :references},
        {103_281_375, 31_224_562, :subtype},
        {103_281_375, 31_224_562, :supertype},
        {103_281_375, 97_769_855, :supertype}
      ]

      assert [] = Graph.vertices() -- expected_vertices
      assert [] = Graph.edges() -- expected_edges
    end

    test "prune!/0 | keeps only actual data" do
      defmodule TestSchema2 do
        use Apix.Schema

        schema a: Any.t()

        schema b: a()

        schema c: Tuple.t() do
          item a()
          item b()
        end
      end

      TestSchema2
      |> Apix.Schema.get_schema(:c, 0)
      |> struct(schema: :d)
      |> Apix.Schema.hash()
      # Simulates `Apix.Schema.get_schema/1` not finding the module
      |> Graph.add_vertex({:deleted, :deleted, 0})

      TypeGraph.prune!()

      expected_vertices = [
        6_255_210,
        31_224_562,
        34_944_339,
        57_272_863,
        65_673_262,
        98_305_695
      ]

      expected_edges =
        [
          {6_255_210, 6_255_210, :subtype},
          {6_255_210, 6_255_210, :supertype},
          {31_224_562, 98_305_695, :referenced},
          {34_944_339, 34_944_339, :subtype},
          {34_944_339, 34_944_339, :supertype},
          {57_272_863, 57_272_863, :subtype},
          {57_272_863, 57_272_863, :supertype},
          {65_673_262, 65_673_262, :subtype},
          {65_673_262, 65_673_262, :supertype},
          {98_305_695, 31_224_562, :references},
          {98_305_695, 98_305_695, :subtype},
          {98_305_695, 98_305_695, :supertype}
        ]

      assert [] = Graph.vertices() -- expected_vertices
      assert [] = Graph.edges() -- expected_edges
    end
  end
end
