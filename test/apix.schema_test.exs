defmodule Apix.SchemaTest do
  use Apix.Schema.Case

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
               } = Module.get_attribute(__MODULE__, :apix_schema_context)
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
               } = Module.get_attribute(__MODULE__, :apix_schema_context)
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
                     line: 92,
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
  end
end
