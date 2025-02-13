defmodule Apix.Schema.Extensions.Core.TypeGraph.Dot do
  alias Apix.Schema.Extensions.Core.TypeGraph.Graph

  @moduledoc """
  Utility to visualize the graph in dot format.
  """

  @doc """
  Serializes the graph to dot format.

  Optionally, renders it in given formats using `dot` program.
  """
  @spec to_dot(Path.t(), formats :: [atom()]) :: :ok
  def to_dot(path \\ "#{inspect Graph}", formats \\ []) do
    dot_path = "#{path}.dot"

    vertices =
      Graph.postorder()
      |> Map.new(fn {m, s, a} = v -> {v, "\"#{inspect m}.#{s}/#{a}\""} end)

    vertices_dot =
      vertices
      |> Map.values()
      |> Enum.join("\n")

    edges_dot =
      Graph.edges()
      |> Enum.map_join("\n", fn {f, t, l} -> "#{vertices[f]} -> #{vertices[t]} [label = #{l}]" end)

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
