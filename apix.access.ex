defmodule Apix.Access do
  defmacro __using__(_opts) do
    quote do
      @behaviour Access

      @impl Access
      defdelegate fetch(schema, key), to: unquote(__MODULE__)

      @impl Access
      defdelegate get_and_update(schema, key, fun), to: unquote(__MODULE__)

      @impl Access
      defdelegate pop(schema, key), to: unquote(__MODULE__)
    end
  end

  def fetch(schema, key) do
    case schema do
      %{^key => value} -> {:ok, value}
      _ -> raise KeyError, key: key, term: schema
    end
  end

  def get_and_update(schema, key, fun) do
    case schema do
      %{^key => value} ->
        case fun.(value) do
          {value, update} ->
            {value, %{schema | key => update}}

          :pop ->
            {value, %{schema | key => nil}}
        end

      _ ->
        raise KeyError, key: key, term: schema
    end
  end

  def pop(schema, key) do
    case schema do
      %{^key => value} ->
        {value, %{schema | key => nil}}

      _ ->
        raise KeyError, key: key, term: schema
    end
  end
end
