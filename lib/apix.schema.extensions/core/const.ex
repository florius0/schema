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
  Wraps value into `t:#{inspect __MODULE__}.t/0` if it isn't `#{inspect Ast}.t/0` or `t:#{inspect Context}.t/0`.
  """
  def maybe_wrap(%Ast{} = ast), do: ast
  def maybe_wrap(%Context{} = context), do: context

  def maybe_wrap(arg, ast \\ %Ast{}) do
    struct(ast,
      module: Const,
      schema: :t,
      args: [arg]
    )
  end
end
