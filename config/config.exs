import Config

config :apix_schema, Apix.Schema.Extension, [
  Apix.Schema.Extensions.Core,
  Apix.Schema.Extensions.Elixir,
  Apix.Schema.Extensions.Core.LocalReference
]
