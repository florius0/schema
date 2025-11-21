import Kernel, except: [inspect: 2]
import Inspect.Algebra
import Inspect.Apix.Schema.Shared

alias Apix.Schema.Ast
alias Apix.Schema.Ast.Meta
alias Apix.Schema.Extension

defimpl Inspect, for: Ast do
  @dialyzer {:nowarn_function, inspect: 2}

  def inspect(%Ast{parameter?: true} = ast, opts) do
    "#{ast.schema}("
    |> color_doc(:rest, opts)
    |> concat(
      container_doc(
        empty(),
        ast.args,
        empty(),
        opts,
        &inspect/2,
        separator: color_doc(", ", :list, opts)
      )
    )
    |> concat(color_doc(")", :rest, opts))
    |> group()
    |> enable(ast, opts)
  end

  def inspect(%Ast{module: nil} = ast, opts) do
    color_doc("_", :rest, opts)
    |> enable(ast, opts)
  end

  def inspect(%Ast{} = ast, opts) do
    ast = maybe_rewrite_delegate(ast, opts)

    "#{Macro.inspect_atom(:literal, ast.module)}"
    |> color_doc(:atom, opts)
    |> concat(".#{Macro.inspect_atom(:remote_call, ast.schema)}" |> color_doc(:call, opts))
    |> concat(
      container_doc(
        color_doc("(", :call, opts),
        ast.args,
        color_doc(")", :call, opts),
        opts,
        &inspect/2,
        separator: color_doc(",", :list, opts),
        break: :maybe
      )
    )
    |> group()
    |> mark(Ast, opts)
    |> group()
    |> enable(ast, opts)
  end

  def inspect(doc, _opts) when is_doc(doc), do: doc

  def inspect([{_k, _v} | _rest] = keyword, opts) do
    keyword
    |> Enum.map(fn {k, v} ->
      :key
      |> Macro.inspect_atom(k)
      |> color_doc(:atom, opts)
      |> space(to_doc(v, opts))
    end)
    |> Enum.intersperse(
      color_doc(",", :list, opts)
      |> concat(line())
    )
    |> Enum.reduce(empty(), &concat/2)
    |> group()
  end

  def inspect(literal, opts), do: Inspect.inspect(literal, opts) |> group()

  defp maybe_rewrite_delegate(%Ast{meta: %Meta{generated_by: %Extension{}}} = ast, opts) do
    rewrite? = Keyword.get(opts.custom_options, :apix_schema_rewrite_delegates?, true)

    if rewrite? do
      {{module, schema}, _to} = List.keyfind(ast.meta.generated_by.delegates, {ast.module, ast.schema}, 1, {{ast.module, ast.schema}, nil})

      struct(ast, module: module, schema: schema)
    else
      ast
    end
  end

  defp maybe_rewrite_delegate(ast, _opts), do: ast
end
