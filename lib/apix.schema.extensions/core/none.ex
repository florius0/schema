defmodule Apix.Schema.Extensions.Core.None do
  use Apix.Schema

  @moduledoc false

  schema t: _ do
    validate false

    relate it, to do
      [
        {:subtype, it, to},
        {:supertype, to, it},
        {:subtype, it, it},
        {:supertype, it, it}
      ]
    end

    relationship it, peer, existing do
      if peer.flags[:kind] == :meta do
        existing
      else
        [
          {:subtype, it, peer},
          {:subtype, it, it},
          {:supertype, peer, it},
          {:supertype, it, it}
          | existing
        ]
      end
    end
  end
end
