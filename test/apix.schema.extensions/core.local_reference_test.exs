defmodule Apix.Schema.Extensions.Core.LocalReferenceTest do
  use Apix.Schema.Case

  describe "#{inspect Apix.Schema.Extensions.Core.LocalReference}" do
    test "expressions | local (defied in same module) schema referencing" do
      defmodule TestSchema1 do
        use Apix.Schema

        schema a: 1, params: [:p]
        schema b: a(Any.t())
      end

      assert %{
               {Apix.Schema.Extensions.Core.LocalReferenceTest.TestSchema1, :b, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Core.LocalReferenceTest.TestSchema1,
                   schema: :a,
                   args: [
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
                   ],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.Core.LocalReferenceTest.TestSchema1,
                 schema: :b,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema1.__apix_schemas__()
    end
  end
end
