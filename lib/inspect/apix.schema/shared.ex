defmodule Inspect.Apix.Schema.Shared do
  import Inspect.Algebra

  @moduledoc false

  @spec enable(Inspect.Algebra.t(), any(), Inspect.Opts.t()) :: Inspect.Algebra.t()
  def enable(doc, data, opts) do
    enabled? = Keyword.get(opts.custom_options, :apix_schema?, true)

    if enabled? do
      doc
    else
      Inspect.Any.inspect(data, opts)
    end
  end

  @spec mark(Inspect.Algebra.t(), atom(), Inspect.Opts.t()) :: Inspect.Algebra.t()
  # def mark(doc, _name, _opts), do: doc

  def mark(doc, name, opts) do
    color_doc("##{Macro.inspect_atom(:literal, name)}<", :rest, opts)
    |> concat(doc)
    |> concat(color_doc(">", :rest, opts))
  end
end
