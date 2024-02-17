schema struct1: :struct, params: [p1: 0, p2: 1] do
  param p1: 0, p2: 0

  shortdoc "A schema for a struct."

  doc """
  This is a schema for a struct.

  Smth about it.
  """

  field :a, p1(), required: true
  field :b, p1() or p2(:param), required: true
  field :c, id(), # optional: true, missing: {:set | :skip, %Apix.Schema.Missing{}}

  validate it.a != it.b
  validate struct1.a
  validate is_string(a) and b in p2

  example %{a: 1}
  default %{a: 1}
end

schema map1: :map, params: [p1/0, p2/1] do
  field :a, p1(), required: true
  field :b, p1() or p2(:param), required: true
  field :c, id(), # optional: true, missing: {:set | :skip, %Apix.Schema.Missing{}}
  pattern_field ~r/\w+\d{1,5}/, any(), default: true, required: true
  additional_fields :string, default: true, required: true do

  end# any()

  validate a != b
  validate if is_string(a), do: b is p2

  example %{a: 1}
  default %{a: 1}
end

schema list1: :list, params: [p1/0, p2/0, p3/0] do
  item p1()
  item p2()
  rest p3()
end

schema list2: :list, params: p1/0 do
  rest p1()
end

schema tuple1: :tuple do
  item :ok or :error
  item MyApp.Schemas.Result.t(0), default: :ok, required: true do

  end
end

schema id: :integer do
  validate id >= 1
end

schema :name
schema name: String.t()
schema :name, params: [p1: 0, p2: 1]
schema name: String.t(), params: [p1: 0, p2: 1]

schema :name, String.t(), parasm: ... .

schema do
  field :a #, Any.t()
  field :a, Any.t()
  field :a, Any.t(), required: true, default: 1
  field :a, Map.t(), required: true, default: 1 do
    field :a
  end
  # field :a, :name, default: 1, required: true do end
  # field :a, String.t(), default: 1, required: true do end
  # field :a, default: 1, required: true do end
  # field :a, name: String.t(), default: 1, required: true do end
  # field :a, Map.t(), default: 1, required: true do end
end

schema name: String.t()
