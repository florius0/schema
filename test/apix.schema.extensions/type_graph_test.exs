defmodule Apix.Schema.Extensions.TypeGraphTest do
  use Apix.Schema.Case

  alias Apix.Schema.Extensions.TypeGraph

  alias Apix.Schema.Extensions.TypeGraph.Errors.FullyRecursiveAstError
  alias Apix.Schema.Extensions.TypeGraph.Errors.UndefinedReferenceAstError

  alias Apix.Schema.Extensions.TypeGraph.Warnings.ReducibleAstWarning

  alias Apix.Schema.Ast
  alias Apix.Schema.Ast.Meta
  alias Apix.Schema.Context

  describe "#{inspect Apix.Schema.Extensions.TypeGraph}" do
    test "expressions | relate" do
      defmodule RelateHelper do
        def remote_relate(it, to), do: [{:remote_capture, it, to}]

        def tuple_mfa(it, to, _tag), do: [{:mfa_relate, it, to}]
      end

      defmodule TestSchema1 do
        use Apix.Schema

        schema a: Any.t()
      end

      defmodule TestSchema2 do
        use Apix.Schema

        schema a: Any.t() do
          relate it, to do
            [
              {:test1, it, to}
            ]
          end
        end
      end

      defmodule TestSchema3 do
        use Apix.Schema

        schema a: TestSchema2.a() do
          relate it, to do
            [
              {:test2, it, to}
            ]
          end
        end
      end

      defmodule TestSchema4 do
        use Apix.Schema

        schema a: Any.t() do
          relate it, to when :some == to do
            [
              {:test3, it, :some}
            ]
          end
        end
      end

      defmodule TestSchema5 do
        use Apix.Schema

        schema a: Any.t() do
          relate it, to when is_atom(to) do
            [
              {:guarded, it, to}
            ]
          end
        end
      end

      defmodule TestSchema6 do
        use Apix.Schema

        schema a: Any.t() do
          relate &Apix.Schema.Extensions.TypeGraphTest.RelateHelper.remote_relate/2
        end
      end

      defmodule TestSchema7 do
        use Apix.Schema

        def local_capture(it, to), do: [{:local_capture, it, to}]

        schema a: Any.t() do
          relate &local_capture/2
        end
      end

      defmodule TestSchema8 do
        use Apix.Schema

        schema a: Any.t() do
          relate {Apix.Schema.Extensions.TypeGraphTest.RelateHelper, :tuple_mfa, [:smth]}
        end
      end

      assert [
               {:subtype, %Context{module: TestSchema1, schema: :a, params: []}, :to},
               {:supertype, :to, %Context{module: TestSchema1, schema: :a, params: []}},
               {:subtype, %Context{module: TestSchema1, schema: :a, params: []}, %Context{module: TestSchema1, schema: :a, params: []}},
               {:supertype, %Context{module: TestSchema1, schema: :a, params: []}, %Context{module: TestSchema1, schema: :a, params: []}}
             ] =
               %Context{module: TestSchema1, schema: :a, params: []}
               |> TypeGraph.relate(:to)

      assert [
               {:subtype, %Ast{module: TestSchema1, schema: :a, args: []}, :to},
               {:supertype, :to, %Ast{module: TestSchema1, schema: :a, args: []}},
               {:subtype, %Ast{module: TestSchema1, schema: :a, args: []}, %Ast{module: TestSchema1, schema: :a, args: []}},
               {:supertype, %Ast{module: TestSchema1, schema: :a, args: []}, %Ast{module: TestSchema1, schema: :a, args: []}}
             ] =
               %Ast{module: TestSchema1, schema: :a, args: []}
               |> TypeGraph.relate(:to)

      assert [
               {:test1, %Context{module: TestSchema2, schema: :a, params: []}, :to}
             ] =
               %Context{module: TestSchema2, schema: :a, params: []}
               |> TypeGraph.relate(:to)

      assert [
               {:test1, %Ast{module: TestSchema2, schema: :a, args: []}, :to}
             ] =
               %Ast{module: TestSchema2, schema: :a, args: []}
               |> TypeGraph.relate(:to)

      assert [
               {:test2, %Context{module: TestSchema3, schema: :a, params: []}, :to}
             ] =
               %Context{module: TestSchema3, schema: :a, params: []}
               |> TypeGraph.relate(:to)

      assert [
               {:test2, %Ast{module: TestSchema3, schema: :a, args: []}, :to}
             ] =
               %Ast{module: TestSchema3, schema: :a, args: []}
               |> TypeGraph.relate(:to)

      assert [] =
               %Context{module: TestSchema4, schema: :a, params: []}
               |> TypeGraph.relate(:to)

      assert [] =
               %Ast{module: TestSchema4, schema: :a, args: []}
               |> TypeGraph.relate(:to)

      assert [
               {:test3, %Context{module: TestSchema4, schema: :a, params: []}, :some}
             ] =
               %Context{module: TestSchema4, schema: :a, params: []}
               |> TypeGraph.relate(:some)

      assert [
               {:test3, %Ast{module: TestSchema4, schema: :a, args: []}, :some}
             ] =
               %Ast{module: TestSchema4, schema: :a, args: []}
               |> TypeGraph.relate(:some)

      assert [
               {:guarded, %Context{module: TestSchema5, schema: :a, params: []}, :ok}
             ] =
               %Context{module: TestSchema5, schema: :a, params: []}
               |> TypeGraph.relate(:ok)

      assert [] =
               %Context{module: TestSchema5, schema: :a, params: []}
               |> TypeGraph.relate(%Context{module: TestSchema1, schema: :a, params: []})

      assert [
               {:remote_capture, %Context{module: TestSchema6, schema: :a, params: []}, :peer}
             ] =
               %Context{module: TestSchema6, schema: :a, params: []}
               |> TypeGraph.relate(:peer)

      assert [
               {:remote_capture, %Ast{module: TestSchema6, schema: :a, args: []}, :peer}
             ] =
               %Ast{module: TestSchema6, schema: :a, args: []}
               |> TypeGraph.relate(:peer)

      assert [
               {:local_capture, %Context{module: TestSchema7, schema: :a, params: []}, :peer}
             ] =
               %Context{module: TestSchema7, schema: :a, params: []}
               |> TypeGraph.relate(:peer)

      assert [
               {:local_capture, %Ast{module: TestSchema7, schema: :a, args: []}, :peer}
             ] =
               %Ast{module: TestSchema7, schema: :a, args: []}
               |> TypeGraph.relate(:peer)

      assert [
               {:mfa_relate, %Context{module: TestSchema8, schema: :a, params: []}, :peer}
             ] =
               %Context{module: TestSchema8, schema: :a, params: []}
               |> TypeGraph.relate(:peer)

      assert [
               {:mfa_relate, %Ast{module: TestSchema8, schema: :a, args: []}, :peer}
             ] =
               %Ast{module: TestSchema8, schema: :a, args: []}
               |> TypeGraph.relate(:peer)
    end

    test "expressions | relationship" do
      defmodule RelationshipHelper do
        def remote_relationship(it, peer, existing), do: [{:remote_relationship, it, peer} | existing]
        def tuple_relationship(it, peer, existing, _tag), do: [{:tuple_relationship, it, peer} | existing]
      end

      defmodule TestSchema9 do
        use Apix.Schema

        schema a: Any.t()
      end

      defmodule TestSchema10 do
        use Apix.Schema

        schema a: Any.t() do
          relationship it, peer, existing do
            [
              {:test_relationship, it, peer}
              | existing
            ]
          end
        end
      end

      defmodule TestSchema11 do
        use Apix.Schema

        schema a: Any.t() do
          relationship it, peer, existing when is_atom(peer) do
            [
              {:guarded_relationship, it, peer}
              | existing
            ]
          end
        end
      end

      defmodule TestSchema12 do
        use Apix.Schema

        schema a: Any.t() do
          relationship &Apix.Schema.Extensions.TypeGraphTest.RelationshipHelper.remote_relationship/3
        end
      end

      defmodule TestSchema13 do
        use Apix.Schema

        def local_relationship(it, peer, existing), do: [{:local_relationship, it, peer} | existing]

        schema a: Any.t() do
          relationship &local_relationship/3
        end
      end

      defmodule TestSchema14 do
        use Apix.Schema

        schema a: Any.t() do
          relationship {Apix.Schema.Extensions.TypeGraphTest.RelationshipHelper, :tuple_relationship, [:tagged]}
        end
      end

      assert [:existing] =
               %Context{module: TestSchema9, schema: :a, params: []}
               |> TypeGraph.relationship(:peer, [:existing])

      assert [:existing] =
               %Ast{module: TestSchema9, schema: :a, args: []}
               |> TypeGraph.relationship(:peer, [:existing])

      assert [
               {:test_relationship, %Context{module: TestSchema10, schema: :a, params: []}, :peer},
               :existing
             ] =
               %Context{module: TestSchema10, schema: :a, params: []}
               |> TypeGraph.relationship(:peer, [:existing])

      assert [
               {:test_relationship, %Ast{module: TestSchema10, schema: :a, args: []}, :peer},
               :existing
             ] =
               %Ast{module: TestSchema10, schema: :a, args: []}
               |> TypeGraph.relationship(:peer, [:existing])

      assert [
               {:guarded_relationship, %Context{module: TestSchema11, schema: :a, params: []}, :peer},
               :existing
             ] =
               %Context{module: TestSchema11, schema: :a, params: []}
               |> TypeGraph.relationship(:peer, [:existing])

      assert [:existing] =
               %Context{module: TestSchema11, schema: :a, params: []}
               |> TypeGraph.relationship(%Context{module: TestSchema9, schema: :a, params: []}, [:existing])

      assert [
               {:guarded_relationship, %Ast{module: TestSchema11, schema: :a, args: []}, :peer},
               :existing
             ] =
               %Ast{module: TestSchema11, schema: :a, args: []}
               |> TypeGraph.relationship(:peer, [:existing])

      assert [:existing] =
               %Ast{module: TestSchema11, schema: :a, args: []}
               |> TypeGraph.relationship(%Ast{module: TestSchema9, schema: :a, args: []}, [:existing])

      assert [
               {:remote_relationship, %Context{module: TestSchema12, schema: :a, params: []}, :peer},
               :existing
             ] =
               %Context{module: TestSchema12, schema: :a, params: []}
               |> TypeGraph.relationship(:peer, [:existing])

      assert [
               {:remote_relationship, %Ast{module: TestSchema12, schema: :a, args: []}, :peer},
               :existing
             ] =
               %Ast{module: TestSchema12, schema: :a, args: []}
               |> TypeGraph.relationship(:peer, [:existing])

      assert [
               {:local_relationship, %Context{module: TestSchema13, schema: :a, params: []}, :peer},
               :existing
             ] =
               %Context{module: TestSchema13, schema: :a, params: []}
               |> TypeGraph.relationship(:peer, [:existing])

      assert [
               {:local_relationship, %Ast{module: TestSchema13, schema: :a, args: []}, :peer},
               :existing
             ] =
               %Ast{module: TestSchema13, schema: :a, args: []}
               |> TypeGraph.relationship(:peer, [:existing])

      assert [
               {:tuple_relationship, %Context{module: TestSchema14, schema: :a, params: []}, :peer},
               :existing
             ] =
               %Context{module: TestSchema14, schema: :a, params: []}
               |> TypeGraph.relationship(:peer, [:existing])

      assert [
               {:tuple_relationship, %Ast{module: TestSchema14, schema: :a, args: []}, :peer},
               :existing
             ] =
               %Ast{module: TestSchema14, schema: :a, args: []}
               |> TypeGraph.relationship(:peer, [:existing])
    end

    test "subtype?/2" do
      defmodule TestSchema15 do
        use Apix.Schema

        schema a: Any.t()
        schema b: Any.t()
        schema c: Any.t()
        schema d: Any.t()

        schema x: a() or b() or c()
        schema y: a() and b() and c()
        schema z: not d()
      end

      a = Apix.Schema.get_schema(TestSchema15, :a, 0)
      b = Apix.Schema.get_schema(TestSchema15, :b, 0)
      c = Apix.Schema.get_schema(TestSchema15, :c, 0)
      d = Apix.Schema.get_schema(TestSchema15, :d, 0)
      x = Apix.Schema.get_schema(TestSchema15, :x, 0)
      y = Apix.Schema.get_schema(TestSchema15, :y, 0)
      z = Apix.Schema.get_schema(TestSchema15, :z, 0)

      assert TypeGraph.subtype?(a, a)
      assert TypeGraph.subtype?(b, b)
      assert TypeGraph.subtype?(c, c)
      assert TypeGraph.subtype?(d, d)
      assert TypeGraph.subtype?(x, x)
      assert TypeGraph.subtype?(y, y)

      assert TypeGraph.subtype?(a.ast, a)
      assert TypeGraph.subtype?(b.ast, b)
      assert TypeGraph.subtype?(c.ast, c)
      assert TypeGraph.subtype?(d.ast, d)
      assert TypeGraph.subtype?(x.ast, x)
      assert TypeGraph.subtype?(y.ast, y)

      assert TypeGraph.subtype?(a.ast, a.ast)
      assert TypeGraph.subtype?(b.ast, b.ast)
      assert TypeGraph.subtype?(c.ast, c.ast)
      assert TypeGraph.subtype?(d.ast, d.ast)
      assert TypeGraph.subtype?(x.ast, x.ast)
      assert TypeGraph.subtype?(y.ast, y.ast)

      assert TypeGraph.subtype?(a, x.ast)
      assert TypeGraph.subtype?(b, x.ast)
      assert TypeGraph.subtype?(c, x.ast)

      assert TypeGraph.subtype?(%Ast{module: TestSchema15, schema: :a, args: []}, x.ast)
      assert TypeGraph.subtype?(%Ast{module: TestSchema15, schema: :b, args: []}, x.ast)
      assert TypeGraph.subtype?(%Ast{module: TestSchema15, schema: :c, args: []}, x.ast)

      assert TypeGraph.subtype?(y.ast, %Ast{module: TestSchema15, schema: :a, args: []})
      assert TypeGraph.subtype?(y.ast, %Ast{module: TestSchema15, schema: :b, args: []})
      assert TypeGraph.subtype?(y.ast, %Ast{module: TestSchema15, schema: :c, args: []})

      refute TypeGraph.subtype?(d, z)
    end

    test "supertype?/2" do
      defmodule TestSchema16 do
        use Apix.Schema

        schema a: Any.t()
        schema b: Any.t()
        schema c: Any.t()
        schema d: Any.t()

        schema x: a() or b() or c()
        schema y: a() and b() and c()
        schema z: not d()
      end

      a = Apix.Schema.get_schema(TestSchema16, :a, 0)
      b = Apix.Schema.get_schema(TestSchema16, :b, 0)
      c = Apix.Schema.get_schema(TestSchema16, :c, 0)
      d = Apix.Schema.get_schema(TestSchema16, :d, 0)
      x = Apix.Schema.get_schema(TestSchema16, :x, 0)
      y = Apix.Schema.get_schema(TestSchema16, :y, 0)
      z = Apix.Schema.get_schema(TestSchema16, :z, 0)

      assert TypeGraph.supertype?(a, a)
      assert TypeGraph.supertype?(b, b)
      assert TypeGraph.supertype?(c, c)
      assert TypeGraph.supertype?(d, d)
      assert TypeGraph.supertype?(x, x)
      assert TypeGraph.supertype?(y, y)

      assert TypeGraph.supertype?(a.ast, a)
      assert TypeGraph.supertype?(b.ast, b)
      assert TypeGraph.supertype?(c.ast, c)
      assert TypeGraph.supertype?(d.ast, d)
      assert TypeGraph.supertype?(x.ast, x)
      assert TypeGraph.supertype?(y.ast, y)

      assert TypeGraph.supertype?(a.ast, a.ast)
      assert TypeGraph.supertype?(b.ast, b.ast)
      assert TypeGraph.supertype?(c.ast, c.ast)
      assert TypeGraph.supertype?(d.ast, d.ast)
      assert TypeGraph.supertype?(x.ast, x.ast)
      assert TypeGraph.supertype?(y.ast, y.ast)

      assert TypeGraph.supertype?(a, x.ast)
      assert TypeGraph.supertype?(b, x.ast)
      assert TypeGraph.supertype?(c, x.ast)

      assert TypeGraph.supertype?(%Ast{module: TestSchema16, schema: :a, args: []}, x.ast)
      assert TypeGraph.supertype?(%Ast{module: TestSchema16, schema: :b, args: []}, x.ast)
      assert TypeGraph.supertype?(%Ast{module: TestSchema16, schema: :c, args: []}, x.ast)

      assert TypeGraph.supertype?(y.ast, %Ast{module: TestSchema16, schema: :a, args: []})
      assert TypeGraph.supertype?(y.ast, %Ast{module: TestSchema16, schema: :b, args: []})
      assert TypeGraph.supertype?(y.ast, %Ast{module: TestSchema16, schema: :c, args: []})

      refute TypeGraph.supertype?(d, z)
    end

    test "path_exists?/3" do
      defmodule TestSchema17 do
        use Apix.Schema

        schema a: Any.t()
        schema b: a()
        schema c: b()
      end

      a = Apix.Schema.get_schema(TestSchema17, :a, 0)
      b = Apix.Schema.get_schema(TestSchema17, :b, 0)
      c = Apix.Schema.get_schema(TestSchema17, :c, 0)

      assert TypeGraph.path_exists?(b, a, &(&1 == :references))
      assert TypeGraph.path_exists?(c, b, &(&1 == :references))
      assert TypeGraph.path_exists?(c, a, &(&1 == :references))
    end

    test "#{inspect FullyRecursiveAstError}" do
      exception =
        assert_raise FullyRecursiveAstError, fn ->
          defmodule TestSchema18 do
            use Apix.Schema

            schema a: a()
          end
        end

      assert %FullyRecursiveAstError{
               ast: %Ast{module: Apix.Schema.Extensions.TypeGraphTest.TestSchema18, schema: :a, args: []},
               meta: %Meta{}
             } = exception

      assert Exception.message(exception) =~ "is fully recursive"

      Apix.Schema.Case.clean()

      exception =
        assert_raise FullyRecursiveAstError, fn ->
          defmodule TestSchema19 do
            use Apix.Schema

            schema a: b()
            schema b: a()
          end
        end

      assert %FullyRecursiveAstError{
               ast: %Ast{module: Apix.Schema.Extensions.TypeGraphTest.TestSchema19, schema: :a, args: []},
               meta: %Meta{}
             } = exception

      assert Exception.message(exception) =~ "is fully recursive"

      Apix.Schema.Case.clean()

      exception =
        assert_raise FullyRecursiveAstError, fn ->
          defmodule TestSchema20 do
            use Apix.Schema

            schema a: Map.t() do
              field :a, a()
            end
          end
        end

      assert %FullyRecursiveAstError{
               ast: %Ast{module: Apix.Schema.Extensions.Elixir.Map, schema: :t, args: [_]},
               meta: %Meta{}
             } = exception

      assert Exception.message(exception) =~ "is fully recursive"

      Apix.Schema.Case.clean()

      exception =
        assert_raise FullyRecursiveAstError, fn ->
          defmodule TestSchema21 do
            use Apix.Schema

            schema a: Map.t() do
              field :a, Map.t() do
                field :a, a()
              end
            end
          end
        end

      assert %FullyRecursiveAstError{
               ast: %Ast{module: Apix.Schema.Extensions.Elixir.Map, schema: :t, args: [_]},
               meta: %Meta{}
             } = exception

      assert Exception.message(exception) =~ "is fully recursive"

      Apix.Schema.Case.clean()

      defmodule TestSchema22 do
        use Apix.Schema

        schema a: a() or Any.t()

        schema b: Map.t() do
          field :b, b() or Any.t()
        end

        schema c: Map.t() do
          field :c, Map.t() do
            field :c, c() or Any.t()
          end
        end
      end
    end

    test "#{inspect UndefinedReferenceAstError}" do
      exception =
        assert_raise UndefinedReferenceAstError,
                     fn ->
                       defmodule TestSchema23 do
                         use Apix.Schema

                         schema a: b()
                       end
                     end

      assert %UndefinedReferenceAstError{
               ast: %Ast{module: Apix.Schema.Extensions.TypeGraphTest.TestSchema23, schema: :b, args: []},
               meta: %Meta{}
             } = exception

      assert Exception.message(exception) =~ "is undefined"
    end

    test "#{inspect ReducibleAstWarning}" do
      defmodule TestSchema24 do
        # use Apix.Schema

        # schema a: Any.t() or Any.t()
      end
    end
  end
end
