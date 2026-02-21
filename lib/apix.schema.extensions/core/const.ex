defmodule Apix.Schema.Extensions.Core.Const do
  use Apix.Schema

  alias Apix.Schema.Ast
  alias Apix.Schema.Context

  @moduledoc false

  schema t: Any.t(), params: [:value] do
    validate it == value()
  end

  @doc """
  Unwraps the value.
  """
  @spec value(any()) :: any() | nil
  def value(%Ast{module: __MODULE__, schema: :t, args: [value]}), do: value
  def value(_ast), do: nil

  @doc group: "Internal"
  @doc """
  Wraps value into `t:#{inspect __MODULE__}.t/0` if it isn't `#{inspect Ast}.t/0` or `t:#{inspect Context}.t/0` or ast/context keyword.
  """
  def maybe_wrap(arg, ast \\ %Ast{})

  def maybe_wrap(%Ast{} = ast, _ast), do: ast
  def maybe_wrap(%Context{} = context, _ast), do: context
  def maybe_wrap([%Ast{} | _rest] = ast_list, _ast), do: ast_list
  def maybe_wrap([%Context{} | _rest] = context_list, _ast), do: context_list
  def maybe_wrap([{key, %Ast{}} | _rest] = ast_keyword, _ast) when is_atom(key), do: ast_keyword
  def maybe_wrap([{key, %Context{}} | _rest] = context_keyword, _ast) when is_atom(key), do: context_keyword
  def maybe_wrap([{key, tuple} | _rest] = ast_keyword, _ast) when is_atom(key) and (is_struct(elem(tuple, 0), Ast) or is_struct(is_struct(elem(tuple, 1), Ast))), do: ast_keyword
  def maybe_wrap([{key, tuple} | _rest] = context_keyword, _ast) when is_atom(key) and (is_struct(elem(tuple, 0), Context) or is_struct(is_struct(elem(tuple, 1), Context))), do: context_keyword

  def maybe_wrap(arg, ast) do
    struct(ast,
      module: Const,
      schema: :t,
      args: [arg]
    )
  end
end
