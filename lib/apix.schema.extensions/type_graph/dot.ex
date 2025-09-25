defmodule Apix.Schema.Extensions.TypeGraph.Dot do
  alias Apix.Schema.Extensions.TypeGraph.Graph

  @moduledoc """
  Utility to visualize the graph in dot format.
  """

  @doc """
  Serializes the graph to dot format.

  Optionally, renders it in given formats using `dot-compatible` program.

  ## Options
  - `:program` – program to use to render the graph. Defaults to `:neato`. Other common options are `:dot`, `:fdp`, `:sfdp`, `:twopi`, `:circo`.
  - `:path` - path to save the dot file and rendered files. Defaults to `#{inspect(Graph)}.dot/<format>`.
  - `:format` – format(s) to render the graph in. Uses `dot` program. Supported formats depend on the installed `dot` program. Common ones are `:png`, `:svg`, `:pdf`. By default, no rendering is done.
  - `:edges` – list of edge labels to include. By default, all edges are included.
  """
  @spec to_dot(keyword()) :: :ok
  def to_dot(opts \\ []) do
    program = opts[:program] || :neato
    path = opts[:path] || inspect(Graph)
    formats = List.wrap(opts[:format])
    filter_edges = List.wrap(opts[:edges])

    dot_path = "#{path}.dot"

    vertices =
      Graph.vertices()
      |> Map.new(fn hash ->
        {^hash, context} = Graph.vertex(hash)

        inspect =
          context
          |> inspect()
          |> String.replace("Apix.Schema.Extensions.", "")

        {hash, "\"#{inspect}\""}
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
    Enum.each(formats, &System.shell("#{program} -T#{&1} -Goverlap=prism -Gsep=+15 '#{dot_path}' -o '#{path}.#{&1}'"))
  end
end
