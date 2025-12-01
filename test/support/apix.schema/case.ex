defmodule Apix.Schema.Case do
  use ExUnit.CaseTemplate

  alias Apix.Schema.Extensions.TypeGraph.Graph

  @moduledoc false

  setup do
    clean()
    :ok
  end

  def clean do
    Graph.vertices()
    |> Graph.del_vertices()
  end
end
