defmodule Apix.Schema.Extensions.TypeGraph.Graph do
  use GenServer

  require Apix.Schema.Extensions.TypeGraph.Definition
  Apix.Schema.Extensions.TypeGraph.Definition.define()

  @moduledoc """
  Low level graph utilities.

  This module defines a `GenServer` to hold `:digraph`, delegates to `:digraph` to work with it, and functions for persisting it.
  """

  @format 0

  @opts []

  @filename "#{__MODULE__}.etf"

  @mutating_functions [:new, :add_edge, :add_vertex, :del_edge, :del_edges, :del_path, :del_vertex, :del_vertices]

  @typedoc """
  Struct to hold the state.

  ## Fields

  - `:format` – format version. Current version is #{@format}.
  - `:version` – version of the data to track changes properly.
  - `:digraph` – see `t::digraph.graph/0`.
  """
  @type t() :: %__MODULE__{
          format: non_neg_integer(),
          version: non_neg_integer(),
          digraph: :digraph.graph() | nil,
          subgraphs: %{{fun(), fun()} => :digraph.graph()}
        }

  @typedoc """
  Predicate to filter vertices on.

  Can have arity 1 or 2:
    - `fn label -> boolean end`
    - `fn vertex, label -> boolean end`
  """
  @type vertex_predicate() ::
          (:digraph.label() -> boolean())
          | (:digraph.vertex(), :digraph.label() -> boolean())

  @typedoc """
  Predicate to filter edges on.

  Can have arity 1, 2, 3 or 4:
    - `fn label -> boolean end`
    - `fn from, to -> boolean end`
    - `fn from, to, label -> boolean end`
    - `fn edge, from, to, label -> boolean end`
  """
  @type edge_predicate() ::
          (:digraph.label() -> boolean())
          | (:digraph.vertex(), :digraph.vertex() -> boolean())
          | (:digraph.vertex(), :digraph.vertex(), :digraph.label() -> boolean())
          | (:digraph.edge(), :digraph.vertex(), :digraph.vertex(), :digraph.label() -> boolean())

  defstruct format: @format,
            version: 0,
            digraph: nil,
            subgraphs: %{}

  @doc """
  Ensures unlinked instance is started.

  Intended to be used during compilation, since the GenServer can't be supervised as part of the application tree.
  """
  @spec ensure!() :: :ok
  def ensure!() do
    with {:ok, _pid} <- GenServer.start(__MODULE__, [], name: __MODULE__) do
      :ok
    else
      {:error, {:already_started, _pid}} ->
        :ok
    end
  end

  @dialyzer {:no_unknown, dump: 0}

  @doc """
  Dumps the graph at given path in Erlang Term Format.
  """
  @spec dump(Path.t()) :: :ok
  def dump(path \\ Mix.Project.compile_path()) do
    ensure!()
    GenServer.call(__MODULE__, {:dump, path})
  end

  @dialyzer {:no_unknown, load: 0}

  @doc """
  Loads the graph at given path in Erlang Term Format.
  """
  @spec load(Path.t()) :: :ok
  def load(path \\ Mix.Project.compile_path()) do
    ensure!()
    GenServer.call(__MODULE__, {:load, path})
  end

  @doc """
  Starts the graph instance.

  Intended to be used at run time to start the GenServer under supervision.
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    with {:ok, pid} <- GenServer.start(__MODULE__, [opts], name: __MODULE__) do
      {:ok, pid}
    else
      {:error, {:already_started, pid}} ->
        Process.link(pid)

        {:ok, pid}

      error ->
        error
    end
  end

  @doc """
  Like `:digraph.get_path/3`, but only traverses vertices/edges filtered by predicates.

  Returns `false` if no path exists, or a list of vertices `[v1, ..., vn]` otherwise.
  """
  @spec get_path_by(:digraph.vertex(), :digraph.vertex(), edge_predicate(), vertex_predicate()) :: false | [:digraph.edge()]
  def get_path_by(source, target, edge_predicate \\ fn _ -> true end, vertex_predicate \\ fn _ -> true end) do
    ensure!()
    GenServer.call(__MODULE__, {:get_path_by, source, target, edge_predicate, vertex_predicate})
    ensure!()
    GenServer.call(__MODULE__, {:get_path_by, source, target, predicate})
  end

  # GenServer

  @impl GenServer
  def init(_opts) do
    System.at_exit(fn _code -> dump() end)

    Process.flag(:trap_exit, true)
    do_load(%__MODULE__{})
  end

  @impl GenServer
  def handle_call({:dump, path}, _from, state) do
    state
    |> do_dump(path)
    |> case do
      {:ok, state} ->
        {:reply, :ok, state}

      error ->
        {:reply, error, state}
    end
  end

  def handle_call({:load, path}, _from, state) do
    with {:ok, state} <- do_dump(state, path) do
      {:reply, :ok, state}
    else
      error ->
        {:reply, error, state}
    end
  end

  def handle_call(:expose, _from, state), do: {:reply, state, state}

  def handle_call({:digraph, fun, args}, _from, state) do
    reply = apply(:digraph, fun, [state.digraph | args])

    if fun in @mutating_functions,
      do: struct(state, subgraphs: %{}),
      else: state

    {:reply, reply, state}
  end

  def handle_call({:digraph_utils, :subgraph, args}, _from, state) do
    reply = apply(:digraph_utils, :subgraph, [state.digraph | args])

    {:reply, reply, state}
  end

  def handle_call({:digraph_utils, fun, args}, _from, state) do
    reply = apply(:digraph_utils, fun, args ++ [state.digraph])

    {:reply, reply, state}
  end

  def handle_call({:get_path_by, source, target, edge_predicate, vertex_predicate}, _from, state) do
    {subgraph, state} = subgraph_by(state, edge_predicate, vertex_predicate)

    reply = :digraph.get_path(subgraph, source, target)

    {:reply, reply, state}
  end

  @impl GenServer
  def handle_info({:EXIT, _from, _reason}, state) do
    {:ok, state} = do_dump(state)
    {:noreply, state}
  end

  # Private

  defp do_dump(state, path \\ Mix.Project.compile_path()) do
    with path <- Path.join(path, @filename),
         {:ok, existing} <- do_load(state),
         {:newer, true} <- {:newer, state.version >= existing.version},
         data <-
           state
           |> Map.from_struct()
           |> Map.put(:vertices, state.digraph |> :digraph.vertices() |> Enum.map(fn v -> :digraph.vertex(state.digraph, v) end))
           |> Map.put(:edges, state.digraph |> :digraph.edges() |> Enum.map(fn e -> :digraph.edge(state.digraph, e) end))
           |> Map.delete(:digraph)
           |> :erlang.term_to_binary(),
         :ok <- path |> Path.dirname() |> File.mkdir_p(),
         :ok <- File.write(path, data),
         state <- struct(state, version: state.version + 1) do
      {:ok, state}
    else
      {:newer, false} ->
        {:error, :version_mismatch}

      error ->
        error
    end
  end

  # sobelow_skip ["Misc.BinToTerm"]
  defp do_load(_state, path \\ Mix.Project.compile_path()) do
    with path <- Path.join(path, @filename),
         :ok <- path |> Path.dirname() |> File.mkdir_p(),
         {:ok, etf} <- File.read(path),
         # Trusted binary, sobelow false positive
         %{format: @format} = loaded <- :erlang.binary_to_term(etf),
         digraph <- :digraph.new(),
         loaded <-
           loaded
           |> Map.update!(:format, fn format -> @format = format end)
           |> Map.update!(:vertices, fn v -> Enum.each(v, fn {v, label} -> :digraph.add_vertex(digraph, v, label) end) end)
           |> Map.update!(:edges, fn e -> Enum.each(e, fn {e, from, to, label} -> :digraph.add_edge(digraph, e, from, to, label) end) end)
           |> Map.put(:digraph, digraph),
         state <- struct(__MODULE__, loaded) do
      {:ok, state}
    else
      {:error, :enoent} ->
        do_new()

      %{format: _} ->
        do_new()

      error ->
        error
    end
  end

  defp do_new do
    digraph = :digraph.new(@opts)

    {:ok, %__MODULE__{digraph: digraph}}
  end

  defp subgraph_by(state, edge_predicate, vertex_predicate) do
    subgraph = :digraph.new()
    state = put_in(state.subgraphs[{edge_predicate, vertex_predicate}], subgraph)

    state.digraph
    |> :digraph.vertices()
    |> Enum.map(&:digraph.vertex(state.digraph, &1))
    |> Enum.each(fn {vertex, label} ->
      if filter_vertex?(vertex_predicate, vertex, label),
        do: :digraph.add_vertex(subgraph, vertex, label)
    end)

    state.digraph
    |> :digraph.edges()
    |> Enum.map(&:digraph.edge(state.digraph, &1))
    |> Enum.each(fn {edge, from, to, label} ->
      if filter_edge?(edge_predicate, edge, from, to, label) && :digraph.vertex(state.digraph, from) && :digraph.vertex(state.digraph, to),
        do: :digraph.add_edge(subgraph, edge, from, to, label)
    end)

    {subgraph, state}
  end

  defp filter_vertex?(predicate, _vertex, label) when is_function(predicate, 1), do: predicate.(label)
  defp filter_vertex?(predicate, vertex, label) when is_function(predicate, 2), do: predicate.(vertex, label)

  defp filter_edge?(predicate, _e, _from, _to, label) when is_function(predicate, 1), do: predicate.(label)
  defp filter_edge?(predicate, _e, from, to, _label) when is_function(predicate, 2), do: predicate.(from, to)
  defp filter_edge?(predicate, _e, from, to, label) when is_function(predicate, 3), do: predicate.(from, to, label)
  defp filter_edge?(predicate, e, from, to, label) when is_function(predicate, 4), do: predicate.(e, from, to, label)
end
