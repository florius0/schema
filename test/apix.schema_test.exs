defmodule Apix.SchemaTest do
  use Apix.Schema.Case

  alias Apix.Schema.Ast
  alias Apix.Schema.Context

  describe "#{inspect Apix.Schema}" do
    test "__using__/1 | allows for inline extension passing" do
      defmodule TestSchema1 do
        use Apix.Schema

        assert %Apix.Schema.Context{
                 extensions: [
                   %Apix.Schema.Extension{module: Apix.Schema.Extensions.TypeGraph},
                   %Apix.Schema.Extension{module: Apix.Schema.Extensions.Core},
                   %Apix.Schema.Extension{module: Apix.Schema.Extensions.Elixir},
                   %Apix.Schema.Extension{module: Apix.Schema.Extensions.Core.LocalReference}
                 ]
               } = Context.get(__MODULE__)
      end

      defmodule TestSchema2 do
        use Apix.Schema,
          extensions: [
            Apix.Schema.Extensions.Core,
            %Apix.Schema.Extension{module: Apix.Schema.Extensions.Core.LocalReference}
          ]

        assert %Apix.Schema.Context{
                 extensions: [
                   %Apix.Schema.Extension{module: Apix.Schema.Extensions.Core},
                   %Apix.Schema.Extension{module: Apix.Schema.Extensions.Core.LocalReference}
                 ]
               } = Context.get(__MODULE__)
      end
    end

    test "schema/2 | normalizes params" do
      defmodule TestSchema3 do
        use Apix.Schema

        schema a: Any.t(), params: [:p1, p2: 1, p3: Any.t(), p4: 0 \\ Any.t()] do
        end
      end

      assert %{
               {Apix.SchemaTest.TestSchema3, :a, 4} => %Apix.Schema.Context{
                 module: Apix.SchemaTest.TestSchema3,
                 schema: :a,
                 params: [
                   {:p1, 0, nil},
                   {:p2, 1, nil},
                   {
                     :p3,
                     0,
                     %Apix.Schema.Ast{
                       module: Apix.Schema.Extensions.Core.Any,
                       schema: :t,
                       args: [],
                       shortdoc: nil,
                       doc: nil,
                       examples: [],
                       validators: [],
                       flags: [],
                       parameter?: false
                     }
                   },
                   {
                     :p4,
                     0,
                     %Apix.Schema.Ast{
                       module: Apix.Schema.Extensions.Core.Any,
                       schema: :t,
                       args: [],
                       shortdoc: nil,
                       doc: nil,
                       examples: [],
                       validators: [],
                       flags: [],
                       parameter?: false
                     }
                   }
                 ],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema3.__apix_schemas__()
    end

    test "schema/2 | includes metadata" do
      defmodule TestSchema4 do
        use Apix.Schema

        schema a: Any.t() do
        end
      end

      file = __ENV__.file

      assert %{
               {Apix.SchemaTest.TestSchema4, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   meta: %Apix.Schema.Ast.Meta{
                     file: ^file,
                     line: 95,
                     module: Apix.SchemaTest.TestSchema4,
                     generated_by: %Apix.Schema.Extension{module: Apix.Schema.Extensions.Core}
                   }
                 },
                 module: Apix.SchemaTest.TestSchema4,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema4.__apix_schemas__()
    end

    test "schema/2 | sets flags" do
      defmodule TestSchema5 do
        use Apix.Schema

        schema a: Any.t(), other: :other do
        end
      end

      assert %{
               {Apix.SchemaTest.TestSchema5, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{},
                 module: Apix.SchemaTest.TestSchema5,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: [other: :other]
               }
             } = TestSchema5.__apix_schemas__()
    end

    test "equals?/2" do
      ast = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: []}
      other = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: [], flags: [other: :other]}
      different = %Ast{module: Apix.Schema.Extensions.Core.Any, schema: :t, args: []}

      assert Apix.Schema.equals?(ast, ast)
      assert Apix.Schema.equals?(ast, other)
      refute Apix.Schema.equals?(ast, different)

      context = %Context{module: Apix.Schema.Extensions.Core.Const, schema: :t, params: [], ast: ast}
      other = %Context{module: Apix.Schema.Extensions.Core.Const, schema: :t, params: [], ast: ast, flags: [:other]}
      different = %Context{module: Apix.Schema.Extensions.Core.Any, schema: :t, params: [], ast: ast}

      assert Apix.Schema.equals?(context, context)
      assert Apix.Schema.equals?(context, other)
      refute Apix.Schema.equals?(context, different)
    end

    test "hash/1" do
      ast = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: []}
      other = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: [], flags: [other: :other]}
      different = %Ast{module: Apix.Schema.Extensions.Core.Any, schema: :t, args: []}

      assert Apix.Schema.hash(ast) == Apix.Schema.hash(ast)
      assert Apix.Schema.hash(ast) == Apix.Schema.hash(other)
      refute Apix.Schema.hash(ast) == Apix.Schema.hash(different)

      context = %Context{module: Apix.Schema.Extensions.Core.Const, schema: :t, params: [], ast: ast}
      other = %Context{module: Apix.Schema.Extensions.Core.Const, schema: :t, params: [], ast: ast, flags: [:other]}
      different = %Context{module: Apix.Schema.Extensions.Core.Any, schema: :t, params: [], ast: ast}

      assert Apix.Schema.hash(context) == Apix.Schema.hash(context)
      assert Apix.Schema.hash(context) == Apix.Schema.hash(other)
      refute Apix.Schema.hash(context) == Apix.Schema.hash(different)
    end

    test "msa/1" do
      ast = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: []}
      context = %Context{module: Apix.Schema.Extensions.Core.Const, schema: :t, params: [], ast: ast}

      assert {Apix.Schema.Extensions.Core.Const, :t, 0} = Apix.Schema.msa(context)
      assert {Apix.Schema.Extensions.Core.Const, :t, 0} = Apix.Schema.msa(ast)
    end

    test "get_schema/3" do
      assert %Apix.Schema.Context{
               module: Apix.Schema.Extensions.Core.Const,
               schema: :t,
               params: [{:value, 0, nil}]
             } =
               Apix.Schema.get_schema(Apix.Schema.Extensions.Core.Const, :t, 1)
    end

    test "map_flags/2" do
      assert %Ast{flags: [old: true, mapped: true]} =
               %Ast{
                 module: Apix.Schema.Extensions.Core.Const,
                 schema: :t,
                 flags: [old: true]
               }
               |> Apix.Schema.map_flags(&(&1 ++ [mapped: true]))
    end

    test "add_flags/2" do
      assert %Context{flags: [base: :flag, added: :flag]} =
               %Context{
                 module: Apix.Schema.Extensions.Core.Const,
                 schema: :t,
                 flags: [base: :flag]
               }
               |> Apix.Schema.add_flags(added: :flag)
    end

    test "remove_flags/2" do
      assert %Context{flags: []} =
               %Context{
                 module: Apix.Schema.Extensions.Core.Const,
                 schema: :t,
                 flags: [base: :flag]
               }
               |> Apix.Schema.remove_flags(base: :flag)
    end
  end
end
