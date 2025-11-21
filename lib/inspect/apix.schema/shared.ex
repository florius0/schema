defmodule Inspect.Apix.Schema.Shared do
  import Inspect.Algebra

  @moduledoc false

  @doc false
  @spec enable(Inspect.Algebra.t(), any(), Inspect.Opts.t()) :: Inspect.Algebra.t()
  def enable(doc, data, opts) do
    enabled? = Keyword.get(opts.custom_options, :apix_schema?, true)

    if enabled?,
      do: doc,
      else: Inspect.Any.inspect(data, opts)
  end

  @doc false
  @spec mark(Inspect.Algebra.t(), atom(), Inspect.Opts.t()) :: Inspect.Algebra.t()
  def mark(doc, name, opts) do
    mark? = Keyword.get(opts.custom_options, :apix_schema_mark?, true)

    if mark? do
      color_doc("##{Macro.inspect_atom(:literal, name)}<", :rest, opts)
      |> concat(doc)
      |> concat(color_doc(">", :rest, opts))
    else
      doc
    end
  end
end
