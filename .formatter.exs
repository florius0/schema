# Used by "mix format"
locals_without_parens = [
  schema: :*,
  doc: :*,
  shortdoc: :*,
  example: :*,
  item: :*,
  rest: :*,
  field: :*,
  key: :*,
  value: :*,
  validate: :*,
  relate: :*,
  relationship: :*
]

[
  export: [
    locals_without_parens: locals_without_parens
  ],
  locals_without_parens:
    [
      inspect: :*,
      capture_io: :*
    ] ++ locals_without_parens,
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  line_length: 200
]
