defmodule Apix.Schema.Extensions.Core.TypeGraph.Validator do
  alias Apix.Schema.Extensions.Core.TypeGraph

  @moduledoc """
  Validator & Task

  This module defines a `Task` to call `#{inspect TypeGraph}.validate!/0` on application start.
  """
  @spec child_spec(keyword()) :: Supervisor.child_spec()
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      restart: :temporary
    }
  end

  @doc """
  Starts `#{inspect TypeGraph}.validate!/0`.
  """
  @spec start_link(keyword()) :: {:ok, pid()}
  def start_link(_opts), do: Task.start_link(&TypeGraph.validate!/0)
end
