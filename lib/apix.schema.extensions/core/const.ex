defmodule Apix.Schema.Extensions.Core.Const do
  use Apix.Schema

  alias Apix.Schema.Ast

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
end
