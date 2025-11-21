defmodule Apix.Schema.Extensions.ElixirTest do
  use Apix.Schema.Case

  describe "#{inspect Apix.Schema.Extensions.Elixir}" do
    test "delegates | Atom.t -> Apix.Schema.Extensions.Elixir.Atom.t" do
      defmodule TestSchema1 do
        use Apix.Schema

        schema a: Atom.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema1, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.Atom,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema1,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema1.__apix_schemas__()
    end

    test "delegates | String.t -> Apix.Schema.Extensions.Elixir.String.t" do
      defmodule TestSchema2 do
        use Apix.Schema

        schema a: String.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema2, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.String,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema2,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema2.__apix_schemas__()
    end

    test "delegates | Integer.t -> Apix.Schema.Extensions.Elixir.Integer.t" do
      defmodule TestSchema3 do
        use Apix.Schema

        schema a: Integer.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema3, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.Integer,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema3,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema3.__apix_schemas__()
    end

    test "delegates | Float.t -> Apix.Schema.Extensions.Elixir.Float.t" do
      defmodule TestSchema4 do
        use Apix.Schema

        schema a: Float.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema4, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.Float,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema4,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema4.__apix_schemas__()
    end

    test "delegates | Number.t -> Apix.Schema.Extensions.Elixir.Number.t" do
      defmodule TestSchema5 do
        use Apix.Schema

        schema a: Number.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema5, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.Number,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema5,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema5.__apix_schemas__()
    end

    test "delegates | Tuple.t -> Apix.Schema.Extensions.Elixir.Tuple.t" do
      defmodule TestSchema6 do
        use Apix.Schema

        schema a: Tuple.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema6, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.Tuple,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema6,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema6.__apix_schemas__()
    end

    test "delegates | List.t -> Apix.Schema.Extensions.Elixir.List.t" do
      defmodule TestSchema7 do
        use Apix.Schema

        schema a: List.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema7, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.List,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema7,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema7.__apix_schemas__()
    end

    test "delegates | Map.t -> Apix.Schema.Extensions.Elixir.Map.t" do
      defmodule TestSchema8 do
        use Apix.Schema

        schema a: Map.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema8, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.Map,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema8,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema8.__apix_schemas__()
    end

    test "delegates | Struct.t -> Apix.Schema.Extensions.Elixir.Struct.t" do
      defmodule TestSchema9 do
        use Apix.Schema

        schema a: Struct.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema9, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.Struct,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema9,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema9.__apix_schemas__()
    end

    test "delegates | Record.t -> Apix.Schema.Extensions.Elixir.Record.t" do
      defmodule TestSchema10 do
        use Apix.Schema

        schema a: Record.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema10, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.Record,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema10,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema10.__apix_schemas__()
    end

    test "delegates | MapSet.t -> Apix.Schema.Extensions.Elixir.MapSet.t" do
      defmodule TestSchema11 do
        use Apix.Schema

        schema a: MapSet.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema11, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.MapSet,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema11,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema11.__apix_schemas__()
    end

    test "delegates | Range.t -> Apix.Schema.Extensions.Elixir.Range.t" do
      defmodule TestSchema12 do
        use Apix.Schema

        schema a: Range.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema12, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.Range,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema12,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema12.__apix_schemas__()
    end

    test "delegates | Function.t -> Apix.Schema.Extensions.Elixir.Function.t" do
      defmodule TestSchema13 do
        use Apix.Schema

        schema a: Function.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema13, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.Function,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema13,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema13.__apix_schemas__()
    end

    test "delegates | Module.t -> Apix.Schema.Extensions.Elixir.Module.t" do
      defmodule TestSchema14 do
        use Apix.Schema

        schema a: Module.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema14, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.Module,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema14,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema14.__apix_schemas__()
    end

    test "delegates | PID.t -> Apix.Schema.Extensions.Elixir.PID.t" do
      defmodule TestSchema15 do
        use Apix.Schema

        schema a: PID.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema15, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.PID,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema15,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema15.__apix_schemas__()
    end

    test "delegates | Port.t -> Apix.Schema.Extensions.Elixir.Port.t" do
      defmodule TestSchema16 do
        use Apix.Schema

        schema a: Port.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema16, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.Port,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema16,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema16.__apix_schemas__()
    end

    test "delegates | Reference.t -> Apix.Schema.Extensions.Elixir.Reference.t" do
      defmodule TestSchema17 do
        use Apix.Schema

        schema a: Reference.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema17, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.Reference,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema17,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema17.__apix_schemas__()
    end

    test "delegates | Date.t -> Apix.Schema.Extensions.Elixir.Date.t" do
      defmodule TestSchema18 do
        use Apix.Schema

        schema a: Date.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema18, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.Date,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema18,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema18.__apix_schemas__()
    end

    test "delegates | Date.Range.t -> Apix.Schema.Extensions.Elixir.Date.Range.t" do
      defmodule TestSchema19 do
        use Apix.Schema

        schema a: Date.Range.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema19, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.Date.Range,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema19,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema19.__apix_schemas__()
    end

    test "delegates | Time.t -> Apix.Schema.Extensions.Elixir.Time.t" do
      defmodule TestSchema20 do
        use Apix.Schema

        schema a: Time.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema20, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.Time,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema20,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema20.__apix_schemas__()
    end

    test "delegates | DateTime.t -> Apix.Schema.Extensions.Elixir.DateTime.t" do
      defmodule TestSchema21 do
        use Apix.Schema

        schema a: DateTime.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema21, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.DateTime,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema21,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema21.__apix_schemas__()
    end

    test "delegates | NaiveDateTime.t -> Apix.Schema.Extensions.Elixir.NaiveDateTime.t" do
      defmodule TestSchema22 do
        use Apix.Schema

        schema a: NaiveDateTime.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema22, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.NaiveDateTime,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema22,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema22.__apix_schemas__()
    end

    test "delegates | Regex.t -> Apix.Schema.Extensions.Elixir.Regex.t" do
      defmodule TestSchema23 do
        use Apix.Schema

        schema a: Regex.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema23, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.Regex,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema23,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema23.__apix_schemas__()
    end

    test "delegates | URI.t -> Apix.Schema.Extensions.Elixir.URI.t" do
      defmodule TestSchema24 do
        use Apix.Schema

        schema a: URI.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema24, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.URI,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema24,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema24.__apix_schemas__()
    end

    test "delegates | Version.t -> Apix.Schema.Extensions.Elixir.Version.t" do
      defmodule TestSchema25 do
        use Apix.Schema

        schema a: Version.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema25, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.Version,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema25,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema25.__apix_schemas__()
    end

    test "delegates | Version.Requirement.t -> Apix.Schema.Extensions.Elixir.Version.Requirement." do
      defmodule TestSchema26 do
        use Apix.Schema

        schema a: Version.Requirement.t() do
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema26, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.Version.Requirement,
                   schema: :t,
                   args: [],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema26,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema26.__apix_schemas__()
    end

    test "expressions | item" do
      defmodule TestSchema27 do
        use Apix.Schema

        schema a: Tuple.t() do
          item Any.t()

          item Any.t(), flag: :a

          item Any.t() do
            shortdoc "Third element"
            doc "Third element of the tuple"
            example 42
          end

          item Any.t(), flag: :a do
            shortdoc "Fourth element"
            doc "Fourth element of the tuple"
            example 42
          end
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema27, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.Tuple,
                   schema: :t,
                   args: [
                     [
                       item: %Apix.Schema.Ast{
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
                       item: %Apix.Schema.Ast{
                         module: Apix.Schema.Extensions.Core.Any,
                         schema: :t,
                         args: [],
                         shortdoc: nil,
                         doc: nil,
                         examples: [],
                         validators: [],
                         flags: [flag: :a],
                         parameter?: false
                       },
                       item: %Apix.Schema.Ast{
                         module: Apix.Schema.Extensions.Core.Any,
                         schema: :t,
                         args: [],
                         shortdoc: "Third element",
                         doc: "Third element of the tuple",
                         examples: [42],
                         validators: [],
                         flags: [],
                         parameter?: false
                       },
                       item: %Apix.Schema.Ast{
                         module: Apix.Schema.Extensions.Core.Any,
                         schema: :t,
                         args: [],
                         shortdoc: "Fourth element",
                         doc: "Fourth element of the tuple",
                         examples: [42],
                         validators: [],
                         flags: [flag: :a],
                         parameter?: false
                       }
                     ]
                   ],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema27,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema27.__apix_schemas__()
    end

    test "expressions | rest" do
      defmodule TestSchema28 do
        use Apix.Schema

        schema a: Tuple.t() do
          rest Any.t()

          rest Any.t(), flag: :a

          rest Any.t() do
            shortdoc "Third element"
            doc "Third element of the tuple"
            example 42
          end

          rest Any.t(), flag: :a do
            shortdoc "Fourth element"
            doc "Fourth element of the tuple"
            example 42
          end
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema28, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.Tuple,
                   schema: :t,
                   args: [
                     [
                       rest: %Apix.Schema.Ast{
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
                       rest: %Apix.Schema.Ast{
                         module: Apix.Schema.Extensions.Core.Any,
                         schema: :t,
                         args: [],
                         shortdoc: nil,
                         doc: nil,
                         examples: [],
                         validators: [],
                         flags: [flag: :a],
                         parameter?: false
                       },
                       rest: %Apix.Schema.Ast{
                         module: Apix.Schema.Extensions.Core.Any,
                         schema: :t,
                         args: [],
                         shortdoc: "Third element",
                         doc: "Third element of the tuple",
                         examples: [42],
                         validators: [],
                         flags: [],
                         parameter?: false
                       },
                       rest: %Apix.Schema.Ast{
                         module: Apix.Schema.Extensions.Core.Any,
                         schema: :t,
                         args: [],
                         shortdoc: "Fourth element",
                         doc: "Fourth element of the tuple",
                         examples: [42],
                         validators: [],
                         flags: [flag: :a],
                         parameter?: false
                       }
                     ]
                   ],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema28,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema28.__apix_schemas__()
    end

    test "expressions | field" do
      defmodule TestSchema29 do
        use Apix.Schema

        schema a: Map.t() do
          field Any.t(), Any.t()

          field Any.t(), Any.t(), flag: :a

          field do
            key Any.t()
            value Any.t()
          end

          field do
            key Any.t() do
              shortdoc "Key"
              doc "Key of the field"
              example 42
            end

            value Any.t() do
              shortdoc "Value"
              doc "Value of the field"
              example 42
            end
          end

          field flag: :a do
            key Any.t()
            value Any.t()
          end

          field flag: :a do
            key Any.t() do
              shortdoc "Key"
              doc "Key of the field"
              example 42
            end

            value Any.t() do
              shortdoc "Value"
              doc "Value of the field"
              example 42
            end
          end
        end
      end

      assert %{
               {Apix.Schema.Extensions.ElixirTest.TestSchema29, :a, 0} => %Apix.Schema.Context{
                 ast: %Apix.Schema.Ast{
                   module: Apix.Schema.Extensions.Elixir.Map,
                   schema: :t,
                   args: [
                     [
                       field: {
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
                       },
                       field: {
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
                           flags: [flag: :a],
                           parameter?: false
                         }
                       },
                       field: {
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
                       },
                       field: {
                         %Apix.Schema.Ast{
                           module: Apix.Schema.Extensions.Core.Any,
                           schema: :t,
                           args: [],
                           shortdoc: "Key",
                           doc: "Key of the field",
                           examples: [42],
                           validators: [],
                           flags: [],
                           parameter?: false
                         },
                         %Apix.Schema.Ast{
                           module: Apix.Schema.Extensions.Core.Any,
                           schema: :t,
                           args: [],
                           shortdoc: "Value",
                           doc: "Value of the field",
                           examples: [42],
                           validators: [],
                           flags: [],
                           parameter?: false
                         }
                       },
                       field: {
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
                           flags: [flag: :a],
                           parameter?: false
                         }
                       },
                       field: {
                         %Apix.Schema.Ast{
                           module: Apix.Schema.Extensions.Core.Any,
                           schema: :t,
                           args: [],
                           shortdoc: "Key",
                           doc: "Key of the field",
                           examples: [42],
                           validators: [],
                           flags: [],
                           parameter?: false
                         },
                         %Apix.Schema.Ast{
                           module: Apix.Schema.Extensions.Core.Any,
                           schema: :t,
                           args: [],
                           shortdoc: "Value",
                           doc: "Value of the field",
                           examples: [42],
                           validators: [],
                           flags: [flag: :a],
                           parameter?: false
                         }
                       }
                     ]
                   ],
                   shortdoc: nil,
                   doc: nil,
                   examples: [],
                   validators: [],
                   flags: [],
                   parameter?: false
                 },
                 module: Apix.Schema.Extensions.ElixirTest.TestSchema29,
                 schema: :a,
                 params: [],
                 warnings: [],
                 errors: [],
                 flags: []
               }
             } = TestSchema29.__apix_schemas__()
    end
  end
end
