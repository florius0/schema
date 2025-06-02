import Kernel, except: [inspect: 2]
import Inspect.Algebra
import Inspect.Apix.Schema.Shared

alias Apix.Schema.Context

defimpl Inspect, for: Context do
  def inspect(%Context{} = context, opts) do
    definition =
      if opts.custom_options[:apix_schema_expand_definitions?] do
        color_doc(" #=> ", :rest, opts)
        |> concat(Inspect.Apix.Schema.Ast.inspect(context.ast, opts))
      else
        empty()
      end

    context.module
    |> Inspect.Atom.inspect(opts)
    |> concat(color_doc(".#{context.schema}(", :call, opts))
    |> concat(
      container_doc(
        empty(),
        context.params,
        empty(),
        opts,
        &inspect/2,
        separator: color_doc(", ", :list, opts)
      )
    )
    |> concat(color_doc(")", :call, opts))
    |> concat(definition)
    |> group()
    |> enable(context, opts)
  end

  def inspect({param, arity, default}, opts) do
    param
    |> to_string()
    |> color_doc(:rest, opts)
    |> concat(color_doc("/", :rest, opts))
    |> concat(color_doc(to_string(arity), :rest, opts))
    |> concat(
      case default do
        nil ->
          empty()

        _ ->
          color_doc(" // ", :operator, opts)
          |> concat(Inspect.Apix.Schema.Ast.inspect(default, opts))
      end
    )
    |> group()
  end
end
