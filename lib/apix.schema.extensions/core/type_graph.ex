defmodule Apix.Schema.Extensions.Core.TypeGraph do
  alias Apix.Schema.Ast
  alias Apix.Schema.Context

  alias Apix.Schema.Extensions.Core.And
  alias Apix.Schema.Extensions.Core.Or
  alias Apix.Schema.Extensions.Core.Not

  alias Apix.Schema.Extensions.Core.TypeGraph.Graph

  alias Apix.Schema.Extensions.Core.Errors.FullyRecursiveAstError
  alias Apix.Schema.Extensions.Core.Errors.UndefinedReferenceAstError

  @moduledoc """
  High-level interface for working with graph of types information.
  """

  @doc """
  Runs all the `#{inspect __MODULE__}` functions that are intended to be run
  after compilation if compilation is finished to avoid corrupting `#{inspect __MODULE__}` state:application

  - `prune!/0`
  - `validate!/0`
  - `build_type_relations!/0`
  """
  @spec on_compilation!() :: :ok | no_return()
  def on_compilation! do
    unless Code.can_await_module_compilation?() do
      prune!()
      validate!()
      build_type_relations!()
    end

    :ok
  end

  @doc """
  Tracks schema and it's references in the graph.
  """
  @spec track!(Context.t()) :: :ok
  def track!(%Context{} = context) do
    vertex = Apix.Schema.msa(context)
    vertex_label = build_vertex_label(context)

    Graph.add_vertex(vertex, vertex_label)

    Ast.prewalk(context.ast, fn
      %Ast{module: nil} = ast ->
        ast

      ast ->
        # Referenced module can be undefined
        # || {m, s, length(a)}
        ast_vertex = Apix.Schema.msa(ast)
        ast_vertex_label = build_vertex_label(ast)

        Graph.add_vertex(ast_vertex, ast_vertex_label)
        Graph.add_edge({vertex, ast_vertex, :references}, vertex, ast_vertex, :references)
        Graph.add_edge({ast_vertex, vertex, :referenced}, ast_vertex, vertex, :referenced)

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
    |> Enum.map(fn msa ->
      {^msa, context} = Graph.vertex(msa)
      new_context = build_vertex_label(context)

      {context, new_context}
    end)
    |> Enum.each(fn
      # "virtual" context, will handle orphans later
      {%Context{module: nil}, nil} ->
        :ok

      # Context unchanged, do nothing
      {%Context{} = context, %Context{} = context} ->
        :ok

      # Context deleted, delete it
      {%Context{} = context1, nil} ->
        Graph.del_vertex(context1)

      # Context changed, re-track it
      {%Context{} = context1, %Context{} = context2} ->
        Graph.del_vertex(context1)
        track!(context2)
    end)

    # Delete orphaned "virtual" contexts
    # Do it as separate second pass since re-tracking may produce new edges
    Graph.vertices()
    |> Enum.filter(fn msa ->
      {^msa, context} = Graph.vertex(msa)

      virtual? =
        if context,
          do: !!context.flags[:virtual?],
          else: true

      virtual? and Graph.in_degree(msa) + Graph.out_degree(msa) == 0
    end)
    |> Graph.del_vertices()
  end

  @doc """
  Validates the graph.

  Raises `t:#{inspect FullyRecursiveAstError}.t/0`.

  Intended to be called after either all code is compiled or on hot reloads.
  """
  @spec validate!() :: :ok | no_return()
  def validate! do
    Graph.vertices()
    |> Enum.each(fn msa ->
      unless Apix.Schema.get_schema(msa) do
        {^msa, context} = Graph.vertex(msa)
        raise UndefinedReferenceAstError, context.ast
      end
    end)
  end

  @spec build_type_relations!() :: :ok | no_return()
  def build_type_relations! do
    Graph.vertices()
    |> Enum.each(fn msa ->
      {^msa, context} = Graph.vertex(msa)
      build_type_relations!(msa, context)
    end)
  end

  defp build_type_relations!(_msa, %Context{} = context) do
    context.ast
    |> Ast.prewalk(fn ast ->
      # TODO
      ast
    end)
  end

  defp build_vertex_label(%Ast{module: m, schema: s, args: a}), do: Apix.Schema.get_schema(m, s, length(a))
  defp build_vertex_label(%Context{module: m, schema: s, params: p}), do: Apix.Schema.get_schema(m, s, length(p))
end
