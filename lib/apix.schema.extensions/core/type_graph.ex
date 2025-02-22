defmodule Apix.Schema.Extensions.Core.TypeGraph do
  alias Apix.Schema.Ast
  alias Apix.Schema.Context

  alias Apix.Schema.Extensions.Core.TypeGraph.Graph

  alias Apix.Schema.Extensions.Core.Errors.FullyRecursiveAstError
  alias Apix.Schema.Extensions.Core.Errors.UndefinedReferenceAstError

  @moduledoc """
  High-level interface for working with graph of types information.
  """

  @doc """
  Tracks schema and it's references in the graph.
  """
  @spec track!(Context.t()) :: :ok
  def track!(%Context{} = context) do
    vertex = build_vertex(context)
    vertex_label = build_vertex_label(module: context.module, ast: context.ast)

    Graph.add_vertex(vertex, vertex_label)

    Ast.prewalk(context.ast, fn ast ->
      ast_vertex = build_vertex(ast)
      ast_vertex_label = build_vertex_label(module: ast.module, ast: ast)

      {edge_label_1, edge_label_2} = build_edge_label(context, ast)

      Graph.add_vertex(ast_vertex, ast_vertex_label)
      Graph.add_edge({ast_vertex, vertex, edge_label_1}, ast_vertex, vertex, edge_label_1)
      Graph.add_edge({vertex, ast_vertex, edge_label_2}, vertex, ast_vertex, edge_label_2)

      ast
    end)

    :ok
  end

  @doc """
  Prunes graph of non-existent or stale information.

  Intended to be called after either all code is compiled or on hot reloads.
  """
  @spec prune!() :: :ok
  def prune! do
    Graph.vertices()
    |> Enum.each(fn {m, _s, _a} = v ->
      {^v, recorded} = Graph.vertex(v)
      new = build_vertex_label(recorded, module: m)

      # Delete vertex if module is deleted
      if (recorded[:vsn] == nil and new[:vsn] != nil) or recorded[:vsn] == new[:vsn] do
        Graph.add_vertex(v, new)
      else
        Graph.del_vertex(v)
      end
    end)
  end

  @doc """
  Validates the graph.

  Raises `t:#{inspect FullyRecursiveAstError}.t/0`.

  Intended to be called after either all code is compiled or on hot reloads.
  """
  @spec validate!() :: :ok | no_return()
  def validate! do
    Graph.vertices()
    |> Enum.each(fn {m, s, a} = v ->
      unless Apix.Schema.defines_schema?(m, s, a) do
        {^v, label} = Graph.vertex(v)
        raise UndefinedReferenceAstError, label.ast
      end
    end)
  end

  defp build_vertex(%Ast{module: m, schema: s, args: a}), do: {m, s, length(a)}
  defp build_vertex(%Context{module: m, schema: s, params: p}), do: {m, s, length(p)}

  defp build_vertex_label(label \\ %{}, opts) do
    label =
      if opts[:module],
        do: Map.put(label, :vsn, maybe_module_vsn(opts[:module])),
        else: label

    label =
      if opts[:ast],
        do: Map.put(label, :ast, opts[:ast]),
        else: label

    label
  end

  defp build_edge_label(%{ast: ast} = _context, ast), do: {:supertype, :subtype}
  defp build_edge_label(_context, _ast), do: {:referenced, :references}

  # Support erlang modules
  defp maybe_module_vsn(module) do
    if function_exported?(module, :module_info, 1),
      do: :attributes |> module.module_info() |> Keyword.get(:vsn),
      else: nil
  end
end
