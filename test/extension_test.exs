defmodule Apix.Schema.ExtensionTest do
  use Apix.Schema.Case

  alias Apix.Schema.Ast
  alias Apix.Schema.Context
  alias Apix.Schema.Extension

  describe "#{inspect Extension}" do
    defmodule CallbackExtension do
      @behaviour Extension

      def manifest, do: %Extension{module: __MODULE__, delegates: []}

      def install!(%Context{} = context), do: struct(context, flags: [:installed])
      def require!, do: :required!
      def validate_ast!(%Context{} = context), do: struct(context, flags: [:validated])
      def expression!(_context, _elixir_ast, %Ast{} = ast, _literal?), do: struct(ast, flags: [:expressed])
      def normalize_ast!(_context, %Ast{} = ast), do: struct(ast, flags: [:normalized])
    end

    test "manifest/1" do
      manifest = %Extension{module: CallbackExtension, delegates: []}

      assert ^manifest = Extension.manifest(manifest)
      assert %Extension{module: CallbackExtension} = Extension.manifest(CallbackExtension)
    end

    test "install!/2" do
      assert %Context{flags: [:installed]} =
               Extension.install!(CallbackExtension.manifest(), %Context{})
    end

    test "require!/1" do
      assert :required! = Extension.require!(CallbackExtension.manifest())
    end

    test "validate_ast!/2" do
      assert %Context{flags: [:validated]} =
               Extension.validate_ast!(CallbackExtension.manifest(), %Context{})
    end

    test "expression!/5" do
      assert %Ast{flags: [:expressed]} =
               Extension.expression!(CallbackExtension.manifest(), %Context{}, :elixir_ast, %Ast{}, false)
    end

    test "normalize_ast!/3" do
      assert %Ast{flags: [:normalized]} =
               Extension.normalize_ast!(CallbackExtension.manifest(), %Context{}, %Ast{})
    end

    test "delegates_doc/1" do
      assert %Extension{}
             |> Extension.delegates_doc()
             |> String.contains?("no delegates")

      assert %Extension{
               module: __MODULE__,
               delegates: [
                 {
                   {Elixir.Any, :t},
                   {Apix.Schema.Extensions.Core.Any, :t}
                 }
               ]
             }
             |> Extension.delegates_doc()
             |> String.contains?("`Any.t` -> `Apix.Schema.Extensions.Core.Any.t`")
    end
  end
end
