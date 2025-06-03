defmodule Apix.Schema.Extensions.Core.TypeGraph.Dot do
  alias Apix.Schema.Extensions.Core.TypeGraph.Graph

  @moduledoc """
  Utility to visualize the graph in dot format.
  """

  @doc """
  Serializes the graph to dot format.

  Optionally, renders it in given formats using `dot` program.
  """
  @spec to_dot(keyword()) :: :ok
  def to_dot(opts \\ []) do
    path = opts |> Keyword.get(:path, "#{inspect Graph}")
    formats = opts |> Keyword.get(:format) |> List.wrap()
    filter_edges = opts |> Keyword.get(:filter_edges) |> List.wrap()

    dot_path = "#{path}.dot"

    vertices =
      Graph.vertices()
      |> Map.new(fn msa ->
        {^msa, context} = Graph.vertex(msa)

        inspect =
          context
          |> dbg()
          |> inspect()
          |> String.replace("Apix.Schema.Extensions.", "")

        {msa, "\"#{inspect}\""}
      end)

    vertices_dot =
      vertices
      |> Map.to_list()
      |> Enum.sort_by(fn {v, _t} -> Graph.in_degree(v) end, :desc)
      |> Enum.map(fn {_v, t} -> t end)
      |> Enum.join("\n")

    edges_dot = Graph.edges()

    edges_dot =
      if filter_edges == [],
        do: edges_dot,
        else: Enum.filter(edges_dot, fn {_f, _t, l} -> l in filter_edges end)

    edges_dot = Enum.map_join(edges_dot, "\n", fn {f, t, l} -> "#{vertices[f]} -> #{vertices[t]} [label = #{l}]" end)

    dot = """
    digraph "#{inspect Graph}" {
    # Vertices
    #{vertices_dot}

    # Edges
    #{edges_dot}
    }
    """

    File.write(dot_path, dot)
    Enum.each(formats, &System.shell("dot -T#{&1} '#{dot_path}' -o '#{path}.#{&1}'"))
  end
end
