defmodule Apix.Schema.ContextTest do
  use Apix.Schema.Case

  alias Apix.Schema.Ast
  alias Apix.Schema.Ast.Meta
  alias Apix.Schema.Context
  alias Apix.Schema.Extension

  describe "#{inspect Context}" do
    defmodule DelegateExtension do
      def manifest do
        %Extension{
          module: __MODULE__,
          delegates: [
            {
              {Apix.Schema.Extensions.Core.Const, :t},
              {Apix.Schema.Extensions.Core.Any, :t}
            }
          ],
          function_delegates: [
            {
              {Apix.Schema.Extensions.Core.Const, :value},
              {Apix.Schema.Extensions.Core.Any, :value}
            }
          ]
        }
      end
    end

    test "normalize_ast!/1" do
      ast = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: []}
      context = %Context{extensions: [], ast: ast}

      assert ast == Context.normalize_ast!(context)
    end

    test "install!/1 and rewrite_delegates/2" do
      context = %Context{extensions: [DelegateExtension.manifest()]}

      assert %Context{
               delegates: %{
                 {Apix.Schema.Extensions.Core.Const, :t} => {
                   {Apix.Schema.Extensions.Core.Any, :t},
                   extension = %Apix.Schema.Extension{module: DelegateExtension}
                 }
               },
               function_delegates: %{
                 {Apix.Schema.Extensions.Core.Const, :value} => {
                   {Apix.Schema.Extensions.Core.Any, :value},
                   extension = %Apix.Schema.Extension{module: DelegateExtension}
                 }
               }
             } = context = Context.install!(context)

      assert %Ast{
               module: Apix.Schema.Extensions.Core.Any,
               schema: :t,
               args: [],
               meta: %Meta{
                 generated_by: ^extension
               }
             } =
               %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: []}
               |> Context.rewrite_delegates(context)
    end

    test "map_ast/2" do
      context = %Context{ast: %Ast{shortdoc: nil}}

      result = Context.map_ast(context, fn ctx -> struct(ctx.ast, shortdoc: "foo") end)

      assert "foo" == result.ast.shortdoc
    end

    test "equals?/2" do
      ast = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: []}

      context = %Context{module: Apix.Schema.Extensions.Core.Const, schema: :t, params: [], ast: ast}
      other = %Context{module: Apix.Schema.Extensions.Core.Const, schema: :t, params: [], ast: ast, flags: [:other]}
      different = %Context{module: Apix.Schema.Extensions.Core.Any, schema: :t, params: [], ast: ast}

      assert Context.equals?(context, context)
      assert Context.equals?(context, other)
      refute Context.equals?(context, different)
    end

    test "hash/1" do
      ast = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: []}

      context = %Context{module: Apix.Schema.Extensions.Core.Const, schema: :t, params: [], ast: ast}
      other = %Context{module: Apix.Schema.Extensions.Core.Const, schema: :t, params: [], ast: ast, flags: [:other]}
      different = %Context{module: Apix.Schema.Extensions.Core.Any, schema: :t, params: [], ast: ast}

      assert Context.hash(context) == Context.hash(context)
      assert Context.hash(context) == Context.hash(other)
      refute Context.hash(context) == Context.hash(different)
    end
  end
end
