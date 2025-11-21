defmodule Apix.Schema.Extensions.TypeGraph.OnCompilation do
  alias Apix.Schema.Extensions.TypeGraph

  @moduledoc """
  OnCompilation Task.

  This module defines a `Task` to call `#{inspect TypeGraph}.on_compilation!/0` on application start.
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
  Starts `#{inspect TypeGraph}.on_compilation!/0`.
  """
  @spec start_link(keyword()) :: {:ok, pid()}
  def start_link(_opts), do: Task.start_link(&TypeGraph.on_compilation!/0)
end
