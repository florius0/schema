defmodule A do
  use Apix.Schema

  schema tuple1: Tuple.t(), params: [:p1, p2: 1] do
    # shortdoc "Tuple schema"

    # doc """
    # Consists of two elements
    # """

    # example {1, 2}
    # example {2, 3}

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

  # schema(name: :tuple1, type: Tuple.t(), params: [:p1, p2: 1], do: doc("123"))
end
