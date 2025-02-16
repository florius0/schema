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
  end
end
