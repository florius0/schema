# Used by "mix format"
locals_without_parens = [
  schema: :*,
  doc: :*,
  shortdoc: :*,
  example: :*,
  item: :*,
  rest: :*,
  field: :*,
  pattern_field: :*,
  key_value: :*,
  validate: :*
]

[
  export: [
    locals_without_parens: locals_without_parens
  ],
  locals_without_parens:
    [
      inspect: 1,
      inspect: 2
    ] ++ locals_without_parens,
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  line_length: 200
]
