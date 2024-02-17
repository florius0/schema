defmodule Apix.Schema.Ast.Meta do
  @type t() :: %__MODULE__{
          file: String.t() | nil,
          line: integer() | nil,
          module: atom() | nil
        }

  defstruct file: nil,
            line: nil,
            module: nil

  def new(env, node) do
    meta =
      case node do
        {_, meta, _} -> meta
        _ -> []
      end

    %__MODULE__{
      file: env.file,
      module: env.module,
      line: Keyword.get(meta, :line, env.line)
    }
  end
end
