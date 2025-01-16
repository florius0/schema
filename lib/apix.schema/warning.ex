defmodule Apix.Schema.Warning do
  alias Apix.Schema.Ast.Meta

  @moduledoc """
  Warning type and common functions
  """

  @typedoc """
  Warning.

  Every Warning must implement `#{inspect Exception}` behaviour.
  """
  @type t() :: %{
          __struct__: module(),
          __exception__: true,
          message: String.t(),
          meta: Meta.t() | nil
        }

  @doc """
  Prints a warning using `#{inspect IO}.warn/2` in order for compile to track warnings
  """
  @spec print(t()) :: :ok
  def print(warning) do
    opts =
      case warning.meta do
        %Meta{} = m ->
          m
          |> Map.from_struct()
          |> Keyword.new()

        _ ->
          [file: "<no file>"]
      end

    IO.warn(warning.message, opts)
  end
end
