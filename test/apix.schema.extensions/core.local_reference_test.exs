defmodule Apix.Schema.Extensions.Core.LocalReferenceTest do
  use ExUnit.Case, async: true

  describe "#{inspect Apix.Schema.Extensions.Core.LocalReference}" do
    test "expressions | local (defied in same module) schema referencing" do
      defmodule TestSchema1 do
        use Apix.Schema

        schema a: t(Any.t())
      end

      assert [
               %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Core.LocalReferenceTest.TestSchema1,
                   schema: :t,
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
                 schema: :a,
                 params: [],
                 errors: [],
                 flags: []
               }
             ] = TestSchema1.__apix_schemas__()
    end
  end
end
