defmodule Apix.Schema.Extensions.CoreTest do
  use Apix.Schema.Case

  alias Apix.Schema.Ast

  describe "#{inspect Apix.Schema.Extensions.Core}" do
    test "delegates | `Any.t` -> `Apix.Schema.Extensions.Core.Any.t`" do
      defmodule TestSchema1 do
        use Apix.Schema

        schema a: Any.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.CoreTest.TestSchema1, :a, 0} => %Apix.Schema.Context{
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
                 module: Apix.Schema.Extensions.CoreTest.TestSchema1,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema1.__apix_schemas__()
    end

    test "delegates | `None.t` -> `Apix.Schema.Extensions.Core.None.t`" do
      defmodule TestSchema2 do
        use Apix.Schema

        schema a: None.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.CoreTest.TestSchema2, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Core.None,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.CoreTest.TestSchema2,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema2.__apix_schemas__()
    end

    test "expressions | `shortdoc \"smth\"` - defines `:shortdoc` in `t:#{inspect Ast}.t/0`" do
      defmodule TestSchema3 do
        use Apix.Schema

        schema a: Any.t() do
          shortdoc "smth"
        end
      end

      assert %{
               {Apix.Schema.Extensions.CoreTest.TestSchema3, :a, 0} => %Apix.Schema.Context{
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
                 module: Apix.Schema.Extensions.CoreTest.TestSchema3,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema3.__apix_schemas__()

      defmodule TestSchema4 do
        use Apix.Schema

        schema a: Any.t() do
          shortdoc "smth1"
          shortdoc "smth2"
        end
      end

      assert %{
               {Apix.Schema.Extensions.CoreTest.TestSchema4, :a, 0} => %Apix.Schema.Context{
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
                 module: Apix.Schema.Extensions.CoreTest.TestSchema4,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema4.__apix_schemas__()
    end

    test "expressions | `doc \"smth\"` – defines `:doc` in `t:#{inspect Ast}.t/0`" do
      defmodule TestSchema5 do
        use Apix.Schema

        schema a: Any.t() do
          doc "smth"
        end
      end

      assert %{
               {Apix.Schema.Extensions.CoreTest.TestSchema5, :a, 0} => %Apix.Schema.Context{
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
                 module: Apix.Schema.Extensions.CoreTest.TestSchema5,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema5.__apix_schemas__()

      defmodule TestSchema6 do
        use Apix.Schema

        schema a: Any.t() do
          doc "smth1"
          doc "smth2"
        end
      end

      assert %{
               {Apix.Schema.Extensions.CoreTest.TestSchema6, :a, 0} => %Apix.Schema.Context{
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
                 module: Apix.Schema.Extensions.CoreTest.TestSchema6,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema6.__apix_schemas__()
    end

    test "expressions | `example value` – adds example to `:examples` in `t:#{inspect Ast}.t/0`" do
      defmodule TestSchema7 do
        use Apix.Schema

        schema a: Any.t() do
          example 1
        end
      end

      assert %{
               {Apix.Schema.Extensions.CoreTest.TestSchema7, :a, 0} => %Apix.Schema.Context{
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
                 module: Apix.Schema.Extensions.CoreTest.TestSchema7,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema7.__apix_schemas__()

      defmodule TestSchema8 do
        use Apix.Schema

        schema a: Any.t() do
          example 1
          example 2
        end
      end

      assert %{
               {Apix.Schema.Extensions.CoreTest.TestSchema8, :a, 0} => %Apix.Schema.Context{
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
                 module: Apix.Schema.Extensions.CoreTest.TestSchema8,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema8.__apix_schemas__()
    end

    test "expressions | `a and b` – builds `and` schema expression – the value is expected to be valid against `a` and `b` schema expressions" do
      defmodule TestSchema9 do
        use Apix.Schema

        # credo:disable-for-next-line
        schema a: Any.t() and Any.t()
      end

      assert %{
               {Apix.Schema.Extensions.CoreTest.TestSchema9, :a, 0} => %Apix.Schema.Context{
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
                 module: Apix.Schema.Extensions.CoreTest.TestSchema9,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema9.__apix_schemas__()

      defmodule TestSchema10 do
        use Apix.Schema

        # credo:disable-for-next-line
        schema a: Any.t() and Any.t() and Any.t()
      end

      assert %{
               {Apix.Schema.Extensions.CoreTest.TestSchema10, :a, 0} => %Apix.Schema.Context{
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
                 module: Apix.Schema.Extensions.CoreTest.TestSchema10,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema10.__apix_schemas__()
    end

    test "expressions | `a or b` – builds `or` schema expression – the value is expected to be valid against `a` or `b` schema expressions" do
      defmodule TestSchema11 do
        use Apix.Schema

        # credo:disable-for-next-line
        schema a: Any.t() or Any.t()
      end

      assert %{
               {Apix.Schema.Extensions.CoreTest.TestSchema11, :a, 0} => %Apix.Schema.Context{
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
                 module: Apix.Schema.Extensions.CoreTest.TestSchema11,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema11.__apix_schemas__()

      defmodule TestSchema12 do
        use Apix.Schema

        # credo:disable-for-next-line
        schema a: Any.t() or Any.t() or Any.t()
      end

      assert %{
               {Apix.Schema.Extensions.CoreTest.TestSchema12, :a, 0} => %Apix.Schema.Context{
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
                 module: Apix.Schema.Extensions.CoreTest.TestSchema12,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema12.__apix_schemas__()
    end

    test "expressions | `not a` – builds `not` schema expression – the value is expected to be invalid against `a` schema expression" do
      defmodule TestSchema13 do
        use Apix.Schema

        schema a: not Any.t()
      end

      assert %{
               {Apix.Schema.Extensions.CoreTest.TestSchema13, :a, 0} => %Apix.Schema.Context{
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
                 module: Apix.Schema.Extensions.CoreTest.TestSchema13,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema13.__apix_schemas__()
    end

    test "expressions | module attribute expansion as const – the value is expected to be equal to" do
      defmodule TestSchema14 do
        use Apix.Schema

        @attribute 1

        schema a: @attribute
      end

      assert %{
               {Apix.Schema.Extensions.CoreTest.TestSchema14, :a, 0} => %Apix.Schema.Context{
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
                 module: Apix.Schema.Extensions.CoreTest.TestSchema14,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema14.__apix_schemas__()
    end

    test "expressions | literal expansion as const – the value is expected to be equal to" do
      defmodule TestSchema15 do
        use Apix.Schema

        schema a: 1
      end

      assert %{
               {Apix.Schema.Extensions.CoreTest.TestSchema15, :a, 0} => %Apix.Schema.Context{
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
                 module: Apix.Schema.Extensions.CoreTest.TestSchema15,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema15.__apix_schemas__()
    end

    test "expressions | remote (defined in other module) schema referencing" do
      defmodule TestSchema16 do
        use Apix.Schema

        schema a: X.t(Any.t())
      end

      assert %{
               {Apix.Schema.Extensions.CoreTest.TestSchema16, :a, 0} => %Apix.Schema.Context{
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
                 module: Apix.Schema.Extensions.CoreTest.TestSchema16,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema16.__apix_schemas__()
    end

    test "expressions | parameter referencing" do
      defmodule TestSchema17 do
        use Apix.Schema

        schema a: p2(p1), params: [:p1, p2: 1]
      end

      assert %{
               {Apix.Schema.Extensions.CoreTest.TestSchema17, :a, 2} => %Apix.Schema.Context{
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
                 module: Apix.Schema.Extensions.CoreTest.TestSchema17,
                 schema: :a,
                 params: [{:p1, 0, nil}, {:p2, 1, nil}],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema17.__apix_schemas__()
    end
  end
end
