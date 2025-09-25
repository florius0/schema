defmodule Apix.Schema.Application do
  use Application

  @moduledoc false

  @doc false
  @impl Application
  def start(_type, _args) do
    [
      Apix.Schema.Extensions.TypeGraph.Graph,
      Apix.Schema.Extensions.TypeGraph.OnCompilation
    ]
    |> Supervisor.start_link(strategy: :one_for_one, name: Empay.Supervisor)
  end
end
