defmodule Apix.Schema.Extensions.Core.TypeGraph.Definition do
  alias Apix.Schema.Extensions.Core.TypeGraph.Graph

  @moduledoc """
  Utilities to define delegates to `:digraph` and `:digraph_utils`.
  """

  @doc """
  Defines "delegates" as in `:digraph` and `:digraph_utils` as `GenServer.call/2`.

  Drops the graph argument, since the graph is held by `#{inspect Graph}`
  """
  @spec define() :: Macro.t()
  defmacro define do
    do_define(:digraph, __CALLER__) ++ do_define(:digraph_utils, __CALLER__)
  end

  defp do_define(mod, caller) do
    :exports
    |> mod.module_info()
    |> Keyword.drop([:module_info, :new])
    |> Enum.map(fn {fun, n_args} ->
      vars = Enum.map(1..(n_args - 1)//1, &Macro.var(:"x#{&1}", caller.module))

      quote generated: true do
        @doc """
        Delegates to `#{unquote(mod)}.#{unquote(fun)}/#{unquote(n_args)}`
        """
        def unquote(fun)(unquote_splicing(vars)) do
          ensure!()
          GenServer.call(__MODULE__, {unquote(mod), unquote(fun), [unquote_splicing(vars)]})
        end
      end
    end)
  end
end
