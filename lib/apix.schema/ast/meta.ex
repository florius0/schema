defmodule Apix.Schema.Ast.Meta do
  alias Apix.Schema.Ast
  alias Apix.Schema.Extension

  @moduledoc """
  Metadata of the AST and utilities to work with it.
  """

  @typedoc """
  Metadata struct

  ## Fields

  - `:file` – file the AST node was defined in.
  - `:line` – line the AST node was defined on.
  - `:module` – module the AST node was defined in.
  - `:generated_by` – `#{inspect Extension}` that generated the AST node.
  """

  @type opts() :: [
          {:elixir_ast, Macro.t()}
          | {:env, Macro.Env.t()}
          | {:file, String.t() | nil}
          | {:line, integer() | nil}
          | {:module, module() | nil}
          | {:generated_by, module() | nil}
        ]

  @type t() :: %__MODULE__{
          file: String.t() | nil,
          line: integer() | nil,
          module: module() | nil,
          generated_by: module() | nil
        }

  defstruct file: nil,
            line: nil,
            module: nil,
            generated_by: nil

  @doc """
  Helper function to put metadata in `t:#{inspect Ast}.t/0`.

  If invoked on anything else, just returns the value passed.
  """
  @spec maybe_put_in(maybe_ast, opts()) :: maybe_ast when maybe_ast: Ast.t() | any()
  def maybe_put_in(ast, opts \\ [])

  def maybe_put_in(%Ast{} = ast, opts), do: put_in_meta_field(ast, opts)
  def maybe_put_in(ast, _opts), do: ast

  @doc """
  Builds new `t:#{inspect __MODULE__}.t/0` from `t:opts/0`
  """
  @spec new(opts()) :: t()
  def new(opts) do
    {env, opts} = Keyword.pop(opts, :env)
    {elixir_ast, opts} = Keyword.pop(opts, :elixir_ast)

    %__MODULE__{
      file: get_file(env),
      module: get_module(env),
      line: get_line(elixir_ast, env)
    }
    |> struct(opts)
  end

  defp put_in_meta_field(struct, opts), do: struct(struct, meta: new(opts))

  defp get_file(%{file: file}), do: file
  defp get_file(_env), do: nil

  defp get_module(%{module: module}), do: module
  defp get_module(_env), do: nil

  defp get_line({_, meta, _}, %{line: line}), do: Keyword.get(meta, :line, line)
  defp get_line(_elixir_ast, %{line: line}), do: line
  defp get_line(_elixir_ast, _env), do: nil
end
