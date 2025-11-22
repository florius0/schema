defmodule Apix.Schema.AstTest do
  use Apix.Schema.Case

  alias Apix.Schema.Ast

  describe "#{inspect Ast}" do
    setup do
      ast = %Ast{
        args: [
          %Ast{
            meta: 2
          }
        ],
        meta: 1
      }

      {:ok, ast: ast}
    end

    test "prewalk/2", %{ast: ast} do
      assert %Ast{
               args: [
                 %Ast{
                   meta: 3
                 }
               ],
               meta: 2
             } = Ast.prewalk(ast, fn a -> struct(a, meta: a.meta + 1) end)
    end

    test "prewalk/3", %{ast: ast} do
      assert {
               %Ast{
                 args: [
                   %Ast{
                     meta: 2
                   }
                 ],
                 meta: 1
               },
               [
                 %Ast{meta: 2},
                 %Ast{meta: 1}
               ]
             } = Ast.prewalk(ast, [], fn a, acc -> {a, [a | acc]} end)
    end

    test "postwalk/2", %{ast: ast} do
      assert %Ast{
               args: [
                 %Ast{
                   meta: 3
                 }
               ],
               meta: 2
             } = Ast.postwalk(ast, fn a -> struct(a, meta: a.meta + 1) end)
    end

    test "postwalk/3", %{ast: ast} do
      assert {
               %Ast{
                 args: [
                   %Ast{
                     meta: 2
                   }
                 ],
                 meta: 1
               },
               [
                 %Ast{meta: 1},
                 %Ast{meta: 2}
               ]
             } = Ast.postwalk(ast, [], fn a, acc -> {a, [a | acc]} end)
    end

    test "traverse/3", %{ast: ast} do
      assert {
               %Ast{
                 args: [
                   %Ast{
                     meta: 2
                   }
                 ],
                 meta: 1
               },
               [
                 post: %Ast{meta: 1},
                 post: %Ast{meta: 2},
                 pre: %Ast{meta: 2},
                 pre: %Ast{meta: 1}
               ]
             } = Ast.traverse(ast, [], fn a, acc -> {a, [{:pre, a} | acc]} end, fn a, acc -> {a, [{:post, a} | acc]} end)
    end

    test "equals?/2" do
      ast = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: []}
      other = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: [], flags: [:other]}
      different = %Ast{module: Apix.Schema.Extensions.Core.Any, schema: :t, args: []}

      assert Ast.equals?(ast, ast)
      assert Ast.equals?(ast, other)
      refute Ast.equals?(ast, different)
    end

    test "hash/1" do
      ast = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: []}
      other = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: [], flags: [:other]}
      different = %Ast{module: Apix.Schema.Extensions.Core.Any, schema: :t, args: []}

      assert Ast.hash(ast) == Ast.hash(ast)
      assert Ast.hash(ast) == Ast.hash(other)
      refute Ast.hash(ast) == Ast.hash(different)
    end

    test "map_keyword_args/2" do
      assert %Ast{args: [[], [:baz]]} =
               %Ast{args: [[], [foo: :bar]]}
               |> Ast.map_keyword_args(fn _ -> [:baz] end)
    end

    test "put_keyword_args/2" do
      assert %Ast{args: [[], [foo: :baz]]} =
               %Ast{args: [[], [foo: :bar]]}
               |> Ast.put_keyword_args(foo: :baz)
    end

    test "add_keyword_args/2" do
      assert %Ast{args: [[], [foo: :bar, baz: :qux]]} =
               %Ast{args: [[], [foo: :bar]]}
               |> Ast.add_keyword_args(baz: :qux)
    end

    test "remove_keyword_args/2" do
      assert %Ast{args: [[], []]} =
               %Ast{args: [[], [foo: :bar]]}
               |> Ast.remove_keyword_args(foo: :bar)
    end
  end
end
