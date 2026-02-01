import Kernel, except: [inspect: 2]
import Inspect.Algebra
import Inspect.Apix.Schema.Shared

alias Apix.Schema.Context

defimpl Inspect, for: Context do
  def inspect(%Context{data: nil, module: nil, schema: nil, params: [], errors: []} = context, opts), do: color_doc("_", :rest, opts) |> enable(context, opts)

  def inspect(%Context{} = context, opts) do
    context = maybe_rewrite_delegate(context, opts)

    definition =
      if opts.custom_options[:apix_schema_expand_definitions?] do
        color_doc(" #=> ", :rest, opts)
        |> concat(Inspect.Apix.Schema.Ast.inspect(context.ast, opts))
      else
        empty()
      end

    additional_data =
      [
        data: context.data,
        errors: if(context.errors != [], do: context.errors)
      ]
      |> Enum.reject(&match?({_, nil}, &1))

    additional_data? = additional_data != []

    additional_data =
      container_doc(
        empty(),
        additional_data,
        empty(),
        opts,
        fn {key, value}, opts ->
          Macro.inspect_atom(:key, key)
          |> color_doc(:atom, opts)
          |> concat(" ")
          |> concat(inspect(value, opts))
        end,
        separator: color_doc(",", :list, opts)
      )
      |> group()

    additional_data =
      color_doc(",", :list, opts)
      |> space(additional_data)

    type =
      container_doc(
        "#{Macro.inspect_atom(:literal, context.module)}"
        |> color_doc(:atom, opts)
        |> concat(".#{Macro.inspect_atom(:remote_call, context.schema)}(" |> color_doc(:call, opts)),
        context.params,
        color_doc(")", :call, opts),
        opts,
        &inspect/2,
        separator: color_doc(",", :list, opts)
      )
      |> concat(definition)
      |> group()

    if additional_data? do
      type
      |> concat(additional_data)
    else
      type
    end
    |> mark(Context, opts)
    |> enable(context, opts)
  end

  def inspect({param, arity, default}, opts) do
    Macro.inspect_atom(:remote_call, param)
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

  def inspect(data, opts), do: Inspect.inspect(data, opts)

  defp maybe_rewrite_delegate(%Context{} = context, opts) do
    rewrite? = Keyword.get(opts.custom_options, :apix_schema_rewrite_delegates?, true)

    if rewrite? do
      {{module, schema}, _to} =
        context.extensions
        |> Enum.flat_map(& &1.delegates)
        |> List.keyfind({context.module, context.schema}, 1, {{context.module, context.schema}, nil})

      struct(context, module: module, schema: schema)
    else
      context
    end
  end
end
