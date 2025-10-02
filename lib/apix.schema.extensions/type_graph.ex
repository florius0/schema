defmodule Apix.Schema.Extensions.TypeGraph do
  alias Apix.Schema.Extension

  alias Apix.Schema.Ast
  alias Apix.Schema.Context

  alias Apix.Schema.Extensions.Core.And
  alias Apix.Schema.Extensions.Core.Or

  alias Apix.Schema.Extensions.Core.Any

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

  - `relate it, to, do: [{:relationship, it, to}]` – returns what relationships exist between two type expressions one of which references another, e.g. `schema a: b()`.

     Another syntax variants:

     - `relate it, to when guard, do: [{:relationship, it, to}]` – same as above but with guard clause
     - `relate &Module.function/2` – uses 2-arity remote function capture
     - `relate &function/2` – uses 2-arity local function capture
     - `relate {Module, :function, args}` – uses MFA tuple to reference function. `args` will be appended to `[it, to]` when calling the function.

  - `relationship it, peer, do: [{:relationship, it, peer}]` – returns what relationships exist between two types expressions in general, e.g. is `a()` a subtype of `Any.t()`.

      Another syntax variants:

      - `relationship it, peer when guard, do: [{:relationship, it, peer}]` – same as above but with guard clause
      - `relationship &Module.function/2` – uses 2-arity remote function capture
      - `relationship &function/2` – uses 2-arity local function capture
      - `relationship {Module, :function, args}` – uses MFA tuple to reference function. `args` will be appended to `[it, peer]` when calling the function.

  ## Relationships

  Since `#{inspect Apix.Schema}` is set-theoretic, some relationship types are pre-defined:

  1. `{:subtype, sub, sup}` – `sub` is a subtype of `sup` meaning values valid against `sub` are also valid against `sup` (not necessarily true in reverse).
  2. `{:supertype, sup, sub}` – `sup` is a supertype of `sub` meaning values valid against `sub` are also valid against `sup` (not necessarily true in reverse).
  3. `{:not_subtype, sub, sup}` – `sub` is not a subtype of `sup` meaning values valid against `sub` are not valid against `sup`.
  4. `{:not_supertype, sup, sub}` – `sup` is not a supertype of `sub` meaning values valid against `sub` are not valid against `sup`.
  5. `{:references, from, to}` – `from` references `to` meaning `from` schema uses `to` schema in it's definition.
  6. `{:referenced, to, from}` – `to` is referenced by `from` meaning `to` schema is used in `from` schema definition.

  These relationships are designed to be returned in pairs by custom `relate` and `relationship` clauses and should be considered a dependency of the overall API.

  Users are free to define custom relationship types as they see fit, but should be aware that these custom relationships will not be used by `#{inspect Apix.Schema}` functionality directly.
  ```
  """

  @behaviour Extension

  @impl Extension
  def manifest, do: @manifest

  @impl Extension
  def expression!(_context, {:relate, _, [arg1, {:when, _, [arg2, guard]}, [do: block]]} = _elixir_ast, schema_ast, env, _literal?) do
    function_name = :"__apix_schema_relate_#{:erlang.phash2(block)}__"

    quote do
      def unquote(function_name)(unquote(arg1), unquote(arg2)) when unquote(guard), do: unquote(block)
    end
    |> Code.eval_quoted([], env)

    struct(schema_ast, relates: [{env.module, function_name, []}, schema_ast.relates])
  end

  def expression!(_context, {:relate, _, [arg1, arg2, [do: block]]} = _elixir_ast, schema_ast, env, _literal?) do
    function_name = :"__apix_schema_relate_#{:erlang.phash2(block)}__"

    quote do
      def unquote(function_name)(unquote(arg1), unquote(arg2)), do: unquote(block)
    end
    |> Code.eval_quoted([], env)

    struct(schema_ast, relates: [{env.module, function_name, []}, schema_ast.relates])
  end

  def expression!(_context, {:relate, _, [{:&, _, [{:/, _, [{{:., _, [module, function_name]}, _, []}, 2]}]}]} = _elixir_ast, schema_ast, env, _literal?) do
    {module, _binding} = Code.eval_quoted(module, [], env)

    struct(schema_ast, relates: [{module, function_name, []} | schema_ast.relates])
  end

  def expression!(_context, {:relate, _, [{:&, _, [{:/, _, [{function_name, _, _}, 2]}]}]} = _elixir_ast, schema_ast, env, _literal?) do
    struct(schema_ast, relates: [{env.module, function_name, []} | schema_ast.relates])
  end

  def expression!(_context, {:relate, _, [{:{}, _, [_m, _f, _a] = mfa}]} = _elixir_ast, schema_ast, env, _literal?) do
    {mfa, _binding} = Code.eval_quoted(mfa, [], env)

    struct(schema_ast, relates: [mfa | schema_ast.relates])
  end

  def expression!(_context, {:relationship, _, [arg1, {:when, _, [arg2, guard]}, [do: block]]} = _elixir_ast, schema_ast, env, _literal?) do
    function_name = :"__apix_schema_relationship_#{:erlang.phash2(block)}__"

    quote do
      def unquote(function_name)(unquote(arg1), unquote(arg2)) when unquote(guard), do: unquote(block)
    end
    |> Code.eval_quoted([], env)

    struct(schema_ast, relationships: [{env.module, function_name, []}, schema_ast.relationships])
  end

  def expression!(_context, {:relationship, _, [arg1, arg2, [do: block]]} = _elixir_ast, schema_ast, env, _literal?) do
    function_name = :"__apix_schema_relationship_#{:erlang.phash2(block)}__"

    quote do
      def unquote(function_name)(unquote(arg1), unquote(arg2)), do: unquote(block)
    end
    |> Code.eval_quoted([], env)

    struct(schema_ast, relationships: [{env.module, function_name, []}, schema_ast.relationships])
  end

  def expression!(_context, {:relationship, _, [{:&, _, [{:/, _, [{{:., _, [module, function_name]}, _, []}, 2]}]}]} = _elixir_ast, schema_ast, env, _literal?) do
    {module, _binding} = Code.eval_quoted(module, [], env)

    struct(schema_ast, relationships: [{module, function_name, []} | schema_ast.relationships])
  end

  def expression!(_context, {:relationship, _, [{:&, _, [{:/, _, [{function_name, _, _}, 2]}]}]} = _elixir_ast, schema_ast, env, _literal?) do
    struct(schema_ast, relationships: [{env.module, function_name, []} | schema_ast.relationships])
  end

  def expression!(_context, {:relationship, _, [{:{}, _, [_m, _f, _a] = mfa}]} = _elixir_ast, schema_ast, env, _literal?) do
    {mfa, _binding} = Code.eval_quoted(mfa, [], env)

    struct(schema_ast, relationships: [mfa | schema_ast.relationships])
  end

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
        ast_vertex = context |> Context.normalize_ast!(ast) |> Apix.Schema.hash()
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
      |> Context.normalize_ast!()
      |> Apix.Schema.hash()

    supertype =
      supertype
      |> Apix.Schema.get_schema()
      |> Kernel.||(supertype)
      |> Context.normalize_ast!()
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
      |> Context.normalize_ast!()
      |> Apix.Schema.hash()

    subtype =
      subtype
      |> Apix.Schema.get_schema()
      |> Kernel.||(subtype)
      |> Context.normalize_ast!()
      |> Apix.Schema.hash()

    !!Graph.get_path_by(subtype, supertype, &(&1 == :supertype))
  end

  def build_type_relations!(context_or_ast) do
    context_or_ast
    |> Context.normalize_ast!()
    |> Ast.prewalk({context_or_ast, []}, fn
      ast, {%Ast{module: And, schema: :t, args: [_, _]} = last, relations} ->
        {ast, {last, [{ast, last} | relations]}}

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
      sup_ast =
        case sup do
          %Context{} -> sup.ast
          %Ast{} -> sup
        end

      sub_ast =
        case sub do
          %Context{} -> sub.ast
          %Ast{} -> sub
        end

      sup_context = Apix.Schema.get_schema(sup) || sup
      sub_context = Apix.Schema.get_schema(sub) || sub

      sup_ast_v = Apix.Schema.hash(sup_ast)
      sub_ast_v = Apix.Schema.hash(sub_ast)
      sup_ctx_v = Apix.Schema.hash(sup_context)
      sub_ctx_v = Apix.Schema.hash(sub_context)

      Graph.add_vertex(sup_ast_v, sup_ast)
      Graph.add_vertex(sub_ast_v, sub_ast)
      Graph.add_vertex(sup_ctx_v, sup_context)
      Graph.add_vertex(sub_ctx_v, sub_context)

      Graph.add_edge({sub_ctx_v, sub_ast_v, :subtype}, sub_ctx_v, sub_ast_v, :subtype)
      Graph.add_edge({sub_ast_v, sup_ast_v, :subtype}, sub_ast_v, sup_ast_v, :subtype)
      Graph.add_edge({sup_ast_v, sup_ctx_v, :subtype}, sup_ast_v, sup_ctx_v, :subtype)

      Graph.add_edge({sup_ctx_v, sup_ast_v, :supertype}, sup_ctx_v, sup_ast_v, :supertype)
      Graph.add_edge({sup_ast_v, sub_ast_v, :supertype}, sup_ast_v, sub_ast_v, :supertype)
      Graph.add_edge({sub_ast_v, sub_ctx_v, :supertype}, sub_ast_v, sub_ctx_v, :supertype)
    end)
  end
end
