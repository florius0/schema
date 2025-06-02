import Kernel, except: [inspect: 2]
import Inspect.Algebra
import Inspect.Apix.Schema.Shared

alias Apix.Schema.Ast

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
    Ast.postwalk(ast, fn ast ->
      ast.module
      |> Inspect.Atom.inspect(opts)
      |> concat(color_doc(".#{ast.schema}(", :call, opts))
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
      |> concat(color_doc(")", :call, opts))
      |> group()
    end)
    |> group()
    |> enable(ast, opts)
  end

  def inspect(doc, _opts) when is_doc(doc), do: doc

  def inspect(literal, opts), do: Inspect.inspect(literal, opts) |> group()
end
