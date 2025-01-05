defmodule A do
  use Apix.Schema

  @moduledoc false

  schema tuple1: Tuple.t(), params: [:p1, p2: 1] do
    # item Any.t()

    # item Any.t() do
    # shortdoc "First element"
    # doc "First element of the tuple"
    # example 1
    # end

    # item Any.t(), flag: :a

    # item Any.t(), flag: :b do
    #   shortdoc "Second element"
    #   doc "Second element of the tuple"
    #   example 2
    # end

    # rest Any.t()

    # field :a, local()

    # field do
    #   key Any.t() do
    #   end

    #   value Any.t() do
    #   end
    # end
  end
end
