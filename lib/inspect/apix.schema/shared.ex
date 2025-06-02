defmodule Inspect.Apix.Schema.Shared do
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
end
