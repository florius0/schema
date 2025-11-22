defmodule Apix.Schema.Extensions.CoreTest do
  use Apix.Schema.Case

  alias Apix.Schema.Ast
  alias Apix.Schema.Extensions.Core

  describe "#{inspect Core}" do
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

    test "expressions | empty expression" do
      defmodule TestSchema18 do
        use Apix.Schema

        schema a: _
      end

      assert %{
               {Apix.Schema.Extensions.CoreTest.TestSchema18, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: nil,
                   schema: nil,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.CoreTest.TestSchema18,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema18.__apix_schemas__()
    end

    test "normalize_ast!/2 | double negation" do
      ast = %Ast{
        module: Apix.Schema.Extensions.Core.Not,
        schema: :t,
        args: [
          %Ast{
            module: Apix.Schema.Extensions.Core.Not,
            schema: :t,
            args: [
              %Ast{module: Apix.Schema.Extensions.Core.Any, schema: :t, args: []}
            ]
          }
        ]
      }

      assert %Ast{module: Apix.Schema.Extensions.Core.Any, schema: :t, args: []} =
               Core.normalize_ast!(
                 nil,
                 ast
               )
    end

    test "normalize_ast!/2 | identity" do
      const_one = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: [1]}
      const_two = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: [2]}
      const_three = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: [3]}
      const_four = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: [4]}
      any = %Ast{module: Apix.Schema.Extensions.Core.Any, schema: :t, args: []}
      none = %Ast{module: Apix.Schema.Extensions.Core.None, schema: :t, args: []}

      assert ^const_one =
               Core.normalize_ast!(
                 nil,
                 %Ast{
                   module: Apix.Schema.Extensions.Core.And,
                   schema: :t,
                   args: [const_one, any]
                 }
               )

      assert ^const_one =
               Core.normalize_ast!(
                 nil,
                 %Ast{
                   module: Apix.Schema.Extensions.Core.And,
                   schema: :t,
                   args: [any, const_one]
                 }
               )

      assert ^none =
               Core.normalize_ast!(
                 nil,
                 %Ast{
                   module: Apix.Schema.Extensions.Core.And,
                   schema: :t,
                   args: [const_two, none]
                 }
               )

      assert ^none =
               Core.normalize_ast!(
                 nil,
                 %Ast{
                   module: Apix.Schema.Extensions.Core.And,
                   schema: :t,
                   args: [none, const_two]
                 }
               )

      assert ^const_three =
               Core.normalize_ast!(
                 nil,
                 %Ast{
                   module: Apix.Schema.Extensions.Core.Or,
                   schema: :t,
                   args: [const_three, none]
                 }
               )

      assert ^const_three =
               Core.normalize_ast!(
                 nil,
                 %Ast{
                   module: Apix.Schema.Extensions.Core.Or,
                   schema: :t,
                   args: [none, const_three]
                 }
               )

      assert %Ast{module: Apix.Schema.Extensions.Core.Any, schema: :t, args: []} =
               Core.normalize_ast!(
                 nil,
                 %Ast{
                   module: Apix.Schema.Extensions.Core.Or,
                   schema: :t,
                   args: [const_four, any]
                 }
               )

      assert %Ast{module: Apix.Schema.Extensions.Core.Any, schema: :t, args: []} =
               Core.normalize_ast!(
                 nil,
                 %Ast{
                   module: Apix.Schema.Extensions.Core.Or,
                   schema: :t,
                   args: [any, const_four]
                 }
               )
    end

    test "normalize_ast!/2 | absorption" do
      const_a = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: [:a]}
      const_b = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: [:b]}
      const_p = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: [:p]}
      const_x = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: [:x]}
      const_y = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: [:y]}
      const_z = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: [:z]}

      and_expression = %Ast{
        module: Apix.Schema.Extensions.Core.And,
        schema: :t,
        args: [
          const_a,
          %Ast{module: Apix.Schema.Extensions.Core.Or, schema: :t, args: [const_a, const_b]}
        ]
      }

      or_expression = %Ast{
        module: Apix.Schema.Extensions.Core.Or,
        schema: :t,
        args: [
          const_x,
          %Ast{module: Apix.Schema.Extensions.Core.And, schema: :t, args: [const_x, const_y]}
        ]
      }

      and_expression_flipped = %Ast{
        module: Apix.Schema.Extensions.Core.And,
        schema: :t,
        args: [
          %Ast{module: Apix.Schema.Extensions.Core.Or, schema: :t, args: [const_a, const_b]},
          const_a
        ]
      }

      or_expression_flipped = %Ast{
        module: Apix.Schema.Extensions.Core.Or,
        schema: :t,
        args: [
          %Ast{module: Apix.Schema.Extensions.Core.And, schema: :t, args: [const_x, const_y]},
          const_x
        ]
      }

      no_absorption = %Ast{
        module: Apix.Schema.Extensions.Core.And,
        schema: :t,
        args: [
          %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: [:p]},
          %Ast{module: Apix.Schema.Extensions.Core.Or, schema: :t, args: [const_y, const_z]}
        ]
      }

      and_no_absorption_flipped = %Ast{
        module: Apix.Schema.Extensions.Core.And,
        schema: :t,
        args: [
          %Ast{module: Apix.Schema.Extensions.Core.Or, schema: :t, args: [const_y, const_z]},
          const_p
        ]
      }

      or_no_absorption = %Ast{
        module: Apix.Schema.Extensions.Core.Or,
        schema: :t,
        args: [
          const_p,
          %Ast{module: Apix.Schema.Extensions.Core.And, schema: :t, args: [const_y, const_z]}
        ]
      }

      or_no_absorption_flipped = %Ast{
        module: Apix.Schema.Extensions.Core.Or,
        schema: :t,
        args: [
          %Ast{module: Apix.Schema.Extensions.Core.And, schema: :t, args: [const_y, const_z]},
          const_p
        ]
      }

      assert ^const_a =
               Core.normalize_ast!(
                 nil,
                 and_expression
               )

      assert ^const_x =
               Core.normalize_ast!(
                 nil,
                 or_expression
               )

      assert ^const_a =
               Core.normalize_ast!(
                 nil,
                 and_expression_flipped
               )

      assert ^const_x =
               Core.normalize_ast!(
                 nil,
                 or_expression_flipped
               )

      assert ^no_absorption =
               Core.normalize_ast!(
                 nil,
                 no_absorption
               )

      assert ^and_no_absorption_flipped =
               Core.normalize_ast!(
                 nil,
                 and_no_absorption_flipped
               )

      assert ^or_no_absorption =
               Core.normalize_ast!(
                 nil,
                 or_no_absorption
               )

      assert ^or_no_absorption_flipped =
               Core.normalize_ast!(
                 nil,
                 or_no_absorption_flipped
               )
    end

    test "normalize_ast!/2 | idempotence" do
      const_a = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: [:a]}
      const_b = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: [:b]}

      assert ^const_a =
               Core.normalize_ast!(
                 nil,
                 %Ast{
                   module: Apix.Schema.Extensions.Core.And,
                   schema: :t,
                   args: [const_a, const_a]
                 }
               )

      assert ^const_b =
               Core.normalize_ast!(
                 nil,
                 %Ast{
                   module: Apix.Schema.Extensions.Core.Or,
                   schema: :t,
                   args: [const_b, const_b]
                 }
               )
    end

    test "normalize_ast!/2 | compact" do
      const_a = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: [:a]}
      const_b = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: [:b]}
      const_c = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: [:c]}
      const_d = %Ast{module: Apix.Schema.Extensions.Core.Const, schema: :t, args: [:d]}

      ast =
        %Ast{
          module: Apix.Schema.Extensions.Core.Or,
          schema: :t,
          args: [
            %Ast{module: Apix.Schema.Extensions.Core.And, schema: :t, args: [const_a, const_b]},
            %Ast{module: Apix.Schema.Extensions.Core.And, schema: :t, args: [const_a, const_c]}
          ]
        }

      expected = %Ast{
        module: Apix.Schema.Extensions.Core.And,
        schema: :t,
        args: [
          const_a,
          %Ast{module: Apix.Schema.Extensions.Core.Or, schema: :t, args: [const_b, const_c]}
        ]
      }

      assert ^expected =
               Core.normalize_ast!(
                 nil,
                 ast
               )

      ast_right_match =
        %Ast{
          module: Apix.Schema.Extensions.Core.Or,
          schema: :t,
          args: [
            %Ast{module: Apix.Schema.Extensions.Core.And, schema: :t, args: [const_a, const_b]},
            %Ast{module: Apix.Schema.Extensions.Core.And, schema: :t, args: [const_c, const_a]}
          ]
        }

      assert %Ast{
               module: Apix.Schema.Extensions.Core.And,
               schema: :t,
               args: [
                 ^const_a,
                 %Ast{module: Apix.Schema.Extensions.Core.Or, schema: :t, args: [^const_b, ^const_c]}
               ]
             } =
               Core.normalize_ast!(
                 nil,
                 ast_right_match
               )

      ast_middle_match =
        %Ast{
          module: Apix.Schema.Extensions.Core.Or,
          schema: :t,
          args: [
            %Ast{module: Apix.Schema.Extensions.Core.And, schema: :t, args: [const_a, const_b]},
            %Ast{module: Apix.Schema.Extensions.Core.And, schema: :t, args: [const_b, const_c]}
          ]
        }

      assert %Ast{
               module: Apix.Schema.Extensions.Core.And,
               schema: :t,
               args: [
                 ^const_b,
                 %Ast{module: Apix.Schema.Extensions.Core.Or, schema: :t, args: [^const_a, ^const_c]}
               ]
             } =
               Core.normalize_ast!(
                 nil,
                 ast_middle_match
               )

      ast_last_match =
        %Ast{
          module: Apix.Schema.Extensions.Core.Or,
          schema: :t,
          args: [
            %Ast{module: Apix.Schema.Extensions.Core.And, schema: :t, args: [const_a, const_b]},
            %Ast{module: Apix.Schema.Extensions.Core.And, schema: :t, args: [const_c, const_b]}
          ]
        }

      assert %Ast{
               module: Apix.Schema.Extensions.Core.And,
               schema: :t,
               args: [
                 ^const_b,
                 %Ast{module: Apix.Schema.Extensions.Core.Or, schema: :t, args: [^const_a, ^const_c]}
               ]
             } =
               Core.normalize_ast!(
                 nil,
                 ast_last_match
               )

      no_compact =
        %Ast{
          module: Apix.Schema.Extensions.Core.Or,
          schema: :t,
          args: [
            %Ast{module: Apix.Schema.Extensions.Core.And, schema: :t, args: [const_a, const_b]},
            %Ast{module: Apix.Schema.Extensions.Core.And, schema: :t, args: [const_c, const_d]}
          ]
        }

      assert ^no_compact =
               Core.normalize_ast!(
                 nil,
                 no_compact
               )
    end
  end
end
