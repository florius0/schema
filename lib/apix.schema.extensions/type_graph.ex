defmodule Apix.Schema.Extensions.TypeGraph do
  alias Apix.Schema.Extension

  alias Apix.Schema.Ast
  alias Apix.Schema.Context

  alias Apix.Schema.Warning

  alias Apix.Schema.Extensions.TypeGraph.Graph

  alias Apix.Schema.Extensions.TypeGraph.Errors.FullyRecursiveAstError
  alias Apix.Schema.Extensions.TypeGraph.Errors.UndefinedReferenceAstError

  alias Apix.Schema.Extensions.TypeGraph.Warnings.ReducibleAstWarning

  @manifest %Extension{
    module: __MODULE__
  }

  @type relation() ::
          :subtype
          | :supertype
          | :not_subtype
          | :not_supertype
          | :references
          | :referenced
          | atom()

  @moduledoc """
  Type graph extension for `#{inspect Apix.Schema}`.
  Provides high-level interface for working with graph of types information.

  ## Relationships

  Since `#{inspect Apix.Schema}` is set-theoretic, some relationship types are pre-defined:

  1. `{:subtype, sub, sup}` – `sub` is a subtype of `sup` meaning values valid against `sub` are also valid against `sup` (not necessarily true in reverse).
  2. `{:supertype, sup, sub}` – `sup` is a supertype of `sub` meaning values valid against `sub` are also valid against `sup` (not necessarily true in reverse).
  3. `{:not_subtype, sub, sup}` – `sub` is not a subtype of `sup` meaning values valid against `sub` are not valid against `sup`.
  4. `{:not_supertype, sup, sub}` – `sup` is not a supertype of `sub` meaning values valid against `sub` are not valid against `sup`.
  5. `{:references, from, to}` – `from` references `to` meaning `from` schema uses `to` schema in it's definition.
  6. `{:referenced, to, from}` – `to` is referenced by `from` meaning `to` schema is used in `from` schema definition.

  These relationships are designed to be returned in pairs by custom `relate` and `relationship` clauses and should be considered a dependency of the overall API.

  Note that references/referenced relationships are managed automatically by the extension and do not need to be defined manually, though it is technically possible to do so.

  Users are free to define custom relationship types as they see fit, but should be aware that these custom relationships will not be used by `#{inspect Apix.Schema}` functionality directly.

  ## Custom Relationships

  This extension allows to define custom relationships between types using `relate/3` and `relationship/3` expressions.

  By default, subtypes/supertypes are inferred automatically based on the structure of the types – `schema a: b()` means `a` is a subtype of `b`, since the semantics of the schema definition implies that all values valid against `a` must also be valid against `b`.
  However, in some cases the structural inference may not be correct, for example when dealing with complex types or when the relationship is not strictly hierarchical, for example `schema a: b() or c()`.

  In such cases, users can define custom relationships using `relate/2` and `relationship/3` expressions.

  #{Extension.delegates_doc(@manifest)}

  ## Expressions

  - `relate it, to, do: [{:relationship, it, to}]` – returns what relationships exist between two type expressions one of which references another, e.g. `schema a: b()`.

     Another syntax variants:

     - `relate it, to when guard, do: [{:relationship, it, to}]` – same as above but with guard clause
     - `relate &Module.function/2` – uses 2-arity remote function capture
     - `relate &function/2` – uses 2-arity local function capture
     - `relate {Module, :function, args}` – uses MFA tuple to reference function. `args` will be appended to `[it, to]` when calling the function.

  - `relationship it, peer, existing, do: [{:relationship, it, peer}]` – returns what relationships exist between two types expressions in general, e.g. is `a()` a subtype of `Any.t()`.

      Another syntax variants:

      - `relationship it, peer, existing when guard, do: [{:relationship, it, peer}]` – same as above but with guard clause
      - `relationship &Module.function/3` – uses 3-arity remote function capture
      - `relationship &function/3` – uses 3-arity local function capture
      - `relationship {Module, :function, args}` – uses MFA tuple to reference function. `args` will be appended to `[it, peer, existing]` when calling the function.

  ## Flags

  This extension uses the following flags:

  - `:recursion` – to determine recursion evaluation strategy:
    - `:all` (default)  means that `#{inspect Context}.t/0`/`#{inspect Ast}.t/0` must reference only other recursive definitions to be considered recursive.

       Intended to be used for scalar types or container types with single type parameter semantics, such as `#{inspect Apix.Schema.Extensions.Elixir.MapSet}.t/0`

    - `:at_least_one` means that `#{inspect Context}.t/0`/`#{inspect Ast}.t/0` must reference at least one other recursive definition to be considered recursive.

       Intended to be used for container types with multiple fields type parameters semantics, such as `#{inspect Apix.Schema.Extensions.Elixir.Map}.t/0`
  """

  @behaviour Extension

  @doc """
  Returns `true` if `subtype` is a subtype of `supertype`.

  - Structurally equal types are subtypes.
  - Known and unknown types are not subtypes.
  - `t:#{inspect Ast}.t/0` and `t:#{inspect Context}.t/0` referencing same schema are subtypes.
  """
  defmacro subtype?(subtype, supertype) do
    quote do
      binding = binding()

      context =
        __ENV__.module
        |> Context.get_or_default()
        |> struct(
          binding: binding(),
          env: Code.env_for_eval(__ENV__)
        )

      subtype = Context.inner_expression!(context, [unquote(Macro.escape(subtype))], %Ast{})
      supertype = Context.inner_expression!(context, [unquote(Macro.escape(supertype))], %Ast{})

      unquote(__MODULE__).check_subtype?(subtype, supertype)
    end
  end

  @doc """
  Returns `true` if `subtype` is a subtype of `supertype`.

  - Structurally equal types are subtypes.
  - Known and unknown types are not subtypes.
  - `t:#{inspect Ast}.t/0` and `t:#{inspect Context}.t/0` referencing same schema are subtypes.
  """
  @spec check_subtype?(Context.t() | Ast.t(), Context.t() | Ast.t()) :: boolean()
  def check_subtype?(subtype, supertype) do
    subtype = to_vertex(subtype)
    supertype = to_vertex(supertype)

    subtype == supertype or !!Graph.get_path_by(supertype, subtype, &(&1 == :subtype))
  end

  @doc """
  Returns `true` if `supertype` is a subtype of `subtype`.

  - Structurally equal types are supertypes.
  - Known and unknown types are not supertypes.
  - `t:#{inspect Ast}.t/0` and `t:#{inspect Context}.t/0` referencing same schema are supertypes.
  """
  defmacro supertype?(subtype, supertype) do
    quote do
      binding = binding()

      context =
        __ENV__.module
        |> Context.get_or_default()
        |> struct(
          binding: binding(),
          env: Code.env_for_eval(__ENV__)
        )

      subtype = Context.inner_expression!(context, [unquote(Macro.escape(subtype))], %Ast{})
      supertype = Context.inner_expression!(context, [unquote(Macro.escape(supertype))], %Ast{})

      unquote(__MODULE__).check_supertype?(subtype, supertype)
    end
  end

  @doc """
  Returns `true` if `supertype` is a subtype of `subtype`.

  - Structurally equal types are supertypes.
  - Known and unknown types are not supertypes.
  - `t:#{inspect Ast}.t/0` and `t:#{inspect Context}.t/0` referencing same schema are supertypes.
  """
  @spec check_supertype?(Context.t() | Ast.t(), Context.t() | Ast.t()) :: boolean()
  def check_supertype?(supertype, subtype) do
    supertype = to_vertex(supertype)
    subtype = to_vertex(subtype)

    supertype == subtype or !!Graph.get_path_by(supertype, subtype, &(&1 == :supertype))
  end

  @doc """
  Returns `true` if path matching the `predicate` exists between `from` and `to` vertices in the graph.

  Note that this function knows nothing about the semantics of the graph, it just finds a path matching the `predicate`.
  """
  defmacro path_exists?(from, to, predicate) do
    quote do
      binding = binding()

      context =
        __ENV__.module
        |> Context.get_or_default()
        |> struct(
          binding: binding(),
          env: Code.env_for_eval(__ENV__)
        )

      from = Context.inner_expression!(context, [unquote(Macro.escape(from))], %Ast{})
      to = Context.inner_expression!(context, [unquote(Macro.escape(to))], %Ast{})

      unquote(__MODULE__).check_path_exists?(from, to, unquote(predicate))
    end
  end

  @doc """
  Returns `true` if path matching the `predicate` exists between `from` and `to` vertices in the graph.

  Note that this function knows nothing about the semantics of the graph, it just finds a path matching the `predicate`.
  """
  @spec check_path_exists?(Context.t() | Ast.t(), Context.t() | Ast.t(), (relation() -> as_boolean(any()))) :: boolean()
  def check_path_exists?(from, to, predicate) do
    from = to_vertex(from)
    to = to_vertex(to)

    !!Graph.get_path_by(from, to, predicate)
  end

  @doc group: "Internal"
  @doc """
  Calls the `relate/2` function to determine relationships between two types.

  Returns a list of relationships in the form of tuples `{:relationship, from, to}`.
  By default, if no custom `relate/2` clauses are defined, it will return the basic relationships:

  - `{:subtype, it, to}` – `it` is a subtype of `to` which is implied by `schema it: to()` semantics – for data to be valid relative to `it`, it also needs to be valid relative to `to`.
  - `{:supertype, to, it}` – `to` is a supertype of `it` which is implied by `schema it: to()` semantics – for data to be valid relative to `it`, it also needs to be valid relative to `to`.
  - `{:subtype, it, it}` – `it` is a subtype of itself which is always true.
  - `{:supertype, it, it}` – `it` is a supertype of itself which is always true.
  """
  @spec relate(Context.t() | Ast.t(), Context.t() | Ast.t()) :: [{atom(), Context.t() | Ast.t(), Context.t() | Ast.t()}]
  def relate(it, to) do
    cond do
      is_struct(it, Context) && length(it.ast.relates) > 0 ->
        it.ast.relates

      is_struct(it, Ast) && length(it.relates) > 0 ->
        it.relates

      (
        context = Apix.Schema.get_schema(it)
        context && length(context.ast.relates) > 0
      ) ->
        context.ast.relates

      true ->
        [{__MODULE__, :default_relate, []}]
    end
    |> Enum.flat_map(fn {m, f, a} ->
      try do
        apply(m, f, [it, to | a])
      rescue
        FunctionClauseError ->
          []
      end
    end)
    |> Enum.filter(&filter_empty/1)
  end

  @doc false
  def default_relate(it, to) do
    [
      {:subtype, it, to},
      {:supertype, to, it},
      {:subtype, it, it},
      {:supertype, it, it}
    ]
  end

  @doc group: "Internal"
  @doc """
  Calls the `relationship/3` function to determine relationships between two types in general.

  Returns a list of relationships in the form of tuples `{:relationship, it, peer}`.
  By default, if no custom `relationship/3` clauses are defined, it will return the existing relationships unchanged.
  """
  @spec relationship(Context.t() | Ast.t(), Context.t() | Ast.t(), [{atom(), Context.t() | Ast.t(), Context.t() | Ast.t()}]) :: [{atom(), Context.t() | Ast.t(), Context.t() | Ast.t()}]
  def relationship(it, peer, existing) do
    cond do
      is_struct(it, Context) && length(it.ast.relationships) > 0 ->
        it.ast.relationships

      is_struct(it, Ast) && length(it.relationships) > 0 ->
        it.relationships

      (
        context = Apix.Schema.get_schema(it)
        context && length(context.ast.relationships) > 0
      ) ->
        context.ast.relationships

      true ->
        [{__MODULE__, :default_relationship, []}]
    end
    |> Enum.flat_map(fn {m, f, a} ->
      try do
        apply(m, f, [it, peer, existing | a])
      rescue
        FunctionClauseError ->
          existing
      end
    end)
    |> Enum.filter(&filter_empty/1)
  end

  @doc false
  def default_relationship(_it, _peer, existing), do: existing

  defp filter_empty({_type, nil = _left, _right} = _relation), do: false
  defp filter_empty({_type, _left, nil = _right} = _relation), do: false
  defp filter_empty({_type, %Ast{module: nil, schema: nil, args: []} = _left, _right} = _relation), do: false
  defp filter_empty({_type, %Context{module: nil, schema: nil, params: []} = _left, _right} = _relation), do: false
  defp filter_empty({_type, _left, %Ast{module: nil, schema: nil, args: []} = _right} = _relation), do: false
  defp filter_empty({_type, _left, %Context{module: nil, schema: nil, params: []} = _right} = _relation), do: false
  defp filter_empty(_relation), do: true

  @doc group: "Internal"
  @doc """
  Converts `t:#{inspect Context}.t/0` or `t:#{inspect Ast}.t/0` to `:digraph.vertex()`.
  """
  @spec to_vertex(Context.t() | Ast.t()) :: :digraph.vertex()
  def to_vertex(context_or_ast) when is_struct(context_or_ast, Context) or is_struct(context_or_ast, Ast) do
    context_or_ast
    |> case do
      %Context{} = context ->
        ast = Context.normalize_ast!(context)
        struct(context, ast: ast)

      %Ast{} = ast ->
        Context.normalize_ast!(ast)
    end
    |> Apix.Schema.hash()
  end

  @doc group: "Internal"
  @doc """
  Tracks schema and it's references in the graph.
  """
  @spec track!(Context.t() | Ast.t()) :: :ok
  def track!(context_or_ast) when is_struct(context_or_ast, Context) or is_struct(context_or_ast, Ast) do
    context = Apix.Schema.get_schema(context_or_ast)

    context.ast
    |> Ast.traverse(
      {
        [context],
        [
          {:references, context, context.ast},
          {:referenced, context, context.ast}
        ]
      },
      fn
        ast, {[parent | _rest] = stack, acc} ->
          context = Apix.Schema.get_schema(ast)

          references = [
            {:references, parent, ast},
            {:referenced, ast, parent},
            {:references, ast, context},
            {:referenced, context, ast}
          ]

          {ast, {[ast | stack], references ++ acc}}
      end,
      fn
        ast, {[ast | stack], acc} -> {ast, {stack, acc}}
        ast, {stack, acc} -> {ast, {stack, acc}}
      end
    )
    |> elem(1)
    |> elem(1)
    |> Enum.filter(&filter_empty/1)
    |> add_relations()
  end

  @doc group: "Internal"
  @doc """
  Prunes graph of non-existent of stale `#{inspect Context}.t/0`.

  Intended to be called after either all code is compiled or on hot reloads before `validate!/0`.
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
      # Unchanged, do nothing
      {_hash, context_or_ast, context_or_ast} ->
        :ok

      # Context changed, re-track it
      {hash, %Context{} = _context1, %Context{} = context2} ->
        Graph.del_vertex(hash)
        track!(context2)

      # Context deleted or missing, delete it
      {hash, %Context{} = _context1, nil} ->
        Graph.del_vertex(hash)

      # Otherwise do nothing
      {_hash, _context_or_ast1, _context_or_ast2} ->
        :ok
    end)
  end

  @doc group: "Internal"
  @doc """
  Prunes graph of non-existent of all stale information.

  Intended to be called after either all code is compiled or on hot reloads after `validate!/0`.
  """
  @spec prune_all!() :: :ok
  def prune_all! do
    Graph.vertices()
    |> Enum.map(fn hash ->
      {^hash, context} = Graph.vertex(hash)
      new_context = Apix.Schema.get_schema(context)

      {hash, context, new_context}
    end)
    |> Enum.each(fn
      # Unchanged, do nothing
      {_hash, context_or_ast, context_or_ast} ->
        :ok

      # Context or Ast deleted or missing, delete it
      {hash, _context_or_ast1, nil} ->
        Graph.del_vertex(hash)

      # Otherwise do nothing
      {_hash, _context_or_ast_1, _context_or_ast_2} ->
        :ok
    end)
  end

  @doc group: "Internal"
  @doc """
  Validates the graph.

  Raises either:
    - `t:#{inspect FullyRecursiveAstError}.t/0`.
    - `t:#{inspect UndefinedReferenceAstError}.t/0`.

  Intended to be called after either all code is compiled or on hot reloads.
  """
  @spec validate!() :: :ok | no_return()
  def validate! do
    validate_undefined_reference!()
    validate_fully_recursive!()
  end

  defp validate_undefined_reference! do
    Graph.vertices()
    |> Enum.each(fn hash ->
      {^hash, context_or_ast} = Graph.vertex(hash)

      unless match?(%Ast{parameter?: true}, context_or_ast) or Apix.Schema.get_schema(context_or_ast) do
        raise UndefinedReferenceAstError, context_or_ast
      end
    end)
  end

  defp validate_fully_recursive! do
    Graph.cyclic_strong_components_by(&(&1 == :references))
    |> Enum.each(fn [hash | _] = component ->
      component
      |> Enum.all?(fn hash ->
        {^hash, context_or_ast} = Graph.vertex(hash)

        referenced =
          hash
          |> Graph.out_edges()
          |> Enum.filter(&match?({_from, _to, :references}, &1))
          |> Enum.map(&elem(&1, 1))

        Apix.Schema.get_schema(context_or_ast).flags[:recursion]
        |> get_in()
        |> Kernel.||(:all)
        |> case do
          :all ->
            referenced -- component == []

          :at_least_one ->
            referenced -- component != referenced
        end
      end)
      |> if do
        {^hash, context_or_ast} = Graph.vertex(hash)

        raise FullyRecursiveAstError, context_or_ast
      end
    end)
  end

  defp validate_reducible!(context) do
    ast = context.ast
    reduced_ast = Context.normalize_ast!(context)

    unless Ast.equals?(ast, reduced_ast) do
      [ast: ast, reduced_ast: reduced_ast]
      |> ReducibleAstWarning.exception()
      |> Warning.print()
    end
  end

  @doc group: "Internal"
  @doc """
  Builds the sub/super-type relations in the graph.
  """
  @spec build_type_relations!() :: :ok | no_return()
  def build_type_relations! do
    Graph.vertices()
    |> Enum.each(fn hash ->
      {^hash, context} = Graph.vertex(hash)
      build_type_relates!(context)
    end)

    Graph.vertices()
    |> Enum.each(fn hash ->
      {^hash, context} = Graph.vertex(hash)

      peers =
        Graph.vertices()
        |> Kernel.--(Graph.in_neighbours(hash))
        |> Kernel.--(Graph.out_neighbours(hash))
        |> Enum.map(fn hash ->
          {^hash, context} = Graph.vertex(hash)
          context
        end)

      existing =
        hash
        |> Graph.in_edges()
        |> Kernel.++(Graph.out_edges(hash))
        |> Enum.map(fn {lv, rv, kind} ->
          {^lv, left} = Graph.vertex(lv)
          {^rv, right} = Graph.vertex(rv)

          {kind, left, right}
        end)

      build_type_relationships!(context, peers, existing)
    end)
  end

  @doc group: "Internal"
  @doc """
  Builds the sub/super-type relates in the graph for given `t:#{inspect Context}.t/0` or `t:#{inspect Ast}.t/0`.
  """
  def build_type_relates!(context_or_ast) do
    context_or_ast
    |> Context.normalize_ast!()
    |> Ast.traverse(
      {
        [context_or_ast],
        relate(context_or_ast, context_or_ast)
      },
      fn
        ast, {[parent | _rest] = stack, acc} ->
          context = Apix.Schema.get_schema(ast)

          relate1 = relate(parent, ast)

          relate2 =
            if context,
              do: relate(ast, context),
              else: []

          {ast, {[ast | stack], relate1 ++ relate2 ++ acc}}
      end,
      fn
        ast, {[ast | stack], acc} -> {ast, {stack, acc}}
        ast, {stack, acc} -> {ast, {stack, acc}}
      end
    )
    |> elem(1)
    |> elem(1)
    |> add_relations()
  end

  @doc group: "Internal"
  @doc """
  Builds the sub/super-type relationships in the graph for given `t:#{inspect Context}.t/0` or `t:#{inspect Ast}.t/0`.
  """
  def build_type_relationships!(context_or_ast, peers, existing) do
    new = Enum.reduce(peers, existing, &relationship(context_or_ast, &1, &2))

    add_relations(new -- existing)
    delete_relations(existing -- new)
  end

  defp add_relations(relations) do
    Enum.each(relations, fn {kind, left, right} ->
      lv = Apix.Schema.hash(left)
      rv = Apix.Schema.hash(right)

      Graph.add_vertex(lv, left)
      Graph.add_vertex(rv, right)
      Graph.add_edge({lv, rv, kind}, lv, rv, kind)
    end)
  end

  defp delete_relations(relations) do
    Enum.each(relations, fn {kind, left, right} ->
      lv = Apix.Schema.hash(left)
      rv = Apix.Schema.hash(right)

      Graph.del_edge({lv, rv, kind})
    end)
  end

  @impl Extension
  def manifest, do: @manifest

  @impl Extension
  def require! do
    quote do
      import unquote(__MODULE__), only: [path_exists?: 3, subtype?: 2, supertype?: 2]
    end
  end

  @impl Extension
  def expression!(context, {:relate, _, [arg1, {:when, _, [arg2, guard]}, [do: block]]} = _elixir_ast, schema_ast, _literal?) do
    quote do
      def __apix_schema_relate__(unquote(arg1), unquote(arg2)) when unquote(guard), do: unquote(block)
    end
    |> Context.eval_quoted(context)

    struct(schema_ast, relates: Enum.uniq([{context.env.module, :__apix_schema_relate__, []} | schema_ast.relates]))
  end

  def expression!(context, {:relate, _, [arg1, arg2, [do: block]]} = _elixir_ast, schema_ast, _literal?) do
    quote do
      def __apix_schema_relate__(unquote(arg1), unquote(arg2)), do: unquote(block)
    end
    |> Context.eval_quoted(context)

    struct(schema_ast, relates: Enum.uniq([{context.env.module, :__apix_schema_relate__, []} | schema_ast.relates]))
  end

  def expression!(context, {:relate, _, [{:&, _, [{:/, _, [{{:., _, [module, function]}, _, []}, 2]}]}]} = _elixir_ast, schema_ast, _literal?) do
    {module, _binding} = Context.eval_quoted(module, context)

    struct(schema_ast, relates: [{module, function, []} | schema_ast.relates])
  end

  def expression!(context, {:relate, _, [{:&, _, [{:/, _, [{function, _, _}, 2]}]}]} = _elixir_ast, schema_ast, _literal?) do
    struct(schema_ast, relates: [{context.env.module, function, []} | schema_ast.relates])
  end

  def expression!(context, {:relate, _, [{:{}, _, [_m, _f, _a]} = mfa]} = _elixir_ast, schema_ast, _literal?) do
    {mfa, _binding} = Context.eval_quoted(mfa, context)

    struct(schema_ast, relates: [mfa | schema_ast.relates])
  end

  def expression!(context, {:relationship, _, [arg1, arg2, {:when, _, [arg3, guard]}, [do: block]]} = _elixir_ast, schema_ast, _literal?) do
    quote do
      def __apix_schema_relationship__(unquote(arg1), unquote(arg2), unquote(arg3)) when unquote(guard), do: unquote(block)
    end
    |> Context.eval_quoted(context)

    struct(schema_ast, relationships: Enum.uniq([{context.env.module, :__apix_schema_relationship__, []} | schema_ast.relationships]))
  end

  def expression!(context, {:relationship, _, [arg1, arg2, arg3, [do: block]]} = _elixir_ast, schema_ast, _literal?) do
    quote do
      def __apix_schema_relationship__(unquote(arg1), unquote(arg2), unquote(arg3)), do: unquote(block)
    end
    |> Context.eval_quoted(context)

    struct(schema_ast, relationships: Enum.uniq([{context.env.module, :__apix_schema_relationship__, []} | schema_ast.relationships]))
  end

  def expression!(context, {:relationship, _, [{:&, _, [{:/, _, [{{:., _, [module, function]}, _, []}, 3]}]}]} = _elixir_ast, schema_ast, _literal?) do
    {module, _binding} = Context.eval_quoted(module, context)

    struct(schema_ast, relationships: [{module, function, []} | schema_ast.relationships])
  end

  def expression!(context, {:relationship, _, [{:&, _, [{:/, _, [{function, _, _}, 3]}]}]} = _elixir_ast, schema_ast, _literal?) do
    struct(schema_ast, relationships: [{context.env.module, function, []} | schema_ast.relationships])
  end

  def expression!(context, {:relationship, _, [{:{}, _, [_m, _f, _a]} = mfa]} = _elixir_ast, schema_ast, _literal?) do
    {mfa, _binding} = Context.eval_quoted(mfa, context)

    struct(schema_ast, relationships: [mfa | schema_ast.relationships])
  end

  def expression!(_context, _elixir_ast, _schema_ast, _literal?), do: false

  @impl Extension
  def validate_ast!(context) do
    track!(context)
    validate_reducible!(context)
    on_compilation!()

    context
  end

  @doc group: "Internal"
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
  after
    unless Code.can_await_module_compilation?() do
      prune_all!()
    end
  end
end
