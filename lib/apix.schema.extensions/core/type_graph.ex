defmodule Apix.Schema.Extensions.Core.TypeGraph do
  alias Apix.Schema.Ast
  alias Apix.Schema.Context

  alias Apix.Schema.Extensions.Core.And
  alias Apix.Schema.Extensions.Core.Or
  alias Apix.Schema.Extensions.Core.Not

  alias Apix.Schema.Extensions.Core.Const

  alias Apix.Schema.Extensions.Core.Any
  alias Apix.Schema.Extensions.Core.None

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

  def normalize(ast) do
    ast
    |> Ast.postwalk(&normalize_not/1)
    |> Ast.postwalk(&normalize_double_not/1)
    |> Ast.postwalk(&normalize_identity/1)
    |> Ast.postwalk(&normalize_absorption/1)
    |> Ast.postwalk(&normalize_idempotence/1)
    |> Ast.postwalk(&normalize_compact/1)
  end

  def normalize_not(%Ast{module: Not, schema: :t, args: [%Ast{module: Any, schema: :t, args: []} = ast]}), do: struct(ast, module: None, schema: :t, args: [])
  def normalize_not(%Ast{module: Not, schema: :t, args: [%Ast{module: None, schema: :t, args: []} = ast]}), do: struct(ast, module: Any, schema: :t, args: [])

  def normalize_not(%Ast{module: Not, schema: :t, args: [%Ast{module: And, schema: :t, args: args}]} = ast) do
    args
    |> Enum.sort_by(&Apix.Schema.msa/1)
    |> Enum.map(&struct(ast, module: Not, schema: :t, args: [&1]))

    struct(ast, module: Or, schema: :t, args: args)
  end

  def normalize_not(%Ast{module: Not, schema: :t, args: [%Ast{module: Or, schema: :t, args: args}]} = ast) do
    args
    |> Enum.sort_by(&Apix.Schema.msa/1)
    |> Enum.map(&struct(ast, module: Not, schema: :t, args: [&1]))

    struct(ast, module: And, schema: :t, args: args)
  end

  def normalize_not(%Ast{module: Not, schema: :t, args: [arg]} = ast) do
    msa = Apix.Schema.msa(arg)

    Graph.vertices()
    |> Enum.filter(&(&1 not in [msa, {And, :t, 2}, {Or, :t, 2}, {Not, :t, 1}, {Const, :t, 1}, {Any, :t, 0}, {None, :t, 0}]))
    |> Enum.sort()
    |> IO.inspect()
    |> Enum.map(fn msa ->
      msa
      |> Graph.vertex()
      |> elem(1)
    end)
    |> case do
      [] ->
        struct(ast, module: None, schema: :t, args: [])

      [ast] ->
        ast

      [first | rest] ->
        Enum.reduce(rest, first, fn current, acc ->
          struct(ast, module: And, schema: :t, args: [current, acc])
        end)
    end
  end

  def normalize_not(ast), do: ast

  def normalize_double_not(%Ast{module: Not, schema: :t, args: [%Ast{module: Not, schema: :t, args: [ast]}]}), do: ast

  def normalize_double_not(ast), do: ast

  def normalize_identity(%Ast{module: And, schema: :t, args: [ast, %Ast{module: Any, schema: :t, args: []}]}), do: ast
  def normalize_identity(%Ast{module: And, schema: :t, args: [%Ast{module: Any, schema: :t, args: []}, ast]}), do: ast

  def normalize_identity(%Ast{module: And, schema: :t, args: [ast, %Ast{module: None, schema: :t, args: []}]}), do: struct(ast, module: None, schema: :t, args: [])
  def normalize_identity(%Ast{module: And, schema: :t, args: [%Ast{module: None, schema: :t, args: []}, ast]}), do: struct(ast, module: None, schema: :t, args: [])

  def normalize_identity(%Ast{module: Or, schema: :t, args: [ast, %Ast{module: None, schema: :t, args: []}]}), do: ast
  def normalize_identity(%Ast{module: Or, schema: :t, args: [%Ast{module: None, schema: :t, args: []}, ast]}), do: ast

  def normalize_identity(%Ast{module: Or, schema: :t, args: [ast, %Ast{module: Any, schema: :t, args: []}]}), do: struct(ast, module: Any, schema: :t, args: [])
  def normalize_identity(%Ast{module: Or, schema: :t, args: [%Ast{module: Any, schema: :t, args: []}, ast]}), do: struct(ast, module: Any, schema: :t, args: [])

  def normalize_identity(ast), do: ast

  def normalize_absorption(%Ast{module: And, schema: :t, args: [ast1, %Ast{module: Or, schema: :t, args: [ast2, ast3]}]} = ast) do
    if Ast.equals?(ast1, ast2) or Ast.equals?(ast1, ast3) do
      ast1
    else
      ast
    end
  end

  def normalize_absorption(%Ast{module: And, schema: :t, args: [%Ast{module: Or, schema: :t, args: [ast2, ast3]}, ast1]} = ast) do
    if Ast.equals?(ast1, ast2) or Ast.equals?(ast1, ast3) do
      ast1
    else
      ast
    end
  end

  def normalize_absorption(%Ast{module: Or, schema: :t, args: [ast1, %Ast{module: And, schema: :t, args: [ast2, ast3]}]} = ast) do
    if Ast.equals?(ast1, ast2) or Ast.equals?(ast1, ast3) do
      ast1
    else
      ast
    end
  end

  def normalize_absorption(%Ast{module: Or, schema: :t, args: [%Ast{module: And, schema: :t, args: [ast2, ast3]}, ast1]} = ast) do
    if Ast.equals?(ast1, ast2) or Ast.equals?(ast1, ast3) do
      ast1
    else
      ast
    end
  end

  def normalize_absorption(ast), do: ast

  def normalize_idempotence(%Ast{module: And, schema: :t, args: [ast1, ast2]} = ast) do
    if Ast.equals?(ast1, ast2) do
      ast1
    else
      ast
    end
  end

  def normalize_idempotence(%Ast{module: Or, schema: :t, args: [ast1, ast2]} = ast) do
    if Ast.equals?(ast1, ast2) do
      ast1
    else
      ast
    end
  end

  def normalize_idempotence(ast), do: ast

  def normalize_compact(%Ast{module: Or, schema: :t, args: [%Ast{module: And, schema: :t, args: [ast1, ast2]}, %Ast{module: And, schema: :t, args: [ast3, ast4]} = inner_ast]} = ast) do
    cond do
      Ast.equals?(ast1, ast3) ->
        struct(ast, module: And, schema: :t, args: [ast1, struct(inner_ast, module: Or, schema: :t, args: [ast2, ast4])])

      Ast.equals?(ast1, ast4) ->
        struct(ast, module: And, schema: :t, args: [ast1, struct(inner_ast, module: Or, schema: :t, args: [ast2, ast3])])

      Ast.equals?(ast2, ast3) ->
        struct(ast, module: And, schema: :t, args: [ast2, struct(inner_ast, module: Or, schema: :t, args: [ast1, ast4])])

      Ast.equals?(ast2, ast4) ->
        struct(ast, module: And, schema: :t, args: [ast2, struct(inner_ast, module: Or, schema: :t, args: [ast1, ast3])])

      true ->
        ast
    end
  end

  def normalize_compact(ast), do: ast

  defp build_vertex_label(%Ast{module: m, schema: s, args: a}), do: Apix.Schema.get_schema(m, s, length(a))
  defp build_vertex_label(%Context{module: m, schema: s, params: p}), do: Apix.Schema.get_schema(m, s, length(p))
end
