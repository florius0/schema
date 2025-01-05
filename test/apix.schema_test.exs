defmodule Apix.SchemaTest do
  use ExUnit.Case, async: true

  alias Apix.Schema.Ast

  describe "#{inspect Apix.Schema}" do
    test "__using__/1 | allows for inline extension passing" do
      defmodule A do
        use Apix.Schema

        assert %Apix.Schema.Context{
                 extensions: [
                   %Apix.Schema.Extension{module: Apix.Schema.Extensions.Core},
                   %Apix.Schema.Extension{module: Apix.Schema.Extensions.Elixir},
                   %Apix.Schema.Extension{module: Apix.Schema.Extensions.Core.LocalReference}
                 ]
               } = Module.get_attribute(__MODULE__, :apix_schema_context)
      end

      defmodule B do
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
      defmodule C do
        use Apix.Schema

        schema a: Any.t(), params: [:p1, p2: 1, p3: Any.t(), p4: 0 \\ Any.t()] do
        end
      end

      assert [
               %Apix.Schema.Context{
                 module: Apix.SchemaTest.C,
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
                 errors: [],
                 flags: [],
                 extensions: [
                   %Apix.Schema.Extension{module: Apix.Schema.Extensions.Core},
                   %Apix.Schema.Extension{module: Apix.Schema.Extensions.Elixir},
                   %Apix.Schema.Extension{module: Apix.Schema.Extensions.Core.LocalReference}
                 ]
               }
             ] = C.__apix_schemas__()
    end

    test "schema/2 | includes metadata" do
      defmodule D do
        use Apix.Schema

        schema a: Any.t() do
        end
      end

      file = __ENV__.file

      assert [
               %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   meta: %Apix.Schema.Ast.Meta{
                     file: ^file,
                     line: 97,
                     module: Apix.SchemaTest.D,
                     generated_by: %Apix.Schema.Extension{module: Apix.Schema.Extensions.Core}
                   }
                 },
                 module: Apix.SchemaTest.D,
                 schema: :a,
                 params: [],
                 errors: [],
                 flags: []
               }
             ] = D.__apix_schemas__()
    end
  end

  describe "#{inspect Apix.Schema.Extensions.Core}" do
    test "delegates | `Any.t` -> `Apix.Schema.Extensions.Core.Any.t`" do
      defmodule E do
        use Apix.Schema

        schema a: Any.t() do
        end
      end

      assert [
               %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Core.Any,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.SchemaTest.E,
                 schema: :a,
                 params: [],
                 errors: [],
                 flags: []
               }
             ] = E.__apix_schemas__()
    end

    test "expressions | `shortdoc \"smth\"` - defines `:shortdoc` in `t:#{inspect Ast}.t/0`" do
      defmodule F do
        use Apix.Schema

        schema a: Any.t() do
          shortdoc "smth"
        end
      end

      assert [
               %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Core.Any,
                   schema: :t,
                   args: [],
                   shortdoc: "smth",
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.SchemaTest.F,
                 schema: :a,
                 params: [],
                 errors: [],
                 flags: []
               }
             ] = F.__apix_schemas__()

      defmodule G do
        use Apix.Schema

        schema a: Any.t() do
          shortdoc "smth1"
          shortdoc "smth2"
        end
      end

      assert [
               %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Core.Any,
                   schema: :t,
                   args: [],
                   shortdoc: "smth2",
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.SchemaTest.G,
                 schema: :a,
                 params: [],
                 errors: [],
                 flags: []
               }
             ] = G.__apix_schemas__()
    end

    test "expressions | `doc \"smth\"` – defines `:doc` in `t:#{inspect Ast}.t/0`" do
      defmodule H do
        use Apix.Schema

        schema a: Any.t() do
          doc "smth"
        end
      end

      assert [
               %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Core.Any,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: "smth",
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.SchemaTest.H,
                 schema: :a,
                 params: [],
                 errors: [],
                 flags: []
               }
             ] = H.__apix_schemas__()

      defmodule I do
        use Apix.Schema

        schema a: Any.t() do
          doc "smth1"
          doc "smth2"
        end
      end

      assert [
               %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Core.Any,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: "smth2",
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.SchemaTest.I,
                 schema: :a,
                 params: [],
                 errors: [],
                 flags: []
               }
             ] = I.__apix_schemas__()
    end

    test "expressions | `example value` – adds example to `:examples` in `t:#{inspect Ast}.t/0`" do
      defmodule J do
        use Apix.Schema

        schema a: Any.t() do
          example 1
        end
      end

      assert [
               %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Core.Any,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [1],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.SchemaTest.J,
                 schema: :a,
                 params: [],
                 errors: [],
                 flags: []
               }
             ] = J.__apix_schemas__()

      defmodule K do
        use Apix.Schema

        schema a: Any.t() do
          example 1
          example 2
        end
      end

      assert [
               %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Core.Any,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [2, 1],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.SchemaTest.K,
                 schema: :a,
                 params: [],
                 errors: [],
                 flags: []
               }
             ] = K.__apix_schemas__()
    end

    test "expressions | `a and b` – builds `and` schema expression – the value is expected to be valid against `a` and `b` schema expressions" do
      defmodule L do
        use Apix.Schema

        # credo:disable-for-next-line
        schema a: Any.t() and Any.t()
      end

      assert [
               %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Core.And,
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
                     },
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
                 module: Apix.SchemaTest.L,
                 schema: :a,
                 params: [],
                 errors: [],
                 flags: []
               }
             ] = L.__apix_schemas__()

      defmodule M do
        use Apix.Schema

        # credo:disable-for-next-line
        schema a: Any.t() and Any.t() and Any.t()
      end

      assert [
               %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Core.And,
                   schema: :t,
                   args: [
                     %Apix.Schema.Ast{
                       module: Apix.Schema.Extensions.Core.And,
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
                         },
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
                 module: Apix.SchemaTest.M,
                 schema: :a,
                 params: [],
                 errors: [],
                 flags: []
               }
             ] = M.__apix_schemas__()
    end

    test "expressions | `a or b` – builds `or` schema expression – the value is expected to be valid against `a` or `b` schema expressions" do
      defmodule N do
        use Apix.Schema

        # credo:disable-for-next-line
        schema a: Any.t() or Any.t()
      end

      assert [
               %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Core.Or,
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
                     },
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
                 module: Apix.SchemaTest.N,
                 schema: :a,
                 params: [],
                 errors: [],
                 flags: []
               }
             ] = N.__apix_schemas__()

      defmodule O do
        use Apix.Schema

        # credo:disable-for-next-line
        schema a: Any.t() or Any.t() or Any.t()
      end

      assert [
               %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Core.Or,
                   schema: :t,
                   args: [
                     %Apix.Schema.Ast{
                       module: Apix.Schema.Extensions.Core.Or,
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
                         },
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
                 module: Apix.SchemaTest.O,
                 schema: :a,
                 params: [],
                 errors: [],
                 flags: []
               }
             ] = O.__apix_schemas__()
    end

    test "expressions | `not a` – builds `not` schema expression – the value is expected to be invalid against `a` schema expression" do
      defmodule P do
        use Apix.Schema

        schema a: not Any.t()
      end

      assert [
               %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Core.Not,
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
                 module: Apix.SchemaTest.P,
                 schema: :a,
                 params: [],
                 errors: [],
                 flags: []
               }
             ] = P.__apix_schemas__()
    end

    # Fails due to https://github.com/elixir-lang/elixir/issues/14144
    test "expressions | module attribute expansion as const – the value is expected to be equal to" do
      defmodule Q do
        use Apix.Schema

        @attribute 1

        schema a: @attribute
      end

      assert [
               %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Core.Const,
                   schema: :t,
                   args: [1],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.SchemaTest.Q,
                 schema: :a,
                 params: [],
                 errors: [],
                 flags: []
               }
             ] = Q.__apix_schemas__()
    end

    test "expressions | literal expansion as const – the value is expected to be equal to" do
      defmodule R do
        use Apix.Schema

        schema a: 1
      end

      assert [
               %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Core.Const,
                   schema: :t,
                   args: [1],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.SchemaTest.R,
                 schema: :a,
                 params: [],
                 errors: [],
                 flags: []
               }
             ] = R.__apix_schemas__()
    end

    test "expressions | remote (defined in other module) schema referencing" do
      defmodule S do
        use Apix.Schema

        schema a: X.t(Any.t())
      end

      assert [
               %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: X,
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
                 module: Apix.SchemaTest.S,
                 schema: :a,
                 params: [],
                 errors: [],
                 flags: []
               }
             ] = S.__apix_schemas__()
    end

    test "expressions | parameter referencing" do
      defmodule T do
        use Apix.Schema

        schema a: p2(p1), params: [:p1, p2: 1]
      end

      assert [
               %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: nil,
                   schema: :p2,
                   args: [
                     %Apix.Schema.Ast{
                       module: nil,
                       schema: :p1,
                       args: [],
                       shortdoc: nil,
                       doc: nil,
                       examples: [],
                       validators: [],
                       flags: [],
                       parameter?: true
                     }
                   ],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: true
                 },
                 module: Apix.SchemaTest.T,
                 schema: :a,
                 params: [{:p1, 0, nil}, {:p2, 1, nil}],
                 errors: [],
                 flags: []
               }
             ] = T.__apix_schemas__()
    end
  end

  describe "#{inspect Apix.Schema.Extensions.Core.LocalReference}" do
    test "expressions | local (defied in same module) schema referencing" do
      defmodule U do
        use Apix.Schema

        schema a: t(Any.t())
      end

      assert [
               %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.SchemaTest.U,
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
                 module: Apix.SchemaTest.U,
                 schema: :a,
                 params: [],
                 errors: [],
                 flags: []
               }
             ] = U.__apix_schemas__()
    end
  end

  describe "#{inspect Apix.Schema.Extensions.Elixir}" do
  end
end
