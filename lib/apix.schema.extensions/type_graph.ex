defmodule Apix.Schema.Extensions.TypeGraph do
  alias Apix.Schema.Extension

  alias Apix.Schema.Ast
  alias Apix.Schema.Context

  alias Apix.Schema.Extensions.Core.And
  alias Apix.Schema.Extensions.Core.Or
  alias Apix.Schema.Extensions.Core.Not

  alias Apix.Schema.Extensions.Core.Const

  alias Apix.Schema.Extensions.Core.Any
  alias Apix.Schema.Extensions.Core.None

  alias Apix.Schema.Extensions.TypeGraph.Graph

  alias Apix.Schema.Extensions.TypeGraph.Errors.FullyRecursiveAstError
  alias Apix.Schema.Extensions.TypeGraph.Errors.UndefinedReferenceAstError

  @manifest %Extension{
    module: __MODULE__
  }

  @moduledoc """
  Type graph extension for `#{inspect Apix.Schema}`.
  Provides high-level interface for working with graph of types information.

  #{Extension.delegates_doc(@manifest)}

  ## Expressions

  - `relate/2` – returns what relationship exists between two type expressions one of which references another, e.g. `schema a: b()`
      ```elixir
      relate it, to do
        [:relationship]
      end
  ```
  - `relationship` – returns what relationship exists between two types expressions in general, e.g. is `a()` a subtype of `Any.t()`
      ```elixir
      relationship it, peer do
        [:relationship]
      end
  ```
  """

  @behaviour Extension

  @impl Extension
  def manifest, do: @manifest

  @impl Extension
  def expression!(_context, _elixir_ast, _schema_ast, _env, _literal?), do: false

  @impl Extension
  def validate_ast!(context) do
    track!(context)
    on_compilation!()

    context
  end

  @doc """
  Runs all the `#{inspect __MODULE__}` functions that are intended to be run
  after compilation is finished to avoid corrupting `#{inspect __MODULE__}` state.

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
  @spec track!(Context.t() | Ast.t()) :: :ok
  def track!(context_or_ast) when is_struct(context_or_ast, Context) or is_struct(context_or_ast, Ast) do
    context = Apix.Schema.get_schema(context_or_ast)

    vertex = Apix.Schema.hash(context)
    vertex_label = context

    Graph.add_vertex(vertex, vertex_label)

    Ast.prewalk(context.ast, fn
      %Ast{module: nil} = ast ->
        ast

      ast ->
        ast_vertex = ast |> normalize() |> Apix.Schema.hash()
        ast_vertex_label = Apix.Schema.get_schema(ast) || Apix.Schema.msa(ast)

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
    |> Enum.map(fn hash ->
      {^hash, context} = Graph.vertex(hash)
      new_context = Apix.Schema.get_schema(context)

      {hash, context, new_context}
    end)
    |> Enum.each(fn
      # "virtual" context, will handle orphans later
      {_hash, %Context{module: nil}, nil} ->
        :ok

      # Context unchanged, do nothing
      {_hash, context, context} ->
        :ok

      # Context deleted, delete it
      {hash, _context1, nil} ->
        Graph.del_vertex(hash)

      # Context changed, re-track it
      {hash, _context1, context2} ->
        Graph.del_vertex(hash)
        track!(context2)
    end)

    # Delete "virtual" contexts
    # Do it as separate second pass since re-tracking may produce new edges
    Graph.vertices()
    |> Enum.filter(fn hash ->
      {^hash, context} = Graph.vertex(hash)

      if context.module do
        !!context.flags[:virtual?]
      else
        true
      end
    end)
    |> Graph.del_vertices()
  end

  @doc """
  Validates the graph.

  Raises either:
    - `t:#{inspect FullyRecursiveAstError}.t/0`.
    - `t:#{inspect UndefinedReferenceAstError}.t/0`.

  Intended to be called after either all code is compiled or on hot reloads.
  """
  @spec validate!() :: :ok | no_return()
  def validate! do
    Graph.vertices()
    |> Enum.each(fn hash ->
      {^hash, context} = Graph.vertex(hash)

      unless Apix.Schema.get_schema(context) do
        raise UndefinedReferenceAstError, context.ast
      end
    end)
  end

  @doc """
  Builds the sub/super-type relations in the graph.
  """
  @spec build_type_relations!() :: :ok | no_return()
  def build_type_relations! do
    Graph.vertices()
    |> Enum.each(fn hash ->
      {^hash, context} = Graph.vertex(hash)
      build_type_relations!(context)
    end)
  end

  @doc """
  Returns `true` if `subtype` is a subtype of `supertype`.

  - Structurally equal types are subtypes.
  - Known and unknown types are not subtypes.
  - `t:Ast.t/0` and `t:Context.t/0` referencing same schema are subtypes.
  """
  def is_subtype?(_subtype, %Context{module: Any, schema: :t, params: []}), do: true
  def is_subtype?(_subtype, %Ast{module: Any, schema: :t, args: []}), do: true

  def is_subtype?(subtype, supertype) when (is_struct(subtype, Context) or is_struct(subtype, Ast)) and (is_struct(supertype, Context) or is_struct(supertype, Ast)) do
    subtype =
      subtype
      |> Apix.Schema.get_schema()
      |> Kernel.||(subtype)
      |> Apix.Schema.hash()

    supertype =
      supertype
      |> Apix.Schema.get_schema()
      |> Kernel.||(supertype)
      |> Apix.Schema.hash()

    !!Graph.get_path_by(supertype, subtype, &(&1 == :subtype))
  end

  @doc """
  Returns `true` if `supertype` is a subtype of `subtype`.

  - Structurally equal types are supertypes.
  - Known and unknown types are not supertypes.
  - `t:Ast.t/0` and `t:Context.t/0` referencing same schema are supertypes.
  """
  def is_supertype?(%Context{module: Any, schema: :t, params: []}, _subtype), do: true
  def is_supertype?(%Ast{module: Any, schema: :t, args: []}, _subtype), do: true

  def is_supertype?(supertype, subtype) when (is_struct(supertype, Context) or is_struct(supertype, Ast)) and (is_struct(subtype, Context) or is_struct(subtype, Ast)) do
    supertype =
      supertype
      |> Apix.Schema.get_schema()
      |> Kernel.||(supertype)
      |> Apix.Schema.hash()

    subtype =
      subtype
      |> Apix.Schema.get_schema()
      |> Kernel.||(subtype)
      |> Apix.Schema.hash()

    !!Graph.get_path_by(subtype, supertype, &(&1 == :supertype))
  end

  def build_type_relations!(context_or_ast) do
    context_or_ast
    |> case do
      %Context{} = context ->
        context.ast

      %Ast{} = ast ->
        ast
    end
    |> normalize()
    |> Ast.prewalk({context_or_ast, []}, fn
      ast, {%Ast{module: And, schema: :t, args: [_, _]} = last, relations} ->
        {
          ast,
          {last, [{ast, last} | relations]}
        }

      ast, {%Ast{module: Or, schema: :t, args: [_, _]} = last, relations} ->
        {ast, {last, [{last, ast} | relations]}}

      ast, {last, []} ->
        {ast, {ast, [{last, ast}]}}

      ast, acc ->
        {ast, acc}
    end)
    |> elem(1)
    |> elem(1)
    |> Enum.each(fn {sup, sub} ->
      sup =
        case sup do
          %{module: m} when m in [And, Or] ->
            sup

          _ ->
            Apix.Schema.get_schema(sup) || sup
        end

      sub =
        case sub do
          %{module: m} when m in [And, Or] ->
            sub

          _ ->
            Apix.Schema.get_schema(sub) || sub
        end

      sup_vertex = Apix.Schema.hash(sup)
      sub_vertex = Apix.Schema.hash(sub)
      sub_vertex_label = sub

      Graph.add_vertex(sub_vertex, sub_vertex_label)
      Graph.add_edge({sub_vertex, sup_vertex, :subtype}, sub_vertex, sup_vertex, :subtype)
      Graph.add_edge({sup_vertex, sub_vertex, :supertype}, sup_vertex, sub_vertex, :supertype)
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

  defp normalize_not(%Ast{module: Not, schema: :t, args: [%Ast{module: Any, schema: :t, args: []} = ast]}), do: struct(ast, module: None, schema: :t, args: [])
  defp normalize_not(%Ast{module: Not, schema: :t, args: [%Ast{module: None, schema: :t, args: []} = ast]}), do: struct(ast, module: Any, schema: :t, args: [])

  defp normalize_not(%Ast{module: Not, schema: :t, args: [%Ast{module: And, schema: :t, args: args}]} = ast) do
    args =
      args
      |> Enum.sort_by(&Apix.Schema.msa/1)
      |> Enum.map(&struct(ast, module: Not, schema: :t, args: [&1]))

    struct(ast, module: Or, schema: :t, args: args)
  end

  defp normalize_not(%Ast{module: Not, schema: :t, args: [arg]} = ast) do
    reject =
      arg
      |> Ast.postwalk([], fn
        %Ast{module: Or, schema: :t, args: args} = ast, acc ->
          msa =
            args
            |> Enum.map(&Apix.Schema.msa/1)
            |> Enum.reject(&(&1 == {Or, :t, 2}))

          {ast, msa ++ acc}

        ast, acc ->
          {ast, acc}
      end)
      |> elem(1)
      |> Kernel.++([
        {And, :t, 2},
        {Or, :t, 2},
        {Not, :t, 1},
        {Const, :t, 1},
        {Any, :t, 0},
        {None, :t, 0}
      ])

    Graph.vertices()
    |> Enum.map(fn hash ->
      hash
      |> Graph.vertex()
      |> elem(1)
    end)
    |> Enum.reject(&(Apix.Schema.msa(&1) in reject))
    |> Enum.sort_by(&Apix.Schema.msa/1)
    |> Enum.uniq()
    |> case do
      [] ->
        struct(ast, module: None, schema: :t, args: [])

      [context] ->
        context.ast

      [first | rest] ->
        Enum.reduce(rest, %Ast{module: first.module, schema: first.schema, args: Enum.map(first.params, fn _ -> false end)}, fn current, acc ->
          struct(ast, module: Or, schema: :t, args: [%Ast{module: current.module, schema: current.schema, args: Enum.map(current.params, fn _ -> false end)}, acc])
        end)
    end
  end

  defp normalize_not(ast), do: ast

  defp normalize_double_not(%Ast{module: Not, schema: :t, args: [%Ast{module: Not, schema: :t, args: [ast]}]}), do: ast

  defp normalize_double_not(ast), do: ast

  defp normalize_identity(%Ast{module: And, schema: :t, args: [ast, %Ast{module: Any, schema: :t, args: []}]}), do: ast
  defp normalize_identity(%Ast{module: And, schema: :t, args: [%Ast{module: Any, schema: :t, args: []}, ast]}), do: ast

  defp normalize_identity(%Ast{module: And, schema: :t, args: [ast, %Ast{module: None, schema: :t, args: []}]}), do: struct(ast, module: None, schema: :t, args: [])
  defp normalize_identity(%Ast{module: And, schema: :t, args: [%Ast{module: None, schema: :t, args: []}, ast]}), do: struct(ast, module: None, schema: :t, args: [])

  defp normalize_identity(%Ast{module: Or, schema: :t, args: [ast, %Ast{module: None, schema: :t, args: []}]}), do: ast
  defp normalize_identity(%Ast{module: Or, schema: :t, args: [%Ast{module: None, schema: :t, args: []}, ast]}), do: ast

  defp normalize_identity(%Ast{module: Or, schema: :t, args: [ast, %Ast{module: Any, schema: :t, args: []}]}), do: struct(ast, module: Any, schema: :t, args: [])
  defp normalize_identity(%Ast{module: Or, schema: :t, args: [%Ast{module: Any, schema: :t, args: []}, ast]}), do: struct(ast, module: Any, schema: :t, args: [])

  defp normalize_identity(ast), do: ast

  defp normalize_absorption(%Ast{module: And, schema: :t, args: [ast1, %Ast{module: Or, schema: :t, args: [ast2, ast3]}]} = ast) do
    if Ast.equals?(ast1, ast2) or Ast.equals?(ast1, ast3) do
      ast1
    else
      ast
    end
  end

  defp normalize_absorption(%Ast{module: And, schema: :t, args: [%Ast{module: Or, schema: :t, args: [ast2, ast3]}, ast1]} = ast) do
    if Ast.equals?(ast1, ast2) or Ast.equals?(ast1, ast3) do
      ast1
    else
      ast
    end
  end

  defp normalize_absorption(%Ast{module: Or, schema: :t, args: [ast1, %Ast{module: And, schema: :t, args: [ast2, ast3]}]} = ast) do
    if Ast.equals?(ast1, ast2) or Ast.equals?(ast1, ast3) do
      ast1
    else
      ast
    end
  end

  defp normalize_absorption(%Ast{module: Or, schema: :t, args: [%Ast{module: And, schema: :t, args: [ast2, ast3]}, ast1]} = ast) do
    if Ast.equals?(ast1, ast2) or Ast.equals?(ast1, ast3) do
      ast1
    else
      ast
    end
  end

  defp normalize_absorption(ast), do: ast

  defp normalize_idempotence(%Ast{module: And, schema: :t, args: [ast1, ast2]} = ast) do
    if Ast.equals?(ast1, ast2) do
      ast1
    else
      ast
    end
  end

  defp normalize_idempotence(%Ast{module: Or, schema: :t, args: [ast1, ast2]} = ast) do
    if Ast.equals?(ast1, ast2) do
      ast1
    else
      ast
    end
  end

  defp normalize_idempotence(ast), do: ast

  defp normalize_compact(%Ast{module: Or, schema: :t, args: [%Ast{module: And, schema: :t, args: [ast1, ast2]}, %Ast{module: And, schema: :t, args: [ast3, ast4]} = inner_ast]} = ast) do
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

  defp normalize_compact(ast), do: ast
end
