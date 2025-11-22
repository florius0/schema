defmodule Inspect.Apix.Schema.ContextTest do
  use Apix.Schema.Case

  alias Apix.Schema.Ast
  alias Apix.Schema.Context
  alias Inspect.Opts

  describe "#{inspect Inspect.Apix.Schema.Context}" do
    test "renders parameterized contexts" do
      const_ast = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: []}

      base_context = %Context{
        module: Inspect.Apix.Schema.Shared,
        schema: :foo,
        params: [{:bar, 0, nil}],
        ast: const_ast
      }

      defaulted_context = %Context{
        module: Inspect.Apix.Schema.Shared,
        schema: :foo,
        params: [{:ok, 1, const_ast}],
        ast: const_ast
      }

      cases = [
        {base_context, "#Apix.Schema.Context<Inspect.Apix.Schema.Shared.foo(bar/0)>"},
        {defaulted_context, "#Apix.Schema.Context<Inspect.Apix.Schema.Shared.foo(\n  ok/1 // #Apix.Schema.Ast<Apix.Schema.Extensions.Core.Const.t()>\n)>"}
      ]

      opts = Opts.new([])

      for {context, expected} <- cases do
        assert expected == inspect_context(context, opts)
      end
    end

    test "supports definition expansion" do
      context = %Context{
        module: Inspect.Apix.Schema.Shared,
        schema: :foo,
        params: [],
        ast: %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: []}
      }

      opts = Opts.new(custom_options: [apix_schema_expand_definitions?: true])

      assert "#Apix.Schema.Context<Inspect.Apix.Schema.Shared.foo() #=> #Apix.Schema.Ast<Apix.Schema.Extensions.Core.Const.t()>>" ==
               inspect_context(context, opts)
    end

    test "rewrites delegates when requested" do
      context = %Context{
        module: Apix.Schema.Extensions.Core.Any,
        schema: :t,
        params: [],
        ast: %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: []},
        extensions: [Apix.Schema.Extensions.Core.manifest()]
      }

      assert "#Apix.Schema.Context<Any.t()>" == inspect_context(context, Opts.new([]))
    end

    test "honors shared enable/mark toggles" do
      context = %Context{
        module: Inspect.Apix.Schema.Shared,
        schema: :foo,
        params: [{:bar, 0, nil}],
        ast: %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: []}
      }

      assert "Inspect.Apix.Schema.Shared.foo(bar/0)" ==
               inspect_context(context, Opts.new(custom_options: [apix_schema_mark?: false]))

      expected =
        """
        %Apix.Schema.Context{
          ast: %Apix.Schema.Ast{
            module: Apix.Schema.Extensions.Core.Const,
            schema: :t,
            args: [],
            shortdoc: nil,
            doc: nil,
            examples: [],
            validators: [],
            relates: [],
            relationships: [],
            flags: [],
            meta: nil,
            parameter?: false
          },
          data: nil,
          module: Inspect.Apix.Schema.Shared,
          schema: :foo,
          params: [{:bar, 0, nil}],
          warnings: [],
          errors: [],
          flags: [],
          extensions: []
        }
        """
        |> String.trim_trailing()

      assert expected ==
               inspect_context(context, Opts.new(custom_options: [apix_schema?: false]))
    end

    test "renders empty context as underscore" do
      context = %Context{
        module: nil,
        schema: nil,
        params: [],
        ast: %Ast{module: nil, schema: nil, args: []}
      }

      assert "_" == inspect_context(context, Opts.new([]))
    end

    test "omits delegate rewrite when option disabled" do
      context = %Context{
        module: Apix.Schema.Extensions.Core.Any,
        schema: :t,
        params: [],
        ast: %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: []},
        extensions: [Apix.Schema.Extensions.Core.manifest()]
      }

      opts = Opts.new(custom_options: [apix_schema_rewrite_delegates?: false])

      assert "#Apix.Schema.Context<Apix.Schema.Extensions.Core.Any.t()>" == inspect_context(context, opts)
    end
  end

  defp inspect_context(context, opts) do
    context
    |> Inspect.Apix.Schema.Context.inspect(opts)
    |> Inspect.Algebra.format(opts.width)
    |> IO.iodata_to_binary()
  end
end
