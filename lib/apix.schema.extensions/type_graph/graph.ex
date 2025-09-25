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
          digraph: :digraph.graph() | nil
        }

  defstruct format: @format,
            version: 0,
            digraph: nil

  @doc """
  Ensures unlinked instance is started.

  Intended to be used during compilation, since the GenServer can't be supervised as part of the application tree.
  """
  @spec ensure!() :: :ok
  def ensure!() do
    __MODULE__
    |> GenServer.start([], name: __MODULE__)
    |> case do
      {:ok, _pid} ->
        :ok

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
    __MODULE__
    |> GenServer.start([opts], name: __MODULE__)
    |> case do
      {:error, {:already_started, pid}} ->
        Process.link(pid)

        {:ok, pid}

      x ->
        x
    end
  end

  @doc """
  Like `:digraph.get_path/3`, but only traverses edges for which `predicate` returns `true`.

  `predicate` can have arity 1, 3, or 4:
    - `fn label -> boolean end`
    - `fn from, to` -> boolean end`
    - `fn from, to, label -> boolean end`
    - `fn edge, from, to, label -> boolean end`

  Returns `false` if no path exists, or a list of vertices `[v1, ..., vn]` otherwise.
  """
  @spec get_path_by(
          :digraph.vertex(),
          :digraph.vertex(),
          (:digraph.label() -> boolean())
          | (:digraph.vertex(), :digraph.vertex() -> boolean())
          | (:digraph.vertex(), :digraph.vertex(), :digraph.label() -> boolean())
          | (:digraph.edge(), :digraph.vertex(), :digraph.vertex(), :digraph.label() -> boolean())
        ) :: false | [:digraph.edge()]
  def get_path_by(source, target, predicate) when is_function(predicate, 1) or is_function(predicate, 2) or is_function(predicate, 3) or is_function(predicate, 4) do
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
    state
    |> do_load(path)
    |> case do
      {:ok, state} ->
        {:reply, :ok, state}

      error ->
        {:reply, error, state}
    end
  end

  def handle_call(:expose, _from, state), do: {:reply, state, state}

  def handle_call({:digraph, fun, args}, _from, state) do
    reply = apply(:digraph, fun, [state.digraph | args])

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

  def handle_call({:get_path_by, source, target, predicate}, _from, state) do
    path = do_get_path_by(state.digraph, source, target, predicate)
    {:reply, path, state}
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

  defp do_load(_state, path \\ Mix.Project.compile_path()) do
    with path <- Path.join(path, @filename),
         :ok <- path |> Path.dirname() |> File.mkdir_p(),
         {:ok, etf} <- File.read(path),
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

  defp do_get_path_by(_g, v, v, _predicate), do: [v]

  defp do_get_path_by(g, source, target, predicate) do
    # Ensure both vertices exist (match :digraph.get_path/3 behavior)
    with {^source, _} <- :digraph.vertex(g, source) || :error,
         {^target, _} <- :digraph.vertex(g, target) || :error do
      bfs_with_edge_filter(g, source, target, predicate)
    else
      _ -> false
    end
  end

  defp bfs_with_edge_filter(g, source, target, predicate) do
    # Standard BFS over vertices, but we only traverse out-edges passing `predicate`
    queue = :queue.from_list([source])
    visited = MapSet.new([source])
    prev = %{source => nil}

    do_bfs(g, target, predicate, queue, visited, prev)
  end

  defp do_bfs(g, target, predicate, queue, visited, prev) do
    case :queue.out(queue) do
      {:empty, _} ->
        false

      {{:value, v}, queue1} ->
        if v == target do
          reconstruct_path(prev, v)
        else
          {queue2, visited2, prev2} = expand_neighbours(g, v, predicate, queue1, visited, prev)
          do_bfs(g, target, predicate, queue2, visited2, prev2)
        end
    end
  end

  defp expand_neighbours(g, v, predicate, queue, visited, prev) do
    # Filter out-edges by predicate, then enqueue unseen `to` vertices
    Enum.reduce(:digraph.out_edges(g, v), {queue, visited, prev}, fn e, {q, vis, pr} ->
      {^e, from, to, label} = :digraph.edge(g, e)

      if edge_passes?(predicate, e, from, to, label) and not MapSet.member?(vis, to) do
        {:queue.in(to, q), MapSet.put(vis, to), Map.put(pr, to, from)}
      else
        {q, vis, pr}
      end
    end)
  end

  defp edge_passes?(predicate, _e, _from, _to, label) when is_function(predicate, 1), do: predicate.(label)
  defp edge_passes?(predicate, _e, from, to, _label) when is_function(predicate, 2), do: predicate.(from, to)
  defp edge_passes?(predicate, _e, from, to, label) when is_function(predicate, 3), do: predicate.(from, to, label)
  defp edge_passes?(predicate, e, from, to, label) when is_function(predicate, 4), do: predicate.(e, from, to, label)

  defp reconstruct_path(prev, v), do: do_reconstruct(prev, v, []) |> Enum.reverse()

  defp do_reconstruct(prev, v, acc) do
    case Map.fetch(prev, v) do
      {:ok, nil} -> [v | acc]
      {:ok, p} -> do_reconstruct(prev, p, [v | acc])
      :error -> false
    end
  end
end
