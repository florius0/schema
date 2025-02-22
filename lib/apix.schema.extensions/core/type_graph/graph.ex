defmodule Apix.Schema.Extensions.Core.TypeGraph.Graph do
  use GenServer

  require Apix.Schema.Extensions.Core.TypeGraph.Definition
  Apix.Schema.Extensions.Core.TypeGraph.Definition.define()

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

  @impl GenServer
  def handle_info({:EXIT, _from, _reason}, state) do
    {:ok, state} = do_dump(state)
    {:noreply, state}
  end

  # Private

  defp do_dump(state, path \\ "") do
    with path <- Path.join(path, @filename),
         {:ok, existing} <- do_load(state),
         {:newer, true} <- {:newer, state.version >= existing.version},
         data <-
           state
           |> Map.from_struct()
           |> Map.put(:sofs, :sofs.digraph_to_family(state.digraph))
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

  defp do_load(_state, path \\ "") do
    with path <- Path.join(path, @filename),
         :ok <- path |> Path.dirname() |> File.mkdir_p(),
         {:ok, etf} <- File.read(path),
         %{format: @format} = loaded <- :erlang.binary_to_term(etf),
         loaded <-
           loaded
           |> Map.update!(:format, fn format -> @format = format end)
           |> Map.put(:digraph, :sofs.family_to_digraph(loaded.sofs))
           |> Map.delete(:sofs),
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
end
