defmodule Inspect.Apix.Schema.AstTest do
  use Apix.Schema.Case

  alias Apix.Schema.Ast
  alias Apix.Schema.Ast.Meta
  alias Inspect.Algebra
  alias Inspect.Opts

  describe "#{inspect Inspect.Apix.Schema.Ast}" do
    test "renders various AST shapes" do
      const_ast = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: []}
      arg_ast = %Ast{module: nil, schema: nil, args: []}
      parameter_ast = %Ast{module: nil, schema: :foo, args: [arg_ast], parameter?: true}
      or_ast = %Ast{module: Apix.Schema.Extensions.Core.Or, schema: :t, args: [const_ast, const_ast]}

      cases = [
        {:parameter, parameter_ast, "foo(_)"},
        {:module, const_ast, "#Apix.Schema.Ast<Apix.Schema.Extensions.Core.Const.t()>"},
        {:nested, or_ast,
         "#Apix.Schema.Ast<Apix.Schema.Extensions.Core.Or.t(\n  #Apix.Schema.Ast<Apix.Schema.Extensions.Core.Const.t()>,\n  #Apix.Schema.Ast<Apix.Schema.Extensions.Core.Const.t()>\n)>"},
        {:underscore, arg_ast, "_"}
      ]

      opts = Opts.new([])

      for {_name, ast, expected} <- cases do
        assert expected == inspect_ast(ast, opts)
      end
    end

    test "respects shared inspect options" do
      const_ast = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: []}

      mark_disabled = Opts.new(custom_options: [apix_schema_mark?: false])

      assert "Apix.Schema.Extensions.Core.Const.t()" == inspect_ast(const_ast, mark_disabled)

      decorated_disabled = Opts.new(custom_options: [apix_schema?: false])

      assert """
             %Apix.Schema.Ast{
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
             }
             """
             |> String.trim_trailing() ==
               inspect_ast(const_ast, decorated_disabled)
    end

    test "rewrites delegates when metadata is present" do
      ast =
        %Ast{
          module: Apix.Schema.Extensions.Core.Any,
          schema: :t,
          args: [],
          meta: %Meta{generated_by: Apix.Schema.Extensions.Core.manifest()}
        }

      assert "#Apix.Schema.Ast<Any.t()>" == inspect_ast(ast, Opts.new([]))
    end

    test "renders keywords, literals, and raw docs" do
      const_ast = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: []}
      opts = Opts.new([])

      keyword_output = inspect_ast([foo: const_ast, bar: const_ast], opts)

      assert String.contains?(
               keyword_output,
               "foo: #Apix.Schema.Ast<Apix.Schema.Extensions.Core.Const.t()>"
             )

      assert String.contains?(
               keyword_output,
               "bar: #Apix.Schema.Ast<Apix.Schema.Extensions.Core.Const.t()>"
             )

      assert "123" == inspect_ast(123, opts)

      doc = Algebra.color_doc("custom", :rest, opts)

      assert "custom" == inspect_ast(doc, opts)
    end

    test "respects rewrite toggle" do
      ast =
        %Ast{
          module: Apix.Schema.Extensions.Core.Any,
          schema: :t,
          args: [],
          meta: %Meta{generated_by: Apix.Schema.Extensions.Core.manifest()}
        }

      opts = Opts.new(custom_options: [apix_schema_rewrite_delegates?: false])

      assert "#Apix.Schema.Ast<Apix.Schema.Extensions.Core.Any.t()>" == inspect_ast(ast, opts)
    end
  end

  defp inspect_ast(ast, opts) do
    ast
    |> Inspect.Apix.Schema.Ast.inspect(opts)
    |> Inspect.Algebra.format(opts.width)
    |> IO.iodata_to_binary()
  end
end
