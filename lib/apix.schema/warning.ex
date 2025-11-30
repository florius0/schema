defmodule Apix.Schema.Warning do
  alias Apix.Schema.Ast
  alias Apix.Schema.Ast.Meta
  alias Apix.Schema.Context

  @moduledoc """
  Warning type and common functions
  """

  @typedoc """
  Warning.

  Every Warning must implement `#{inspect Exception}` behaviour.
  """
  @type t() :: %{
          :__struct__ => module(),
          :__exception__ => true,
          :message => String.t(),
          optional(:ast) => Ast.t() | nil,
          optional(:context) => Context.t() | nil,
          optional(:meta) => Meta.t() | nil
        }

  @doc """
  Prints a warning using `#{inspect IO}.warn/2` in order for compile to track warnings
  """
  @spec print(t()) :: :ok
  def print(warning) do
    opts =
      case warning do
        %{meta: %Meta{} = m} ->
          m
          |> Map.from_struct()
          |> Keyword.new()

        _ ->
          [file: "<no file>"]
      end

    warning
    |> Exception.message()
    |> IO.warn(opts)
  end
end
